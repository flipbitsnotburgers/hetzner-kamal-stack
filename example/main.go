package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	_ "github.com/lib/pq"
	"github.com/redis/go-redis/v9"
)

var (
	redisClient *redis.Client
	db          *sql.DB
)

func main() {
	// Initialize Redis
	if redisURL := os.Getenv("REDIS_URL"); redisURL != "" {
		opt, err := redis.ParseURL(redisURL)
		if err != nil {
			log.Printf("Warning: Failed to parse REDIS_URL: %v", err)
		} else {
			redisClient = redis.NewClient(opt)
		}
	}

	// Initialize Postgres
	if dbURL := os.Getenv("DATABASE_URL"); dbURL != "" {
		var err error
		db, err = sql.Open("postgres", dbURL)
		if err != nil {
			log.Printf("Warning: Failed to connect to Postgres: %v", err)
		}
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprint(w, "Hello Kamal!")
	})

	http.HandleFunc("/up", handleHealth)

	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	log.Printf("Server starting on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

func handleHealth(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	status := map[string]string{
		"status": "ok",
		"redis":  "ok",
		"postgres": "ok",
	}
	httpStatus := http.StatusOK

	// Check Redis
	if redisClient != nil {
		if err := redisClient.Ping(ctx).Err(); err != nil {
			status["redis"] = fmt.Sprintf("error: %v", err)
			status["status"] = "degraded"
			httpStatus = http.StatusServiceUnavailable
		}
	} else {
		status["redis"] = "not configured"
	}

	// Check Postgres
	if db != nil {
		if err := db.PingContext(ctx); err != nil {
			status["postgres"] = fmt.Sprintf("error: %v", err)
			status["status"] = "degraded"
			httpStatus = http.StatusServiceUnavailable
		}
	} else {
		status["postgres"] = "not configured"
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(httpStatus)
	json.NewEncoder(w).Encode(status)
}

%{ for server in web_servers ~}
Host ${server.name}
    HostName ${server.ip}
    User ${ssh_user}
    IdentityFile ~/.ssh/hetzner

%{ endfor ~}

%{ for server in accessories_servers ~}
Host ${server.name}
    HostName ${server.ip}
    User ${ssh_user}
    IdentityFile ~/.ssh/hetzner

%{ endfor ~}
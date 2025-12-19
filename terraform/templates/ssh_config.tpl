%{ for server in web_servers ~}
Host ${server.name}
    HostName ${server.ip}
    User ${ssh_user}
    IdentityFile ${ssh_key_path}

%{ endfor ~}

%{ for server in accessories_servers ~}
Host ${server.name}
    HostName ${server.ip}
    User ${ssh_user}
    IdentityFile ${ssh_key_path}

%{ endfor ~}
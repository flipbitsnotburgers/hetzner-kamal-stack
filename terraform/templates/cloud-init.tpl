#cloud-config
hostname: ${hostname}
fqdn: ${hostname}
manage_etc_hosts: false

write_files:
  - path: /etc/hosts
    permissions: '0644'
    content: |
      127.0.0.1 localhost
      127.0.1.1 ${hostname}

      # Private network hosts
%{ for host in hosts ~}
      ${host.ip} ${host.name}
%{ endfor }

%{ if length(volumes) > 0 ~}
mounts:
%{ for volume_key, volume in volumes ~}
  - [ "${volume.device}", "${volume.path}", "ext4", "defaults,nofail,discard", "0", "0" ]
%{ endfor ~}
%{ endif ~}

runcmd:
%{ for volume_key, volume in volumes ~}
  - mkdir -p ${volume.path}
%{ endfor ~}
  - systemctl restart systemd-hostnamed

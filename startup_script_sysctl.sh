%{ for name, value in conf ~}
sysctl -w ${name}="${value}"
%{ endfor ~}

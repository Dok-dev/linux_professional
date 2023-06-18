# Домашнее задание к занятию 33 - "Мосты, туннели и VPN"

## Описание домашнего задания

1. Между двумя виртуалками поднять vpn в режимах    
 - tun;
 - tap;
 - прочуствовать разницу.
2. Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на виртуалку.
3.  (*). Самостоятельно изучить, поднять ocserv и подключиться с хоста к виртуалке

---

## Выполнение     

Подготовлен [Vagrantfile](./Vagrantfile), [роль](./roles/openvpn/) и ansible playbooks разворачивающие данный стенд.

Использование:    
```bash
vagrant up
```

На поднятой инфраструктуре будут автоматически запущены 3 плейбука настаивающие VPN-тонели в tun, tap и tun+RAS режимах, с последущим выводом результатов тестирования каналов.

---

Информационные материлы по заданию:    

[Презентация](docs/network_bridge_vpn.pdf)    
[Презентация2](docs/network_bridge_vpn2.pdf)    
[Практика](docs/practic.pdf)    

Network bridge - https://wiki.archlinux.org/title/network_bridge    
Ethernet bridge administration - https://manpages.ubuntu.com/manpages/bionic/man8/brctl.8.html    

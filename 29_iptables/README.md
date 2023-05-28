# Домашнее задание к занятию 29 - "Фильтрация трафика - iptables "

## Описание домашнего задания

1. Рализовать knocking port (centralRouter может попасть на ssh inetrRouter через knock скрипт).
2. Добавить inetRouter2, который виден(маршрутизируется (host-only тип сети для виртуалки)) с хоста или форвардится порт через локалхост.
3. Запустить nginx на centralServer.
4. Пробросить 80й порт на inetRouter2 8080.
5. Дефолт в инет оставить через inetRouter.
6. Реализовать проход на 80й порт без маскарадинга*

---

## Выполнение     

Подготовлен [Vagrantfile](./Vagrantfile) c [ansible playbook](ansible/play.yml) разворачивающий данный стенд.

Использование:    
```bash
vagrant up
```


---

Информационные материлы по заданию:    

[Презентация](docs/iptables_firewalld.pdf)    

Борьба с SYN-флудом при помощи iptables и SYNPROXY - https://www.opennet.ru/tips/2928_linux_iptables_synflood_synproxy_ddos.shtml    
Iptables Tutorial 1.2.2 - https://www.frozentux.net/iptables-tutorial/iptables-tutorial.html    
Port knocking - https://wiki.archlinux.org/title/Port_knocking    
IP set features - https://ipset.netfilter.org/features.html    
Iptables Викиучебник - https://ru.wikibooks.org/wiki/Iptables    
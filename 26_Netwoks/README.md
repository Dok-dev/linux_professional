# Домашнее задание к занятию 23-34 "Сбор и анализ логов"


## Описание домашнего задания

1. Скачать и развернуть [Vagrant-стенд](https://github.com/erlong15/otus-linux/tree/network)    
2. Построить следующую сетевую архитектуру:    
Сеть office1
- 192.168.2.0/26    - dev
- 192.168.2.64/26   - test servers
- 192.168.2.128/26  - managers
- 192.168.2.192/26  - office hardware

Сеть office2
- 192.168.1.0/25    - dev
- 192.168.1.128/26  - test servers
- 192.168.1.192/26  - office hardware


Сеть central
- 192.168.0.0/28   - directors
- 192.168.0.32/28  - office hardware
- 192.168.0.64/26  - wifi

```
Office1 ---\
      -----> Central --IRouter --> internet
Office2----/
```
Итого должны получится следующие сервера
- inetRouter
- centralRouter
- office1Router
- office2Router
- centralServer
- office1Server
- office2Server

### Теоретическая часть
- Найти свободные подсети
- Посчитать сколько узлов в каждой подсети, включая свободные
- Указать broadcast адрес для каждой подсети
- проверить нет ли ошибок при разбиении

### Практическая часть
- Соединить офисы в сеть согласно схеме и настроить роутинг
- Все сервера и роутеры должны ходить в инет черз inetRouter
- Все сервера должны видеть друг друга
- у всех новых серверов отключить дефолт на нат (eth0), который вагрант поднимает для связи
- при нехватке сетевых интервейсов добавить по несколько адресов на интерфейс 


---

## Выполнение     

Подготовлен [Vagrantfile](./Vagrantfile) c [ansible playbook](ansible/play.yml) разворачивающий данный стенд.

Использование:    
```bash
vagrant up
```

---

Информационные материлы по заданию:    

[Презентация](docs/Otus_Networks.pdf)    
[Методичка по созданию стенда](https://docs.google.com/document/d/1XtCmYJYPKwoMDjwiTskALvYLZaE4I49g/edit)    

Статья «Маршрутизация в linux» - https://losst.ru/marshrutizatsiya-v-linux    
Статья «NAT для новичков» - https://habr.com/ru/post/583172/    
Статья «Templating(Jinja2)» - https://docs.ansible.com/ansible/2.9/user_guide/playbooks_templating.html    
Статья «Ansible Provisioner» - https://www.vagrantup.com/docs/provisioning/ansible 

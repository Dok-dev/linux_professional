# Домашнее задание к занятию 34 - "DNS - настройка и обслуживание"

## Описание домашнего задания
1.    
* Взять стенд https://github.com/erlong15/vagrant-bind
* Добавить еще один сервер client2
* Завести в зоне dns.lab имена:
* - web1 - смотрит на клиент1;
* - web2 смотрит на клиент2.
* Завести еще одну зону newdns.lab
    
2.    
* Завести в ней запись www - смотрит на обоих клиентов
* Настроить split-dns
* Клиент1 - видит обе зоны, но в зоне dns.lab только web1
* Клиент2 - видит только dns.lab

Дополнительное задание:    
- настроить все без выключения selinux*


---

## Выполнение     

Подготовлен [Vagrantfile](./Vagrantfile) c [ansible playbook](./provisioning/playbook.yml) разворачивающий данный стенд c lookup тестами.

Использование:    
```bash
vagrant up
```

---

Информационные материлы по заданию:    

[Презентация](docs/DNS.pdf)    

DNSSEC - https://www.cloudflare.com/dns/dnssec/how-dnssec-works/    
bundy - http://bundy-dns.de/documentation.html    
Split DNS - http://it2web.ru/index.php/dns/77-split-dns-nauchim-bind-rabotat-na-dva-tri-chetyre-i-bolee-frontov    
views in BIND 9 - https://kb.isc.org/docs/aa-00851    
DNS сервер BIND (теория) - https://habr.com/ru/articles/137587/    
Настройка DNS-сервера BIND - http://xgu.ru/wiki/Настройка_DNS-сервера_BIND    
Пряморукий DNS: делаем правильно - https://habr.com/ru/companies/oleg-bunin/articles/350550/    
DNSSec: Что такое и зачем - https://habr.com/ru/articles/120620/    
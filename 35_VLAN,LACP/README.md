# Домашнее задание к занятию 35 - "Сетевые пакеты. VLAN'ы, LACP"

## Описание домашнего задания

в Office1 в тестовой подсети появляется сервера с доп интерфесами и адресами    
в internal сети testLAN:    
- testClient1 - 10.10.10.254     
- testClient2 - 10.10.10.254     
- testServer1- 10.10.10.1    
- testServer2- 10.10.10.1    

Равести вланами:    
testClient1 <-> testServer1    
testClient2 <-> testServer2    

Между centralRouter и inetRouter "пробросить" 2 линка (общая inernal сеть) и объединить их в бонд, проверить работу c отключением интерфейсов.

Схема стенда:    
![network_scheme](./docs/scheme.png)

---

## Выполнение     

Подготовлен [Vagrantfile](./Vagrantfile) c [ansible playbook](./ansible/provision.yml) разворачивающий данный стенд c ping-тестами.

Использование:    
```bash
vagrant up
```

---

Информационные материлы по заданию:    

[Презентация](docs/VLAN.pdf)    

VLAN в Linux - http://xgu.ru/wiki/VLAN_в_Linux    
Linux Bonding - http://xgu.ru/wiki/Linux_Bonding    
[Объединение сетевых интерфейсов в Linux](https://www.adminia.ru/linux-bonding-obiedinenie-setevyih-interfeysov-v-linux/)    
[Understanding Network Teaming](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/networking_guide/ch-configure_network_teaming)    

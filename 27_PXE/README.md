# Домашнее задание к занятию  "PXE, DHCP"

## Описание домашнего задания
### Настройка PXE сервера для автоматической установки

1. Следуя шагам из [документа](https://docs.centos.org/en-US/8-docs/advanced-install/assembly_preparing-for-a-network-install) установить и настроить загрузку по сети для дистрибутива CentOS8. В качестве шаблона воспользуйтесь [репозиторием](https://github.com/nixuser/virtlab/tree/main/centos_pxe).
2. Поменять установку из репозитория NFS на установку из репозитория HTTP.     
3. Настроить автоматическую установку для созданного kickstart файла (*) Файл загружается по HTTP.    
Задание со звездочкой *:    
4. Автоматизировать процесс установки Cobbler cледуя шагам из документа https://cobbler.github.io/quickstart/.    

Настройка Cobbler (*)    
Зачем делать:    
Настройка сервера для автоматизации управления процессом сетевой установки. Поддержка установки различных дистрибутивов, разных версий. Автоматизация установки и шаблоны.    
Задание:    
Следуя шагам из документа установить и настроить Cobbler    
https://cobbler.readthedocs.io/en/latest/quickstart-guide.html    
автоматизировать процесс установки    
Можно основываться на пример. Рекомендую обновить его до 8.x    
https://github.com/michalkacprzyk/cobbler-kickstart-playground 

---

## Выполнение     

Подготовлен [Vagrantfile](./Vagrantfile) c [ansible playbook](ansible/provision.yml) разворачивающий данный стенд.

Использование:    
```bash
vagrant up
```


---

Информационные материлы по заданию:    

[Презентация](docs/DHCP_PXE.pdf)    
[Методичка](docs/manual_PXE_DHCP.pdf)    

Пример Vagrant+PXE - https://github.com/eoli3n/vagrant-pxe    
Cobber documentation - https://cobbler.readthedocs.io/en/latest/quickstart-guide.html  

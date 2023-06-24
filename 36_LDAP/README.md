# Домашнее задание к занятию 36 - "LDAP. Централизованная авторизация и аутентификация"

## Описание домашнего задания

1) Установить FreeIPA
2) Написать Ansible-playbook для конфигурации клиента

Дополнительное задание
3)* Настроить аутентификацию по SSH-ключам
4)** Firewall должен быть включен на сервере и на клиенте


---

## Выполнение     

Подготовлен [Vagrantfile](./Vagrantfile), роли [freeipa_server](./ansible/roles/freeipa_server/) и [freeipa_client](./ansible/roles/freeipa_client/), а так же [ansible playbook](./ansible/provision.yml) разворачивающий данный стенд.

Использование:    
```bash
vagrant up
```

---

Информационные материлы по заданию:    

[Презентация](docs/LDAP.pdf)    

LDAP по-русски - https://pro-ldap.ru/    
[Red Hat Identity Management](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/linux_domain_identity_authentication_and_policy_guide/introduction)    
[IPA Client Design Overview](https://www.freeipa.org/page/FreeIPAv2:IPA_Client_Design_Overview)    

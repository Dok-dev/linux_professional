# Домашнее задание к занятию 23-34 "Сбор и анализ логов"


## Описание домашнего задания

1. в вагранте поднимаем 2 машины web и log    
2. на web поднимаем nginx    
3. на log настраиваем центральный лог сервер на любой системе на выбор:    
 - journald;    
 - rsyslog;    
 - elk.
4. настраиваем аудит, следящий за изменением конфигов нжинкса    

Все критичные логи с web должны собираться и локально и удаленно.
Все логи с nginx должны уходить на удаленный сервер (локально только критичные).
Логи аудита должны также уходить на удаленную систему.

Дополнительное задание:    
- развернуть еще машину elk*     
- таким образом настроить 2 центральных лог системы elk и какую либо еще;    
- в elk должны уходить только логи нжинкса;    
- во вторую систему все остальное.


---

## Выполнение     

Подготовлен [Vagrantfile](./Vagrantfile) c [ansible playbook](ansible/play.yml) разворачивающий данный стенд.

Использование:    
```bash
vagrant up
```

---

Информационные материлы по заданию:    

[Презентация](docs/Otus_Logs.pdf)    
[Презентация 2](docs/Otus_Logs2.pdf)   
[Общая информация по логам](docs/Logs.pdf)    
[Методичка по созданию стенда](docs/metodic.pdf)    

Статья «Настройка rsyslog для хранения логов на удаленном сервере» - https://www.dmosk.ru/miniinstruktions.php?mini=rsyslog    
Статья «Запись в syslog» - https://nginx.org/ru/docs/syslog.html    
Статья «Директивы в nginx» - https://nginx.org/ru/docs/ngx_core_module.html#error_log    
Статья «How to Setup Rsyslog Client to Send Logs to Rsyslog Server in CentOS 7» - https://www.tecmint.com/setup-rsyslog-client-to-send-logs-to-rsyslog-server-in-centos-7/     
Статья «Configure Audit Service to Send Audit Messages to Another Server» - https://www.lisenet.com/2019/configure-audit-service-to-send-audit-messages-to-another-server/    
Описание параметров auditd.conf - https://www.opennet.ru/man.shtml?topic=auditd.conf&category=5&russian=0    

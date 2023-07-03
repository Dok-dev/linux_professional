# Домашнее задание к занятию 38 - "Резервное копирование"

## Описание домашнего задания

Настроить стенд Vagrant с двумя виртуальными машинами: backup_server и client.    
Настроить удаленный бекап каталога /etc c сервера client при помощи borgbackup. Резервные копии должны соответствовать следующим критериям:

- директория для резервных копий /var/backup. Это должна быть отдельная точка монтирования. В данном случае для демонстрации размер не принципиален, достаточно будет и 2GB;    
- репозиторий дле резервных копий должен быть зашифрован ключом или паролем - на ваше усмотрение;    
- имя бекапа должно содержать информацию о времени снятия бекапа;    
- глубина бекапа должна быть год, хранить можно по последней копии на конец месяца, кроме последних трех. Последние три месяца должны содержать копии на каждый день. Т.е. должна быть правильно настроена политика удаления старых бэкапов;    
- резервная копия снимается каждые 5 минут. Такой частый запуск в целях демонстрации;    
- написан скрипт для снятия резервных копий. Скрипт запускается из соответствующей Cron джобы, либо systemd timer-а - на ваше усмотрение;    
- настроено логирование процесса бекапа. Для упрощения можно весь вывод перенаправлять в logger с соответствующим тегом. Если настроите не в syslog, то обязательна ротация логов.    

Запустите стенд на 30 минут.    
Убедитесь что резервные копии снимаются.    
Остановите бекап, удалите (или переместите) директорию /etc и восстановите ее из бекапа.    
Для сдачи домашнего задания ожидаем настроенные стенд, логи процесса бэкапа и описание процесса восстановления.    


---

## Выполнение     

Подготовлен [Vagrantfile](./Vagrantfile) и [ansible playbook](./ansible/provision.yml) разворачивающий данный стенд.

Использование:    
```bash
vagrant up
```

Проверяем работу таймера:    
```bash
[root@client vagrant]# systemctl list-timers --all
NEXT                         LEFT          LAST                         PASSED       UNIT                         ACTIVATES
Sat 2023-07-01 22:31:27 UTC  2min 47s left Sat 2023-07-01 22:26:27 UTC  2min 12s ago borg-backup.timer            borg-backup.service
```

Логи процесса бэкапа:    
```bash
[root@client vagrant]# journalctl -S today -f -u borg-backup.service
-- Logs begin at Sat 2023-07-01 22:20:39 UTC. --
Jul 01 22:20:39 client systemd[1]: Starting Borg Backup...
Jul 01 22:20:41 client borg[998]: ------------------------------------------------------------------------------
Jul 01 22:20:41 client borg[998]: Archive name: etc-2023-07-01_22:20:39
Jul 01 22:20:41 client borg[998]: Archive fingerprint: 43f01c5f061996611bb61c3b67265a66118dff7813eebda2239a980e3dc4360e
Jul 01 22:20:41 client borg[998]: Time (start): Sat, 2023-07-01 22:20:40
Jul 01 22:20:41 client borg[998]: Time (end):   Sat, 2023-07-01 22:20:41
Jul 01 22:20:41 client borg[998]: Duration: 1.13 seconds
Jul 01 22:20:41 client borg[998]: Number of files: 1705
Jul 01 22:20:41 client borg[998]: Utilization of max. archive size: 0%
Jul 01 22:20:41 client borg[998]: ------------------------------------------------------------------------------
Jul 01 22:20:41 client borg[998]: Original size      Compressed size    Deduplicated size
Jul 01 22:20:41 client borg[998]: This archive:               28.45 MB             13.51 MB             11.85 MB
Jul 01 22:20:41 client borg[998]: All archives:               28.45 MB             13.51 MB             11.85 MB
Jul 01 22:20:41 client borg[998]: Unique chunks         Total chunks
Jul 01 22:20:41 client borg[998]: Chunk index:                    1290                 1707
Jul 01 22:20:41 client borg[998]: ------------------------------------------------------------------------------
Jul 01 22:20:43 client systemd[1]: Started Borg Backup.
Jul 01 22:26:27 client systemd[1]: Starting Borg Backup...
Jul 01 22:26:28 client borg[1017]: ------------------------------------------------------------------------------
Jul 01 22:26:28 client borg[1017]: Archive name: etc-2023-07-01_22:26:28
Jul 01 22:26:28 client borg[1017]: Archive fingerprint: 8a39f4b7c3309ee260df01a1fdb76e235c11bb5df1aca87c4b88ead7622eca56
Jul 01 22:26:28 client borg[1017]: Time (start): Sat, 2023-07-01 22:26:28
Jul 01 22:26:28 client borg[1017]: Time (end):   Sat, 2023-07-01 22:26:28
Jul 01 22:26:28 client borg[1017]: Duration: 0.21 seconds
Jul 01 22:26:28 client borg[1017]: Number of files: 1705
Jul 01 22:26:28 client borg[1017]: Utilization of max. archive size: 0%
Jul 01 22:26:28 client borg[1017]: ------------------------------------------------------------------------------
Jul 01 22:26:28 client borg[1017]: Original size      Compressed size    Deduplicated size
Jul 01 22:26:28 client borg[1017]: This archive:               28.44 MB             13.51 MB            126.07 kB
Jul 01 22:26:28 client borg[1017]: All archives:               56.89 MB             27.01 MB             11.98 MB
Jul 01 22:26:28 client borg[1017]: Unique chunks         Total chunks
Jul 01 22:26:28 client borg[1017]: Chunk index:                    1294                 3410
Jul 01 22:26:28 client borg[1017]: ------------------------------------------------------------------------------
Jul 01 22:26:30 client systemd[1]: Started Borg Backup.
Jul 01 22:32:27 client systemd[1]: Starting Borg Backup...
Jul 01 22:32:28 client borg[1036]: ------------------------------------------------------------------------------
Jul 01 22:32:28 client borg[1036]: Archive name: etc-2023-07-01_22:32:28
Jul 01 22:32:28 client borg[1036]: Archive fingerprint: 2863bc2b4ca0c42752cf8b2c3107a90695593abef6dc382d0fa16ec08813436e
Jul 01 22:32:28 client borg[1036]: Time (start): Sat, 2023-07-01 22:32:28
Jul 01 22:32:28 client borg[1036]: Time (end):   Sat, 2023-07-01 22:32:28
Jul 01 22:32:28 client borg[1036]: Duration: 0.20 seconds
Jul 01 22:32:28 client borg[1036]: Number of files: 1705
Jul 01 22:32:28 client borg[1036]: Utilization of max. archive size: 0%
Jul 01 22:32:28 client borg[1036]: ------------------------------------------------------------------------------
Jul 01 22:32:28 client borg[1036]: Original size      Compressed size    Deduplicated size
Jul 01 22:32:28 client borg[1036]: This archive:               28.44 MB             13.51 MB                572 B
Jul 01 22:32:28 client borg[1036]: All archives:               56.89 MB             27.01 MB             11.86 MB
Jul 01 22:32:28 client borg[1036]: Unique chunks         Total chunks
Jul 01 22:32:28 client borg[1036]: Chunk index:                    1287                 3406
Jul 01 22:32:28 client borg[1036]: ------------------------------------------------------------------------------
Jul 01 22:32:30 client systemd[1]: Started Borg Backup.
```

Процесс восстановления     
```bash
[root@client vagrant]# borg list borg@192.168.60.160:/var/backup/
etc-2023-07-01_22:32:28              Sat, 2023-07-01 22:32:28 [2863bc2b4ca0c42752cf8b2c3107a90695593abef6dc382d0fa16ec08813436e]

[root@client vagrant]# borg extract borg@192.168.60.160:/var/backup/::etc-2023-07-02_20:51:10 etc
Enter passphrase for key ssh://borg@192.168.60.160/var/backup: 
```
---

Информационные материлы по заданию:    

[Презентация](docs/backup.pdf)    

https://habr.com/ru/company/flant/blog/420055/    
https://www.opennet.ru/tips/3180_borg_backup.shtml    

[Borgbackup](https://borgbackup.readthedocs.io/en/stable/usage/general.html)    
[Примеры настройки service](https://github.com/alisianoi/borg-systemd)    
[Примеры настройки автоматического бэкапа через borgmatic](https://dextervolkman.com/posts/borg_backups)

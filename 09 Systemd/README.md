# Домашнее задание к занятию 9 "Инициализация системы. Systemd. "
https://drive.google.com/file/d/1yVi3sJjl9maOCN_Z6cUyPj4rzo0CpudR


## Описание домашнего задания

1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig).    
2. Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi).    
3. Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами.    

4*. Скачать демо-версию Atlassian Jira и переписать основной скрипт запуска на unit-файл.

---


## 1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig).  

```bash
# Для начала создаём файл с конфигурацией для сервиса в директории /etc/sysconfig - из неё сервис будет брать необходимые переменные:
[root@centos7 vagrant]# cat > /etc/sysconfig/watchlog << EOF
# Configuration file for my watchlog service
# Place it to /etc/sysconfig

# File and word in that file that we will be monit
WORD="ALERT"
LOG=/var/log/watchlog.log
EOF


# Затем создаем /var/log/watchlog.log и пишем туда строки на своё усмотрение, плюс ключевое слово ‘ALERT’:
[root@centos7 vagrant]# cat > /opt/watchlog.sh << EOF
#!/bin/bash

WORD=$1
LOG=$2
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
logger "$DATE: I found word, Master!"
else
exit 0
fi
EOF

[root@centos7 vagrant]# chmod +x /opt/watchlog.sh


# Создадим юнит для сервиса:
[root@centos7 vagrant]# cat > /etc/systemd/system/watchlog.service << EOF
[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG
EOF


# Создадим юнит для таймера:
[root@centos7 vagrant]# cat > /etc/systemd/system/watchlog.timer << EOF
[Unit]
Description=Run watchlog script every 30 second

[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service

[Install]
WantedBy=multi-user.target
EOF


# Убедимся в результате:
[root@centos7 vagrant]# tail -f /var/log/messages
Feb  5 16:01:24 centos7 systemd: Created slice User Slice of vagrant.
Feb  5 16:01:24 centos7 systemd-logind: New session 4 of user vagrant.
Feb  5 16:01:24 centos7 systemd: Started Session 4 of user vagrant.
Feb  5 16:01:28 centos7 su: (to root) vagrant on pts/0
Feb  5 16:10:01 centos7 systemd: Created slice User Slice of root.
Feb  5 16:10:01 centos7 systemd: Started Session 5 of user root.
Feb  5 16:10:01 centos7 systemd: Removed slice User Slice of root.
Feb  5 16:16:18 centos7 systemd: Starting Cleanup of Temporary Directories...
Feb  5 16:16:18 centos7 systemd: Started Cleanup of Temporary Directories.
Feb  5 16:17:11 centos7 systemd: Started Run watchlog script every 30 second.
```


## 2. Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi)

```bash
# Устанавливаем spawn-fcgi и необходимые для него пакеты:
[root@centos7 vagrant]# yum install epel-release -y && yum install spawn-fcgi php php-cli -y


# Необходимо раскомментировать строки с переменными в/etc/sysconfig/spawn-fcgi:
[root@centos7 vagrant]# sed -i 's/#SOCKET/SOCKET/' /etc/sysconfig/spawn-fcgi
[root@centos7 vagrant]# sed -i 's/#OPTIONS/OPTIONS/' /etc/sysconfig/spawn-fcgi
[root@centos7 vagrant]# cat /etc/sysconfig/spawn-fcgi
# You must set some working options before the "spawn-fcgi" service will work.
# If SOCKET points to a file, then this file is cleaned up by the init script.
#
# See spawn-fcgi(1) for all possible options.
#
# Example :
SOCKET=/var/run/php-fcgi.sock
OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -P /var/run/spawn-fcgi.pid -- /usr/bin/php-cgi"


# Cам юнит файл:
[root@centos7 vagrant]# cat > /etc/systemd/system/spawn-fcgi.servicer << EOF
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
EOF


# Убеждаемся что все успешно работает:
[root@centos7 vagrant]# systemctl start spawn-fcgi
[root@centos7 vagrant]# systemctl status spawn-fcgi
● spawn-fcgi.service - LSB: Start and stop FastCGI processes
   Loaded: loaded (/etc/rc.d/init.d/spawn-fcgi; bad; vendor preset: disabled)
   Active: active (running) since Вс 2023-02-05 17:13:27 UTC; 5s ago
     Docs: man:systemd-sysv-generator(8)
  Process: 4980 ExecStart=/etc/rc.d/init.d/spawn-fcgi start (code=exited, status=0/SUCCESS)
   CGroup: /system.slice/spawn-fcgi.service
           ├─4992 /usr/bin/php-cgi
           ├─4993 /usr/bin/php-cgi
           ├─4994 /usr/bin/php-cgi
           ├─4995 /usr/bin/php-cgi
           ├─4996 /usr/bin/php-cgi
           ├─4997 /usr/bin/php-cgi
           ├─4998 /usr/bin/php-cgi
           ├─4999 /usr/bin/php-cgi
           ├─5000 /usr/bin/php-cgi
           ├─5001 /usr/bin/php-cgi
           ├─5002 /usr/bin/php-cgi
           ├─5003 /usr/bin/php-cgi
           ├─5004 /usr/bin/php-cgi
           ├─5005 /usr/bin/php-cgi
           ├─5006 /usr/bin/php-cgi
           ├─5007 /usr/bin/php-cgi
           ├─5008 /usr/bin/php-cgi
           ├─5009 /usr/bin/php-cgi
           ├─5010 /usr/bin/php-cgi
           ├─5011 /usr/bin/php-cgi
           ├─5012 /usr/bin/php-cgi
           ├─5013 /usr/bin/php-cgi
           ├─5014 /usr/bin/php-cgi
           ├─5015 /usr/bin/php-cgi
           ├─5016 /usr/bin/php-cgi
           ├─5017 /usr/bin/php-cgi
           ├─5018 /usr/bin/php-cgi
           ├─5019 /usr/bin/php-cgi
           ├─5020 /usr/bin/php-cgi
           ├─5021 /usr/bin/php-cgi
           ├─5022 /usr/bin/php-cgi
           ├─5023 /usr/bin/php-cgi
           └─5024 /usr/bin/php-cgi

фев 05 17:13:27 centos7.localdomain systemd[1]: Starting LSB: Start and stop FastCGI processes...
фев 05 17:13:27 centos7.localdomain spawn-fcgi[4980]: Starting spawn-fcgi: [  OK  ]
фев 05 17:13:27 centos7.localdomain systemd[1]: Started LSB: Start and stop FastCGI processes.
```

## 3. Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами


```bash
# Убедимся что httpd установлен
[root@centos7 vagrant]# yum list httpd
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.corbina.net
 * epel: mirror.logol.ru
 * extras: mirror.corbina.net
 * updates: mirror.corbina.net
Installed Packages
httpd.x86_64  2.4.6-98.el7.centos.6  @updates


# Исходный файл сервиса:
[root@centos7 vagrant]# cat /usr/lib/systemd/system/httpd.service
[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd(8)
Documentation=man:apachectl(8)

[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/httpd
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
ExecStop=/bin/kill -WINCH ${MAINPID}
KillSignal=SIGCONT
PrivateTmp=true

[Install]
WantedBy=multi-user.target

# Добавим возможность считавания параметров запуска сервиса:
[root@centos7 vagrant]# mv /usr/lib/systemd/system/httpd.service /usr/lib/systemd/system/httpd@.service

# Внесем изменения (добавим параметр '%I' к EnvironmentFile):
[root@centos7 vagrant]# ed -i 's/EnvironmentFile=\/etc\/sysconfig\/httpd/EnvironmentFile=\/etc\/sysconfig\/httpd-%I/' /usr/lib/systemd/system/httpd@.service

# В самом файле окружения (которых будет два) задается опция для запуска веб-сервера с необходимым конфигурационным файлом:
[root@centos7 vagrant]# echo 'OPTIONS=-f conf/first.conf' > /etc/sysconfig/httpd-first
[root@centos7 vagrant]# echo 'OPTIONS=-f conf/second.conf' > /etc/sysconfig/httpd-second

# Соответственно в директории с конфигами httpd (/etc/httpd/conf) должны лежать два конфига, в нашем случае это будут first.conf и second.conf:
[root@centos7 vagrant]# mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/first.conf
[root@centos7 vagrant]# cp /etc/httpd/conf/first.conf /etc/httpd/conf/second.conf

# Для удачного запуска, в конфигурационных файлах должны быть указаны уникальные для каждого экземпляра опции Listen и PidFile:
[root@centos7 vagrant]# sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/second.conf
[root@centos7 vagrant]# echo 'PidFile /var/run/httpd-second.pid' >> /etc/httpd/conf/second.conf

# Запустим:
[root@centos7 vagrant]# systemctl start httpd@first
[root@centos7 vagrant]# systemctl start httpd@second

# Проверим:
[root@centos7 vagrant]# ss -tnulp | grep httpd
tcp    LISTEN     0      128       *:8080    *:*  users:(("httpd",pid=29978,fd=3),("httpd",pid=29977,fd=3),("httpd",pid=29976,fd=3),("httpd",pid=29975,fd=3),("httpd",pid=29974,fd=3),("httpd",pid=29973,fd=3))
tcp    LISTEN     0      128       *:80      *:*  users:(("httpd",pid=29955,fd=3),("httpd",pid=29954,fd=3),("httpd",pid=29953,fd=3),("httpd",pid=29952,fd=3),("httpd",pid=29951,fd=3),("httpd",pid=29950,fd=3))

[root@centos7 vagrant]# systemctl status httpd@*
● httpd@first.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: active (running) since Вс 2023-02-05 18:01:47 UTC; 4min 56s ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 29950 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/system-httpd.slice/httpd@first.service
           ├─29950 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─29951 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─29952 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─29953 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           ├─29954 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
           └─29955 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND

фев 05 18:01:47 centos7.localdomain systemd[1]: Starting The Apache HTTP Server...
фев 05 18:01:47 centos7.localdomain httpd[29950]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using centos7.localdomain. Set the 'ServerName' directive globally to suppress this message
фев 05 18:01:47 centos7.localdomain systemd[1]: Started The Apache HTTP Server.

● httpd@second.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: active (running) since Вс 2023-02-05 18:02:01 UTC; 4min 43s ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 29973 (httpd)
   Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
   CGroup: /system.slice/system-httpd.slice/httpd@second.service
           ├─29973 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─29974 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─29975 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─29976 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           ├─29977 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
           └─29978 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND

фев 05 18:02:00 centos7.localdomain systemd[1]: Starting The Apache HTTP Server...
фев 05 18:02:01 centos7.localdomain httpd[29973]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using centos7.localdomain. Set the 'ServerName' directive globally to suppress this message
фев 05 18:02:01 centos7.localdomain systemd[1]: Started The Apache HTTP Server.
```

---

Информационные материлы по заданию:    
[Презентация "Инициализация системы. Systemd"](./systemd.pdf)    
[методичка](./practic_systemd.pdf)
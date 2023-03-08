# Домашнее задание к занятию 17 "SELinux - когда все запрещено"


## Описание домашнего задания

1. Запустить nginx на нестандартном порту 3-мя разными способами:    
 - переключатели setsebool;    
 - добавление нестандартного порта в имеющийся тип;    
 - формирование и установка модуля SELinux.    

   К сдаче:    
      - README с описанием каждого решения (скриншоты и демонстрация приветствуются).

2. Обеспечить работоспособность приложения при включенном selinux.    
 - развернуть приложенный стенд https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems;     
 - выяснить причину неработоспособности механизма обновления зоны (см. README);    
 - предложить решение (или решения) для данной проблемы;    
 - выбрать одно из решений для реализации, предварительно обосновав выбор;    
 - реализовать выбранное решение и продемонстрировать его работоспособность.    

   К сдаче:    
      - README с анализом причины неработоспособности, возможными способами решения и обоснованием выбора одного из них;
      - исправленный стенд или демонстрация работоспособной системы скриншотами и описанием.

Критерии оценки:    
Статус "Принято" ставится при выполнении следующих условий:
- для задания 1 описаны, реализованы и продемонстрированы все 3 способа решения;
- для задания 2 описана причина неработоспособности механизма обновления зоны;
- для задания 2 реализован и продемонстрирован один из способов решения.
Опционально для выполнения:
- для задания 2 предложено более одного способа решения;
- для задания 2 обоснованно(!) выбран один из способов решения.

---


## 1. Запустить nginx на нестандартном порту 3-мя разными способами.

Разрешим в SELinux работу nginx на порту TCP 4881 c помощью переключателей setsebool:    
```bash
[root@selinux ~]# systemctl status firewalld
● firewalld.service - firewalld - dynamic firewall daemon
   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
   Active: inactive (dead)
     Docs: man:firewalld(1)

[root@selinux ~]# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
[root@selinux ~]# 
[root@selinux ~]# getenforce
Enforcing

[root@selinux ~]# cat /var/log/audit/audit.log | grep -A 1 4881 
type=AVC msg=audit(1678025251.063:850): avc:  denied  { name_bind } for  pid=2914 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
type=SYSCALL msg=audit(1678025251.063:850): arch=c000003e syscall=49 success=no exit=-13 a0=6 a1=55878a986878 a2=10 a3=7fff803dc990 items=0 ppid=1 pid=2914 auid=4294967295 uid=0 gid=0 euid=0 suid=0 fsuid=0 egid=0 sgid=0 fsgid=0 tty=(none) ses=4294967295 comm="nginx" exe="/usr/sbin/nginx" subj=system_u:system_r:httpd_t:s0 key=(null)

# Доставим утилиты для работы с SELinux
[root@selinux ~]# yum install policycoreutils-python
[root@selinux ~]# yum -q provides audit2why


[root@selinux ~]# cat /var/log/audit/audit.log | grep 4881 
type=AVC msg=audit(1678027299.865:853): avc:  denied  { name_bind } for  pid=2940 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

[root@selinux ~]# grep 1678027299.865:853 /var/log/audit/audit.log | audit2why
type=AVC msg=audit(1678027299.865:853): avc:  denied  { name_bind } for  pid=2940 comm="nginx" src=4881 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0

        Was caused by:
        The boolean nis_enabled was set incorrectly. 
        Description:
        Allow nis to enabled

        Allow access by executing:
        # setsebool -P nis_enabled 1

[root@selinux ~]# setsebool -P nis_enabled 1

[root@selinux ~]# systemctl restart nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2023-03-05 14:52:42 UTC; 19s ago
  Process: 3275 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 3273 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 3272 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 3277 (nginx)
   CGroup: /system.slice/nginx.service
           ├─3277 nginx: master process /usr/sbin/nginx
           └─3279 nginx: worker process

Mar 05 14:52:42 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Mar 05 14:52:42 selinux nginx[3273]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Mar 05 14:52:42 selinux nginx[3273]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Mar 05 14:52:42 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.

[root@selinux ~]# getsebool -a | grep nis_enabled
nis_enabled --> on
```
[brouser](./img/01.png)    
   
```bash
# Вернём запрет работы nginx на порту 4881 обратно.
[root@selinux ~]# setsebool -P nis_enabled off

[root@selinux ~]# systemctl restart nginx
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for detail
```

Теперь разрешим в SELinux работу nginx на порту TCP 4881 c помощью добавления нестандартного порта в имеющийся тип:    
```bash
# Поиск имеющегося типа, для http трафика:
[root@selinux ~]# semanage port -l | grep http
http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
http_cache_port_t              udp      3130
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
pegasus_https_port_t           tcp      5989

# Добавим порт в тип http_port_t:
[root@selinux ~]# semanage port -a -t http_port_t -p tcp 4881
[root@selinux ~]# semanage port -l | grep  http_port_t
http_port_t                    tcp      4881, 80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988

[root@selinux ~]# systemctl restart nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2023-03-05 15:02:25 UTC; 7s ago
  Process: 3338 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 3336 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 3335 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 3340 (nginx)
   CGroup: /system.slice/nginx.service
           ├─3340 nginx: master process /usr/sbin/nginx
           └─3341 nginx: worker process

Mar 05 15:02:25 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Mar 05 15:02:25 selinux nginx[3336]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Mar 05 15:02:25 selinux nginx[3336]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Mar 05 15:02:25 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
```
[brouser](./img/01.png)   

```bash
# Удалить нестандартный порт из имеющегося типа можно с помощью команды: 
[root@selinux ~]# semanage port -d -t http_port_t -p tcp 4881
[root@selinux ~]# semanage port -l | grep  http_port_t
http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
pegasus_http_port_t            tcp      5988
[root@selinux ~]# systemctl restart nginx
Job for nginx.service failed because the control process exited with error code. See "systemctl status nginx.service" and "journalctl -xe" for details.
```   

Разрешим в SELinux работу nginx на порту TCP 4881 c помощью формирования и установки модуля SELinux:    
```bash
# Посмотрим последнее сообщение в логе SELinux, о nginx: 
[root@selinux ~]# grep nginx /var/log/audit/audit.log | tail -1
grep: /: Is a directory
grep: е: No such file or directory
/var/log/audit/audit.log:type=SERVICE_START msg=audit(1678029100.444:932): pid=1 uid=0 auid=4294967295 ses=4294967295 subj=system_u:system_r:init_t:s0 msg='unit=nginx comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=failed'

# Воспользуемся утилитой audit2allow для того, чтобы на основе логов SELinux сделать модуль, разрешающий работу nginx на нестандартном порту:
[root@selinux ~]# grep nginx /var/log/audit/audit.log | audit2allow -M nginx
******************** IMPORTANT ***********************
To make this policy package active, execute:

semodule -i nginx.pp

# Audit2allow сформировал модуль, и сообщил нам команду, с помощью которой можно применить данный модуль:
[root@selinux ~]# semodule -i nginx.pp

[root@selinux ~]# systemctl start nginx
[root@selinux ~]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2023-03-05 15:17:30 UTC; 7s ago
  Process: 3405 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
  Process: 3402 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
  Process: 3401 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
 Main PID: 3407 (nginx)
   CGroup: /system.slice/nginx.service
           ├─3407 nginx: master process /usr/sbin/nginx
           └─3409 nginx: worker process

Mar 05 15:17:30 selinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
Mar 05 15:17:30 selinux nginx[3402]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
Mar 05 15:17:30 selinux nginx[3402]: nginx: configuration file /etc/nginx/nginx.conf test is successful
Mar 05 15:17:30 selinux systemd[1]: Started The nginx HTTP and reverse proxy server.
# После добавления модуля nginx запустился без ошибок. При использовании модуля изменения сохранятся после перезагрузки. 

# Просмотр всех установленных модулей:
[root@selinux ~]# semodule -l
abrt    1.4.1
accountsd       1.1.0
acct    1.6.0
afs     1.9.0
aiccu   1.1.0
...

# Для удаления модуля воспользуемся командой:
[root@selinux ~]# semodule -r nginx
libsemanage.semanage_direct_remove_key: Removing last nginx module (no other nginx module exists at another priority).
```

## 2. Обеспечение работоспособности приложения при включенном SELinux

Причиной неработоспособности являлся неверный контекст безопасности для дирректории `/etc/named` на name-сервере, что не позволяло изменить файлы зоны.     
Для решения этой проблемы рациональнее изменить несовпадающий понтекст безопасноти для этой директории, в противнос случае придется делать компиляцию модулей SELinux с другим контекстом безопасности.    
Другие решения будут носить временный эффект, например `setenforce 0`.

[Исправленный стенд](./selinux_dns_problems/)

---

Информационные материлы по заданию:    
   
https://wiki.gentoo.org/wiki/SELinux/Tutorials/How_does_a_process_get_into_a_certain_context    
https://defcon.ru/os-security/1264/     
[The SELinux Notebook](./The_SELinux_Notebook.pdf)    
[Презентация](./SELinux.pdf)    
[Стенд с Vagrant c SELinux](./stand.pdf)    
https://docs.google.com/document/d/1QwyccIn8jijBKdaoNR4DCtTULEqb5MKK
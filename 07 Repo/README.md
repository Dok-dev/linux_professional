# Домашнее задание к занятию 7 "Управление пакетами. Дистрибьюция софта "
https://docs.google.com/document/d/1Xz7dCWSzaM8Q0VzBt78K3emh7zlNX3C-Q27B6UuVexI


## Описание домашнего задания

Основная часть:    
- создать свой RPM (можно взять свое приложение, либо собрать к примеру апач с определенными опциями);
- создать свой репо и разместить там свой RPM;
реализовать это все либо в вагранте, либо развернуть у себя через nginx и дать ссылку на репо.


Задание со звездочкой*:    
- реализовать дополнительно пакет через docker.
---


## Создать свой RPM    

```bash
# Скачаем распакуем ngix и openssl:
[root@repo vagrant]# curl -L https://nginx.org/packages/centos/8/SRPMS/nginx-1.20.2-1.el8.ngx.src.rpm --output nginx-1.20.2-1.el8.ngx.src.rpm
[root@repo vagrant]# rpm -i nginx-1.*
[root@repo vagrant]# curl -L https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1s/openssl-1.1.1s.tar.gz --output openssl-1.1.1s.tar.gz
[root@repo vagrant]# tar -C "/root" -xvf openssl-1.1.1s.tar.gz

# Установим пакет с сырцами:
[root@repo vagrant]# yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el7.ngx.x86_64.rpm 

# Заранее поставим все зависимости чтобы в процессе сборки не было ошибок:rpmbuild -tsappa
[root@repo vagrant]# yum-builddep -y /root/rpmbuild/SPECS/nginx.spec

# Добавим в speck-файле опцию для сборки с openssl:
[root@repo vagrant]# sed -i 's/--with-debug/--with-openssl=\/root\/openssl-1.1.1s --with-debug/' /root/rpmbuild/SPECS/nginx.spec

# Теперь можно приступить к сборке RPM пакета:
[root@repo vagrant]# rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec
[root@repo vagrant]# ls -lh /root/rpmbuild/RPMS/x86_64/
total 4,1M
-rw-r--r--. 1 root root 2,1M фев  1 18:52 nginx-1.20.2-1.el7.ngx.x86_64.rpm
-rw-r--r--. 1 root root 2,0M фев  1 18:52 nginx-debuginfo-1.20.2-1.el7.ngx.x86_64.rpm

# Теперь можно установить наш пакет и убедиться что nginx работает:
[root@repo vagrant]# yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el7.ngx.x86_64.rpm
[root@repo vagrant]# systemctl start nginx
[root@repo vagrant]# systemctl status nginx
```

## Создать свой репо и разместить там свой RPM    

```bash
# Директория для статики у NGINX по умолчанию /usr/share/nginx/html. Создадим там каталог repo и скопируем туда RPM-пакет:
[root@repo vagrant]# mkdir /usr/share/nginx/html/repo
[root@repo vagrant]# cp /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el7.ngx.x86_64.rpm /usr/share/nginx/html/repo/

# Скопируем туда RPM-пакет для установки репозиторий Percona-Server:
[root@repo vagrant]# curl -L https://downloads.percona.com/downloads/percona-distribution-mysql-ps/percona-distribution-mysql-ps-8.0.28/binary/redhat/7/x86_64/percona-orchestrator-3.2.6-2.el7.x86_64.rpm --output /usr/share/nginx/html/repo/percona-orchestrator-3.2.6-2.el7.x86_64.rpm

# Инициализируем репозиторий командой:
[root@repo vagrant]# createrepo /usr/share/nginx/html/repo/

# Для прозрачности настроим в NGINX доступ к листингу каталога:
[root@repo vagrant]# sed -i 's/index  index.html index.htm;/index  index.html index.htm;autoindex on;/' /etc/nginx/conf.d/default.conf

# Проверяем конфиг и применяем его:
[root@repo vagrant]# nginx -t && nginx -s reload

# Проверка:
[root@repo vagrant]# curl -a http://localhost/repo/
<html>
<head><title>Index of /repo/</title></head>
<body>
<h1>Index of /repo/</h1><hr><pre><a href="../">../</a>
<a href="repodata/">repodata/</a>                                          04-Feb-2023 10:56                   -
<a href="nginx-1.20.2-1.el7.ngx.x86_64.rpm">nginx-1.20.2-1.el7.ngx.x86_64.rpm</a>                  04-Feb-2023 10:17             2200708
<a href="percona-orchestrator-3.2.6-2.el8.x86_64.rpm">percona-orchestrator-3.2.6-2.el8.x86_64.rpm</a>        04-Feb-2023 10:54             5222976
</pre><hr></body>
</html>

# Добавим наш репозиторий в /etc/yum.repos.d:
[root@repo vagrant]# cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF

# Убедимся что репозиторий подключился и посмотрим что в нем есть:
[root@repo vagrant]# yum repolist enabled | grep otus
otus                                otus-linux

[root@repo vagrant]# yum list | grep otus
nginx                                       1:1.20.2-1.el7.ngx         otus
percona-orchestrator.x86_64                 2:3.2.6-2.el8              otus

# Установим percona-orchestrator из нашего репозитория, но сначала устраним проблему с зависимостями
[root@repo vagrant]# yum install epel-release -y
[root@repo vagrant]# yum install jq oniguruma -y
[root@repo vagrant]# yum install percona-orchestrator.x86_64 -y
```

[Vagrantfile](./Vagrantfile) с машиной подымающей репозиторий.

---

Информационные материлы по заданию:    
http://wiki.rosalab.ru/ru/index.php/Сборка_RPM_-_быстрый_старт    
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html-single/rpm_packaging_guide/index    
https://blog.packagecloud.io/working-with-source-rpms/    
https://rpm-packaging-guide.github.io/    
[Презентация Управление репозиториями](./repo.pdf)
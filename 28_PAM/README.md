# Домашнее задание к занятию  "Пользователи и группы. Авторизация и аутентификация."

## Описание домашнего задания

1. Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников.    
2. Дать конкретному пользователю права работать с докером и возможность рестартить докер сервис.*    

---

### Настройка запрета для всех пользователей (кроме группы Admin) логина в выходные дни (Праздники не учитываются).   

```bash
#Переходим в root-пользователя
[vagrant@pam ~]$ sudo -i

# Создаём пользователя otusadm и otus
[root@pam ~]# useradd otusadm && useradd otus

# Создаём пользователям пароли
[root@pam ~]#  echo "Otus2023!" | passwd --stdin otusadm && echo "Otus2023!" | passwd --stdin otus
Changing password for user otusadm.
passwd: all authentication tokens updated successfully.
Changing password for user otus.
passwd: all authentication tokens updated successfully.

# Создаём группу admin
[root@pam ~]# groupadd -f admin

# Добавляем пользователей vagrant,root и otusadm в группу admin
[root@pam ~]# usermod otusadm -a -G admin && usermod root -a -G admin && usermod vagrant -a -G admin

# Пытаемся подключиться с хостовой машины
$ ssh otus@192.168.60.10
otus@192.168.60.10's password: 
Last failed login: Sun May 21 12:34:16 UTC 2023 from 192.168.60.1 on ssh:notty
There was 1 failed login attempt since the last successful login.
Last login: Sun May 21 12:33:46 2023 from 192.168.60.1
[otus@pam ~]$ whoami
otus
[otus@pam ~]$ logout
Connection to 192.168.60.10 closed.
$ ssh otusadm@192.168.60.10
otusadm@192.168.60.10's password: 
[otusadm@pam ~]$ whoami
otusadm
[otusadm@pam ~]$ logout

# Проверим, что пользователи root, vagrant и otusadm есть в группе admin
[root@pam ~]# cat /etc/group | grep admin
printadmin:x:994:
admin:x:1004:otusadm,root,vagrant

# Выберем метод PAM-аутентификации, так как у нас используется только ограничение по времени, то было бы логично использовать метод pam_time, однако, данный метод не работает с локальными группами пользователей, и, получается, что использование данного метода добавит нам большое количество однообразных строк с разными пользователями. В текущей ситуации лучше написать небольшой скрипт контроля и использовать модуль pam_exe.
# Создадим файл-скрипт /usr/local/bin/login.sh
[root@pam ~]# cat > /usr/local/bin/login.sh<< 'EOF'
#!/bin/bash
#Первое условие: если день недели суббота или воскресенье
if [ $(date +%a) = "Sat" ] || [ $(date +%a) = "Sun" ]; then
 #Второе условие: входит ли пользователь в группу admin
 if getent group admin | grep -qw "$PAM_USER"; then
        #Если пользователь входит в группу admin, то он может подключиться
        exit 0
      else
        #Иначе ошибка (не сможет подключиться)
        exit 1
    fi
  #Если день не выходной, то подключиться может любой пользователь
  else
    exit 0
fi
EOF
[root@pam ~]# chmod +x /usr/local/bin/login.sh

# Укажем в файле /etc/pam.d/sshd модуль pam_exec и наш скрипт
[root@pam ~]# cat /etc/pam.d/sshd 
#%PAM-1.0
auth       substack     password-auth
auth       include      postlogin
account    required     pam_sepermit.so
account    required     pam_nologin.so
account    include      password-auth
password   include      password-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open env_params
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    optional     pam_motd.so
session    include      password-auth
session    include      postlogin
[root@pam ~]# sed -i '/account    required     pam_nologin.so/a account    required     pam_exec.so /usr/local/bin/login.sh' /etc/pam.d/sshd
[root@pam ~]# cat /etc/pam.d/sshd 
#%PAM-1.0
auth       substack     password-auth
auth       include      postlogin
account    required     pam_sepermit.so
account    required     pam_nologin.so
account    required     pam_exec.so /usr/local/bin/login.sh
account    include      password-auth
password   include      password-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open env_params
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    optional     pam_motd.so
session    include      password-auth
session    include      postlogin

# Проверка
$ ssh otusadm@192.168.60.10
otusadm@192.168.60.10's password: 
Last failed login: Sun May 21 13:33:38 UTC 2023 from 192.168.60.1 on ssh:notty
There were 4 failed login attempts since the last successful login.
Last login: Sun May 21 13:15:14 2023 from 192.168.60.1
[otusadm@pam ~]$ logout
Connection to 192.168.60.10 closed.
$ ssh otus@192.168.60.10
otus@192.168.60.10's password: 
/usr/local/bin/login.sh failed: exit code 1
Authentication failed.
```

### Дать конкретному пользователю права работать с докером и возможность рестартить докер сервис.

```bash
# Установим докер
[root@pam ~]# dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
Failed to set locale, defaulting to C.UTF-8
Adding repo from: https://download.docker.com/linux/centos/docker-ce.repo
[root@pam ~]# dnf install -y docker-ce
[root@pam ~]# systemctl enable docker
[root@pam ~]# service docker start


# Предоставим права на работу с докером пользователю otusadm
[root@pam ~]# usermod -aG docker otusadm

# Предоставим права на перезапуск службы docker группе admin
[root@pam ~]# echo '%admin ALL=NOPASSWD: /usr/bin/systemctl restart docker' > /etc/sudoers.d/admin

# Проверка
[otusadm@pam ~]$ docker system prune
WARNING! This will remove:
  - all stopped containers
  - all networks not used by at least one container
  - all dangling images
  - all dangling build cache

Are you sure you want to continue? [y/N] y
Total reclaimed space: 0B

[otusadm@pam ~]$ sudo systemctl restart docker
[otusadm@pam ~]$ sudo systemctl stop docker

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for otusadm: 
Sorry, user otusadm is not allowed to execute '/bin/systemctl stop docker' as root on pam.

```

---

Информационные материлы по заданию:    

[Презентация](docs/AuthorizationAuthentication.pdf)    
[Linux_PAM](docs/Linux_PAM_SAG.pdf)    
[Практика](docs/practic.pdf)

[Основы работы с пользователями](https://firstvds.ru/technology/linux-user-management)
pam_script Linux man page - https://linux.die.net/man/5/pam_script      
pam_time PAM module for time control access - Linux Man Pages - https://www.systutorials.com/docs/linux/man/8-pam_time/  
Как работает PAM (Pluggable Authentication Modules) (pam auth linux security howto) - https://www.opennet.ru/base/net/pam_linux.txt.html   
What is PAM? - https://medium.com/information-and-technology/wtf-is-pam-99a16c80ac57    

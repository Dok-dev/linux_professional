# Домашнее задание к занятию 1.4 "Файловая система ZFS"
https://docs.google.com/document/d/1umX2K8cv-aB7iLjzDpkREHhtE65W2fQDWpZHvvF5EjY/edit


## Описание домашнего задания
1) Определить алгоритм с наилучшим сжатием.     
   Зачем: отрабатываем навыки работы с созданием томов и установкой параметров. Находим наилучшее сжатие.    

   Шаги:
   - определить какие алгоритмы сжатия поддерживает zfs (gzip gzip-N, zle lzjb, lz4);
   - создать 4 файловых системы на каждой применить свой алгоритм сжатия;
     Для сжатия использовать либо текстовый файл либо группу файлов:
   - скачать файл “Война и мир” и расположить на файловой системе wget -O War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8, либо скачать файл ядра распаковать и расположить на файловой системе.    

   Результат:
   - список команд которыми получен результат с их выводами;
   - вывод команды из которой видно какой из алгоритмов лучше.

2) Определить настройки pool’a.    
   Зачем: для переноса дисков между системами используется функция export/import. Отрабатываем навыки работы с файловой системой ZFS.    

   Шаги:    
   - загрузить распаковать архив с файлами локально https://drive.google.com/open?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg;
   - с помощью команды zfs import собрать pool ZFS;
   - командами zfs определить настройки:
     - размер хранилища;
     - тип pool;
     - значение recordsize;
     - какое сжатие используется;
     - какая контрольная сумма используется.    

   Результат:
   - список команд которыми восстановили pool . Желательно с Output команд;
   - файл с описанием настроек settings.

3) Найти сообщение от преподавателей.    
   Зачем: для бэкапа используются технологии snapshot. Snapshot можно передавать между хостами и восстанавливать с помощью send/receive. Отрабатываем навыки восстановления snapshot и переноса файла.    

   Шаги:    
   - скопировать файл из удаленной директории. https://drive.google.com/file/d/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG/view?usp=sharing (файл был получен командой zfs send otus/storage@task2 > otus_task2.file)
   - восстановить файл локально. zfs receive
   - найти зашифрованное сообщение в файле secret_message    
   
   Результат:    
   - список шагов которыми восстанавливали;
   - зашифрованное сообщение.


---


## Задача 1 - Определить алгоритм с наилучшим сжатием.

Vagrantfile c дополнительными дисками и поддержкой zfs:    
[Vagrantfile](./Vagrantfile)

```bash
[vagrant@zfs ~]$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0  512M  0 disk 
sdb      8:16   0  512M  0 disk 
sdc      8:32   0  512M  0 disk 
sdd      8:48   0  512M  0 disk 
sde      8:64   0  512M  0 disk 
sdf      8:80   0  512M  0 disk 
sdg      8:96   0  512M  0 disk 
sdh      8:112  0  512M  0 disk 
sdi      8:128  0   40G  0 disk 
`-sdi1   8:129  0   40G  0 part /

######## Создаём 4 пула из двух дисков в режиме RAID 1: ########
[root@zfs vagrant]# zpool create otus1 mirror /dev/sda /dev/sdb
[root@zfs vagrant]# zpool create otus2 mirror /dev/sdc /dev/sdd
[root@zfs vagrant]# zpool create otus3 mirror /dev/sde /dev/sdf
[root@zfs vagrant]# zpool create otus4 mirror /dev/sdg /dev/sdh

[vagrant@zfs ~]$ zpool list
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
otus1   480M   100K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus2   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus3   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus4   480M  91.5K   480M        -         -     0%     0%  1.00x    ONLINE  -

[root@zfs vagrant]# zpool status otus1
  pool: otus1
 state: ONLINE
  scan: none requested
config:

        NAME        STATE     READ WRITE CKSUM
        otus1       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdb     ONLINE       0     0     0
            sdc     ONLINE       0     0     0

######## Добавим разные алгоритмы сжатия в каждую файловую систему: ########
[root@zfs vagrant]# zfs set compression=lzjb otus1
[root@zfs vagrant]# zfs set compression=lz4 otus2
[root@zfs vagrant]# zfs set compression=gzip-9 otus3
[root@zfs vagrant]# zfs set compression=zle otus4

[vagrant@zfs ~]$ zfs get all | grep compression
otus1  compression           lzjb                   local
otus2  compression           lz4                    local
otus3  compression           gzip-9                 local
otus4  compression           zle                    local

######## Скачаем один и тот же текстовый файл во все пулы: ########
[root@zfs vagrant]# for i in {1..4}; do wget -P /otus$i http://www.gutenberg.org/ebooks/2600.txt.utf-8; done
--2023-01-28 10:17:35--  http://www.gutenberg.org/ebooks/2600.txt.utf-8
# ... вывод укорочен
Saving to: '/otus1/2600.txt.utf-8'

100%[==================================================================================================================================================================================================================>] 3,359,372   1.61MB/s   in 2.0s   

2023-01-28 10:17:38 (1.61 MB/s) - '/otus1/2600.txt.utf-8' saved [3359372/3359372]

--2023-01-28 10:17:38--  http://www.gutenberg.org/ebooks/2600.txt.utf-8
# ... вывод укорочен
Saving to: '/otus2/2600.txt.utf-8'

100%[==================================================================================================================================================================================================================>] 3,359,372   1.44MB/s   in 2.2s   

2023-01-28 10:17:42 (1.44 MB/s) - '/otus2/2600.txt.utf-8' saved [3359372/3359372]

--2023-01-28 10:17:42--  http://www.gutenberg.org/ebooks/2600.txt.utf-8
# ... вывод укорочен
Saving to: '/otus3/2600.txt.utf-8'

100%[==================================================================================================================================================================================================================>] 3,359,372   1.48MB/s   in 2.2s   

2023-01-28 10:17:45 (1.48 MB/s) - '/otus3/2600.txt.utf-8' saved [3359372/3359372]

--2023-01-28 10:17:45--  http://www.gutenberg.org/ebooks/2600.txt.utf-8
# ... вывод укорочен
Saving to: '/otus4/2600.txt.utf-8'

100%[==================================================================================================================================================================================================================>] 3,359,372   1.41MB/s   in 2.3s   

2023-01-28 10:17:49 (1.41 MB/s) - '/otus4/2600.txt.utf-8' saved [3359372/3359372]

######## Проверим, что файл был скачан во все пулы: ########
[vagrant@zfs ~]$ ls -l /otus*
/otus1:
total 2443
-rw-r--r--. 1 root root 3359372 Jan  2 09:18 2600.txt.utf-8

/otus2:
total 2041
-rw-r--r--. 1 root root 3359372 Jan  2 09:18 2600.txt.utf-8

/otus3:
total 1239
-rw-r--r--. 1 root root 3359372 Jan  2 09:18 2600.txt.utf-8

/otus4:
total 3287
-rw-r--r--. 1 root root 3359372 Jan  2 09:18 2600.txt.utf-8

# Уже на этом этапе видно, что самый оптимальный метод сжатия у нас используется в пуле otus3.


######## Проверим, сколько места занимает один и тот же файл в разных пулах и проверим степень сжатия файлов: ########

[vagrant@zfs ~]$ zfs list
NAME    USED  AVAIL     REFER  MOUNTPOINT
otus1  2.48M   350M     2.41M  /otus1
otus2  2.09M   350M     2.02M  /otus2
otus3  1.30M   351M     1.23M  /otus3
otus4  3.30M   349M     3.23M  /otus4

[vagrant@zfs ~]$ zfs get all | grep compressratio | grep -v ref
otus1  compressratio         1.35x                  -
otus2  compressratio         1.62x                  -
otus3  compressratio         2.64x                  -
otus4  compressratio         1.01x                  -

# Таким образом, у нас получается, что алгоритм gzip-9 самый эффективный по сжатию.
```

## Задача 2 - Определить настройки pool’a.

```bash
####### Скачиваем архив в домашний каталог: #######
[vagrant@zfs ~]$ wget -O archive.tar.gz --no-check-certificate 'https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download'
--2023-01-28 10:34:30--  https://drive.google.com/u/0/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download
Resolving drive.google.com (drive.google.com)... 173.194.73.194, 2a00:1450:4010:c0d::c2
Connecting to drive.google.com (drive.google.com)|173.194.73.194|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://drive.google.com/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download [following]
--2023-01-28 10:34:30--  https://drive.google.com/uc?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg&export=download
Reusing existing connection to drive.google.com:443.
HTTP request sent, awaiting response... 303 See Other
Location: https://doc-0c-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/n75f6ha463duev623honduc3b48m9tar/1674902025000/16189157874053420687/*/1KRBNW33QWqbvbVHa3hLJivOAt60yukkg?e=download&uuid=66821e24-d714-48cf-8ac7-26e43ff92eab [following]
Warning: wildcards not supported in HTTP.
--2023-01-28 10:34:34--  https://doc-0c-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/n75f6ha463duev623honduc3b48m9tar/1674902025000/16189157874053420687/*/1KRBNW33QWqbvbVHa3hLJivOAt60yukkg?e=download&uuid=66821e24-d714-48cf-8ac7-26e43ff92eab
Resolving doc-0c-bo-docs.googleusercontent.com (doc-0c-bo-docs.googleusercontent.com)... 142.251.1.132, 2a00:1450:4010:c1e::84
Connecting to doc-0c-bo-docs.googleusercontent.com (doc-0c-bo-docs.googleusercontent.com)|142.251.1.132|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 7275140 (6.9M) [application/x-gzip]
Saving to: 'archive.tar.gz'

100%[==================================================================================================================================================================================================================>] 7,275,140   6.19MB/s   in 1.1s   

2023-01-28 10:34:36 (6.19 MB/s) - 'archive.tar.gz' saved [7275140/7275140]

####### Разархивируем его: #######
[vagrant@zfs ~]$ tar -xzvf archive.tar.gz
zpoolexport/
zpoolexport/filea
zpoolexport/fileb

 ####### Проверим, возможно ли импортировать данный каталог в пул: #######
[root@zfs vagrant]# zpool import -d zpoolexport/
   pool: otus
     id: 6554193320433390805
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

        otus                                 ONLINE
          mirror-0                           ONLINE
            /home/vagrant/zpoolexport/filea  ONLINE
            /home/vagrant/zpoolexport/fileb  ONLINE
# Данный вывод показывает нам имя пула, тип raid и его состав.

####### Сделаем импорт данного пула к нам в ОС: #######
[root@zfs vagrant]# zpool import -d zpoolexport/ otus

# Если у Вас уже есть пул с именем otus, то можно поменять его имя во время импорта: zpool import -d zpoolexport/ otus newotus

# Команда zpool status выдаст нам информацию о составе импортированного пула
[root@zfs vagrant]#  zpool status
  pool: otus
 state: ONLINE
  scan: none requested
config:

        NAME                                 STATE     READ WRITE CKSUM
        otus                                 ONLINE       0     0     0
          mirror-0                           ONLINE       0     0     0
            /home/vagrant/zpoolexport/filea  ONLINE       0     0     0
            /home/vagrant/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors

  pool: otus1
 state: ONLINE
  scan: none requested
config:

        NAME        STATE     READ WRITE CKSUM
        otus1       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sda     ONLINE       0     0     0
            sdb     ONLINE       0     0     0

errors: No known data errors

  pool: otus2
 state: ONLINE
  scan: none requested
config:

        NAME        STATE     READ WRITE CKSUM
        otus2       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdc     ONLINE       0     0     0
            sdd     ONLINE       0     0     0

errors: No known data errors

  pool: otus3
 state: ONLINE
  scan: none requested
config:

        NAME        STATE     READ WRITE CKSUM
        otus3       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sde     ONLINE       0     0     0
            sdf     ONLINE       0     0     0

errors: No known data errors

  pool: otus4
 state: ONLINE
  scan: none requested
config:

        NAME        STATE     READ WRITE CKSUM
        otus4       ONLINE       0     0     0
          mirror-0  ONLINE       0     0     0
            sdg     ONLINE       0     0     0
            sdh     ONLINE       0     0     0

errors: No known data errors


####### Далее нам нужно определить настройки: ####### 
# Запрос сразу всех параметров пула: zpool get all otus
[root@zfs vagrant]# zpool get all otus
NAME  PROPERTY                       VALUE                          SOURCE
otus  size                           480M                           -
otus  capacity                       0%                             -
otus  altroot                        -                              default
otus  health                         ONLINE                         -
otus  guid                           6554193320433390805            -
otus  version                        -                              default
otus  bootfs                         -                              default
otus  delegation                     on                             default
otus  autoreplace                    off                            default
otus  cachefile                      -                              default
otus  failmode                       wait                           default
otus  listsnapshots                  off                            default
otus  autoexpand                     off                            default
otus  dedupditto                     0                              default
otus  dedupratio                     1.00x                          -
otus  free                           478M                           -
otus  allocated                      2.09M                          -
otus  readonly                       off                            -
otus  ashift                         0                              default
otus  comment                        -                              default
otus  expandsize                     -                              -
otus  freeing                        0                              -
otus  fragmentation                  0%                             -
otus  leaked                         0                              -
otus  multihost                      off                            default
otus  checkpoint                     -                              -
otus  load_guid                      1084652467522808222            -
otus  autotrim                       off                            default
otus  feature@async_destroy          enabled                        local
otus  feature@empty_bpobj            active                         local
otus  feature@lz4_compress           active                         local
otus  feature@multi_vdev_crash_dump  enabled                        local
otus  feature@spacemap_histogram     active                         local
otus  feature@enabled_txg            active                         local
otus  feature@hole_birth             active                         local
otus  feature@extensible_dataset     active                         local
otus  feature@embedded_data          active                         local
otus  feature@bookmarks              enabled                        local
otus  feature@filesystem_limits      enabled                        local
otus  feature@large_blocks           enabled                        local
otus  feature@large_dnode            enabled                        local
otus  feature@sha512                 enabled                        local
otus  feature@skein                  enabled                        local
otus  feature@edonr                  enabled                        local
otus  feature@userobj_accounting     active                         local
otus  feature@encryption             enabled                        local
otus  feature@project_quota          active                         local
otus  feature@device_removal         enabled                        local
otus  feature@obsolete_counts        enabled                        local
otus  feature@zpool_checkpoint       enabled                        local
otus  feature@spacemap_v2            active                         local
otus  feature@allocation_classes     enabled                        local
otus  feature@resilver_defer         enabled                        local
otus  feature@bookmark_v2            enabled                        local

# Запрос сразу всех параметром файловой системы: zfs get all otus
[root@zfs vagrant]# zfs get all otus
NAME  PROPERTY              VALUE                  SOURCE
otus  type                  filesystem             -
otus  creation              Fri May 15  4:00 2020  -
otus  used                  2.04M                  -
otus  available             350M                   -
otus  referenced            24K                    -
otus  compressratio         1.00x                  -
otus  mounted               yes                    -
otus  quota                 none                   default
otus  reservation           none                   default
otus  recordsize            128K                   local
otus  mountpoint            /otus                  default
otus  sharenfs              off                    default
otus  checksum              sha256                 local
otus  compression           zle                    local
otus  atime                 on                     default
otus  devices               on                     default
otus  exec                  on                     default
otus  setuid                on                     default
otus  readonly              off                    default
otus  zoned                 off                    default
otus  snapdir               hidden                 default
otus  aclinherit            restricted             default
otus  createtxg             1                      -
otus  canmount              on                     default
otus  xattr                 on                     default
otus  copies                1                      default
otus  version               5                      -
otus  utf8only              off                    -
otus  normalization         none                   -
otus  casesensitivity       sensitive              -
otus  vscan                 off                    default
otus  nbmand                off                    default
otus  sharesmb              off                    default
otus  refquota              none                   default
otus  refreservation        none                   default
otus  guid                  14592242904030363272   -
otus  primarycache          all                    default
otus  secondarycache        all                    default
otus  usedbysnapshots       0B                     -
otus  usedbydataset         24K                    -
otus  usedbychildren        2.01M                  -
otus  usedbyrefreservation  0B                     -
otus  logbias               latency                default
otus  objsetid              54                     -
otus  dedup                 off                    default
otus  mlslabel              none                   default
otus  sync                  standard               default
otus  dnodesize             legacy                 default
otus  refcompressratio      1.00x                  -
otus  written               24K                    -
otus  logicalused           1020K                  -
otus  logicalreferenced     12K                    -
otus  volmode               default                default
otus  filesystem_limit      none                   default
otus  snapshot_limit        none                   default
otus  filesystem_count      none                   default
otus  snapshot_count        none                   default
otus  snapdev               hidden                 default
otus  acltype               off                    default
otus  context               none                   default
otus  fscontext             none                   default
otus  defcontext            none                   default
otus  rootcontext           none                   default
otus  relatime              off                    default
otus  redundant_metadata    all                    default
otus  overlay               off                    default
otus  encryption            off                    default
otus  keylocation           none                   default
otus  keyformat             none                   default
otus  pbkdf2iters           0                      default
otus  special_small_blocks  0                      default

# C помощью команды 'get' можно уточнить конкретный параметр, например:
[root@zfs vagrant]# zfs get available otus
NAME  PROPERTY   VALUE  SOURCE
otus  available  350M   -

[root@zfs vagrant]# zfs get readonly otus
NAME  PROPERTY  VALUE   SOURCE
otus  readonly  off     default

[root@zfs vagrant]# zfs get recordsize otus
NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local

[root@zfs vagrant]# zfs get compression otus
NAME  PROPERTY     VALUE     SOURCE
otus  compression  zle       local

[root@zfs vagrant]#  zfs get checksum otus
NAME  PROPERTY  VALUE      SOURCE
otus  checksum  sha256     local
```

## Задача 3 - Работа со снапшотом, поиск сообщения от преподавателя.

```bash
####### Скачаем файл, указанный в задании: #######
[vagrant@zfs ~]$ wget -O otus_task2.file --no-check-certificate 'https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download'
--2023-01-28 10:49:24--  https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download
Resolving drive.google.com (drive.google.com)... 173.194.73.194, 2a00:1450:4010:c0d::c2
Connecting to drive.google.com (drive.google.com)|173.194.73.194|:443... connected.
HTTP request sent, awaiting response... 302 Found
Location: https://drive.google.com/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download [following]
--2023-01-28 10:49:25--  https://drive.google.com/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download
Reusing existing connection to drive.google.com:443.
HTTP request sent, awaiting response... 303 See Other
Location: https://doc-00-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/0diro0mqdb7cosfl7f3lqcbm1asvit78/1674902925000/16189157874053420687/*/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG?e=download&uuid=17246e4a-bfd1-40b8-8f26-c3dd61c7293c [following]
Warning: wildcards not supported in HTTP.
--2023-01-28 10:49:28--  https://doc-00-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/0diro0mqdb7cosfl7f3lqcbm1asvit78/1674902925000/16189157874053420687/*/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG?e=download&uuid=17246e4a-bfd1-40b8-8f26-c3dd61c7293c
Resolving doc-00-bo-docs.googleusercontent.com (doc-00-bo-docs.googleusercontent.com)... 142.251.1.132, 2a00:1450:4010:c1e::84
Connecting to doc-00-bo-docs.googleusercontent.com (doc-00-bo-docs.googleusercontent.com)|142.251.1.132|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 5432736 (5.2M) [application/octet-stream]
Saving to: 'otus_task2.file'

100%[==================================================================================================================================================================================================================>] 5,432,736   6.29MB/s   in 0.8s   

2023-01-28 10:49:30 (6.29 MB/s) - 'otus_task2.file' saved [5432736/5432736]

####### Восстановим файловую систему из снапшота: #######
[root@zfs vagrant]# zfs receive otus/test@today < otus_task2.file

####### Далее, ищем в каталоге /otus/test файл с именем “secret_message”: #######
[vagrant@zfs ~]$ find /otus/test -name "secret_message"
/otus/test/task1/file_mess/secret_message
[vagrant@zfs ~]$ cat /otus/test/task1/file_mess/secret_message
https://github.com/sindresorhus/awesome
```

---
## Рекомендуемые источники
Статья о ZFS https://ru.wikipedia.org/wiki/ZFS    
Статья «Что такое ZFS? И почему люди от неё без ума?» - https://habr.com/ru/post/424651/    
Официальная документация по Oracle Solaris ZFS https://docs.oracle.com/cd/E19253-01/819-5461/gbcya/index.html    
Статья о ZFS (теория и практика) http://xgu.ru/wiki/ZFS    

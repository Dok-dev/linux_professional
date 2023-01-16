# Домашнее задание к занятию 1.2 "Работа с mdadm"
https://drive.google.com/file/d/1phsvBYkiRPVrDG0EXagy-TF4P5y9XOAX/view


## Описание домашнего задания
1) добавить в Vagrantfile еще дисков;
2) собрать R0/R5/R10 на выбор;
3) сломать/починить raid;
4) прописать собранный рейд в конф, чтобы рейд собирался при загрузке;
5) создать GPT раздел и 5 партиций.

На проверку отправьте [измененный Vagrantfile](./1/Vagrantfile), [скрипт для создания рейда](./create_raid.sh), [конф для автосборки рейда](./mdadm.conf) при загрузке.

Дополнительные задания:    
   Vagrantfile, который сразу собирает систему с подключенным рейдом и смонтированными разделами. После перезагрузки стенда разделы должны автоматически примонтироваться.    
Задание повышенной сложности:    
   Перенести работающую систему с одним диском на RAID 1. Даунтайм на загрузку с нового диска предполагается.    
   На проверку отправьте вывод команды lsblk до и после и описание хода решения (можно воспользоваться утилитой Script).

---


## Задача 1 - добавить в Vagrantfile еще дисков

Vagrantfile c дополнительными дисками:    
[Vagrantfile](./1/Vagrantfile)

```bash
[vagrant@linuxnodes ~]$ lsblk
NAME                    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                       8:0    0  128G  0 disk 
├─sda1                    8:1    0    1G  0 part /boot
└─sda2                    8:2    0  127G  0 part 
  ├─centos_centos7-root 253:0    0  125G  0 lvm  /
  └─centos_centos7-swap 253:1    0    2G  0 lvm  [SWAP]
sdb                       8:16   0  250M  0 disk 
sdc                       8:32   0  250M  0 disk 
sdd                       8:48   0  250M  0 disk 
sde                       8:64   0  250M  0 disk 
sdf                       8:80   0  250M  0 disk 
```

## Задача 2 - собрать R0/R5/R10 на выбор

```bash
[vagrant@linuxnodes ~]$ sudo mdadm --create --verbose /dev/md0 -l 10 -n 5 /dev/sd{b,c,d,e,f} 
mdadm: layout defaults to n2
mdadm: layout defaults to n2
mdadm: chunk size defaults to 512K
mdadm: size set to 253952K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
[vagrant@linuxnodes ~]$ cat /proc/mdstat
Personalities : [raid10] 
md0 : active raid10 sdf[4] sde[3] sdd[2] sdc[1] sdb[0]
      634880 blocks super 1.2 512K chunks 2 near-copies [5/5] [UUUUU]
      
unused devices: <none>
[vagrant@linuxnodes ~]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Sun Jan 15 12:55:15 2023
        Raid Level : raid10
        Array Size : 634880 (620.00 MiB 650.12 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Sun Jan 15 12:55:18 2023
             State : clean 
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 0
     Spare Devices : 0

            Layout : near=2
        Chunk Size : 512K

Consistency Policy : resync

              Name : linuxnodes:0  (local to host linuxnodes)
              UUID : 9df6abc3:45e175b6:81cc4648:389d6700
            Events : 17

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       3       8       64        3      active sync   /dev/sde
       4       8       80        4      active sync   /dev/sdf
```

## Задача 3 - сломать/починить raid

```bash
[vagrant@linuxnodes ~]$ sudo mdadm /dev/md0 --fail /dev/sde
mdadm: set /dev/sde faulty in /dev/md0
[vagrant@linuxnodes ~]$ sudo cat /proc/mdstat
Personalities : [raid10] 
md0 : active raid10 sdf[4] sde[3](F) sdd[2] sdc[1] sdb[0]
      634880 blocks super 1.2 512K chunks 2 near-copies [5/4] [UUU_U]
      
unused devices: <none>
[vagrant@linuxnodes ~]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Sun Jan 15 12:55:15 2023
        Raid Level : raid10
        Array Size : 634880 (620.00 MiB 650.12 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 5
     Total Devices : 5
       Persistence : Superblock is persistent

       Update Time : Sun Jan 15 13:11:21 2023
             State : clean, degraded 
    Active Devices : 4
   Working Devices : 4
    Failed Devices : 1
     Spare Devices : 0

            Layout : near=2
        Chunk Size : 512K

Consistency Policy : resync

              Name : linuxnodes:0  (local to host linuxnodes)
              UUID : 9df6abc3:45e175b6:81cc4648:389d6700
            Events : 19

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync   /dev/sdb
       1       8       32        1      active sync   /dev/sdc
       2       8       48        2      active sync   /dev/sdd
       -       0        0        3      removed
       4       8       80        4      active sync   /dev/sdf

       3       8       64        -      faulty   /dev/sde
[vagrant@linuxnodes ~]$ sudo mdadm /dev/md0 --remove /dev/sde
mdadm: hot removed /dev/sde from /dev/md0
[vagrant@linuxnodes ~]$ sudo mdadm /dev/md0 --add /dev/sde
mdadm: added /dev/sde
[vagrant@linuxnodes ~]$ cat /proc/mdstat
Personalities : [raid10] 
md0 : active raid10 sde[5] sdf[4] sdd[2] sdc[1] sdb[0]
      634880 blocks super 1.2 512K chunks 2 near-copies [5/5] [UUUUU]
      
unused devices: <none>

```

## Задача 4 - прописать собранный рейд в конф, чтобы рейд собирался при загрузке

```bash
[vagrant@linuxnodes ~]$ sudo mdadm --detail --scan --verbose
ARRAY /dev/md0 level=raid10 num-devices=5 metadata=1.2 name=linuxnodes:0 UUID=9df6abc3:45e175b6:81cc4648:389d6700
   devices=/dev/sdb,/dev/sdc,/dev/sdd,/dev/sde,/dev/sdf

[vagrant@linuxnodes ~]$ sudo mkdir /etc/mdadm
[vagrant@linuxnodes ~]$ sudo echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
[vagrant@linuxnodes ~]$ sudo mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

[vagrant@linuxnodes ~]$ cat /etc/mdadm/mdadm.conf
DEVICE partitions
ARRAY /dev/md0 level=raid10 num-devices=5 metadata=1.2 name=linuxnodes:0 UUID=9df6abc3:45e175b6:81cc4648:389d670
```

## Задача 5 - создать GPT раздел и 5 партиций

```bash
#Создаем раздел GPT на RAID
[vagrant@linuxnodes ~]$ sudo parted -s /dev/md0 mklabel gpt

#Создаем партиøии
[vagrant@linuxnodes ~]$ sudo parted /dev/md0 mkpart primary ext4 0% 20%
[vagrant@linuxnodes ~]$ sudo parted /dev/md0 mkpart primary ext4 20% 40%
[vagrant@linuxnodes ~]$ sudo parted /dev/md0 mkpart primary ext4 40% 60%
[vagrant@linuxnodes ~]$ sudo parted /dev/md0 mkpart primary ext4 60% 80%
[vagrant@linuxnodes ~]$ sudo parted /dev/md0 mkpart primary ext4 80% 100%

#Далее можно создатþ на ÿтих партиøиāх ФС
[vagrant@linuxnodes ~]$ sudo for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done

#И смонтироватþ их по каталогам
[vagrant@linuxnodes ~]$ sudo mkdir -p /raid/part{1,2,3,4,5}
[vagrant@linuxnodes ~]$ sudo for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done

[vagrant@linuxnodes ~]$ lsblk
NAME                    MAJ:MIN RM   SIZE RO TYPE   MOUNTPOINT
sda                       8:0    0   128G  0 disk   
├─sda1                    8:1    0     1G  0 part   /boot
└─sda2                    8:2    0   127G  0 part   
  ├─centos_centos7-root 253:0    0   125G  0 lvm    /
  └─centos_centos7-swap 253:1    0     2G  0 lvm    [SWAP]
sdb                       8:16   0   250M  0 disk   
└─md0                     9:0    0   620M  0 raid10 
  ├─md0p1               259:1    0 122,5M  0 md     /raid/part1
  ├─md0p2               259:4    0 122,5M  0 md     /raid/part2
  ├─md0p3               259:5    0   125M  0 md     /raid/part3
  ├─md0p4               259:8    0 122,5M  0 md     /raid/part4
  └─md0p5               259:9    0 122,5M  0 md     /raid/part5
sdc                       8:32   0   250M  0 disk   
└─md0                     9:0    0   620M  0 raid10 
  ├─md0p1               259:1    0 122,5M  0 md     /raid/part1
  ├─md0p2               259:4    0 122,5M  0 md     /raid/part2
  ├─md0p3               259:5    0   125M  0 md     /raid/part3
  ├─md0p4               259:8    0 122,5M  0 md     /raid/part4
  └─md0p5               259:9    0 122,5M  0 md     /raid/part5
sdd                       8:48   0   250M  0 disk   
└─md0                     9:0    0   620M  0 raid10 
  ├─md0p1               259:1    0 122,5M  0 md     /raid/part1
  ├─md0p2               259:4    0 122,5M  0 md     /raid/part2
  ├─md0p3               259:5    0   125M  0 md     /raid/part3
  ├─md0p4               259:8    0 122,5M  0 md     /raid/part4
  └─md0p5               259:9    0 122,5M  0 md     /raid/part5
sde                       8:64   0   250M  0 disk   
└─md0                     9:0    0   620M  0 raid10 
  ├─md0p1               259:1    0 122,5M  0 md     /raid/part1
  ├─md0p2               259:4    0 122,5M  0 md     /raid/part2
  ├─md0p3               259:5    0   125M  0 md     /raid/part3
  ├─md0p4               259:8    0 122,5M  0 md     /raid/part4
  └─md0p5               259:9    0 122,5M  0 md     /raid/part5
sdf                       8:80   0   250M  0 disk   
└─md0                     9:0    0   620M  0 raid10 
  ├─md0p1               259:1    0 122,5M  0 md     /raid/part1
  ├─md0p2               259:4    0 122,5M  0 md     /raid/part2
  ├─md0p3               259:5    0   125M  0 md     /raid/part3
  ├─md0p4               259:8    0 122,5M  0 md     /raid/part4
  └─md0p5               259:9    0 122,5M  0 md     /raid/part5

[vagrant@linuxnodes ~]$ df -h
Файловая система                Размер Использовано  Дост Использовано% Cмонтировано в
devtmpfs                          484M            0  484M            0% /dev
tmpfs                             496M            0  496M            0% /dev/shm
tmpfs                             496M          13M  483M            3% /run
tmpfs                             496M            0  496M            0% /sys/fs/cgroup
/dev/mapper/centos_centos7-root   125G         1,7G  124G            2% /
/dev/sda1                        1014M         131M  884M           13% /boot
/dev/md0p1                        115M         1,6M  105M            2% /raid/part1
/dev/md0p2                        115M         1,6M  105M            2% /raid/part2
/dev/md0p3                        118M         1,6M  107M            2% /raid/part3
/dev/md0p4                        115M         1,6M  105M            2% /raid/part4
/dev/md0p5                        115M         1,6M  105M            2% /raid/part5
tmpfs                             100M            0  100M            0% /run/user/1000
```


## Дополнительное задание
Vagrantfile, который сразу собирает систему с подключенным рейдом и смонтированными разделами. После перезагрузки стенда разделы должны автоматически примонтироваться.

[Vagrantfile](./Vagrantfile)


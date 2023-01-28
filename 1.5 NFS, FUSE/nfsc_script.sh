#!/bin/bash

yum install -y nfs-utils

# включаем firewall и проверяем, что он работает
systemctl enable firewalld --now
systemctl status firewalld

# добавляем в __/etc/fstab__ строку_
echo "192.168.60.10:/srv/share/ /mnt nfs vers=3,proto=udp,noauto,x-systemd.automount 0 0" >> /etc/fstab

# перегружаем демон systemd и remote-fs
systemctl daemon-reload
systemctl restart remote-fs.target

# Отметим, что в данном случае происходит автоматическая генерация systemd units в каталоге `/run/systemd/generator/`, которые производят монтирование при первом обращении к каталогу `/mnt/`

# проверяем успешность монтирования
mount | grep mnt

# проверяем чтение с NFS-сервера
cat /mnt/upload/check_file

# проверяем запись на NFS-сервер
echo "NFS write check - OK!" > /mnt/upload/check_file
cat /mnt/upload/check_file
rm /mnt/upload/check_file

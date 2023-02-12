#!/bin/bash

yum install -y nfs-utils

# включаем firewall и проверяем, что он работает
systemctl enable firewalld --now
systemctl status firewalld

# разрешаем в firewall доступ к сервисам NFS
firewall-cmd --add-service="nfs3" \
--add-service="rpc-bind" \
--add-service="mountd" \
--permanent
firewall-cmd --reload

# включаем сервер NFS (для конфигурации NFSv3 over UDP он не требует дополнительнойнастройки, однако вы можете ознакомиться с умолчаниями в файле __/etc/nfs.conf__)
systemctl enable nfs --now

# создаём и настраиваем директорию, которая будет экспортирована в будущем
mkdir -p /srv/share/upload
chown -R nfsnobody:nfsnobody /srv/share
chmod 0777 /srv/share/upload

# создаём в файле __/etc/exports__ структуру, которая позволит экспортировать ранее созданную директорию
cat << EOF > /etc/exports
/srv/share 192.168.60.11/32(rw,sync,root_squash)
EOF

# экспортируем ранее созданную директорию
exportfs -r

# проверяем экспортированную директорию следующейкомандой
exportfs -s

# содздадим фал для проверки на клиенте
echo "NFS read check - OK!" > /srv/share/upload/check_file
chmod 0777 /srv/share/upload/check_file
#!/bin/bash

# Обновление и очистка всех ненужных пакетов
sudo yum update -y
sudo yum clean all


# Добавление ssh-ключа для пользователя vagrant
mkdir -pm 700 /home/vagrant/.ssh
curl -sL https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub -o /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh


# Удаление временных файлов
sudo rm -rf /tmp/*
rsudo m  -f /var/log/wtmp /var/log/btmp
sudo rm -rf /var/cache/* /usr/share/doc/*
sudo rm -rf /var/cache/yum
sudo rm -rf /vagrant/home/*.iso
rm  -f ~/.bash_history
history -c

sudo rm -rf /run/log/journal/*
sync
sudo grub2-set-default 0
sudo echo "###   Hi from second stage" >> /boot/grub2/grub.cfg

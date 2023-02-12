# Домашнее задание к занятию 10 - 11 "Bash, Grep sed, awk и другие."


## Описание домашнего задания

Написать скрипт для CRON, который раз в час будет формировать письмо и отправлять на заданную почту.
Необходимая информация в письме:
- Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
- Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта;
- Ошибки веб-сервера/приложения c момента последнего запуска;
- Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта.
- Скрипт должен предотвращать одновременный запуск нескольких копий, до его завершения.
- В письме должен быть прописан обрабатываемый временной диапазон.

---


## Написать скрипт для CRON, который раз в час будет формировать письмо и отправлять на заданную почту.

[bash скрипт](./log_parcer.sh) с требуемым функционалом и комментариями.    

Пример записи в crotab:    

```shell
0 * * * * /home/vagrant/log_parcer.sh /var/log/nginx/access.log 10
```

---

Информационные материлы по заданию:    
[Презентация "Bash"](./presentation.pdf)    
[Презентация Grep sed, awk и другие](./Sed_Grep_AWK.pdf)  
https://www.opennet.ru/docs/RUS/bash_scripting_guide/    
https://www.opennet.ru/docs/RUS/awk/    
https://www.pement.org/awk/awk1line.txt    
https://habr.com/ru/post/114156/     
https://habr.com/ru/company/ruvds/blog/325522/    
https://help.ubuntu.ru/wiki/bash    
https://linuxconfig.org/learning-linux-commands-sed    
https://tldp.org/LDP/Bash-Beginners-Guide/html/    
https://gitlab.com/otus_linux/stands-05-bash    
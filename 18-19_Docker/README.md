# Домашнее задание к занятию 18-19 "Docker"


## Описание домашнего задания

Основное задание:    
Написать Dockerfile на базе apache/nginx который будет содержать две статичные web-страницы на разных портах. Например, 80 и 3000.    
  - Пробросить эти порты на хост машину. Обе страницы должны быть доступны по адресам localhost:80 и localhost:3000    
  - Добавить 2 вольюма. Один для логов приложения, другой для web-страниц.    

Дополнительное задание:     
Написать Docker-compose для приложения Redmine, с использованием опции build.    
  - Добавить в базовый образ redmine любую кастомную тему оформления.    
  - Убедиться что после сборки новая тема доступна в настройках.    

---


## Основное задание

[Dockerfile](./nginx/Dockerfile)

Использование:    
```bash
cd nginx
docker build -t 0dok0/nginx .
docker run -d -p 3000:3000 -p 8080:80 -v ${PWD}/html:/usr/share/nginx/html:ro -v ${PWD}/logs:/var/log/nginx --name nginx 0dok0/nginx
```
На хостовую проброшен 8080, т.к. 80 не было возможности в момент выполнения освободить.


## Дополнительное задание     

[Dockerfile](./redmine/Dockerfile)    
[docker-compose file](./redmine/docker-compose.yml)

Использование:    
```bash
# Запуск с пребилдом
docker-compose up -d

# Для обновления
docker-compose build  
docker-compose restart
```

---

Информационные материлы по заданию:    

[Презентация 1](./Docker_1.pdf)    
[Презентация 2](./Docker_2.pdf)    

# Mover instalation guide


Инструкция по установке клиентской части ingest mover на ubuntu
```
cd /opt
sudo git clone https://github.com/jidckii/mover.git
```
Создаем пользователя с нужным именем,
к примеру:
```
sudo adduser mover
```
создать симлинку для PATH
```
sudo ln -s /opt/mover/bin/mover /usr/local/sbin/mover
```
Дать права на исполнение
```
sudo chmod +x /opt/mover/bin/mover
```
запускать
 ```
mover
```

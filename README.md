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

назначить правильные права на рабочий каталог
```
sudo chmod -R 2775 /opt/mover/tmp
sudo chown -R mover:mover /opt/mover/tmp
sudo chmod -R 2775 /opt/mover/log
sudo chown -R mover:mover /opt/mover/log
```
создать симлинку для PATH

```
sudo ln -s /opt/mover/bin/mover /usr/local/sbin/mover
```
Дать права на исполнение
```
sudo chmod +x /opt/mover/bin/mover
```

# Для работы в режиме демона при этом с возможностью обрятной связи для инджестера запускать с параметрами:
 
 ```
/usr/local/sbin/mover >> /opt/mover/log/daemon.log 2>&1 &
```
читать вывод 
```
tail -f /opt/mover/log/daemon.log
```
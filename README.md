# Mover instalation guide

Инсталяция ingest-mover
(изначально нужно установить и настроить host ingest-transcoder)

Устанавливаем последнюю LTS desktop ubuntu
при установке указываем пользователя dcadmin

после установки сразу обновляем ос и доустанавливаем нужный софт
```
sudo apt-get update && sudo apt-get upgrade -y \
&& sudo apt-get install -y aptitude curlftpfs mediainfo \
vlc cifs-utils dconf-editor git vim ssh htop expect caffeine
```
если ubuntu 14.04, то caffeine ставится так:
```
sudo add-apt-repository ppa:caffeine-developers/ppa
sudo apt-get update
sudo apt-get install caffeine libappindicator3-1 gir1.2-appindicator3-0.1 
```
в настройках создаем обчного пользователя(не администратора) mover

логинимся под домашним пользователем, создаем нужный для кдаленного монтирвания каталог
```
sudo su mover
cd
mkdir /home/mover/queue-video-tmp/
```
добавляем в файл .bash_aliases строку
```
touch /home/mover/.bash_aliases
echo "alias mover='/opt/mover/bin/mover'" | tee -a /home/mover/.bash_aliases
ssh-keygen
scp .ssh/id_rsa.pub transcoder@ingest-transcoder.otv.loc:~/.ssh/authorized_keys
exit
```
дописываем в файл /etc/fstab строку для монтирования по ftp удаленного каталога
(естественно изначально нужно установить и настроить host ingest-transcoder)
```
echo "curlftpfs#ftp://transcoder:transcoder@ingest-transcoder.otv.loc/queue-video-tmp/ /home/mover/queue-video-tmp/ fuse rw,allow_other,auto,user,uid=mover,gid=mover 0 0" | sudo tee -a /etc/fstab
sudo mount -a 
```
проверяем, что каталог смонтировался 
```
df -h

Устанавливаем программу анализа и копирования видео с SD
```
git clone https://github.com/jidckii/mover.git
sudo cp -R  mover /opt/
reboot
```

Логинимся под mover
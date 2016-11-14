#!/bin/bash

# set -x

log_daemon=/opt/mover/log/daemon.log

end_dir=/home/transcoder/queue-video-tmp/
mediapath=/media

text1="Обнаружен USB носитель, с данными объемом "
text2="USB носитель отсутствует"
text3="видео файлов."
text4="Введите ИМЯ для видео материала:"
text5="Отсутствует видео в формате .MP4 или .MTS , проверьте USB носитель на PC"
text6="Копирование завершено, извлеките USB носитель !!!"
wait_copy="Идет копирование, не извлекайте SD карту! ..."
err_enter="Вы не ввели имя, повторить поиск ?"
err_copy="Ошибка при копировании, повторить поиск ?"

to_copy(){
      find $mediapath -name "$1" -print0 | \
      xargs -0 -I% rsync -a % transcoder@172.20.0.10:$end_dir$dir_name/ | \
      zenity --progress --pulsate --title="Копирование" --text="$wait_copy" \
      --auto-close --auto-kill
}

# Заходим в цикл и работаем как бы в режиме демона
while true; do
  sleep 5
  usbsizenum=$(du -s $mediapath | awk '{print $1}')
  usbsizehum_num=$(du -s -h $mediapath | awk '{print $1}')

  # Если размер каталога меньше 1 мегабайта, начинаем цикл заново.
  if [ "$usbsizenum" -lt "1000" ]; then
    continue
  fi

  echo -e '\n' "\e[0;32m $text1 \e[1;95m $usbsizehum_num \e[0m" '\n'
  worklist=$(find $mediapath -name *.MTS -o -name *.MP4 | wc -l)

  # Если файлов в формате по маске не обнаружено, начинаем цикл заново.
  if [ "$worklist" -eq "0" ]; then
    echo -e '\n' "\e[0;31m $text5 \e[0m" '\n'
    continue
  fi

  if [ "$worklist" -gt "0" ]; then
    echo -e '\n' "\e[0;32m Найдено \e[1;95m $worklist \e[0;32m $text3 \e[0m" '\n'
    # echo -e '\n' "\e[1;33m $text4 \e[0m" '\n'
    dir_name=$(zenity --entry --title="Ввод имени" --text="$text4")

    if [ -z "$dir_name" ]; then
      zenity --error --title="Ошибка" --text="$err_enter"
      continue
    fi
  fi
    dir_name=$(echo -n $dir_name | sed 's/ /_/g')
    echo -e '\n' "\e[1;31m Введено имя: $dir_name \e[0m" '\n'
    echo -e '\n' "\e[1;32m $wait_copy \e[0m" '\n'
    # zenity --error --title="Инфо" --text="$text7"

    worklist=$(find $mediapath -name *.MTS -o -name *.MP4 | awk -F. '{print $NF}' | sed -n -e 1p)
    if [ "$worklist" = "MP4" ]; then
    to_copy "*.MP4"
      if [[ "$?" -ne 0 ]]; then
        zenity --error --title="Ошибка" --text="$err_copy"
        continue
      fi
    elif [ "$worklist" = "MTS" ]; then
      to_copy "*.MTS"
      # wait $pid
      if [[ "$?" -ne 0 ]]; then
        zenity --error --title="Ошибка" --text="$err_copy"
        continue
      fi
    fi

  echo -e '\n' "\e[4;32m $text6 \e[0m" '\n'
  sleep 5
  usbsizeend=`du -s $mediapath | awk '{print $1}'`

  # ждем извлечения USB.
  while [ "$usbsizeend" -eq "$usbsizenum" ]; do
    sleep 2
    usbsizeend=$(du -s $mediapath | awk '{print $1}')

    if [ "$usbsizeend" -ne "$usbsizenum" ];  then
      echo -e '\n' "\e[1;96m $text2 \e[0m" '\n'
      break
    fi
  done
done

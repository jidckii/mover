#!/bin/bash

# set -x

DATE_DAY=$(date +%Y-%m-%d)
LOG=~/Документы/mover_$DATE_DAY.log
# END_DIR=/home/emedvedev/queue-video-tmp/  # dev path
# SYNC_TARGET=${SYNC_TARGET:-"emedvedev@172.20.0.10"}   # dev path

END_DIR=/home/transcoder/queue-video-tmp/
MEDIAPATH=/media
SYNC_TARGET=${SYNC_TARGET:-"transcoder@172.20.0.10"}

ENTER_WINDOW_STR1="видео обнаружено"
ENTER_WINDOW_STR2="объемом"
ENTER_WINDOW_STR3="Введите ИМЯ для видео материала в формате:"
ENTER_WINDOW_STR4="(кто где когда сегодняшняя дата исх)"
ENTER_WINDOW_STR5="пример: представление главы ЖД района 1411 исх"
ENTER_WINDOW_STR6="ЗАПРЕЩЕН ВВОД СПЕЦСИМВОЛОВ !!!"

# text1="Обнаружен USB носитель, с данными объемом "
# EXIT_USB="USB носитель отсутствует"
# text3="видео файлов."

EXIT_MSG="Копирование завершено, извлеките USB носитель !!!"
WAIT_COPY="Идет копирование, не извлекайте SD карту! ..."
ERR_ENTER="Вы не ввели имя, повторить поиск ?"
ERR_COPY="Ошибка при копировании, повторить поиск ?"
ERR_FIND="Отсутствует видео в формате .MP4 или .MTS , проверьте USB носитель на PC"
ERR_MSG="Операция отменена, приостановлена или завершилась ошибкой. \
Проверьте USB носитель на PC, если произошла ошибка! \
Продолжить работу ?"

to_copy(){
      find $MEDIAPATH -name "$1" -print0 | \
      xargs -0 -I% rsync -a % $SYNC_TARGET:$END_DIR$DIR_NAME.$END_FORMAT/ | \
      zenity --progress --no-cancel --pulsate --title="Копирование" \
      --text="Копируется $DIR_NAME \n $WAIT_COPY" --auto-close --auto-kill
      if [[ "$?" -ne 0 ]]; then
        zenity_err $ERR_COPY
        sander "Операция отменена"
        log_info "Операция отменена"
        return 1
      fi
}

log_info() {
  echo -e "$DATE ----> $*" >> $LOG 2>&1
}

zenity_err(){
  log_info "$*"
  zenity --error --title="Ошибка" --text="$*"
}

zenity_info(){
  zenity --info --title="Внимание" --text="$*"
}

zenity_selection_format(){
  zenity --list --radiolist --title="Выбор конечного формата" \
  --text="Выберите тип конечного формата который попадет DALET" \
  --column="Отметка выбора" --column="Конечный формат" TRUE "SD_4:3" FALSE "FHD_16:9"
}

zenity_sleep(){
  zenity --progress --pulsate --no-cancel --title="Поиск" --text="Вставьте SD карту!" & SLEEP_PID=$!
}


sander(){
  notify-send -i /opt/mover/mover.jpg -t 50 "УВЕДОМЛЕНИЕ" "$*"
}

worker(){
  kill -15 $SLEEP_PID
  worklist=$(find $MEDIAPATH -name *.MTS -o -name *.MP4 | wc -l)

  # Если файлов в формате по маске не обнаружено, начинаем цикл заново.
  if [ "$worklist" -eq "0" ]; then
    zenity_err $ERR_FIND
    return 1
  fi

  if [ "$worklist" -gt "0" ]; then
    DIR_NAME=$(zenity --entry --title="Ввод имени" --text="$worklist  $ENTER_WINDOW_STR1 $ENTER_WINDOW_STR2 \
    $usbsizehum_num \n $ENTER_WINDOW_STR3 \n $ENTER_WINDOW_STR4 \n $ENTER_WINDOW_STR5 \n $ENTER_WINDOW_STR6")

    END_FORMAT=$(zenity_selection_format | awk -F_ '{print $1}')
    log_info $worklist $ENTER_WINDOW_STR1 $usbsizehum_num

    if [ -z "$DIR_NAME" ]; then
      zenity_err $ERR_ENTER
      if [[ "$?" -ne 0 ]]; then
        return 1
      fi
      continue
    fi
  fi

  DIR_NAME=$(echo -n $DIR_NAME | sed 's/ /_/g')
  sander "Введено имя:" $DIR_NAME
  log_info "Введено имя:"" $DIR_NAME"
  log_info $END_FORMAT

  FORMAT=$(find $MEDIAPATH -name *.MTS -o -name *.MP4 | awk -F. '{print $NF}' | sed -n -e 1p)

  if [ "$FORMAT" = "MP4" ]; then
    to_copy "*.MP4"
    if [[ "$?" -ne 0 ]]; then
      log_info $ERR_COPY
      return 1
    fi
  elif [ "$FORMAT" = "MTS" ]; then
    to_copy "*.MTS"
    if [[ "$?" -ne 0 ]]; then
      log_info $ERR_COPY
      return 1
    fi
  fi
  log_info $EXIT_MSG
  sander $DIR_NAME $worklist "видео скопированно." $EXIT_MSG
  zenity_info $DIR_NAME $worklist "видео скопированно." $EXIT_MSG
}

zenity_sleep

while kill -0 $SLEEP_PID; do
  sleep 1
  DATE_DAY=$(date +%Y-%m-%d)
  DATE=$(date +%Y-%m-%dT%T%Z)
  usbsizenum=$(du -s $MEDIAPATH | awk '{print $1}')
  usbsizehum_num=$(du -s -h $MEDIAPATH | awk '{print $1}')

  # Если размер каталога меньше 1 мегабайта, начинаем цикл заново.
  if [ "$usbsizenum" -lt "1000" ]; then
    continue
  fi

  worker
  if [[ "$?" -ne 0 ]]; then
    zenity_err $ERR_MSG
    continue
  fi
  usbsizeend=$(du -s $MEDIAPATH | awk '{print $1}')

  # ждем извлечения USB.
  while [ "$usbsizeend" -eq "$usbsizenum" ]; do
    sleep 1
    usbsizeend=$(du -s $MEDIAPATH | awk '{print $1}')
    if [ "$usbsizeend" -ne "$usbsizenum" ];  then
      sander $DIR_NAME "скопированно"
      zenity_sleep
      sleep 1
      break
    fi
    zenity_info $EXIT_MSG
  done
done

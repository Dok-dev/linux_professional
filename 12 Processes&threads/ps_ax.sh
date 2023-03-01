#!/bin/sh

# Вывод шапки
echo -e "PID TTY\\tSTAT\\tTIME\\tCOMMAND"

# Замерим ширину икрана для корректировки вывода
let "screen_wide=$(tput cols) - 32"

# Просматриваем все числовые папки в proc с сортировкой типа версионирования
for pid_dir in $( ls -dv /proc/[0-9]* )
do
  if [ -f ${pid_dir}/stat ]; then
    pid="$( awk '{print $1}' ${pid_dir}/stat )"

    status="$( awk '{print $3}' ${pid_dir}/stat )"

    # Столбец TIME это суммарное время 14, 15, 16 и 17 показателей /proc/[pid]/stat
    time="$( cat ${pid_dir}/stat | rev | awk '{print $36" "$37" "$38" "$39}' | rev | awk '{sum=$1+$2+$3+$4}END{print sum/100}' | awk '{("date +%M:%S -d @"$1) | getline $1}1' )"
    
    # Проверим есть ли данные в файле cmdline
    if [[ $( cat ${pid_dir}/cmdline | wc -c ) > 0 ]]; then
      # тут понадобилось удалить null byte и ограничить длину вывода шириной экрана
      cmd="$( tr -d '\0' < ${pid_dir}/cmdline | cut -c1-${screen_wide} )"
    else
      # Если данных нет то берем из stat
      cmd="$( awk '{print $2}' ${pid_dir}/stat | sed -e 's/(/[/' -e 's/)/]/' )"
    fi
  fi
  
  # Проверим существует ли симлинк на для терминала в нулевом файловом дескрипторе процесса
  if [ -L ${pid_dir}/fd/0 ]; then
    tty="$( ls -l ${pid_dir}/fd/0 | awk '{print $11}' | cut -d/ -f3,4 )"
    if [[ ! "$tty" =~ "/" ]]; then
      tty='?' 
    fi
  else
    tty='?'
  fi
  
  # Формируем вывод если есть pid
  test "$pid" != "" && echo -e "  $pid ${tty}\\t${status}\\t${time}\\t${cmd}"

done


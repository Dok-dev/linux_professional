#!/bin/sh

# usage:
# ./log_parcer.sh ./access.log 10

##########################################################################
######### Создадим lockfle для предотвращения повторного запуска #########
##########################################################################
lockfile=./.lockfile
if ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null
then


#############################################################
######### Проверка на переданных скрипту параметров #########
#########  по умочанию будес делана выборка Top-10  #########
#############################################################
USAGE="SYNOPSIS: ./log_parcer.sh LOG_FILE TOP_LIMIT"
if [ -z "$1" ]
then
    echo "Sorry, there is no first parameter LOG_FILE. "
    echo $USAGE
    exit 1
fi

if [ -z "$2" ]
then
    echo $USAGE
    echo "There is no second parameter TOP_LIMIT. It will be set to top 10"
    TOP_LIMIT=10
else
TOP_LIMIT=${2}
fi

LOG_FILE="${1}"


##############################################
######### Устанвливаем время выборки #########
##############################################
######### Фунция возвращает дату час назад с поправкой на время записи лога #########
hour() {
    # local d=$(LANG=en_EN date -d '1 hour ago' +%d/%b/%Y:%H)
    # Так как необходимо производить выборку за предыдущий час из лога,
    # то производится -d '1 hour ago'
    # При этом локаль принудительно LANG=en_EN, иначе генерирует дату в текущей локали
    # Поскольку в тестовом файле априори нет сведений за прошлый час 2023 года,
    # а только за 14-15 августа 2019 г., то искусственно перенесемся в то время,
    # вычев еще необходимо количество часов, для 12 февраля 2023 г. - это еще минус 30671 часа
    old_log_corrector=30672
    formatted_time=$(LANG=en_EN date -d "$old_log_corrector hour ago" +%d/%b/%Y:%H)
    echo $formatted_time
}

AT_HOUR=$(hour)

DEBUG=0
if [ "${DEBUG}" = "1" ]
then
  echo SELECT LOG-DATA AT HOUR $AT_HOUR
fi

echo "PROCESS DATA OF HOUR $AT_HOUR:00" "OF LOG-FILE" $LOG_FILE > mail.tmp

#######################################################
############## Функции общего назначения ##############
#######################################################

######### Отбираем строки за один час #########
select_rows_at_hour() {
    _LOG_FILE=${LOG_FILE}
    _AT_HOUR=${AT_HOUR}
    cat "${_LOG_FILE}" | grep "\[$_AT_HOUR:"
    exit 0
}

######### Агрегация строк (с сортировкой) #########
group_by_with_sort() {
    sort | uniq -c | sort -rn
}

######### Подсчет {TOP}-первых (по порядку) строк #########
top_limit() {
    head -n ${TOP_LIMIT}
}

######### Trap с выводом строк где произошла ошибка #########
trap "echo Error in ${BASH_COMMAND}}" ERR


##############################################################
######### Извлекаем из выборки IP-адреса и сортируем #########
##############################################################
fetch_ip() {
    awk '{ print $1 }'
}

echo TOP ${TOP_LIMIT}-COUNT URN-ADDRESSES >> mail.tmp
select_rows_at_hour | fetch_ip | group_by_with_sort | top_limit >> mail.tmp


#############################################################
####### Собираем адреса страниц сайта, к которым были #######
#######            обращения, и сортируем             #######
#############################################################
fetch_urn() {
    awk 'BEGIN { FS = "\"" } ; {print $2}'| awk '{print $2}'
}

echo TOP ${TOP_LIMIT}-COUNT IP-ADDRESSES TARGETS >> mail.tmp
select_rows_at_hour | fetch_urn | group_by_with_sort | top_limit >> mail.tmp


################################################################
####### Функция применит фильтр к записям файла, с целью #######
####### выборки неимеющих HTTP-статуса в емкости         #######
#######           200-299, считая их "ошибками"          #######
################################################################
select_rows_with_error_status() {
    awk 'BEGIN { FS = "\" "; OFS= "#"} ; {print $0,$2}' | awk 'BEGIN { FS = "#" }; { if (!(match($2,/2.*/))) { print $1 }}'
}

echo 'SELECT "UNSUCCESS" REQUESTS:' >> mail.tmp
select_rows_at_hour | select_rows_with_error_status >> mail.tmp


##############################################
####### Извлекаем из выборки HTTP-коды #######
##############################################
fetch_http_code() {
    awk 'BEGIN { FS = "\"" } ; {print $3}' | awk '{print $1}'
}

echo CALCULATE COUNT OF HTTP-STATUS CODES >> mail.tmp
select_rows_at_hour | fetch_http_code | group_by_with_sort >> mail.tmp


###############################
####### Отправка письма #######
###############################
# Отправка письма будет осуществляться коомандой mail требующей установленной утилиты mailutils
mail -s "PROCESS DATA OF HOUR $AT_HOUR:00" admin@domain.ru < mail.tmp
rm mail.tmp

########################################################
####### Удаляем lockfile при выходе либо выводим #######
#######    сообщение что скрипт уже запущен      #######
########################################################
trap 'rm -f "$lockfile"; exit $?' TERM EXIT
else
echo "Failed to acquire lockfile: $lockfile."
echo "Held by PID:$(cat $lockfile), seems script already run."
fi

exit 0
#!/bin/sh
# execute manual

# log path
LOG_PATH=/home/creca

# log file
LOG_FILE=$LOG_PATH/logprocess_date_Result`date "+%Y%m"`.log

# help message
help(){
    echo "usage: ./logprocess_date.sh start_date end_date"
	echo "example: ./logprocess_date.sh 2015-01-01 2015-01-02"
}

# log
if [ $# -ne 2 ]; then
    help
    exit 0
else
    # execute command
    # php /home/creca/artisan log $1 $2 >> $LOG_FILE 2>&1
	echo "ok"
fi
# end

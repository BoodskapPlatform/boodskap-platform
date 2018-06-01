#!/bin/sh
SERVICE_NAME=boodskap
BASE_PATH=$HOME
PID_PATH_NAME=$HOME/${SERVICE_NAME}.pid
LOG4J_CONF=file://$BASE_PATH/conf/log4j.properties
LOGBACK_CONF=file://$BASE_PATH/conf/logback.xml
MAIN_JAR=$BASE_PATH/lib/boodskap-all.jar

mkdir -p $HOME/logs
mkdir -p $HOME/tmp

OUT_FILE=$HOME/logs/system.out
LOG_FILE=$HOME/logs/boodskap.log


touch $OUT_FILE
touch $LOG_FILE

#DEBUG_ARGS="-Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=4000,suspend=y"
#LOG_ARGS="-Dlog4j.configuration=$LOG4J_CONF"
LOG_ARGS="-Dlogging.config=$LOGBACK_CONF"
MEM_ARGS="-Xms1g -Xmx1g"
JVM_ARGS="$DEBUG_ARGS $LOG_ARGS $MEM_ARGS -DBOODSKAP_HOME=$HOME -Djava.io.tmpdir=$HOME/tmp -Dkeyspace=complex -jar $MAIN_JAR"

case $1 in
    start)
        echo "Starting $SERVICE_NAME ..."
        if [ ! -f $PID_PATH_NAME ]; then
            rm -f $OUT_FILE
            echo java $JVM_ARGS
            nohup java $JVM_ARGS > $OUT_FILE 2>&1 &
            echo $! > $PID_PATH_NAME
            echo "$SERVICE_NAME started ..."
            timeout 20 tail -f $OUT_FILE
        else
            echo "$SERVICE_NAME is already running ..."
        fi
    ;;
    stop)
        if [ -f $PID_PATH_NAME ]; then
            PID=$(cat $PID_PATH_NAME);
            echo "$SERVICE_NAME stoping ..."
            kill $PID
            timeout 8 tail -f $OUT_FILE
            (kill -9 $PID 2>&1) >/dev/null
            rm -f $PID_PATH_NAME
        else
            echo "$SERVICE_NAME is not running ..."
        fi
    ;;
esac

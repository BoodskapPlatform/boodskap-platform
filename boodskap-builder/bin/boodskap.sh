#!/bin/sh
SERVICE_NAME=boodskap
BASE_PATH=$HOME
PID_PATH_NAME=$HOME/${SERVICE_NAME}.pid
LOG4J_CONF=file://$BASE_PATH/conf/log4j.properties
MAIN_JAR=$BASE_PATH/lib/boodskap-all.jar

mkdir -p $HOME/logs

OUT_FILE=$HOME/logs/system.out
LOG_FILE=$HOME/logs/boodskap.log


touch $OUT_FILE
touch $LOG_FILE

#DEBUG_ARGS="-Xdebug -Xrunjdwp:server=y,transport=dt_socket,address=4000,suspend=y"
JVM_ARGS="$DEBUG_ARGS -DBOODSKAP_HOME=$HOME -Xms1g -Xmx1g -Djava.io.tmpdir=$HOME/tmp -Dkeyspace=complex"

case $1 in
    start)
        echo "Starting $SERVICE_NAME ..."
        if [ ! -f $PID_PATH_NAME ]; then
            rm -f $OUT_FILE
            echo java $JVM_ARGS -Dlog4j.configuration=$LOG4J_CONF -jar $MAIN_JAR
            echo java $JVM_ARGS -Dlog4j.configuration=$LOG4J_CONF -jar $MAIN_JAR > $OUT_FILE 2>&1 &
            nohup java $JVM_ARGS -Dlog4j.configuration=$LOG4J_CONF -jar $MAIN_JAR > $OUT_FILE 2>&1 &
            echo $! > $PID_PATH_NAME
            echo "$SERVICE_NAME started ..."
        tail -f $OUT_FILE
        else
            echo "$SERVICE_NAME is already running ..."
        fi
    ;;
    stop)
        if [ -f $PID_PATH_NAME ]; then
            PID=$(cat $PID_PATH_NAME);
            echo "$SERVICE_NAME stoping ..."
            kill $PID
            sleep 10
            kill -9 $PID
            echo "$SERVICE_NAME stopped ..."
            rm -f $PID_PATH_NAME
        tail -f $OUT_FILE
        else
            echo "$SERVICE_NAME is not running ..."
        fi
    ;;
esac

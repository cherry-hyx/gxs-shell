#!/bin/sh
#
# Simple Redis init.d script conceived to work on Linux systems
# as it does use of the /proc filesystem.

REDIS_ROOT=/data/redis
EXEC=$REDIS_ROOT/bin/redis-server
EXECSEN=$REDIS_ROOT/bin/redis-sentinel
CLIEXEC=$REDIS_ROOT/bin/redis-cli

PIDFILEDIR=$REDIS_ROOT/run
CONFDIR=$REDIS_ROOT/conf

REDIS_PORTS="7379 7380"
SENTINEL_PORTS="26379"

case "$1" in
    start)
        for x in $REDIS_PORTS
        do
            CONF=$CONFDIR/redis${x}.conf
            REDIS_PORT=$(awk '/^port/ { print $2}' $CONF)
            REDIS_HOST=$(awk '/^bind/ { print $2}' $CONF)
            REDIS_AUTH=$(awk '/^requirepass/ { print $2}' $CONF)
            PIDFILE=`ps -ef | grep redis| grep $REDIS_HOST | grep $REDIS_PORT | grep -v grep | awk '{print $2}'`
            echo $PIDFILE
            if [ -n "$PIDFILE" ]
            then
                    echo "$PIDFILE exists, process is already running or crashed"
            else
                    echo "Starting Redis${x} server..."
                    $EXEC $CONF
            fi
        done
        for x in $SENTINEL_PORTS
        do
            CONF=$CONFDIR/sentinel${x}.conf
            REDIS_PORT=$(awk '/^port/ { print $2}' $CONF)
            REDIS_HOST=$(awk '/^bind/ { print $2}' $CONF)
            REDIS_AUTH=$(awk '/^requirepass/ { print $2}' $CONF)
            PIDFILE=`ps -ef | grep redis| grep $REDIS_HOST | grep $REDIS_PORT | grep -v grep | awk '{print $2}'`
            echo $PIDFILE
            if [ -n "$PIDFILE" ]
            then
                    echo "$PIDFILE exists, process is already running or crashed"
            else
                    echo "Starting sentinel${x} server..."
                    $EXECSEN $CONF --sentinel
            fi
        done
        ;;
    stop)
        for x in $SENTINEL_PORTS
        do
            CONF=$CONFDIR/sentinel${x}.conf
            REDIS_PORT=$(awk '/^port/ { print $2}' $CONF)
            REDIS_HOST=$(awk '/^bind/ { print $2}' $CONF)
            REDIS_AUTH=$(awk '/^requirepass/ { print $2}' $CONF)
            PIDFILE=`ps -ef | grep redis| grep $REDIS_HOST | grep $REDIS_PORT | grep -v grep | awk '{print $2}'`
            echo $PIDFILE
            if [ -z "$PIDFILE" ]
            then
                    echo "$PIDFILE does not exist, process is not running"
            else
                    echo "Stopping ..."
                    $CLIEXEC -a "$REDIS_AUTH" -h $REDIS_HOST -p $REDIS_PORT shutdown
                    echo "Redis stopped"
            fi
        done

        for x in $REDIS_PORTS
        do
            CONF=$CONFDIR/redis${x}.conf
            REDIS_PORT=$(awk '/^port/ { print $2}' $CONF)
            REDIS_HOST=$(awk '/^bind/ { print $2}' $CONF)
            REDIS_AUTH=$(awk '/^requirepass/ { print $2}' $CONF)
            PIDFILE=`ps -ef | grep redis| grep $REDIS_HOST | grep $REDIS_PORT | grep -v grep | awk '{print $2}'`
            echo $PIDFILE
            if [ -z "$PIDFILE" ]
            then
                    echo "$PIDFILE does not exist, process is not running"
            else
                    echo "Stopping ..."
                    $CLIEXEC -a "$REDIS_AUTH" -h $REDIS_HOST -p $REDIS_PORT shutdown
                    while [ -x /proc/${PIDFILE} ]
                    do
                        echo "Waiting for Redis${x} to shutdown ..."
                        sleep 1
                    done
                    echo "Redis stopped"
            fi
        done
        ;;
    *)
        echo "Please use start or stop as first argument"
        ;;
esac

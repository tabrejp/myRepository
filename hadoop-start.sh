#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Author: me
# Description: This script is used to start the hadoop service on this machine. Also same script can be used to stop the hadoop service.
# Run Command:
#   ksh -x hadoop-start.sh <start/stop>
# Parameter:
#   1. start: to start the hadoop service
#   2. stop: to stop the hadoop service
#
# Version Contorl:
# 8th Sep, 2018: Initial version
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

export HADOOP_HOME=/usr/local/hadoop/hadoop-2.7.3
export HIVE_HOME=/usr/local/hadoop/hive/apache-hive-2.1.1

echo ">>> Staring the script...!!!"
echo "Verifying the number of arguments passed."

# count the number of arguments passed while running the script
if [ $# -ne 1 ]; then
    echo "The number of argument passed is not correct. Please try again."
    exit
else
    echo "The number of argument passed is correct. Proceeding with Hadoop start/stop."
fi

#!-----------------------------------------------------Function Starts-----------------------------------------------------
#Need to check if Hadoop is already up and running. For this we will execute the JPS command and store the data in file.
#If hadoop is not running the JPS will results will be empty else it's running.
function isAliveHadoop {

export HADOOP_RESULT='/home/hdpuser/hadoop_result.txt'
export HADOOP_ALIVE=0

if [ -f $HADOOP_RESULT ]; then
    echo "$HADOOP_RESULT file exists"
else
    echo "$HADOOP_RESULT file does not exists. Creatingit now."

    `touch $HADOOP_RESULT`
    `chmod 755 $HADOOP_RESULT`
fi

#Run the jps command and collect the result sin HADOOP_RESULT file.
`jps > $HADOOP_RESULT`

COUNT=`cat $HADOOP_RESULT | wc -l`

if [ $COUNT -eq 1 ]; then
    #echo "Hadoop is not running"
    HADOOP_ALIVE=0
else
    #echo "Hadoop is running"
    HADOOP_ALIVE=1
fi
}
#!-----------------------------------------------------Function Ends-----------------------------------------------------

#?=============================================== Main Starts ===============================================
isAliveHadoop           #function call
echo $HADOOP_ALIVE

if [ $HADOOP_ALIVE -eq 0 ]; then   #This meand Hadoop is not working. Need to start.
    # Checking the first argument in the script. If it's start then the hadoop service will start.
    if [ $1 = "start" ] || [ $1 = "Start" ] || [ $1 = "START" ]; then
        echo "Starting Hadoop service"
        `$HADOOP_HOME/sbin/start-all.sh`
        isAliveHadoop
        #check if everything worked fine.
            if [ $HADOOP_ALIVE -eq 1 ]; then
                echo "Hadoop started successfully."
            else
                echo "Hadoop was not started successfully."
                exit
            fi
    else
        echo "Hadoop is not running. Do you want to start it?"
        echo "Please pass the \"start\" argument to start Hadoop."
        exit
    fi
elif [ $HADOOP_ALIVE -eq 1 ]; then   #This meand Hadoop is working. Need to stop.
    if [ $1 = "stop" ] || [ $1 = "Stop" ] || [ $1 = "STOP" ]; then
        echo "Stopping Hadoop service"
        `$HADOOP_HOME/sbin/stop-all.sh`
            #check if everything worked fine.
            isAliveHadoop
            if [ $HADOOP_ALIVE -eq 0 ]; then
                echo "Hadoop stopped successfully."
            else
                echo "Hadoop was not stopped successfully."
                exit
            fi
    else
        echo "Hadoop is already running. Do you want to stop it?"
        echo "Please pass the \"stop\" argument to stop Hadoop."
        exit
    fi
else
    echo "Invalid arguments"
    exit
fi
#?=============================================== Main Ends ===============================================

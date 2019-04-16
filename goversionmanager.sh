#!/bin/sh

#--------------------------------------------
#-This is go version manager script for Golang
#@@@ add by SinTan1071
#--------------------------------------------

PARENTDIR="/home/sintan1071"
ROOTDIR="/usr/local"
BINDIR="/usr/local/bin"
VAR=

[ -f /etc/init.d/functions ] && {
    . /etc/init.d/functions
} || {
    . $PARENTDIR/shell/functions
}

useGoEnv() {
    { nohup sh $GOLANDSH \
	1>$JETLOG \
   	2>&1 &
    } 
    return 0
}

listGoEnv() {
    { nohup sh $PYCHARMSH \
	1>$JETLOG \
        2>&1 &
    }
    return 0
}

installGoEnv() {
    if [ ! -n $VAR ]; then
        echo "you should input the golang version you want to install"
        return 0
    fi
    if [ -d $ROOTDIR/go$VAR ] && [ -f $BINDIR/go$VAR ]; then
        echo "you already have the go$VAR installed"
        return 0
    fi
    HTTPCODE=$(curl -i -m 10 -o /dev/null -s -w %{http_code} https://dl.google.com/go/go$VAR.linux-amd64.tar.gz)
    if [ $HTTPCODE -ne 200 ];then
        echo "no go$VAR is available"
        return 0
    fi
    echo "installing go$VAR...   "
    {
        wget --quiet --no-check-certificate https://dl.google.com/go/go$VAR.linux-amd64.tar.gz && \
        tar -C $ROOTDIR -xzf go$VAR.linux-amd64.tar.gz && \
        mv $ROOTDIR/go $ROOTDIR/go$VAR && \
        ln -s $ROOTDIR/go$VAR/bin/go $BINDIR/go$VAR
    } &
    POINTS='                                                  '
    PROCESS=$((1))
    SLEEPTIME=3
    while [ true ]; do
        echo -ne "\033[42;1m${POINTS:0:$(( $PROCESS/2 ))}\033[0m${POINTS:$(( $PROCESS/2 ))}$PROCESS%\r"
        if [ $PROCESS -eq  $((100)) ];then
            echo ''
            break
        fi
        if [ -d $ROOTDIR/go$VAR ] && [ -f $BINDIR/go$VAR ];then
            rm go$VAR.linux-amd64.tar.gz
            PROCESS=$(( $PROCESS + 1 ))
            SLEEPTIME=0.05
        fi
        if [ ! -d $ROOTDIR/go$VAR ] && [ $PROCESS -lt 73 ];then
            PROCESS=$(( $PROCESS + 1 ))
        fi
        sleep $SLEEPTIME
    done
    return 0
}

VAR=$2
case "$1" in
    use)
        useGoEnv || exit 1
        ;;
    ls)
        listGoEnv || exit 1
        ;;
    install)
        installGoEnv || exit 1
        ;;
    *)
        echo "Usage: $0 {use|ls|install}"
        exit 1
        ;;
esac

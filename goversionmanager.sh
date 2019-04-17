#!/bin/sh

#--------------------------------------------
#-This is a version manager script for Golang
#@@@ add by SinTan1071
#--------------------------------------------

VAR=$2
PARENTDIR="/home/sintan1071"
ROOTDIR="/usr/local"
BINDIR="/usr/local/bin"
DOWNLOADURL="https://dl.google.com/go/go$VAR.linux-amd64.tar.gz"

[ -f /etc/init.d/functions ] && {
    . /etc/init.d/functions
} || {
    . $PARENTDIR/shell/functions
}

useGoEnv() {
    return 0
}

listGoEnv() {
    return 0
}

installGoEnv() {
    if [ ! -n $VAR ]; then
        echo "you should input the golang version you want to install"
        return 0
    fi
    if [ -f $ROOTDIR/go$VAR/bin/go ] && [ -f $BINDIR/go$VAR ]; then
        echo "you already have the go$VAR installed"
        return 0
    fi
    if [ -f $ROOTDIR/go$VAR/bin/go ];then
        ln -s $ROOTDIR/go$VAR/bin/go $BINDIR/go$VAR
        echo "go$VAR install successfull"
        return 0
    fi
    HTTPCODE=$(curl -I -m 10 -o /dev/null -s -w %{http_code} $DOWNLOADURL)
    if [ $HTTPCODE -ne 200 ];then
        echo "no go$VAR is available"
        return 0
    fi
    if [ -f go$VAR.linux-amd64.tar.gz ];then
        SERVERLEN=$(curl -sI $DOWNLOADURL | grep content-length | awk '{print $2}')
        LOCALLEN=$(ls -l go$VAR.linux-amd64.tar.gz | awk '{print $5}')
        if [ ${SERVERLEN:0:$((${#SERVERLEN}-1))} = $LOCALLEN ];then
            tar -C $ROOTDIR -xzf go$VAR.linux-amd64.tar.gz && \
            mv $ROOTDIR/go $ROOTDIR/go$VAR && \
            ln -s $ROOTDIR/go$VAR/bin/go $BINDIR/go$VAR
            echo "go$VAR install successfull"
            return 0
        else
            rm go$VAR.linux-amd64.tar.gz
        fi
    fi
    echo "installing go$VAR...   "
    {
        wget --quiet --no-check-certificate $DOWNLOADURL && \
        tar -C $ROOTDIR -xzf go$VAR.linux-amd64.tar.gz && \
        mv $ROOTDIR/go $ROOTDIR/go$VAR && \
        ln -s $ROOTDIR/go$VAR/bin/go $BINDIR/go$VAR
    } &
    BARS='                                                  '
    PROCESS=$((1))
    SLEEPTIME=2
    while [ true ]; do
        echo -ne "\033[42;1m${BARS:0:$(( $PROCESS/2 ))}\033[0m${BARS:$(( $PROCESS/2 ))}$PROCESS%\r"
        if [ $PROCESS -eq  $((100)) ];then
            echo "go$VAR install successfull"
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

case "$1" in
    use)
        useGoEnv || exit 1
        ;;
    list)
        listGoEnv || exit 1
        ;;
    install)
        installGoEnv || exit 1
        ;;
    *)
        echo "Usage: $0 {use|list|install}"
        exit 1
        ;;
esac

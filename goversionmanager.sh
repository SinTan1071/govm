#!/bin/sh

#--------------------------------------------
#-This is a version manager script for Golang
#@@ by SinTan1071
#--------------------------------------------
OS=$(uname -a | awk '{print $1}')
case "$OS" in
    Linux)
        ARCH=$(dpkg --print-architecture)
        ;;
    FreeBSD)
        ARCH=$(dpkg --print-architecture)
        ;;
    Darwin)
        ARCH=amd64
        ;;
    *)
        echo "Sorry, Your OS is not available for this script !"
        exit 1
        ;;
esac

VAR=$2
ROOTDIR="/usr/local"
BINDIR="/usr/local/bin"
TMPDIR=~/.govm/.tmp
DOWNLOADURL="https://dl.google.com/go/go$VAR.$OS-$ARCH.tar.gz"

useGoEnv() {
    return 0
}

listGoEnv() {
    NOWUSING=$(go version | awk '{print $3}')
    for v in `ls $BINDIR | grep go`
    do
        if [ $v != "go" ];then
            if [ $v = $NOWUSING ];then
                echo -e "\033[33m$v\033[0m    <--- Using Now"
            else
                echo $v
            fi
        fi
    done
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
    if [ -f $TMPDIR/go$VAR.$OS-$ARCH.tar.gz ];then
        SERVERLEN=$(curl -sI $DOWNLOADURL | grep content-length | awk '{print $2}')
        LOCALLEN=$(ls -l $TMPDIR/go$VAR.$OS-$ARCH.tar.gz | awk '{print $5}')
        if [ ${SERVERLEN:0:$((${#SERVERLEN}-1))} = $LOCALLEN ];then
            tar -C $ROOTDIR -xzf $TMPDIR/go$VAR.$OS-$ARCH.tar.gz && \
            mv $ROOTDIR/go $ROOTDIR/go$VAR && \
            ln -s $ROOTDIR/go$VAR/bin/go $BINDIR/go$VAR
            echo "go$VAR install successfull"
            return 0
        else
            rm $TMPDIR/go$VAR.$OS-$ARCH.tar.gz
        fi
    fi
    echo "installing go$VAR...   "
    echo "work dir $TMPDIR"
    {
        wget --quiet --no-check-certificate -P $TMPDIR $DOWNLOADURL && \
        tar -C $ROOTDIR -xzf $TMPDIR/go$VAR.$OS-$ARCH.tar.gz && \
        mv $ROOTDIR/go $ROOTDIR/go$VAR && \
        ln -s $ROOTDIR/go$VAR/bin/go $BINDIR/go$VAR
    } &
    BARS='                                                  '
    PROCESS=$((1))
    SLEEPTIME=3
    while [ true ]; do
        echo -ne "\033[42;1m${BARS:0:$(( $PROCESS/2 ))}\033[0m${BARS:$(( $PROCESS/2 ))}$PROCESS%\r"
        if [ $PROCESS -eq  $((100)) ];then
            echo ''
            echo "go$VAR install successfull"
            break
        fi
        if [ -d $ROOTDIR/go$VAR ] && [ -f $BINDIR/go$VAR ];then
            if [ -f $TMPDIR/go$VAR.$OS-$ARCH.tar.gz ];then
                rm $TMPDIR/go$VAR.$OS-$ARCH.tar.gz
            fi
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

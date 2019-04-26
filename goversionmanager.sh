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
        return 0
        ;;
esac

VAR=$2
ROOTDIR="/usr/local/govm"
SYSROOTDIR="/usr/local"
BINDIR="/usr/local/bin"
USERPATH=~
TMPDIR=$USERPATH/.govm/.tmp
DOWNLOADURL="https://dl.google.com/go/go$VAR.$OS-$ARCH.tar.gz"

useGoEnv() {
    SHCMD=$(bash $USERPATH/.govm/.splitarray.sh $SHELL)
    NOWUSING=$(go version | awk '{print $3}')
    if [ ! $VAR ]; then
        echo "you should input the golang version you want to use"
        return 0
    fi
    if [ -f $ROOTDIR/go$VAR/bin/go ] && [ -f $BINDIR/go$VAR ]; then
        if [ -f $BINDIR/go ];then
            sudo rm $BINDIR/go
        fi
        export GOROOT=$ROOTDIR/go$VAR
        sudo ln -s $BINDIR/go$VAR $BINDIR/go
        OLDGOROOT=$(cat $USERPATH/."$SHCMD"rc | grep GOROOT)
        NEWGOROOT="export GOROOT='$ROOTDIR/go$VAR'"
        if [ $OLDGOROOT ];then
            sed "s|$OLDGOROOT|$NEWGOROOT|" $USERPATH/."$SHCMD"rc >> $USERPATH/."$SHCMD"rc.tmp
            cp $USERPATH/."$SHCMD"rc.tmp $USERPATH/."$SHCMD"rc
            rm $USERPATH/."$SHCMD"rc.tmp
        else
            echo $NEWGOROOT >> $USERPATH/."$SHCMD"rc
        fi
        echo "using go$VAR now"
    else
        echo "no local go$VAR was found, you should install the golang version $VAR first"
    fi
    return 0
}

listGoEnv() {
    if [ "$GOROOT" != $SYSROOTDIR/go ] && [ ! -f $SYSROOTDIR/go/bin/go ];then
        NOWUSING=$(go version | awk '{print $3}')
    fi
    for v in `ls $BINDIR | grep go`
    do
        for vv in `ls $ROOTDIR | grep go`
        do
            if [ $vv != "go" ] && [ $v = $vv ];then
                if [ $v = $NOWUSING ];then
                    echo -e "\033[33m$v\033[0m    <--- using now"
                else
                    echo $v
                fi
            fi    
        done
    done
    return 0
}

installGoEnv() {
    if [ ! $VAR ]; then
        echo "you should input the golang version you want to install"
        return 0
    fi
    if [ -f $ROOTDIR/go$VAR/bin/go ] && [ -f $BINDIR/go$VAR ]; then
        echo "you already have the go$VAR installed"
        return 0
    fi
    if [ -f $SYSROOTDIR/go/bin/go ];then
        SYSUSINGVERSION=$($SYSROOTDIR/go/bin/go version | awk '{print $3}')
        if [ $SYSUSINGVERSION = go$VAR ];then
            sudo mv $SYSROOTDIR/go $ROOTDIR/go$VAR
            # export GOROOT=$ROOTDIR/go$VAR
            sudo ln -s $ROOTDIR/go$VAR/bin/go $BINDIR/go$VAR
            echo "go$VAR install successfull"
            return 0
        fi
    fi
    if [ -f $ROOTDIR/go$VAR/bin/go ];then
        sudo ln -s $ROOTDIR/go$VAR/bin/go $BINDIR/go$VAR
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
            sudo tar -C $ROOTDIR -xzf $TMPDIR/go$VAR.$OS-$ARCH.tar.gz && \
            sudo mv $ROOTDIR/go $ROOTDIR/go$VAR && \
            sudo ln -s $ROOTDIR/go$VAR/bin/go $BINDIR/go$VAR
            echo "go$VAR install successfull"
        fi
        # rm $TMPDIR/go$VAR.$OS-$ARCH.tar.gz
        sudo rm $TMPDIR/go$VAR.$OS-$ARCH.tar.gz
        return 0
    fi
    echo "installing go$VAR...   "
    # echo "work dir $TMPDIR"
    bash $USERPATH/.govm/.wgetgopkg.sh $TMPDIR $DOWNLOADURL & && {
        # wget --quiet --no-check-certificate -P $TMPDIR $DOWNLOADURL && \
        sudo tar -C $ROOTDIR -xzf $TMPDIR/go$VAR.$OS-$ARCH.tar.gz && \
        sudo mv $ROOTDIR/go $ROOTDIR/go$VAR && \
        sudo ln -s $ROOTDIR/go$VAR/bin/go $BINDIR/go$VAR
    } &
    sleep 2
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
                # rm $TMPDIR/go$VAR.$OS-$ARCH.tar.gz
                sudo rm $TMPDIR/go$VAR.$OS-$ARCH.tar.gz
            fi
            PROCESS=$(( $PROCESS + 1 ))
            SLEEPTIME=0.05
        fi
        if [ ! -d $ROOTDIR/go$VAR ] && [ $PROCESS -lt 73 ];then
            PROCESS=$(( $PROCESS + 1 ))
        fi
        sleep $SLEEPTIME
    done
    rm wget-log
    return 0
}

removeGoEnv() {
    # TODO
}

check() {
    if [ ! -d $ROOTDIR ];then
        mkdir -p $ROOTDIR
    fi
    if [ -f $GOROOT/bin/go ];then
        SYSUSINGVERSION=$($GOROOT/bin/go version | awk '{print $3}')
        WHICHGO=$(which go)
        if [ $WHICHGO != $BINDIR/go ];then
            sudo rm $WHICHGO
        fi 
        if [ $GOROOT != $ROOTDIR/$SYSUSINGVERSION ];then
            if [ -f $BINDIR/go ];then
                sudo rm $BINDIR/go
            fi
            if [ -f $BINDIR/$SYSUSINGVERSION ];then
                sudo rm $BINDIR/$SYSUSINGVERSION
            fi
            if [ $GOROOT != $SYSROOTDIR/go ] || [ $GOROOT != $SYSROOTDIR/go/ ];then
                if [ -d $SYSROOTDIR/go ];then
                    sudo rm -fr $SYSROOTDIR/go
                fi
                sudo mv $GOROOT $SYSROOTDIR/go
            fi
            
            sudo mv $SYSROOTDIR/go $ROOTDIR/$SYSUSINGVERSION
            export GOROOT=$ROOTDIR/$SYSUSINGVERSION
            sudo ln -s $ROOTDIR/$SYSUSINGVERSION/bin/go $BINDIR/$SYSUSINGVERSION
            
            SHCMD=$(bash $USERPATH/.govm/.splitarray.sh $SHELL)
            OLDGOROOT=$(cat $USERPATH/."$SHCMD"rc | grep GOROOT)
            NEWGOROOT="export GOROOT='$ROOTDIR/$SYSUSINGVERSION'"
            if [ $OLDGOROOT ];then
                sed "s|$OLDGOROOT|$NEWGOROOT|" $USERPATH/."$SHCMD"rc >> $USERPATH/."$SHCMD"rc.tmp
                cp $USERPATH/."$SHCMD"rc.tmp $USERPATH/."$SHCMD"rc
                rm $USERPATH/."$SHCMD"rc.tmp
            else
                echo $NEWGOROOT >> $USERPATH/."$SHCMD"rc
            fi
            
            echo "govm check system golang version successfull"
        fi
    fi

    for v in `ls $BINDIR | grep go`
    do
        for vv in `ls $ROOTDIR | grep go`
        do
            if [ $vv != "go" ];then
                if [ ! -f $BINDIR/$vv ] && [ -f $ROOTDIR/$vv/bin/go ];then
                    sudo ln -s $ROOTDIR/$vv/bin/go $BINDIR/$vv
                    echo "link check $vv successful"
                fi
                if [ -f $BINDIR/$vv ] && [ -f $ROOTDIR/$vv/bin/go ] && [ ! -f $BINDIR/go ];then
                    SHCMD=$(bash $USERPATH/.govm/.splitarray.sh $SHELL)
                    export GOROOT=$ROOTDIR/$vv
                    sudo ln -s $BINDIR/$vv $BINDIR/go
                    OLDGOROOT=$(cat $USERPATH/."$SHCMD"rc | grep GOROOT)
                    NEWGOROOT="export GOROOT='$ROOTDIR/$vv'"
                    if [ $OLDGOROOT ];then
                        sed "s|$OLDGOROOT|$NEWGOROOT|" $USERPATH/."$SHCMD"rc >> $USERPATH/."$SHCMD"rc.tmp
                        cp $USERPATH/."$SHCMD"rc.tmp $USERPATH/."$SHCMD"rc
                        rm $USERPATH/."$SHCMD"rc.tmp
                    else
                        echo $NEWGOROOT >> $USERPATH/."$SHCMD"rc
                    fi
                    echo "using $vv as default"
                fi
            fi    
        done
    done
}

check

case "$1" in
    use)
        useGoEnv
        ;;
    list)
        listGoEnv
        ;;
    install)
        installGoEnv
        ;;
    *)
        echo "Usage: {use|list|install}"
        return 0
        ;;
esac

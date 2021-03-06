main() {
    USERPATH=~
    SHCMD=
    if [ -d $USERPATH/.govm ];then
        rm -fr $USERPATH/.govm
    fi
    echo "Installing Go Version Manager..." 
    command -v git >/dev/null 2>&1 || {
        echo "Error: git is not installed"
        exit 1
    }
    env git clone --depth=1 https://github.com/sintan1071/govm.git "$USERPATH/.govm" || {
        echo "Error: git clone of govm repo failed"
        exit 1
    } 
    
    # array=(${SHELL//"/"/ }) 
    # i=$((0)) 
    # for var in ${array[@]}
    # do
    #     i=$(($i+1))
    #     if [ $var = bin ];then
    #         SHCMD=${array[$i]}
    #     fi
    # done 
    
    OLD_IFS="$IFS" 
    IFS="/" 
    array=($SHELL) 
    IFS="$OLD_IFS"
    i=$((1)) 
    for var in ${array[@]} 
    do
        i=$(($i+1))
        if [ $var = bin ];then
            SHCMD=${array[$i]}
        fi 
    done

    if [ ! $(cat $USERPATH/."$SHCMD"rc | grep "alias govm" | awk '{print $3}') ];then
        echo "##############################" >> $USERPATH/."$SHCMD"rc
        echo "##    Go Version Manager    ##" >> $USERPATH/."$SHCMD"rc
        echo "##############################" >> $USERPATH/."$SHCMD"rc
        echo "alias govm='source $USERPATH/.govm/goversionmanager.sh'" >> $USERPATH/."$SHCMD"rc
    fi
    alias govm='source $USERPATH/.govm/goversionmanager.sh'
    # source $USERPATH/."$SHCMD"rc
}

main

# array=(${SHELL//"/"/ }) 
# i=$((0))
OLD_IFS="$IFS" 
IFS="/" 
array=($1) 
IFS="$OLD_IFS"
i=$((1))
for var in ${array[@]}
do
    i=$(($i+1))
    if [ $var = bin ];then
        echo ${array[$i]}
    fi
done

#!/bin/sh


_APP=$1
if [[ "$_APP" == "" ]]; then
    echo "Usage: changename.sh Thename"
    exit 1;
fi

_LAPP=`echo $_APP | tr 'A-Z' 'a-z'`

_my_file="$0"

for _FILE in `grep -Rl *`
    do
        echo $_FILE

        if [[ "$_FILE" == "$_my_file" ]]; then
            echo "**** Ignore script ****"
            echo "$_FILE"
            continue
        fi

        #sed -e "s/Appname/$_APP/g" -e "s/appname/$_LAPP/g" "$_FILE" > .rename.tmp
        #mv .rename.tmp "$_FILE"
done


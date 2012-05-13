#!/bin/sh

_APP=$1
if [[ "$_APP" == "" ]]; then
    echo "Usage: changename.sh Thename"
    exit 1;
fi

_LAPP=`echo $_APP | tr 'A-Z' 'a-z'`

for _FILE in `grep -Rl appname *`; do
    if [[ "$_FILE" == "changename.sh" ]]; then
        continue
    fi

    sed -e "s/Appname/$_APP/g" -e "s/appname/$_LAPP/g" "$_FILE" > .rename.tmp
    mv .rename.tmp "$_FILE"
done


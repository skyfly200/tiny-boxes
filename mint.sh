#!/bin/bash

trap "exit" INT TERM    # Convert INT and TERM to EXIT
trap "kill 0" EXIT      # Kill all child processes if we receive EXIT

while getopts "c:f:t:" arg; do
    case $arg in
        c) ADDRESS=$OPTARG;;
        f) FROM=$OPTARG;;
        t) TO=$OPTARG;;
    esac
done

## if deploy or render
## delete oz lock file ./.openzeppelin/.lock
rm -f ./.openzeppelin/.lock

npx oz send-tx -n rinkeby -v --method setPause --to $ADDRESS --args "false"


if [ -z "$TO" ]
    then
        echo "must set to address with -t"
    else        
        if [ -z "$FROM" ]
            then
                npx oz send-tx -n rinkeby -v --method createTo --to $ADDRESS --value 100000000000000000 --args "685525412542, 25, 5, [15,50,70], [100,100,100,100], [50,50], 63, $TO, 0"
            else
                npx oz send-tx -n rinkeby -v --method createTo -f $FROM --to $ADDRESS --value 100000000000000000 --args "685525412542, 25, 5, [15,50,70], [100,100,100,100], [50,50], 63, $TO, 0" 
        fi
fi

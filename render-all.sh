#!/bin/bash

trap "exit" INT TERM    # Convert INT and TERM to EXIT
trap "kill 0" EXIT      # Kill all child processes if we receive EXIT

RAND="0xa30E0997782fe8B4E888b22d711611fBCd0a388B"

## deploy only on calls with a -d flag present
while getopts "d:i:c:a:s:" arg; do
    case $arg in
        d) DEPLOY="set";;
        i) ALL="set";;
        c) ADDRESS=$OPTARG;;
        a) ANIMATION=$OPTARG;;
    esac
done

## if deploy or render
## delete oz lock file ./.openzeppelin/.lock
rm -f ./.openzeppelin/.lock

if [ -z "$DEPLOY" ]
    then
        echo "Skipping Deploy"
    else
        ADDRESS=$(npx oz deploy --no-interactive -k regular -n rinkeby TinyBoxes "$RAND" | tail -n 1)
fi

if [ -z "$ADDRESS" ]
    then
        echo "Error: no contract address provided!";
        echo "(use -a ADDRESS to provide address or -d y to deploy a new one)";
    else
        echo "Calling against contract @ $ADDRESS"
        ## delete oz lock file ./.openzeppelin/.lock
        rm -f ./.openzeppelin/.lock
        if [ -z "$ALL" ]
            then
                if [ -z "$ANIMATION" ]
                    then
                        ANIMATION=0
                fi
                # render svg at
                npx oz call --method tokenPreview -n rinkeby --args "'', [50,10,1], [$ANIMATION,3,7,70], 63, [50,50], [100,100,100,100], 5, 30, [2222,50,70], 0" --to "$ADDRESS" > "./frames/Anim-$ANIMATION.svg"
            else
                # adjust max animation value here
                for ANIMATION in {0..23}
                do  
                    # render svg at
                    npx oz call --method tokenPreview -n rinkeby --args "'', [50,10,1], [$ANIMATION,3,7,70], 63, [50,50], [100,100,100,100], 5, 30, [2222,50,70], 0" --to "$ADDRESS" > "./frames/Anim-$ANIMATION.svg"
                done
        fi
fi
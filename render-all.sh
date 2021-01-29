#!/bin/bash

trap "exit" INT TERM    # Convert INT and TERM to EXIT
trap "kill 0" EXIT      # Kill all child processes if we receive EXIT

RAND="0xa30E0997782fe8B4E888b22d711611fBCd0a388B"
SLOT='" "'
ID=0
OWNER="0x7A832c86002323a5de3a317b3281Eb88EC3b2C00"

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
                npx oz call --method perpetualRenderer -n rinkeby --args "[11111,265,50,70,30,5,100,100,100,100,75,22,63,0,10,2], $ID, $OWNER, [$ANIMATION,2,5,70], $SLOT" --to "$ADDRESS" > "./frames/Anim-$ANIMATION.svg"
            else
                # adjust max animation value here
                for ANIMATION in {0..23}
                do  
                    # render svg at
                    npx oz call --method perpetualRenderer -n rinkeby --args "[11111,265,50,70,30,5,100,100,100,100,75,22,63,0,10,0], $ID, $OWNER, [$ANIMATION,2,5,70], $SLOT" --to "$ADDRESS" > "./frames/Anim-$ANIMATION.svg"
                done
        fi
fi
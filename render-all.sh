#!/bin/bash

trap "exit" INT TERM    # Convert INT and TERM to EXIT
trap "kill 0" EXIT      # Kill all children if we receive EXIT

RAND="0xa30E0997782fe8B4E888b22d711611fBCd0a388B"

## deploy only on calls with a -d flag present
while getopts "d:i:c:a:s:" arg; do
    case $arg in
        d) DEPLOY="set";;
        i) ALL="set";;
        c) ADDRESS=$OPTARG;;
        a) ANIMATION=$OPTARG;;
        s) START=$OPTARG;;
    esac
done

## if deploy or render
## delete oz lock file ./.openzeppelin/.lock
rm -f ./.openzeppelin/.lock

if [ -z "$DEPLOY" ]
    then
        echo "Skipping Deploy"
    else
        if [ -z "$START" ]
            then
                echo "Error: no startBlock provided!";
            else
                ADDRESS=$(npx oz deploy --no-interactive -k regular -n rinkeby TinyBoxes "$RAND" "$START" | tail -n 1)
        fi
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
                npx oz call --method tokenPreview -n rinkeby --args "0, 25, 5, [222,50,50], [50,100,100,150], [50,129], [$ANIMATION,3,0,70], [101,10,1], 63, 100" --to "$ADDRESS" > "./frames/Anim-$ANIMATION.svg"
            else
                # adjust max animation value here
                for ANIMATION in {0..23}
                do  
                    # render svg at
                    npx oz call --method tokenPreview -n rinkeby --args "0, 16, 2, [222,50,50], [111,222,150,200], [50,16], [$ANIMATION,3,0,70], [101,0,1], 63, 100" --to "$ADDRESS" > "./frames/Anim-$ANIMATION.svg"
                done
        fi
fi
#!/bin/bash

trap "exit" INT TERM    # Convert INT and TERM to EXIT
trap "kill 0" EXIT      # Kill all children if we receive EXIT

LINK="0x01be23585060835e02b77ef475b0cc51aa1e0709"
FEED="0xd8bD0a1cB028a31AA859A21A3758685a95dE4623"

## deploy only on calls with a -d flag present
while getopts "d:i:c:a:" arg; do
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
        ADDRESS=$(npx oz deploy --no-interactive -k regular -n rinkeby TinyBoxes "$LINK" "$FEED" | tail -n 1)
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
                npx oz call --method tokenPreview -n rinkeby --args "$ANIMATION, 16,  2, [222,80,70,30], [111,222,150,200], [100,34], [60,120,240,10], true" --to "$ADDRESS" > "./frames/Anim-$ANIMATION.svg"
            else
                # adjust max animation value here
                for ANIMATION in {0..23}
                do  
                    # render svg at
                    npx oz call --method tokenPreview -n rinkeby --args "$ANIMATION, 16, 2, [222,80,70,30], [111,222,150,200], [100,34], [60,120,240,10], true" --to "$ADDRESS" > "./frames/Anim-$ANIMATION.svg"
                done
        fi
fi
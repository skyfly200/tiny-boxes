#!/bin/bash

trap "exit" INT TERM    # Convert INT and TERM to EXIT
trap "kill 0" EXIT      # Kill all children if we receive EXIT

LINK="0x01be23585060835e02b77ef475b0cc51aa1e0709"
FEED="0x3Af8C569ab77af5230596Acf0E8c2F9351d24C38"

## deploy only on calls with a -d flag present
while getopts "d:a:" arg; do
    case $arg in
        d) ADDRESS=$(npx oz deploy --no-interactive -k regular -n rinkeby TinyBoxes "$LINK" "$FEED" | tail -n 1);;
        a) ADDRESS=$OPTARG;;
    esac
done

if [ -z "$ADDRESS" ]
    then
        echo "no address provided";
    else
        echo "$ADDRESS"
        ANIMATION=8
        echo "Testing Token Render"
        for FRAME in {0..119}
        do
            npx oz call --method tokenTest -n rinkeby --args "12345, [10,10], [100,100,2,2,111,222,333,444,2,750,1200,2400,100], [true,true,true], $ANIMATION, $FRAME" --to "$ADDRESS">| "./frames/f$FRAME.svg"
            inkscape -z -w 2400 -h 2400 "./frames/f$FRAME.svg" -e "./frames/png/f$FRAME.png"
        done
        # Find child processes and wait for them to finish so this script doesn't
        # exit before the children do (otherwise our trap will kill them)
        for job in $(jobs -p); do
            wait $job
        done
fi
#!/bin/bash

trap "exit" INT TERM    # Convert INT and TERM to EXIT
trap "kill 0" EXIT      # Kill all children if we receive EXIT

LINK="0x01be23585060835e02b77ef475b0cc51aa1e0709"
FEED="0x3Af8C569ab77af5230596Acf0E8c2F9351d24C38"

## deploy only on calls with a -d flag present
while getopts "d:a:f:r:c:g:" arg; do
    case $arg in
        d) DEPLOY="set";;
        a) ADDRESS=$OPTARG;;
        f) FRAMES=$OPTARG;;
        r) RENDER="set";;
        c) CONVERT="set";;
        g) GIF=$OPTARG;;
    esac
done

## if deploy or render
## delete oz lock file ./.openzeppelin/.lock

if [ -z "$DEPLOY" ]
    then
        echo "Skipping Deploy Step";
    else
        ADDRESS=$(npx oz deploy --no-interactive -k regular -n rinkeby TinyBoxes "$LINK" "$FEED" | tail -n 1)
fi

if [ -z "$RENDER" ]
    then 
        echo "Skipping Frame Rendering"
    else
        if [ -z "$ADDRESS" ]
            then
                echo "Error: no contract address provided!";
            else
                echo "$ADDRESS"
                ANIMATION=7
                echo "Testing Token Render"
                # TODO: use frames to render here for quick test runs
                for FRAME in {000..119}
                do
                    npx oz call --method tokenTest -n rinkeby --args "12345, [10,10], [100,100,2,2,111,222,333,444,2,750,1200,2400,100], [true,true,true], $ANIMATION, $FRAME" --to "$ADDRESS">| "./frames/f$FRAME.svg"
                    inkscape -z -w 1200 -h 1200 "./frames/f$FRAME.svg" -e "./frames/png/f$FRAME.png"
                done 
                # Find child processes and wait for them to finish so this script doesn't
                # exit before the children do
                for job in $(jobs -p); do
                    wait $job
                done
        fi
fi

if [ -z "$CONVERT" ]
    then
        echo "Skipping GIF Conversion"
    else
        # set default name
        if [ -z "$GIF" ]
            then
                GIF="Test"
        fi 
        # generate a GIF from the PNG frames
        magick -delay 50 ./frames/png/*.png -loop 0 "./frames/$GIF-A$ANIMATION.gif"
fi 
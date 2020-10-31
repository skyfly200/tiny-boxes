NETWORK=$1
LINK="0x01be23585060835e02b77ef475b0cc51aa1e0709"
FEED="0x3Af8C569ab77af5230596Acf0E8c2F9351d24C38"

ADDRESS=$(npx oz deploy --no-interactive -k regular -n rinkeby TinyBoxes "$LINK" "$FEED" | tail -n 1)
echo "$ADDRESS"

ANIMATION=2
echo "Testing Token Render"
for FRAME in {0..30}
do
    npx oz call --method tokenTest -n rinkeby --args "12345, [10,10], [100,100,2,2,111,222,333,444,2,750,1200,2400,100], [true,true,true], $ANIMATION, $FRAME" --to "$ADDRESS">| "./frames/f$FRAME.svg"
done

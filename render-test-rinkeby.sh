NETWORK=$1
LINK="0x01be23585060835e02b77ef475b0cc51aa1e0709"
FEED="0x3Af8C569ab77af5230596Acf0E8c2F9351d24C38"
ADDRESS=$(npx oz deploy --no-interactive -k regular -n rinkeby TinyBoxes "$LINK" "$FEED" | tail -n 1)

echo "$ADDRESS"

echo "Testing Token Preview"
npx oz call --method tokenTest -n rinkeby --args "12345, [7,11], [100,100,2,2,111,222,333,444,2,750,1200,2400,100], [true,true,true], 0, 0" --to "$ADDRESS"
npx oz call --method tokenTest -n rinkeby --args "12345, [7,11], [100,100,2,2,111,222,333,444,2,750,1200,2400,100], [true,true,true], 0, 1" --to "$ADDRESS"
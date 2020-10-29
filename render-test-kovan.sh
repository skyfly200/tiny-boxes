LINK="0xa36085f69e2889c224210f603d836748e7dc0088"
FEED="0x3Af8C569ab77af5230596Acf0E8c2F9351d24C38"
ADDRESS=$(npx oz deploy --no-interactive -k regular -n kovan TinyBoxes "$LINK" "$FEED" | tail -n 1)

echo "$ADDRESS"

echo "Testing Token Preview"
npx oz call --method tokenPreview -n kovan --args "12345, [7,11], [100,100,2,2,111,222,333,444,2,750,1200,2400,100], [true,true,true]" --to "$ADDRESS"
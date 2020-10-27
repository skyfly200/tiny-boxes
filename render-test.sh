ADDRESS=$(npx oz deploy --no-interactive -k regular -n ropsten TinyBoxes 0x20fE562d797A42Dcb3399062AE9546cd06f63280 0xb8c99b98913bE2ca4899CdcaF33a3e519C20EeEc | tail -n 1)

echo "$ADDRESS"

echo "Testing Token Preview"
npx oz call --method tokenPreview --args "12345, [7,11], [100,100,2,2,111,222,333,444,2,750,1200,2400,100], [true,true,true]" -n ropsten --to "$ADDRESS"
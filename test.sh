#!/bin/bash

trap "exit" INT TERM    # Convert INT and TERM to EXIT
trap "kill 0" EXIT      # Kill all child processes if we receive EXIT

RAND="0x39268785c0051569f4C133D46f3C8594514e7302"
ROLE="0x843c3a00fa95510a35f425371231fd3fe4642e719cb4595160763d6d02594b50"

## if deploy or render
## delete oz lock file ./.openzeppelin/.lock
rm -f ./.openzeppelin/.lock

ADDRESS=$(npx oz deploy -n rinkeby -v --no-interactive -k regular  TinyBoxes "$RAND" | tail -n 1)

## add caller role for the contract
echo "Adding $ADDRESS as caller on $RAND"
npx oz send-tx -n rinkeby -v --method grantRole --to $RAND --args $ROLE $ADDRESS

## unpause the new contract
echo "Unpausing @ $ADDRESS"
npx oz send-tx -n rinkeby -v --method setPause --to $ADDRESS --args "false"

## create a box
echo "Creating box @ $ADDRESS"
npx oz send-tx -n rinkeby -v --method createTo --to $ADDRESS --value 100000000000000000 --args "0, 25, 5, [15,50,70], [100,100,100,100], [50,50], 63, 0x7A832c86002323a5de3a317b3281Eb88EC3b2C00, 0"
#npx oz send-tx -n rinkeby -v --method createTo --to $ADDRESS--value 100000000000000000 --args "0, 25, 5, [15,50,70], [100,100,100,100], [50,50], 63, 0x7A832c86002323a5de3a317b3281Eb88EC3b2C00"
#!/bin/bash

trap "exit" INT TERM    # Convert INT and TERM to EXIT
trap "kill 0" EXIT      # Kill all child processes if we receive EXIT

RAND="0xa30E0997782fe8B4E888b22d711611fBCd0a388B"

## if deploy or render
## delete oz lock file ./.openzeppelin/.lock
rm -f ./.openzeppelin/.lock

ADDRESS=$(npx oz deploy --no-interactive -k regular -n rinkeby TinyBoxes "$RAND" | tail -n 1)
echo "Calling against contract @ $ADDRESS"
## delete oz lock file ./.openzeppelin/.lock
rm -f ./.openzeppelin/.lock
npx oz send-tx -n rinkeby -v --method createPromo --to $ADDRESS --args "0, 25, 5, [15,50,70], [100,100,100,100], [50,50], 63, 0x7A832c86002323a5de3a317b3281Eb88EC3b2C00"
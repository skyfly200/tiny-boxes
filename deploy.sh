#!/bin/bash

trap "exit" INT TERM    # Convert INT and TERM to EXIT
trap "kill 0" EXIT      # Kill all child processes if we receive EXIT

RAND="0x02F597BFdB0291FE0789CA123D0dD9A2babfE845"

## if deploy or render
## delete oz lock file ./.openzeppelin/.lock
rm -f ./.openzeppelin/.lock

npx oz compile -v --no-interactive --typechain web3-v1 --solc-version 0.6.8
npx oz deploy -v --skip-compile --no-interactive -k regular -n rinkeby TinyBoxes "$RAND"

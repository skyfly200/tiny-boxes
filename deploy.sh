#!/bin/bash

trap "exit" INT TERM    # Convert INT and TERM to EXIT
trap "kill 0" EXIT      # Kill all child processes if we receive EXIT

RAND="0x02F597BFdB0291FE0789CA123D0dD9A2babfE845"

## if deploy or render
## delete oz lock file ./.openzeppelin/.lock
rm -f ./.openzeppelin/.lock

npx oz deploy -v --no-interactive -k regular -n rinkeby TinyBoxes "$RAND"

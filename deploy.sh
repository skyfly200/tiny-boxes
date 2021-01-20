#!/bin/bash

trap "exit" INT TERM    # Convert INT and TERM to EXIT
trap "kill 0" EXIT      # Kill all child processes if we receive EXIT

RAND="0x6a05F48E86b1A77759DEeb4E69caf4ed6FcfBB56"

## if deploy or render
## delete oz lock file ./.openzeppelin/.lock
rm -f ./.openzeppelin/.lock

npx oz deploy -v --no-interactive -k regular -n rinkeby TinyBoxes "$RAND"

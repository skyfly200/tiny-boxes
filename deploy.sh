#!/bin/bash

trap "exit" INT TERM    # Convert INT and TERM to EXIT
trap "kill 0" EXIT      # Kill all child processes if we receive EXIT

RAND="0x3c31a56DB3fc38e8960b77D5089f2e755DEEAFC3"

## if deploy or render
## delete oz lock file ./.openzeppelin/.lock
rm -f ./.openzeppelin/.lock

npx oz deploy -v --no-interactive -k regular -n rinkeby TinyBoxes "$RAND"

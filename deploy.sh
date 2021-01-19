#!/bin/bash

trap "exit" INT TERM    # Convert INT and TERM to EXIT
trap "kill 0" EXIT      # Kill all child processes if we receive EXIT

RAND="0xa30E0997782fe8B4E888b22d711611fBCd0a388B"

## if deploy or render
## delete oz lock file ./.openzeppelin/.lock
rm -f ./.openzeppelin/.lock

npx oz deploy -v --no-interactive -k regular -n rinkeby TinyBoxes "$RAND"

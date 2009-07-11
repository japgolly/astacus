#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $(basename $0) <dir>"
  exit 1
fi

"$(dirname $0)/runner" "require 'scanner'; Astacus::Scanner.new.scan \"$1\""


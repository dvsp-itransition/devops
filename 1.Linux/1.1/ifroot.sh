#!/bin/bash
set -euo pipefail
if [ "$USER"  == "root" ]; then
    echo "This script is run on behalf of $USER user";
else
    echo "This is NOT root user.";
fi    


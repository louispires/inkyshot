#!/bin/bash

# Load the exported environment vars
. /usr/app/env.sh

# Run the Inky update
python3 /usr/app/update-display.py

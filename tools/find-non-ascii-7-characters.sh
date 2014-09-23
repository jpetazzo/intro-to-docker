#!/bin/sh
find -type f -name \*.md | xargs grep -r --color='auto' -P -n "[\x80-\xFF]"

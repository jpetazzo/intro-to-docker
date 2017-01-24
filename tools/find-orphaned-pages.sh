#!/bin/sh
cd ../slides
for F in */*.md; do grep -q $F showoff.json || echo $F; done

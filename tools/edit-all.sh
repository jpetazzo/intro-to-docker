#!/bin/sh
cd ../slides
vi $(grep md showoff.json | grep -v // | cut -d\" -f2)

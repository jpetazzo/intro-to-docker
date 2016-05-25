#!/usr/bin/env python
import json
showoff = json.load(open("slides/showoff.json"))
for src in showoff['sections']:
    cover = False
    for line in open("slides/" + src):
        if line.startswith('#') and cover:
            print line.strip("# \n")
            break
        if line.startswith("<!SLIDE") and " center " in line:
            cover = True

            

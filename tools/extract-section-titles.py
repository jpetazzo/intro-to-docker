#!/usr/bin/env python
import os
import json
import click
"""
Extract and print level 1 and 2 titles from workshop slides.
"""
os.chdir("../slides")

with open("showoff.json", "r") as f:
    data = f.read()

data = data.replace('\n', '')
while '  ' in data:
    data = data.replace('  ', ' ')
data = data.replace('//', '')
data = json.loads(data)

sections = data["sections"]
page = 0
for section in sections:
    #page += 1
    directory, filename = section.split('/')
    print("{}: {}".format(
        click.style(directory, fg='red'),
        click.style(filename, fg='yellow')
        ))
    with open(section, "r") as f:
        slides = f.read()
    slides = slides.split("<!SLIDE")
    for slide in slides:
        page += 1
        slide = "\n".join([x for x in slide.split("\n") if x])
        titles = [x for x in slide.split('\n') if x.startswith('# ')]
        for title in titles:
            print("{}".format(title))
        #print("\n".join(titles))


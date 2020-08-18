#!/bin/bash

source=$1
destination=$2

function modifiedTime () {
    stat -f "%Sm" -t "%Y-%m-%d" $source
}

function title () {
    head -n 1 $source | sed 's/^# //'
}

function summary () {
    cat $source | grep -oE '<!-- summary: (.*?) -->' | cut -f2 -d'"'
}

cat <<EOF > $destination
---
date: "$(modifiedTime)"
title: $(title)
toc: true
summary: $(summary)
---

EOF

tail -n +2 $source >> $destination
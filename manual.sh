#!/bin/bash

# the_manual - a simple script to convert all base man
#	           pages into pdfs 
# author: Rev Taylor R Rainwater
#   date: 23-03-2016

# the various directories which contain the system 
# commands
r_bin="/bin/$1"
r_sbin="/sbin/$1"
u_bin="/usr/bin/$1"
u_sbin="/usr/sbin/$1"
# keeping count makes a warm fuzzy feeling in my stomach
let count=0

manual_process() {
    for f in $1/*
    do
	echo "PROCESSED: " $(basename $f)
	man $(basename $f) | col -bx > $(basename $f).txt
	enscript -Bhqp $2$(basename $f).ps $(basename $f).txt
	yes | rm $(basename $f).txt
	let count=count+1
    done
}

manual_merge() {
    gs -sDEVICE=pdfwrite \
       -dNOPAUSE -dBATCH -dSAFER -q \
       -sOutputFile=$1.pdf $1/*.ps
}

manual_build() {
    gs -sDEVICE=pdfwrite \
       -dNOPAUSE -dBATCH -dSAFER -q \
       -sOutputFile=the_manual.pdf *.pdf
}

manual_clean() {
    rm -f r_bin/*.ps &
    rm -f r_sbin/*.ps &
    rm -f u_bin/*.ps &
    rm -f u_sbin/*.ps &
    rm -f r_bin.pdf r_sbin.pdf u_bin.pdf u_sbin.pdf &
    wait 
}

manual_main() {
    # Create all ps files from the man pages
    echo "!--BEGINNING--!"
    manual_process $r_bin r_bin/ &
    manual_process $r_sbin r_sbin/ &
    manual_process $u_bin u_bin/ &
    manual_process $u_sbin u_sbin/ &
    wait
    # Merge all ps files from their sections
    # to a pdf with the name of the section
    echo "!--MERGING--!"
    manual_merge r_bin &
    manual_merge r_sbin &
    manual_merge u_bin &
    manual_merge u_sbin &
    wait
    # Merge the four sections
    echo "!--BUILDING--!"
    manual_build
    manual_clean
    echo "TOTAL FILES PROCESSED: " $count
    echo "OUTPUT FILE IS the_manual.pdf"
}
manual_main 2> the_manual.log


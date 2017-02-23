#!/bin/bash

# the_manual - a simple script to convert all base man
#	           pages into pdfs 
# author: Rev Taylor R Rainwater
#   date: 23-03-2016

# DEPENDENCIES
# - GNU Parallel 20170122 or greater
# - encript
# - GhostScript
# - col and man (if you don't have these then what are you doing?)

# the various directories which contain the system commands
r_bin="/bin/$1"
r_sbin="/sbin/$1"
u_bin="/usr/bin/$1"
u_sbin="/usr/sbin/$1"

# process a command directory
manual_process() {
    ls $1 | parallel "man {} | col -bx > $2{}.txt && echo PROCESSED: {}"
    ls $2 | parallel "enscript -Bhqp $2{.}.ps $2{}"
}

# merge all postscript into pdf's
manual_merge() {
    parallel "gs -sDEVICE=pdfwrite \
       -dNOPAUSE -dBATCH -dSAFER -q \
       -sOutputFile={}.pdf {}/*.ps" ::: r_bin r_sbin u_bin u_sbin
}

# merge all pdf's into one
manual_build() {
    gs -sDEVICE=pdfwrite \
       -dNOPAUSE -dBATCH -dSAFER -q \
       -sOutputFile=the_manual.pdf *.pdf
}

# gotta keep clean
manual_clean() {
    rm -f r_bin/* &
    rm -f r_sbin/* &
    rm -f u_bin/* &
    rm -f u_sbin/* &
    rm -f r_bin.pdf r_sbin.pdf u_bin.pdf u_sbin.pdf &
    wait 
}

# This uses ghetto parallelism 
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
    manual_merge
    # Merge the four sections
    echo "!--BUILDING--!"
    manual_build
    # Clean
    manual_clean
    echo "OUTPUT FILE IS the_manual.pdf"
}
# Catch errors and put into logfile
manual_main 2> the_manual.log

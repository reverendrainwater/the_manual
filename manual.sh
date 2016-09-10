#!/bin/bash
# the_manual - a simple script to convert all base man
#	           pages into pdfs 
# author: Rev Taylor R Rainwater
#   date: 23-03-2016
######################################################
# TODO
# - fix file counter
# - give more notifications
# - place txt and pdf files in their respective 
#   directories


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
		echo "THE MANUAL SYSTEM INDEPENDENT COMPILER"
		echo "======================================"
		echo "PROCESSED: " $(basename $f)
		man $(basename $f) | col -bx > $2$(basename $f).txt
		enscript -Bhqp $2$(basename $f).ps $2$(basename $f).txt
		yes | rm $2$(basename $f).txt
		clear
		let count=count+1
	done
}

manual_merge() {
	echo "  MERGING: " $1
	gs -sDEVICE=pdfwrite \
	-dNOPAUSE -dBATCH -dSAFER -q \
	-sOutputFile=$1.pdf $1/*.ps
}

manual_build() {
	echo " BUILDING: the_manual.pdf"
	gs -sDEVICE=pdfwrite \
	-dNOPAUSE -dBATCH -dSAFER -q \
	-sOutputFile=the_manual.pdf *.pdf
}

manual_clean() {
	echo "CLEANING UP"
	yes | rm r_bin/*.ps &
	yes | rm r_sbin/*.ps &
	yes | rm u_bin/*.ps &
	yes | rm u_sbin/*.ps &
	yes | rm r_bin.pdf r_sbin.pdf u_bin.pdf u_sbin.pdf &
	wait 
}

manual_main() {
	# Create all ps files from the man pages
	manual_process $r_bin r_bin/ &
	manual_process $r_sbin r_sbin/ &
	manual_process $u_bin u_bin/ &
	manual_process $u_sbin u_sbin/ &
	wait
	# Merge all ps files from their sections
	# to a pdf with the name of the section
	echo "=============================="
	manual_merge r_bin &
	manual_merge r_sbin &
	manual_merge u_bin &
	manual_merge u_sbin &
	wait
	# Merge the four sections
	echo "=============================="
	manual_build
    manual_clean
	echo "TOTAL FILES PROCESSED: " $count
	echo "OUTPUT FILE IS the_manual.pdf"
}
manual_main 2> the_manual.log


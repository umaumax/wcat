#!/usr/bin/env bash

{ [[ $1 == '-h' ]] || [[ $1 == '-help' ]] || [[ $1 == '--help' ]]; } && echo "$0 "'$filepath:$line:$range' && exit 1

function cmdcheck() {
	type -a "$1" >/dev/null 2>&1
}

function main() {
	local file_path="${1%%:*}"
	local range=$(echo "$1" | awk -F':' '{ if ( $3 != "" ) print $3; else print $4; }')
	if [[ -z $range ]]; then
		local range=5
	fi
	local line_no=$(echo "$1" | awk -F':' '{print $2}')
	if [[ -z $line_no ]]; then
		local line_no=0
		local range=9999999
	fi

	local CAT='cat -n'
	local pre_line=0
	if cmdcheck bat; then
		# NOTE: bat has --line-range <start>:<end> option
		local CAT='bat --color=always'
		local pre_line=3
	elif cmdcheck ccat; then
		local CAT='ccat -C=always'
		local pre_line=0
	fi

	eval $CAT $file_path | awk -v base=$line_no -v range=$range -v pre_line=$pre_line '(pre_line+base-range)<=NR && NR<=(pre_line+base+range)'
}

main "$@"

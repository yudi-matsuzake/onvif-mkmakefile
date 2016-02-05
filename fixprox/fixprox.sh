#!/bin/bash

# fixprox - fix the onvif proxies

[ $# -lt 1 ] && exit 1

PREFIX="#ifndef WITH_NOIDREF"
POSFIX="#endif // WITH_NOIDREF"

FIXPROX_SH_FULL_PATH="$0"
FIXPROX_SH="$(basename $0)"
NOs_PATH="${FIXPROX_SH_FULL_PATH%/${FIXPROX_SH}}"

for prox_file in $@
do 

	echo "file: $prox_file"
	for fix in ${NOs_PATH}/*.no
	do
		echo "fixing error ${fix}"
		fix_nline="$(cat $fix | wc -l)"
		regex="$(cat $fix | sed -r 's/(\(|\))/\\\1/g')"

		fix_line_begin="$(pcregrep -nM "$regex" "$prox_file" | head -n 1 | cut -f1 -d:)"
		fix_line_end="$(( fix_line_begin + fix_nline ))"

		if [ -z "$fix_line_begin" ]
		then
			echo "Pattern Not Found"
		else
			echo -e "\tlbegin: $fix_line_begin"
			echo -e "\tlend: $fix_line_end"

			# sed 
			# a - append
			# i - preppend
			# sed -i 
			sed -i -e "${fix_line_begin}i${PREFIX}" -e "${fix_line_end}i${POSFIX}" "$prox_file"
		fi
	done
done

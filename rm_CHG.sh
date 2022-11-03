#!/bin/sh
for ele in *; do
	if [ -d "$ele" ]; then
		cd $ele
		rm CHG*
		cp ~/bin/rm_CHG.sh .
		sh rm_CHG.sh
		rm rm_CHG.sh
		cd ..
fi
done

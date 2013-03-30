#! /bin/bash
#
# this builds exuberant ctags for julia
# you need to have a .ctags file in your
# home directory.
#
# Created: 2013.03.29
# Copyright: Steven E. Pav, 2013-2013
# Author: Steven E. Pav
# Comments: Steven E. Pav

#CTAGS=exuberant-ctags
CTAGS=ctags
CTAGFLAGS='--verbose=no --recurse'
NICE_LEVEL=18
NICE_FLAGS="-n $NICE_LEVEL"
TMP_TAG=.tmp_tags

##set up the julia tags
#for minimal disruption, write it to $TMP_TAG and then move it...
nice $NICE_FLAGS $CTAGS -f $TMP_TAG $CTAGFLAGS --language-force=julia --exclude='.jl\~' --fields=+i `find . -name '*.jl'` 2>/dev/null
if [ -s $TMP_TAG ];
then
	mv $TMP_TAG .j_tags;
else
	echo "empty julia tags?" > 2
fi

# vim:ts=4:sw=2:tw=180:fdm=marker:fmr=FOLDUP,UNFOLD:cms=#%s:syn=sh:ft=sh:ai:si:cin:nu:fo=croql:cino=p0t0c5(0:

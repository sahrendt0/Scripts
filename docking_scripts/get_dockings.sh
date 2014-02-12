grep '^DOCKED' $1.dlg | cut -c9- > $1.all.pdbqt
cut -c-66 $1.all.pdbqt > $1.all.pdb

#set a="grep ENDMDL $1.all.pdb | wc -l"
#set b=`expr $a - 2`
#csplit -k -s -n 3 -f $1. $1.all.pdb '/^ENDMDL/+1' '{'$b'}'
#foreach f ( $1.[0-9][0-9][0-9] )
#  mv $f $f.pdb
#end

REC=$1
DOCK=$2
CONF=$3

grep '^DOCKED' $DOCK\.dlg | cut -c9- > $DOCK\.pdbqt
cut -c-66 $DOCK\.pdbqt > $DOCK\.pdb
csplit -k -s -n 3 -f $DOCK\. $DOCK\.pdb '/^ENDMDL/+1' '{'$(expr $(grep ENDMDL $DOCK\.pdb | wc -l) - 2)'}'
for f in $(ls $DOCK\.[0-9][0-9][0-9])
  do
  mv $f $f.pdb
done
cat $REC\.pdb $DOCK\.$CONF\.pdb | grep -v '^END   ' | grep -v '^END$' > complex.pdb
mkdir conformations
mv $DOCK\.*\.pdb ./conformations

coloring.R
#ln -s colorlistGroups.tmp colorlist
colormap.pl -i id2group.tsv
colorTree_linux_x86_64 -i newickTree -c DendroColor.config -o colored_tree -f newick
Dendroscope -x "open file=colored_tree.dendro" &
plotTree.R

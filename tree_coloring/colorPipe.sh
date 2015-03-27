###
# Description: Shell script to run though process of coloring trees for plotting 
# Author: Steven Ahrendt (sahrendt0@gmail.com)
# Date: 11.26.14
######
# Basically takes a decoded tree file, newick format "newickTree"
#   and an id-to-group mapping file "id2group.tsv" which has
#   each leaf of the tree and which group it belongs to
# Then uses R to get a random selection of colors and assigns each to a uniq grouping
# Cross-ref the groups and colors to each individual Id 
#   and feed those to Dendroscope (to get the colored tree) and R/Ape (to get the legend)
############
## Decode the tree
dephylip_tree.pl -i $1 -c code_file
ln -s $1\.newick newickTree

## First get the uniq groups
cut -f 2 id2group.tsv | sort | uniq > uniqGroups

## coloring.R creates a color mapping file which picks a random color
#   for each group in uniqGroups and gives it a color name (for R)
#   and that color's corresponding RGB values (for dendroscope)
# Requires: uniqGroups
# Produces: colorlist
coloring.R

## colormap.pl takes colorlist file and creates two config files:
#   one for R (colorMap.config) which pairs the id with a color name
#   one for dendroscope (DendroColor.config) which pairs the id with an RGB value 
#     (and some other stuff; see here: https://code.google.com/p/colortree/wiki/ColorTree#Example_of_configuration_file)
# Requires: id2group.tsv, colorlist
# Produces: colorMap.config, DendroColor.config
colormap.pl -i id2group.tsv

## colorTree is a script for coloring trees: https://code.google.com/p/colortree/wiki/ColorTree
# Requires: newickTree, DendroColor.config
# Producse: <output>.dendro
colorTree_linux_x86_64 -i newickTree -c DendroColor.config -o colored_tree -f newick

## Dendroscope is a free tree-viewing program: http://ab.inf.uni-tuebingen.de/software/dendroscope/
Dendroscope -x "open file=colored_tree.dendro" &

## plotTree.R plots a tree using ape in R
#   I wrote it for tree plotting, now I'm using it to generate a figure legend
# Requires: newickTree, colorMap.config
# Produces: plot.pdf
plotTree.R

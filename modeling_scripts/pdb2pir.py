#!/usr/bin/python
# Script: pdb2pir.py
# Description: Prints sequence of pdb files in .pir format (using modeller)
# Author: Steven Ahrendt
# Date: 7.5.13
#       v0.9: Add command line argument support
#       v1.0: command line input and proper output format
########################################
import sys
from modeller import *
from subprocess import call

# PDB code
PDBcode = sys.argv[1]
chain = 'A'
outputfile = PDBcode+'.pir'
tmp = outputfile+'.tmp'

log.none()
env = environ()
aln = alignment(env)
mdl = model(env, file=PDBcode, model_segment=(('FIRST:'+chain),('LAST:'+chain)))
aln.append_model(mdl, align_codes=(PDBcode+chain), atom_files=(PDBcode+'.pdb'))
aln.write(file=outputfile, alignment_format='PIR')

# Format
#callstr = "awk 'NR>1' " + outputfile
#print callstr
tmpfile = open(tmp,"w")
call(["awk","NR>1",outputfile],stdout=tmpfile)
call(['mv',tmp,outputfile])

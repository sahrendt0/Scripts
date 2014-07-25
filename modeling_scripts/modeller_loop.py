#!/usr/bin/python
# Description: Homology modeling by the automodel class
###############################
import sys
from modeller import *
from modeller.automodel import *    # Load the automodel class

log.verbose()
env = environ()

al = sys.argv[1]
kwns = sys.argv[2]
seq = sys.argv[3]

#print al, kwns, seq



# directories for input atom files
env.io.atom_files_directory = ['.']

# Create a new class based on 'loopmodel' so that we can redefine select_loop_atoms
class MyLoop(loopmodel):
    # This routine picks the residues to be refined by loop modeling
    def select_loop_atoms(self):
        return selection(self.residue_range('1:', '5:'),	# N-terminal loop
                         self.residue_range('34:', '39:'),	# IC Loop 1
                         self.residue_range('69:', '76:'),	# EC Loop 1
                         self.residue_range('111:', '117:'),	# IC Loop 2
                         self.residue_range('141:', '145:'),	# EC Loop 2.1
                         self.residue_range('149:', '154:'),	# EC Loop 2.2
                         self.residue_range('158:', '163:'),	# EC Loop 2.3
                         self.residue_range('198:', '214:'),	# IC Loop 3.1
                         self.residue_range('222:', '296:'),	# IC Loop 3.2
                         self.residue_range('324:', '325:'),	# EC Loop 3.1
                         self.residue_range('329:', '335:'),	# EC Loop 3.2
                         self.residue_range('372:', '380:'))	# C-terminal loop

a = MyLoop(env,
              alnfile  = al, #'Bd_1U19.ali',     # alignment filename
              knowns = kwns, #   = 'Btau|1U19',              		# codes of the templates
              sequence = seq, #uence = 'Bden|BDEG_04847modLong',           # code of the target
	      loop_assess_methods=assess.DOPE) 		# assess each loop with DOPE)
a.starting_model= 1                 # index of the first model
a.ending_model  = 1                 # index of the last model
                                    # (determines how many models to calculate)

a.loop.starting_model = 1           # First loop model
a.loop.ending_model   = 1           # Last loop model

a.make()                            # do homology modeling

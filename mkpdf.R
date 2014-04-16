#!/usr/bin/env Rscript
# Script: mkpdf.R
# Description: R script to use Sweave to convert LaTeX file to pdf and display
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 6.1.11
#         v1.0  
#         v1.2  : added option for running BibTeX
####################################
# Usage: mkpdf.R Rnwfile [-b] [-v] #             
#########################################################################################
# When using BibTeX option, be sure that if "file.Rnw" exists, so too should "file.bib" #
#########################################################################################

args <- commandArgs();
help <- grep("-h",args)
rnw <- grep("\\.Rnw",args)
if(length(help)) {
  print("Usage: mkpdf.R file.Rnw [-b] [-v]")
} else if(length(rnw)) {
    file <- args[rnw];
    bib <- grep("-b",args) # check for addtional "-b" argument
    file
    filename <- strsplit(file,"\\."); filename <- filename[[1]][1];
    Sweave(file);
    pdflatex <- paste(c("pdflatex",filename), collapse=" ");
    system(pdflatex); 
    if(length(bib))
    {
      bibtex <- paste(c("bibtex",filename),collapse=" ");
      system(bibtex)
      system(pdflatex); 
      system(pdflatex); 
    }
    evince <- grep("-v",args) # check for "view" argument (open up evince)
    if(length(evince))
    {
      evince <- paste(c("evince", paste(c(filename,"pdf"),collapse="."), "&" ),collapse=" ");
      system(evince)
    }
} else {
    print("No .Rnw file provided.")
    print("Be sure you included the .Rnw file extension.")
}

#!/usr/bin/env Rscript
# Script: mkpdf.R
# Description: R script to use Sweave to convert LaTeX file to pdf and display
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 2.5.15
#         v1.0  
#         v1.2  : added option for running BibTeX
#         v1.3  : added option for cleaning .aux file first
####################################
# Usage: mkpdf.R Rnwfile [-b] [-v] [-c] #             
#########################################################################################
# When using BibTeX option, be sure that if "file.Rnw" exists, so too should "file.bib" #
#########################################################################################

args <- commandArgs();
help <- grep("-h",args)
tex <- grep("\\.tex",args)
if(length(help)) {
  print("Usage: mkpdf.R file.tex [-b] [-v] [-c]")
} else if(length(tex)) {
    file <- args[tex];
    filename <- strsplit(file,"\\."); filename <- filename[[1]][1];
    clean <- grep("-c",args) # Check for "clean" argument
    if(length(clean))
    {
      clean <- paste(c("rm",paste(c(filename,"aux"),collapse=".")),collapse=" ");
      system(clean);
    }
    bib <- grep("-b",args) # check for addtional "-b" argument
    file
    #Sweave(file);
    pdflatex <- paste(c("pdflatex",filename), collapse=" ");
    system(pdflatex); 
    if(length(bib))
    {
      bibtex <- paste(c("bibtex",filename),collapse=" ");
      system(bibtex);
      system(pdflatex); 
      system(pdflatex); 
    }
    evince <- grep("-v",args) # check for "view" argument (open up evince)
    if(length(evince))
    {
      evince <- paste(c("evince", paste(c(filename,"pdf"),collapse="."), "&" ),collapse=" ");
      system(evince);
    }
} else {
    print("No .tex file provided.")
    print("Be sure to include the .tex file extension.")
}

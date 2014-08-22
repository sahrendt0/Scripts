######################
## RNA-Seq Pipeline ##
######################

############################
## (A) Organize data sets ##
############################
## Genome reference from TAIR:
## ftp://ftp.arabidopsis.org/home/tair/Sequences/whole_chromosomes/
## Download all seven chromosomes and concatenate to one file

## system("wget ftp://ftp.arabidopsis.org/home/tair/Sequences/whole_chromosomes/chr1.fas")
## system("wget ftp://ftp.arabidopsis.org/home/tair/Sequences/whole_chromosomes/chr2.fas")
## system("wget ftp://ftp.arabidopsis.org/home/tair/Sequences/whole_chromosomes/chr3.fas")
## system("wget ftp://ftp.arabidopsis.org/home/tair/Sequences/whole_chromosomes/chr4.fas")
## system("wget ftp://ftp.arabidopsis.org/home/tair/Sequences/whole_chromosomes/chr5.fas")
## system("wget ftp://ftp.arabidopsis.org/home/tair/Sequences/whole_chromosomes/chrM.fas")
## system("wget ftp://ftp.arabidopsis.org/home/tair/Sequences/whole_chromosomes/chrC.fas")

## system("cat chr1.fas chr2.fas chr3.fas chr4.fas chr5.fas chrM.fas chrC.fas > At_TAIR10_whole_genome.fas")
## /home/sahrendt/girke_lab/rna_seq/At_TAIR10_chr/At_TAIR10_whole_genome.fas
## genome <- At_TAIR10_whole_genome.fas

## Genome annotations in GFF3 format:
## wget ftp://ftp.arabidopsis.org/home/tair/Genes/TAIR10_genome_release/TAIR10_gff3/TAIR10_GFF3_genes.gff

## RNA-Seq FASTQ files from SRA:
## fastq-dump






############################################
## (B) Align RNA-Seq samples to reference ##
############################################
## add Steven's code



## bwa_align
# Arguments:
#       query: short read dataset in fastq format
#       genome: genome file in fas format, located in "genomedir"
#         (currently, individual chromosomes are located in /home/sahrendt/girke_lab/rna_seq/At_TAIR10_chr/)
# Output:
#       Step1: runs bwa alignment with default settings
#       Step2: generates SAM formatted files
#       Step3: converts SAM to BAM files (using samtools)
# Example:
#       bwa_align("SRR064155","chr1") produces "SRR064155_chr1_aln.bam"
#               as well as "SRR064155_chr1_aln.sam" and "SRR064155_chr1_aln.sai"

samples <- c("SRR064154", "SRR064155", "SRR064166", "SRR064167")
samplesfastqpath <- paste("/home/sahrendt/girke_lab/rna_seq/", samples, "/", samples, sep="")
genomedir <- "/home/sahrendt/girke_lab/rna_seq/At_TAIR10_chr/"
## genome <- "At_TAIR10_whole_genome"

bwa_align <- function(query,genome) {
        gfile <- paste(c(genomedir,genome,".fas"),collapse="")
        qfile <- paste(c(query,"fastq"),collapse=".")
        output <- paste(c(query,genome,"aln"),collapse="_")
        ofile <- paste(c(output,"sai"),collapse=".")
        step1 <- paste(c("bwa aln",gfile,qfile,">",ofile),collapse=" ")
        system(step1)	# run bwa alignment
        step2 <- paste(c("bwa samse -n -1",gfile,ofile,qfile,">",paste(c(output,"sam"),collapse=".")),collapse=" ")
        system(step2)	# generate SAM files
        step3 <- paste(c("samtools view -bST",gfile,paste(c(output,"sam"),collapse="."),"-o",paste(c(output,"bam"),collapse=".") ),collapse=" ")
        system(step3)	# convert SAM files to BAM files
}

for(i in samplesfastqpath) {
	bwa_align(i,genome)
}

## SIBam
# Arguments:
#	.bam filename (without extension) from bwa_align execution
# Output:
#	sorts and indexes .bam files
# Example:
#	SIBam("SRR064155_chr1_aln") produces "SRR064155_chr1_aln.sorted.bam" and "SRR064155_chr1_aln.sorted.bam.bai"
library(RSamtools)
SIBam <- function(output) {
        sortBam(paste(c(output,"bam"),collapse="."), paste(c(output,"sorted"),collapse="."))	
        indexBam(paste(c(output,"sorted","bam"),collapse="."))
}

samplesbampath <- paste("/home/sahrendt/girke_lab/rna_seq/", samples, "/", samples, "_chr1_aln", sep="")

for(i in samplesbampath) {
	SIBam(i)
}

###################################################################
## (C) Enumerate read counts for annotation ranges from GFF file ##
###################################################################

## Annotation data from GFF
library(rtracklayer); library(GenomicFeatures)
gff <- import.gff("/home_girkelab/tgirke/Projects/Rotation_Project_RNA-Seq/reference/TAIR10_GFF3_genes.gff")
gff <- as(gff, "GRanges") # Coerce to GRanges object
subgene_index <- which(elementMetadata(gff)[,"type"] == "gene")
gffsub <- gff[subgene_index,] # Returns only gene ranges
ids <- elementMetadata(gffsub)[, "group"]
gffsub <- split(gffsub) # Coerce to GRangesList

## Count reads from all samples that overlap annotation ranges (e.g. genes)
library(GenomicRanges); library(Rsamtools)
samples <- c("SRR064154", "SRR064155", "SRR064166", "SRR064167")
samplespath <- paste("/home/sahrendt/girke_lab/rna_seq/", samples, "/", samples, "_chr1_aln.sorted.bam", sep="")
countDF <- data.frame(row.names=ids)
for(i in samplespath) {
	aligns <- readBamGappedAlignments(i)
	counts <- countOverlaps(gffsub, aligns)
	countDF <- cbind(countDF, counts)
}
colnames(countDF) <- samples

## Convert to RPKM 
returnRPKM <- function(counts, gffsub) {
	geneLengthsInKB <- sum(width(gffsub))/1000 # Number of bases per exonRanges element in kbp
	millionsMapped <- sum(counts)/1e+06 # Factor for converting to million of mapped reads.
	rpm <- counts/millionsMapped # RPK: reads per kilobase of exon model.
	rpkm <- rpm/geneLengthsInKB # RPKM: reads per kilobase of exon model per million mapped reads. 
	return(rpkm)
}
countDFrpkm <- apply(countDF, 2, function(x) returnRPKM(counts=x, gffsub=gffsub))


#######################
## (D) Identify DEGs ##
#######################

## DESeq method
library(DESeq)
conds <- c("AP3Translatome4","AP3Translatome4","Translatome4","Translatome4") # these are only for our samples: SRR064154, SRR064155, SRR064166, and SRR064167 respectively; will need to change for different samples
cds <- newCountDataSet(countDF, conds)
cds <- estimateSizeFactors(cds)
cds <- estimateVarianceFunctions(cds)
T4_AP3T4.res <- nbinomTest(cds,"Translatome4","AP3Translatome4")



####################################################################
## (E) Enrichment of functional annotation (GO) terms in DEG sets ##
####################################################################

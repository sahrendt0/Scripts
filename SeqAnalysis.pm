package SeqAnalysis;
# Name: SeqAnalysis.pm
# Description: Perl module containing often-used subroutines for sequence processing
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 1.31.14
#######################
# Functionality includes:
#  [x] gc content               : getGC(str dna)
#  [x] protein mass             : getProtMass(str prot)
#  [x] N50                      : N50(str filename)
#  [x] hamming distance         : getHammDist(str dna1, str dna2)
#  [x] reverse complement       : getRevComp(str dna)
#  [x] transcribe to RNA        : transcribe(str dna)
#  [x] motif finding            : getMotifPos(str seq, str match)
#  [x] 6 frame translation      : getSixFrame(str dna)
#  [ ] reverse translation      : revTrans(str prot)
#  [x] get profile from align   : getProfile(hash_ref alignment)
#  [x] get consensus from prof  : getConsensus(hash_ref profile)
#  [x] remove an intron         : removeIntron(str dna, str intron)
#  [x] transition/transversion  : getTTRatio(str dna1, str dna2)
#  [x] get sequences            : getSeqs(str fasta_filename, arrayref accnos)
#  [x] seq to hash              : seq2hash(str seq)
#  [x] hmmscan/search parse     : hmmParse(str filename)
#  [x] initNCBI                 : initNCBI(str mode)
#  [x] get taxonomy for species : getTaxonomybySpecies(str genus_species)
#  [ ] get taxonomy for species : getTaxonomybyID(str taxid)
#  [x] print taxonomy		: printTaxonomy(hash_ref taxonomy)
#  [x] index fastafile          : indexFasta(str filename)
#  [x] remove sequence		: removeSeq(str accno)
#  [x] hash PFAM		: hashPFAM(str filename)
#  [ ] dinucleotide		: diNucDist(str sequence)
########################
use strict;
use warnings;
use Bio::Perl;
use Bio::Seq;
use Bio::SeqIO;
use Bio::Taxon;
use Bio::DB::EUtilities;
use Data::Dumper;
use base 'Exporter';  # to export our subroutines

our @EXPORT = qw(seq2hash 
                 getSeqs 
                 getTTRatio 
                 removeIntron 
                 getConsensus 
                 getProfile 
                 revTrans 
                 getSixFrame 
                 seqTranslate 
                 getMotifPos 
                 getGC 
                 getProtMass 
                 getHammDist 
                 getRevComp
                 transcribe 
                 hmmParse 
                 getTaxonomybySpecies
                 initNCBI
                 getTaxonomybyID 
                 indexFasta
                 printTaxonomy
                 hashPFAM
                 %CODONS_1
                 diNucDist
                 N50
); # export always

our %CODONS_3 = ("MET" => ["ATG"],
                 "ILE" => ["ATA","ATC","ATT"],
                 "ARG" => ["CGG","CGT","CGA","CGC","AGG","AGA"],
                 "GLN" => ["CAG","CAA"],
                 "HIS" => ["CAC","CAT"],
                 "PRO" => ["CCA","CCG","CCC","CCT"],
                 "LEU" => ["CTT","CTA","CTC","CTG","TTA","TTG"],
                 "TRP" => ["TGG"],
                 "CYS" => ["TGC","TGT"],
                 "TYR" => ["TAT","TAC"],
                 "PHE" => ["TTT","TTC"],
                 "GLY" => ["GGG","GGT","GGC","GGA"],
                 "GLU" => ["GAA","GAG"],
                 "ASP" => ["GAT","GAC"],
                 "ALA" => ["GCC","GCA","GCT","GCG"],
                 "VAL" => ["GTA","GTC","GTG","GTT"],
                 "SER" => ["TCA","TCT","TCG","TCC","ATC","AGT"],
                 "LYS" => ["AAA","AAG"],
                 "ASN" => ["AAT","AAC"],
                 "THR" => ["ACA","ACT","ACC","ACG"],
                 "***" => ["TGA","TAA","TAG"]);

our %CODONS_1 = ("M" => ["ATG"],
                 "I" => ["ATA","ATC","ATT"],
                 "R" => ["CGG","CGT","CGA","CGC","AGG","AGA"],
                 "Q" => ["CAG","CAA"],
                 "H" => ["CAC","CAT"],
                 "P" => ["CCA","CCG","CCC","CCT"],
                 "L" => ["CTT","CTA","CTC","CTG","TTA","TTG"],
                 "W" => ["TGG"],
                 "C" => ["TGC","TGT"],
                 "Y" => ["TAT","TAC"],
                 "F" => ["TTT","TTC"],
                 "G" => ["GGG","GGT","GGC","GGA"],
                 "E" => ["GAA","GAG"],
                 "D" => ["GAT","GAC"],
                 "A" => ["GCC","GCA","GCT","GCG"],
                 "V" => ["GTA","GTC","GTG","GTT"],
                 "S" => ["TCA","TCT","TCG","TCC","ATC","AGT"],
                 "K" => ["AAA","AAG"],
                 "N" => ["AAT","AAC"],
                 "T" => ["ACA","ACT","ACC","ACG"],
                 "*" => ["TGA","TAA","TAG"]);

our %prot_mass = ('A' => 71.03711,
                  'C' => 103.00919,
                  'D' => 115.02694,
                  'E' => 129.04259,
                  'F' => 147.06841,
                  'G' => 57.02146,
                  'H' => 137.05891,
                  'I' => 113.08406,
                  'K' => 128.09496,
                  'L' => 113.08406,
                  'M' => 131.04049,
                  'N' => 114.04293,
                  'P' => 97.05276,
                  'Q' => 128.05858,
                  'R' => 156.10111,
                  'S' => 87.03203,
                  'T' => 101.04768,
                  'V' => 99.06841,
                  'W' => 186.07931,
                  'Y' => 163.06333);

our %AA = ("ATG" => "M",
           "ATA" => "I",
           "ATC" => "I",
           "ATT" => "I",
           "CGG" => "R",
           "CGT" => "R",
           "CGA" => "R",
           "CGC" => "R",
           "AGG" => "R",
           "AGA" => "R",
           "CAG" => "Q",
           "CAA" => "Q",
           "CAC" => "H",
           "CAT" => "H",
           "CCA" => "P",
           "CCG" => "P",
           "CCC" => "P",
           "CCT" => "P",
           "CTT" => "L",
           "CTA" => "L",
           "CTC" => "L",
           "CTG" => "L",
           "TTA" => "L",
           "TTG" => "L",
           "TGG" => "W",
           "TGC" => "C",
           "TGT" => "C",
           "TAT" => "Y",
           "TAC" => "Y",
           "TTT" => "F",
           "TTC" => "F",
           "GGG" => "G",
           "GGT" => "G",
           "GGC" => "G",
           "GGA" => "G",
           "GAA" => "E",
           "GAG" => "E",
           "GAT" => "D",
           "GAC" => "D",
           "GCC" => "A",
           "GCA" => "A",
           "GCT" => "A",
           "GCG" => "A",
           "GTA" => "V",
           "GTC" => "V",
           "GTG" => "V",
           "GTT" => "V",
           "TCA" => "S",
           "TCT" => "S",
           "TCG" => "S",
           "TCC" => "S",
           "ATC" => "S",
           "AGT" => "S",
           "AAA" => "K",
           "AAG" => "K",
           "AAT" => "N",
           "AAC" => "N",
           "ACA" => "T",
           "ACT" => "T",
           "ACC" => "T",
           "ACG" => "T",
           "TGA" => "*",
           "TAA" => "*",
           "TAG" => "*");

#####
## Subroutine: N50
#    Input: string filename
#    Returns: N50 value
########
sub N50
{
  my $filename = shift @_;
  my $verb = shift @_;
  my $N50 = 0;
  my @lengths;
  my $sum = 0;
  my $seqobj_io = Bio::SeqIO->new(-file => $filename,
                                  -format => "fasta");
  while(my $seq = $seqobj_io->next_seq)
  {
    push (@lengths,length($seq->seq));
    $sum += length($seq->seq);
  }

  my $total=0;
  print "$sum total bases\n" if($verb);
  foreach my $size (sort {$b <=> $a} @lengths)
  {
    #print "$size\n";
    $N50 = $size;
    $total += $size;
    last if ($total > ($sum/2));
  }
  return $N50;
}

#####
## Subroutine: diNucDist
#    Input: sequence (string)
#    Returns: hash of dinucleotide (distribution)
########
sub diNucDist
{
  my %hash;
  my $seq = shift @_;
  my @seq1 = $seq =~ /(.{2})/g;
  my @seq2 = substr($seq,1) =~ /(.{2})/g;
  my @both = (@seq1,@seq2);
  foreach my $diNuc (@both)
  {
    $hash{$diNuc}++;
  }
  return %hash;
}

##### 
## Subroutine: hashPFAM
########
sub hashPFAM
{
  my %hash;
  my $infile = shift @_;
  open(my $fh, "<", $infile) or die "Can't open $infile: $!\n";
  while(my $line = <$fh>)
  {
    chomp $line;
    next if($line =~ /^#/);
    my ($PROTEIN_NAME, $LOCUS, $GENE_CONTIG, $PFAM_ACC, $PFAM_NAME, $PFAM_DESCRIPTION, $PFAM_START, $PFAM_STOP, $LENGTH, $PFAM_SCORE, $PFAM_EXPECTED) = split(/\s+/,$line);
    $PFAM_ACC =~ s/\.\d+$//;
    $hash{$LOCUS}{$PFAM_ACC}{"Desc"} = $PFAM_DESCRIPTION; 
    $hash{$LOCUS}{$PFAM_ACC}{"Score"} = $PFAM_SCORE; 
    $hash{$LOCUS}{$PFAM_ACC}{"Eval"} = $PFAM_EXPECTED; 
  }
  close($fh);
  return %hash;
}


#####
## Subroutine: indexFasta
#    Input: fasta filename (string)
#    Returns: hash of fasta file
#######
sub indexFasta
{
  my $fastafile = shift @_;
  my $obj = Bio::SeqIO->new(-file => $fastafile,
                            -format => "fasta");
  my %hash;
  while (my $seq = $obj->next_seq)
  {
    $hash{$seq->display_id} = $seq;
  }
  return %hash;
}

#####
## Subroutine: initNCBI
#    Input: mode of taxonomy db (string; "entrez" or "flatfile")
#    Returns: Bio::DB::Taxonomy object
#######
sub initNCBI
{
 # my $species = shift @_;
  my $mode = shift @_;
 # my $verb = shift @_;
 # print $species if $verb;
 # print "($mode)\n" if $verb;
  #my %tax_hash;
  my $NCBI_TAX;
  if($mode eq "flatfile")
  {
    my $tax_dir = "/rhome/sahrendt/bigdata/Data/Taxonomy";
    my $nodesfile = "$tax_dir/nodes.dmp";
    my $namesfile = "$tax_dir/names.dmp";
    my $indexdir = "$tax_dir";
    $NCBI_TAX = Bio::DB::Taxonomy->new(-source => 'flatfile',
                                       -directory => $tax_dir,
                                       -namesfile => $namesfile,
                                       -nodesfile => $nodesfile);
    #print $NCBI_TAX->index_directory,"\n";
  }
  else
  {  
    $NCBI_TAX = Bio::DB::Taxonomy->new(-source => 'entrez');
  }
  return $NCBI_TAX;
}

#####
## Subroutine: getTaxonomybyID
#    Input:
#    Returns: hash of taxonomy
#######
sub getTaxonomybyID
{
  my $NCBI_TAX = shift @_; ## Bio::DB::Taxonomy object
  my $taxid = shift @_;
  my %tax_hash;
  if(my $taxon = $NCBI_TAX->get_taxon(-taxonid => $taxid))
  {
    my $tree = $NCBI_TAX->get_tree($taxon->scientific_name);
    my $root = $tree->get_root_node;
    my $curr_node = $root;
    while(my @nodes = $curr_node->each_Descendent)
    {
      $curr_node = $nodes[0];
      my $id = $curr_node->id;
      my $rank = $curr_node->rank;
      my $name = $curr_node->scientific_name;
#      my $factory = Bio::DB::EUtilities->new(-eutil => 'esummary',
#                                             -db    => 'taxonomy',
#                                             -id    => $id );
#      my ($name) = $factory->next_DocSum->get_contents_by_name("ScientificName");
      $tax_hash{$taxid}{$rank} = $name;
    }
  }
  else
  {
    warn "Failed: <$taxid>\n";
    $tax_hash{$taxid}{"phylum"} = "no_rank";
  }
  return \%tax_hash;
}

#####
## Subroutine: getTaxonomybySpecies
#    Input:
#    Returns: hash of taxonomy
#######
sub getTaxonomybySpecies
{
  my $NCBI_TAX = shift @_; ## Bio::DB::Taxonomy object
  my $species = shift @_;
  my %tax_hash;
  if(my $taxonid = $NCBI_TAX->get_taxonid($species))
  {
    my $tree = $NCBI_TAX->get_tree($species);
    my $root = $tree->get_root_node;
    my $curr_node = $root;
    while(my @nodes = $curr_node->each_Descendent)
    {
      $curr_node = $nodes[0];
      my $id = $curr_node->id;
      my $rank = $curr_node->rank;
      my $factory = Bio::DB::EUtilities->new(-eutil => 'esummary',
                                             -db    => 'taxonomy',
                                             -id    => $id );
      my ($name) = $factory->next_DocSum->get_contents_by_name("ScientificName");
      $tax_hash{$rank} = $name;
    }
    return \%tax_hash;
  }
  else
  {
    warn "Failed: <$species>\n";
    if ($species =~ /^\S+$/)
    {
      warn "<$species> is just one word; nothing more to do\n";
      $tax_hash{"kingdom"} = "NULL";
      return \%tax_hash;
    }
    my $genus = (split(/\s/,$species))[0];
    warn "Try again with <$genus>\n";
    my $ret = getTaxonomybySpecies($NCBI_TAX,$genus);
    return $ret;
  }
}
##########
## Subroutine printTaxonomy
#    Input: reference to taxonomy hash
#           reference to array of taxonomic ranks to use
#           name of specific species (leave blank to print all)
#    Returns: none; prints to STDOUT
################
sub printTaxonomy
{
  #my $tax = shift @_;
  my %tax_hash = %{shift @_};
  my @ranks = @{shift @_};
  my $spec = shift @_;
  my $acc = shift @_;
  my @species;
  my $nr = 0; # counter for levels w/ no rank
  my $str_to_print = "$acc\t";  # final formatted string to print if all checks are met
  if($spec eq "")
  {
    @species = sort keys %tax_hash;
  }
  else
  {
    push @species, $spec;
  }
  foreach my $name (@species)
  {
    #print $name,"\t";
    for(my $rc = 0; $rc < scalar(@ranks);$rc++)
    {
      my $rank = lc($ranks[$rc]);
      my $fl = (split(//,$rank))[0];
      $str_to_print .= "$fl\__";
      if (exists $tax_hash{$name}{$rank})
      {
        $str_to_print .= $tax_hash{$name}{$rank};
      }
      else
      {
        if($rank eq "species")
        {
          $str_to_print .= $name;
        }
        else
        {
          #print "no_rank";
          warn "$name has no_rank at $rank\n";
          $nr++;
          my @fuzzy_ranks = grep {/$rank/} keys %{$tax_hash{$name}};
          if(scalar(@fuzzy_ranks) > 0) 
          {
            warn "possible alternatives: @fuzzy_ranks\n";
            if(scalar(@fuzzy_ranks) == 1)
            {
              warn "using $fuzzy_ranks[0]";
              $str_to_print .= "$tax_hash{$name}{$fuzzy_ranks[0]}";
              $nr--;
            }
          }
          else
          {
            $str_to_print .= "no_rank";
          }
          warn Dumper \%tax_hash;
        }
        ## todo: fuzzy match to existing ranks
        #  eg. if no_rank is "class", grab "subclass" instead
      }
      $str_to_print .= ";" if($rc != (scalar(@ranks)-1));
    }
    if($nr > 0)
    {
      warn "Errors with $name: data missing from critical taxonomic levels.\n";
      open(my $fh,">>", "Failed");
      print "$acc\to__noRank\n";
      print $fh "$acc\n";
      close($fh);
    }
    else
    {
      print "$str_to_print\n";
    }
  }
}

#####
## Subroutine: hmmParse
#    Input: filename (must be m8 format)
#           ret_val ("return as" value; default is hash)
#    Returns: array with:  hash of counts and hash of data
#######
sub hmmParse
{
  my $hmmfile = shift @_;
  my $ref = shift @_;
  my %hits;
  my %hash;
  my @ret;

  my (@seqs,%genes,$gene,$PFAM);
#  my ($type,$tmp,$org,$mod,$ext);
#  my @flags; # flags for positions of gene, PFAM, type, org
  my @filename = split(/[\-|\.|\_]/,$hmmfile);
#  $tmp = $filename[1]; # "vs"
#  $mod = $filename[3]; # "tbl"
  my $ext = $filename[-1];
  #warn $ext,"\n";
#  if($ext =~ m/scan/)
#  {
#    @flags = (1,0,2,0);
#  }
#  if($ext =~ m/search/)
#  {
#    @flags = (0,1,0,2);
#  }
#  $type = $filename[$flags[2]];
#  $all_types{$type}++;
#  $org = $filename[$flags[3]];

  open(HMM, "<$hmmfile") || die "Can't open file \"$hmmfile\".\n";
  foreach my $line (<HMM>)
  {
    chomp $line;
    next if($line =~ m/^#/);
    my ($t_name,$t_acc,$q_name,$q_acc,$full_eval,$full_score,$full_bias,$best_eval,$best_score,$best_bias,$dom_exp,$dom_reg,$dom_clu,$dom_ov,$dom_env,$dom_dom,$dom_rep,$dom_inc,@desc) = split(/\s+/,$line);
    if($ext =~ /scan/)
    {
      $gene = $q_name;
      $PFAM = join(";", (split(/\./,$t_acc))[0], $t_name);
      $hash{$q_name}{$t_acc}{"Desc"} = $t_name; 
      $hash{$q_name}{$t_acc}{"Score"} = $full_score; 
      $hash{$q_name}{$t_acc}{"Eval"} = $full_eval; 
    }
    if($ext =~ /search/)
    {
      $gene = $t_name;
      $PFAM = join(";",(split(/\./,$q_acc))[0],$q_name);
      $hash{$t_name}{$q_acc}{"Desc"} = $q_name; 
      $hash{$t_name}{$q_acc}{"Score"} = $full_score; 
      $hash{$t_name}{$q_acc}{"Eval"} = $full_eval; 
    }
    $hits{$PFAM}++;
    #$hash{$t_name}{$q_acc}{"Desc"} = $q_name; 
    #$hash{$t_name}{$q_acc}{"Score"} = $full_score; 
    #$hash{$t_name}{$q_acc}{"Eval"} = $full_eval; 
  }
  push (@ret, \%hash);
  push (@ret, \%hits);
  return @ret;

 # if($ref)
 # {
 #   return \%hash;
 # }
 # else
 # {
 #   return %hash;
 # }
}

#####
## Subroutine: getSeqs
#    Input: Sequence hash, accnos array
#    Returns: none; write out to file
#######
sub getSeqs
{
  my $fasta_name = shift @_;
  my $accnos = shift @_;
  my $seq_in = Bio::SeqIO->new(-file => "<$fasta_name",
                               -format => "fasta");
  my $seq_out = Bio::SeqIO->new(-file => ">out",
                                -format => "fasta");
  my %fasta;
  while(my $seq = $seq_in->next_seq)
  {
    $fasta{$seq->display_id} = $seq;
  }

  foreach my $acc (@{$accnos})
  {
    if(exists $fasta{$acc})
    {
      $seq_out->write_seq($fasta{$acc});
    }
  }
}

sub changeType
{
  my $base1 = uc(shift @_);
  my $base2 = uc(shift @_);
  my $change = "none";

  if($base1 eq "A")
  {
    if($base2 eq "G")
    {
      $change = "transition";
    }
    elsif(($base2 eq "C") or ($base2 eq "T"))
    {
      $change = "transversion";
    }
  }
  elsif($base1 eq "G")
  {
    if($base2 eq "A")
    { 
      $change = "transition";
    }
    elsif(($base2 eq "C") or ($base2 eq "T"))
    { 
      $change = "transversion";
    }
  }
  elsif($base1 eq "C")
  {
    if($base2 eq "T")
    {    
      $change = "transition";
    }
    elsif(($base2 eq "G") or ($base2 eq "A"))
    {     
      $change = "transversion";
    }
  }
  else # T
  {
    if($base2 eq "C")
    {    
      $change = "transition";
    }
    elsif(($base2 eq "G") or ($base2 eq "A"))
    {    
      $change = "transversion";
    }
  }
  return $change;
}

#####
## Subroutine: getTTRatio
#    Input: two dna strings
#    Returns: ratio
########
sub getTTRatio
{
  my @seq1 = split(//,shift @_);
  my @seq2 = split(//,shift @_);
  my %changes = ("transition"  => 0,
                 "transversion" => 0,
                 "none"         => 0);

  my $TTRatio = 0;

  for(my $i=0;$i<scalar(@seq1);$i++)
  {
    $changes{changeType($seq1[$i],$seq2[$i])}++;
  }
  $TTRatio = $changes{"transition"} / $changes{"transversion"};
  return $TTRatio;
}

#####
## Subroutine: removeIntron
#    Input: dna string and intron
#    Returns: DNA string without intron
########
sub removeIntron
{
  my $seq = shift @_;
  my $intron = shift @_;
  my $result = $seq;
  if($seq =~ /(.*)$intron(.*)/)
  {
    $result = $1.$2;
  }
  return $result;
}


#####
## Subroutine: getConsensus
#    Input:
#    Returns: 
########
sub getConsensus
{
  my %profile = %{shift @_};
  my $cons = "";
  my $al_len = scalar @{$profile{'A'}};
  for(my $i=0;$i<$al_len;$i++)
  {
    my $max = 0;
    my $c = "";
    foreach my $key (keys %profile)
    {
      my $value = $profile{$key}[$i];
      if($value > $max)
      {
        $max = $value;
        $c = $key;
      }
    }
   $cons .= $c;
  }

  return $cons;
}

#####
## Subroutine: getProfile
#    Input: hash of aligned sequences
#    Returns: hash of profile
########
sub getProfile
{
  my $align = shift @_; # hash reference
  my @accnos = sort(keys(%{$align}));  
  my $al_len = length($align->{$accnos[0]});
  
  my @init;
  my %profile = ('A' => [],
                 'T' => [],
                 'G' => [],
                 'C' => []);

  for(my $i=0;$i<$al_len;$i++)
  {
    foreach my $key (keys %profile)
    {
      $profile{$key}[$i] = 0;
    }
  }
 
  for(my $i=0;$i<$al_len;$i++)
  {
    foreach my $acc (@accnos)
    {
      my @seq = split(//,$align->{$acc});
      $profile{$seq[$i]}[$i]++;
    }
  }

  return %profile;
}

#####
## Subroutine: seqTranslate
#    Input: DNA string
#    Returns: use BioPerl to translate sequence
########
sub seqTranslate
{
  my $seq = shift @_;
  my $seq_obj = Bio::Seq->new(-seq => $seq);
  return $seq_obj->translate->seq;
}

#####
## Subroutine: revTrans
#    Input: protein string (one-letter)
#    Returns: total num of possible RNA strings for protein (mod 1,000,000)
########
sub revTrans
{
  my $prot = shift @_;
  my $num_RNA = 1;
  if($prot !~ /\*$/)
  {
    $prot .= "*";
  }
  foreach my $aa (split(//,$prot))
  {
    $num_RNA *= scalar(@{$CODONS_1{$aa}});
  }
  return ($num_RNA%1000000);
}

#####
## Subroutine: getSixFrame
#    Input: string of DNA
#    Returns: array of unique potential orfs
########
sub getSixFrame
{
  my $seq = shift @_;
  my $rc = getRevComp($seq);
  my @frame1 = $seq =~ /(.{3})/g;
  my @frame2 = substr($seq,1) =~ /(.{3})/g;
  my @frame3 = substr($seq,2) =~ /(.{3})/g;
  my @frame4 = $rc =~ /(.{3})/g;
  my @frame5 = substr($rc,1) =~ /(.{3})/g;
  my @frame6 = substr($rc,2) =~ /(.{3})/g;
  my %orfs;
  my @frames = (\@frame1,\@frame2,\@frame3,\@frame4,\@frame5,\@frame6);
  foreach my $frame (@frames)
  {
    my $len = scalar(@{$frame}); 
    for(my $i=0;$i<$len;$i++)
    {
      my $codon = @{$frame}[$i];
      if($codon eq "ATG")
      {
        my @tmp = ($codon);
        #print "$codon($i)<$len>:";
        my @sub = @{$frame}[($i+1)..($len-1)];
        #print "@sub";
        my $j=0;
        while($j < scalar(@sub))#   $j<scalar(@sub))
        {
          #print "$sub[$j]:";
          if($sub[$j] =~ /TAA|TAG|TGA/)
          {
            $orfs{seqTranslate(join("",@tmp))}++;
            last;
          }
          push (@tmp,$sub[$j]);
          $j++;
        }
        #print "\n";
      }
    }
  }
  return %orfs;
}

#####
## Subroutine: getMotifPos
#    Input: sequence,pattern
#    Returns: Array of positions of each match (0 index)
#    Works using "sliding window" of length of match
########
sub getMotifPos
{
  my $seq = shift @_;
  my $match = shift @_;
  my @matches;
  for(my $i=0;$i<length($seq);$i++)
  {
    if(substr($seq,$i,length($match)) eq $match)
    {
      push(@matches,$i);
    }
  }
  return @matches;
}


#####
## Subroutine: getRevComp
#    Input: a DNA string
#    Returns: the reverse complement
########
sub getRevComp
{
  my $seq = shift @_;
  my $rc = reverse $seq;
  $rc =~ tr/ATGCatgc/TACGtacg/;
  return $rc;
}

#####
## Subroutine: transcribe
#    Input: a DNA string
#    Returns: the RNA string
########
sub transcribe
{
  my $seq = shift @_;
  $seq =~ tr/Tt/Uu/;
  return $seq;
}

#####
## Subroutine: getProtMass
#    Input: a protein string
#    Returns: the mass of the protein in kDa
#    Calls: initProtMass
#########
sub getProtMass
{
  my $seq = shift @_;
  my $mass = 0;
  foreach my $res (split(//,uc($seq)))
  {
    $mass += $prot_mass{$res};
  }
  return $mass;
}

#####
# Subroutine: getHammDist
#    Input: two strings
#    Returns: the hamming distance between the two
#########
sub getHammDist
{
  my $str1 = shift @_;
  my @str1 = split(//,$str1);
  my $str2 = shift @_;
  my @str2 = split(//,$str2);
  my $hamm = 0;  # the Hamming Distance b/w str1 and str2
  for(my $i=0;$i<scalar(@str1); $i++)
  {
    #print "$str1[$i] :: $str2[$i]\n";
    if($str1[$i] ne $str2[$i])
    {
      $hamm++;
    }
  }
  return $hamm;
}

#####
## Subroutine: seq2hash
#    Input: a string
#    Returns: a hash, where keys are the bases / residues and values are counts
########
sub seq2hash
{
  my $seq = shift @_;
  my %ret;
  foreach my $item (split(//,$seq))
  {
    $ret{$item}++;
  }
  
  return %ret;
}

#####
## Subroutine: isDNA 
#    Input: a string
#    Returns: 1 if string is DNA, 0 otherwise
#########
sub isDNA
{
  my $seq = shift @_;
  my $isDNA = 0;
  my %seq = seq2hash($seq);
    
  return $isDNA;
}

#####
## Subroutine: getGC
#    Input: a DNA sequence
#    Returns: decimal representation of GC-content
#########
sub getGC
{
  my $seq = shift @_;
  my $gc = 0;
  foreach my $base (split(//,uc($seq)))
  {
    if(($base eq "G") or ($base eq "C"))
    {
      $gc++;
    }
  } 
  return $gc/length($seq);
}

1;

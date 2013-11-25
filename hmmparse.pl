#!/usr/bin/perl 
# Script: hmmparse.pl
# Description: Parses an HMM result file, scan or search
# Author: Steven Ahrendt
# email: sahrend0@gmail.com
# Date: 4.12.13
#         - gather sequences by default
#####################################
# Usage: perl hmmparse.pl [-v] -a [-i input]
#####################################
# If -a argument is used, no need for filename
#####################################

use strict;
use warnings;
use Bio::Seq;
use Bio::SeqIO;
use Bio::SearchIO;
use Getopt::Long qw(:config bundling);

my (%hits,@files,%all_types);
my $pep_dir = "/rhome/sahrendt/bigdata/Genomes/Protein/";
my $results_dir = ".";
my %peps;

## Command line options
my $verbose = 0;
my $all;
my $sequences = "";
my $input = "";
my $help;
GetOptions ('v|verbose+'  => \$verbose, 
            'a|all'       => \$all,
            's|sequences' => \$sequences,
            'i|input=s'   => \$input,
            'h|help'     => \$help);
my $usage = "Usage: perl hmmparse.pl [-v] -a [-i input]\nIf -a argument is used, no need for filename\n";
die $usage if ($help);
die $usage if (!$input and !$all);


## Index proteomes for searching
opendir(PEP,"$pep_dir");
my @proteomes = grep{ /\.fasta$/ } readdir(PEP);
closedir(PEP);
if ($verbose){print join("\n",@proteomes),"\n";}

foreach my $prot (@proteomes)
{
  my $spec = (split(/[\.\_]/,$prot))[0];
  if($verbose){print $spec,"\n";}
  my $seqio_obj = Bio::SeqIO->new(-file => "$pep_dir/$prot",
                                  -format => 'fasta');
  while(my $seq = $seqio_obj->next_seq)
  {
    $peps{$spec}{$seq->display_id} = $seq;
  }
}


## Process results
if($all)
{
  opendir(DIR, $results_dir);
  @files = grep { /\_tbl\.hmms.+/} readdir(DIR); # get --tblout version of output
  closedir DIR;
}
else
{
  push(@files,$input);
}
#print scalar(@files),"\n";
#print $files[0],"\n";
if (scalar @files > 0)
{
  foreach my $hmmfile (@files)
  {
    my (@seqs,%genes,$gene,$PFAM);
    my ($type,$tmp,$org,$mod,$ext);
    my @flags; # flags for positions of gene, PFAM, type, org
    my @filename = split(/[\-|\.|\_]/,$hmmfile);
    $tmp = $filename[1]; # "vs"
    $mod = $filename[3]; # "tbl"
    $ext = $filename[4];
    if($ext =~ m/scan/)
    {
      @flags = (1,0,2,0);
    }
    if($ext =~ m/search/)
    {
      @flags = (0,1,0,2);
    }
    $type = $filename[$flags[2]];
    $all_types{$type}++;
    $org = $filename[$flags[3]];
    open(HMM, "<$results_dir/$hmmfile") || die "Can't open file \"$hmmfile\".\n";
    my $c = 0; # counter for hits
    foreach my $line (<HMM>)
    {
      chomp $line;
      next if($line =~ m/^#/);
      my ($t_name,$t_acc,$q_name,$q_acc,$full_eval,$full_score,$full_bias,$best_eval,$best_score,$best_bias,$dom_exp,$dom_reg,$dom_clu,$dom_ov,$dom_env,$dom_dom,$dom_rep,$dom_inc,@desc) = split(/\s+/,$line);
      my @newline;
      push(@newline, $t_name); # $newline[0] = $t_name
      push(@newline, $q_name); # $newline[1] = $q_name
      $c++;
      $gene = $newline[$flags[0]];
      $PFAM = $newline[$flags[1]];
      #print "$gene => $PFAM\n";
      $genes{$gene} = $PFAM;
      #print "$gene => ",$genes{$gene},"\n";
    }
    $hits{$org}{$type} = \%genes;
    #print keys %{$hits{$type}{$org}},"\n";
  }
}


## Output
open(OUT,">out_table");
if($verbose){print "Org ";}
print OUT "Org ";
foreach my $t (keys %all_types)
{
  if($verbose){print "$t ";}
  print OUT "$t ";
}
if($verbose){print "\n";}
print OUT "\n";
foreach my $o (sort keys %hits)
{
  if($verbose){print "$o ";}
  print OUT "$o ";
  foreach my $t (keys %{$hits{$o}})
  {
    if($verbose){print scalar (keys %{$hits{$o}{$t}})," ";}
    print OUT scalar (keys %{$hits{$o}{$t}})," ";
    if(scalar (keys %{$hits{$o}{$t}}))
    {
      my $outfasta = Bio::SeqIO->new(-file => ">$o\_$t.faa",
                                     -format => 'fasta');
      foreach my $g (keys %{$hits{$o}{$t}})
      {
        $outfasta->write_seq($peps{$o}{$g});
        if($verbose>1){print "$g=>$hits{$o}{$t}{$g} ";}
      }
    }
  }
  if($verbose){print "\n";}
  print OUT "\n";
}
close(OUT);

__END__
      next if($line =~ m/^$/);
      if($line =~ m/\-{2,}/)
      {
        if($line =~ m/inclusion/){last;}
        else {next;}
      }
      if($line =~ m/No hits/){last;}
      if($line =~ m/Domain/){last;}
      next if(($line =~ m/^Query/) || ($line =~ m/^Score/) || ($line =~ m/\s+E/) || ($line =~ m/^Accession/) || ($line =~ m/^Description/));
      $line =~ s/^\s+//;
      my ($full_E,$full_score,$full_bias,$best_E,$best_score,$best_bias,$exp,$N,$seqID,$desc) = split(/\s+/,$line);

=begin COMMENT
      print "FE: $full_E\t";
      print "FS: $full_score\t";
      print "FB: $full_bias\t";
      print "BE: $best_E\t";
      print "BS: $best_score\t";
      print "BB: $best_bias\t";
      print "E: $exp\t";
      print "N: $N\t";
      print "Seq: $seqID\t";
      print "D: $desc\t";
=cut 

#      print $org,$seqID,"\n";
      push(@seqs,$seqID);
      if($verbose){print "$line\n$desc\n";}
      $c++;
      #if($line =~ m/inclusion/){exit;}
    }
    close(HMM);
    print "$hmmfile: $c\n";
    $hits{$type}{$org} = \@seqs;
  }
 
  if($sequences)
  { 
    foreach my $t (keys %hits)
    {
      open(SEQ,">all_seqs_$t\.accnos");
      print $t,"\n";
      my $seq_out = Bio::SeqIO->new(-file => ">all_seqs_$t\.fasta",
                                    -format => 'fasta');
      foreach my $o (sort keys %{$hits{$t}})
      {
        print $o,"\t";
        #my @genome = grep {/^$key\w\.fasta$/} readdir(DIR);
        #print "($genome[0])\t";
        opendir(DIR,$genome_dir) || die "Can't opendir $genome_dir\n";
        my $genome_file = join("",$genome_dir,(grep {/^$o\w*\.fasta$/} readdir(DIR))[0]);
        closedir(DIR);
        print "$genome_file\n";
        foreach my $item (@{$hits{$t}{$o}})
        {
          print SEQ $item,"\n";
          my $genome_obj = Bio::SeqIO->new(-file => $genome_file,
                                           -format => 'fasta');
          #print $item,"\t";
          while(my $seq_obj = $genome_obj->next_seq)
          {
           # print $seq_obj->display_id," :: ",$item,"\n";
            next if ($seq_obj->display_id ne $item);
            #print $seq_obj->seq,"\n";
            $seq_out->write_seq($seq_obj);
          } 
        }
      }
      print "\n";
      close(SEQ);
    }
  }
=begin COMMENT2
    #my @genome = grep {/^$key\w\.fasta$/} readdir(DIR);
    #print "($genome[0])\t";
    opendir(DIR,$genome_dir) || die "Can't opendir $genome_dir\n";
    my $genome_file = join("",$genome_dir,(grep {/^$key\w\.fasta$/} readdir(DIR))[0]);
    closedir(DIR);
    print "$genome_file\n";
    foreach my $item (@{$hits{$key}})
    {
      my $genome_obj = Bio::SeqIO->new(-file => $genome_file,
                                       -format => 'fasta');
      #print $item,"\t";
      while(my $seq_obj = $genome_obj->next_seq)
      {
        next if ($seq_obj->display_id ne $item);
        #print $seq_obj->seq,"\n";
        $seq_out->write_seq($seq_obj);
      } 
    }
    print "\n";
  }
  closedir(DIR);
=cut 
#}
#else
#{
#  print "Invalid input files\n";
#  print "Usage: perl hmmparse.pl [-vs] -a [filename]\n";
#}
__END__
# parse a hmmsearch file (can also parse a hmmpfam file)
my $res = new Bio::Tools::HMMER::Results( -file => 'output.hmm' , -type => 'hmmsearch');

# prinit out the results for each sequence
foreach $seq ( $res->each_Set ) 
{
  print "Sequence bit score is",$seq->bits,"\n";
  foreach $domain ( $seq->each_Domain ) 
  {
    print " Domain start ",$domain->start," end ",$domain->end, " score ",$domain->bits,"\n";
  }
}
__END__
my $seqIO_obj = Bio::SeqIO->new(-format => 'hmmer_pull',
                                -file => $hmmfile);

while (my $result = $seqIO_obj->next_result)
{
  print $result,"\n";
}

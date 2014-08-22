#!/usr/bin/perl
# Script: getSurroundingFasta.pl
# Description: Takes a protein ID and retrieves the surrouding proteins (cluster) 
# Author: Steven Ahrendt
# email: sahrendt0@gmail.com
# Date: 06.19.2014
#       07.08.2014  : also gets sequences automatically
##################################
use warnings;
use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO;
use lib '/rhome/sahrendt/Scripts';
use SeqAnalysis;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);

#####-----Global Variables-----#####
my ($single,$all);
my ($help,$verb);
my $fastadb;

GetOptions ('i|input=s' => \$single,
            'a|all'     => \$all,
            'f|fasta=s'   => \$fastadb,
            'h|help'   => \$help,
            'v|verbose' => \$verb);
my $usage = "Usage: getSurroundingFasta.pl -f host_sequence_file -i input | -a\nTakes a protein ID and retrieves the surrouding proteins (cluster)\n";
die $usage if $help;
die "No input.\n$usage" if (!$single && !$all);

#####-----Main-----#####
my %source = indexFasta($fastadb);
my @accnos = sort keys %source;
my @fasta_files;
if($all)
{
  opendir(DIR,".");
  @fasta_files = grep {/\.aa\.fasta$/} readdir(DIR);
  closedir(DIR);
}
else
{
  push @fasta_files,$single;
}
foreach my $input (@fasta_files)
{
  my %ids;
  warn $input,"\n" if $verb;
  my $fasta_in = Bio::SeqIO->new(-file => $input,
                                 -format => "fasta");
  my $outname = (split(/\_/,$input))[2];
  my $fasta_out = Bio::SeqIO->new(-file => ">$outname",
                                  -format => "fasta");
  my $num_seqs = 1;
  while (my $seq_obj = $fasta_in->next_seq)
  {
    my ($name,$id) = split(/\_/,$seq_obj->display_id);
    my $len = length $id;
    warn "\t$id\n" if $verb;
    ## Low end
    my $new_id;
    $new_id = sprintf("$name\_%04d",$id) if ($len==4);
    $new_id = sprintf("$name\_%05d",$id) if ($len==5);
    my $id_index = indexOf(\@accnos,$new_id);
    my $id_lb = max($id_index-5,0);
    my $id_ub = min($id_index+5,scalar @accnos);
    for(my $i=$id_lb; $i<=$id_ub; $i++)
    {
      warn $accnos[$i],"\n" if $verb;
      $ids{$accnos[$i]}++;
#      $fasta_out->write_seq($source{$accnos[$i]});
    }
=begin QUOTE
    while(scalar keys %ids < 5*$num_seqs)
    {
      $low_id--;

      warn $new_id,"\n" if $verb;
      if (exists $source{$new_id})
      {
        $ids{$new_id} = 1;
      }
    }
    ## High end
    my $high_id = $id;
    while(scalar keys %ids < 10)
    {
      $high_id++;
      my $new_id;
      $new_id = sprintf("$name\_%04d",$high_id) if ($len==4);
      $new_id = sprintf("$name\_%05d",$high_id) if ($len==5);
      warn $new_id,"\n" if $verb;
      if (exists $source{$new_id})
      {
        $ids{$new_id} = 1;
      }
    }
    ## Original
    $ids{$seq_obj->display_id} = 1;
    $num_seqs++;
=end QUOTE
=cut
  }
  #print join("\n",sort @ids),"\n";
  foreach my $key (sort keys %ids)
  {
    $fasta_out->write_seq($source{$key});
  }
}
=begin QUOTE2
    $id -= 5;
    for(my $i = 0; $i<11; $i++)
    {
      my $new_id;
      $new_id = sprintf("$name\_%04d",$id) if ($len==4);
      $new_id = sprintf("$name\_%05d",$id) if ($len==5);
      warn "\t$new_id\n" if $verb;
      $fasta_out->write_seq($source{$new_id});
#      print "$new_id";
#      warn "<--" if ($new_id eq $seq_obj->display_id);
#      print "\n";
  #    print `perl ~/Scripts/getseqfromfile.pl -f Hpol_proteins.aa.fasta -d ~/bigdata/Genomes/Protein -i "$new_id" >> tmp`;
      $id++;
    }
  }
}

=end QUOTE2
=cut
warn "Done.\n";
exit(0);

#####-----Subroutines-----#####
sub indexOf {
  my @array = @{shift @_};
  my $search = shift @_;

  my %index;
  @index{@array} = (0..$#array);
  my $index = $index{$search};
  return $index;
}

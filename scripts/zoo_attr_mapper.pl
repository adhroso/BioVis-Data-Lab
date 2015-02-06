#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename;
##########################################################################################
# Program zoo_attr_mapper.pl takes two files as input: zoo.names zoo.data				 #
# Note: order of input matters															 #
# Purpose: Map and translate zoo species attributes with numerical and boolean type data #
#																						 #		
# Authur: Andi Dhroso																	 #
# version: 1.0																			 #
# correspondence: adhroso@icloud.com													 #
##########################################################################################
usage() unless(@ARGV > 1);
my ($attr_file, $data_file) = ($ARGV[0],$ARGV[1]);

#information on: header, header order, and type
my %attr_hash = ();

#load attributes from file and initialize hash
load_attributes_from_file($attr_file);

#load zoo data
my @data = @{get_zoo_data($data_file)};

#organize header with their respective order
my @header = sort {$a <=> $b} keys %attr_hash;

#print header
for(my $i = 1; $i <= scalar @header; $i++) {
	my $str = ($i+1 <= scalar @header) ? "$attr_hash{$i}->[0],": $attr_hash{$i}->[0];
	print $str;
}
print "\n";

#map machine representation to human meaning
foreach my $line (@data) {
	my @attrs = split(/,/, $line);
	print "$attrs[0]";
	for(my $i = 1; $i < scalar @attrs; $i++) {
		print ",",translate($i+1, $attrs[$i]);
	}
	print "\n";
}

##########################################################################################
# 											helper sub-routines							 #
##########################################################################################
#convert number to word
sub translate {
	exit_with_msg("not enough arguments, line: ".__LINE__) if(@_ < 1);
	my ($key, $value) = ($_[0],$_[1]);	
	my $ref = $attr_hash{$key};
	if($ref->[1] eq "boolean") {
		return $value ? "true" : "false";
	}
	return $value;
}

#load header information, order, and type
sub load_attributes_from_file {
	exit_with_msg("not enough arguments, line: ".__LINE__) if(@_ < 1);
	my ($file) = ($_[0]);
	
	my @raw = @{load_data($file)};
	load_attrs(\@raw);
}

sub load_attrs {
	exit_with_msg("not enough arguments, line: ".__LINE__) if(@_ < 1);
	my @data = @{$_[0]};
	my @tmp = ();
	for(my $i = 0; $i < scalar @data; $i++) {
		my $string = $data[$i];
		next unless($string =~ /^7\./);
		while(++$i < scalar @data ) {
			$string = $data[$i];
			last if($string =~ /^8\./);
			push(@tmp, $string) if(length($string) > 0);
		}
		$i= scalar @data;
	}
	
	foreach my $string (@tmp) {
		$string = trim($string);
		my @tokens = split(/\s+/,$string);
		
		$tokens[0] =~ s/\.$//;
		if($string =~ /numeric/i) {
			$attr_hash{$tokens[0]} = [$tokens[1], "numeric"];
		} elsif($string =~ /boolean/i) {
			$attr_hash{$tokens[0]} = [$tokens[1], "boolean"];
		} else {
			$attr_hash{$tokens[0]} = [$tokens[1], "string"];
		}
	}
}

#load zoo machine data
sub get_zoo_data {
	exit_with_msg("not enough arguments, line: ".__LINE__) if(@_ < 1);
	my $file = $_[0];

	my @data = @{load_data($file)};
	return \@data;
}
##########################################################################################
# 								boiler plate common functions							 #
##########################################################################################
sub get_files {
	exit_with_msg("not enough arguments, line: ".__LINE__) if(@_ < 2);
	my ($path,$match) = ($_[0], $_[1]);
	$path = trim($path);
	my @files = glob("$path/$match");
	return \@files;
}
sub load_data {
	my $file = $_[0];
	open(IN,"<", $file) or die $!;
	my @data = ();
	@data = <IN>;
	close(IN);
	
	chomp(@data);
	return \@data;
}
sub trim {
	my $string = shift;
	#$string =~ s/^\s+|\s+$//g;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	$string =~ s/\/$//;
	
	return $string;
}
sub get_basename {
	exit_with_msg("Cannot get base name, not enough arguments.") if(@_ < 2);
	my $line = shift;
	my $match = shift;
	my($filename, $path, $suffix) = fileparse($line, ($match));
	$path = trim($path);
	
	return ($filename, $path, $suffix);
}
sub parse_line {
	my $string = shift;
	my @line = split(/\s+/,$string);
	return \@line;
}
sub exit_with_msg {
	warn shift,"\n";
	exit;
}
sub usage {
	warn "perl zoo_attr_mapper.pl <names file> <data file>\n\n";
	exit;
}
exit;

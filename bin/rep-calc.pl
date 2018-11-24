#!/usr/bin/env perl
use POSIX;

# tipfs replica calculator
# if less than 4 peers then mirror
# cache the answer for anything less than 10 replicas (73 peers by current formula)
# Anything else we use the formula to calculate

$peer_count=$ARGV[0];
# it's a speed hack
if($peer_count < 4) {
  print $peer_count
} elsif ($peer_count < 8) {
  print 4
} elsif ($peer_count < 13){
  print 5
} elsif ($peer_count < 19){
  print 6
} elsif ($peer_count < 26){
  print 7
} elsif ($peer_count < 37){
  print 8
} elsif ($peer_count < 51){
  print 9
} elsif ($peer_count < 73){
  print 10
} else {
  print ceil($peer_count/(($peer_count/12.0)+3))+2;
}

#!perl

use Modern::Perl;
use Test::Most;

use Path::Class;
use Tree::Path::Class;

my $tree = new_ok( 'Tree::Path::Class' => [ dir('test_dir') ] );

done_testing();

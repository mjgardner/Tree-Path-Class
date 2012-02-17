#!perl

use Modern::Perl;
use Test::Most;

use Path::Class;
use Tree::Path::Class;

my $tree = new_ok( 'Tree::Path::Class' => [ dir('test_dir') ], 'test root' );
isa_ok( $tree->value, 'Path::Class::Dir', 'root value' );
isa_ok( $tree->path,  'Path::Class::Dir', 'root path' );
is( $tree->path->stringify, 'test_dir', 'root path string' );

done_testing();

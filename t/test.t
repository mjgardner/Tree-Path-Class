#!perl

use Modern::Perl;
use Test::Most;

use Path::Class;
use Tree::Path::Class;

my $tree = new_ok( 'Tree::Path::Class' => [ dir('test_dir') ], 'test root' );
isa_ok( $tree->value, 'Path::Class::Dir', 'root value' );
isa_ok( $tree->path,  'Path::Class::Dir', 'root path' );
is( $tree->path->stringify, 'test_dir', 'root path string' );

$tree->value( dir('another_dir') );
is( $tree->path->stringify, 'another_dir', 'root path changes with value' );

my $child = new_ok(
    'Tree::Path::Class' => ['child_dir'],
    'string constructor',
);

lives_ok( sub { $tree->add_child($child) }, 'add child' );

done_testing();

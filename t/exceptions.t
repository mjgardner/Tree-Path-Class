#!perl

use Test::Most;
use Const::Fast;
use Tree::Path::Class;

const my $ERROR => 'Tree::Path::Class::Error';
my $tree;
throws_ok( sub { $tree = Tree::Path::Class->new( {} ) },
    $ERROR, 'bad type to constructor' );

$tree = new_ok('Tree::Path::Class');
throws_ok( sub { $tree->set_value( {} ) }, $ERROR, 'bad type to set_value' );

done_testing();

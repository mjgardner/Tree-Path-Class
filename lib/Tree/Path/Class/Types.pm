use utf8;
use Modern::Perl;

package Tree::Path::Class::Types;
use strict;

# VERSION
use Tree;
use Tree::Path::Class;
use MooseX::Types -declare => [qw(TreePath Tree)];
## no critic (Subroutines::ProhibitCallsToUndeclaredSubs)

class_type Tree,     { class => 'Tree' };
class_type TreePath, { class => 'Tree::Path::Class' };

coerce TreePath, from Tree, via {
    my $tree = $_;
    my $tpc  = Tree::Path::Class->new( $tree->value );
    for my $child ( $tree->children ) { $tpc->add_child($child) }
    return $tpc;
};

1;

# ABSTRACT: Type library for Tree::Path::Class

=head1 SYNOPSIS

    use Moose;
    use Tree::Path::Class::Types 'TreePath';

    has tree => (is => 'ro', isa => TreePath, coerce => 1);

=head1 DESCRIPTION

This is a L<Moose type library|MooseX::Types> for
L<Tree::Path::Class|Tree::Path::Class>.

=type TreePath

An object of L<Tree::Path::Class|Tree::Path::Class>.  Can coerce from
L<Tree|Tree>, where it will also coerce the tree's children.

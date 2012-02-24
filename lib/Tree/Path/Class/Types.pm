use utf8;
use Modern::Perl;

package Tree::Path::Class::Types;
use strict;

# VERSION
use Carp;
use Path::Class;
use MooseX::Types -declare => [qw(TreePath TreePathValue Tree)];
use MooseX::Types::Moose qw(ArrayRef Maybe Str);
use MooseX::Types::Path::Class qw(Dir is_Dir to_Dir File is_File to_File);
## no critic (Subroutines::ProhibitCallsToUndeclaredSubs)

class_type Tree,     { class => 'Tree' };
class_type TreePath, { class => 'Tree::Path::Class' };
subtype TreePathValue,
    as Maybe [ Dir | File ];    ## no critic (Bangs::ProhibitBitwiseOperators)

coerce TreePath, from Tree, via {
    my $tree = $_;
    my $tpc  = Tree::Path::Class->new( $tree->value );
    for my $child ( $tree->children ) { $tpc->add_child($child) }
    return $tpc;
};

coerce TreePathValue,
    from Dir,      via { dir($_) },
    from File,     via { file($_) },
    from ArrayRef, via { _coerce_val( @{$_} ) },
    from Str,      via { _coerce_val($_) };

sub _coerce_val {
    return if !( my @args = @_ );
    for my $arg ( grep {$_} @args ) {
        if ( not( is_Dir($arg) or is_File($arg) ) ) {
            $arg = to_Dir($arg)
                or croak; ## no critic (ErrorHandling::RequireUseOfExceptions)
        }
    }
    return is_File( $args[-1] ) ? to_File( \@args ) : to_Dir( \@args );
}

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

=type TreePathValue

Can either be undefined. a L<Path::Class::Dir|Path::Class::Dir> or a
L<Path::Class:File|Path::Class::File>.  Handles all the coercions that
L<MooseX::Types::Path::Class|MooseX::Types::Path::Class> handles.

=type Tree

A L<Tree|Tree> object.

use utf8;
use Modern::Perl;

package Tree::Path::Class;
use strict;

# VERSION
use Const::Fast;
use English '-no_match_vars';
use Path::Class;
use Tree;
use Try::Tiny;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Has::Options;
use MooseX::Types::Moose qw(ArrayRef Maybe Str);
use MooseX::Types::Path::Class qw(Dir File to_Dir);
use MooseX::MarkAsMethods autoclean => 1;

subtype 'MaybePath',    ## no critic (ProhibitCallsToUndeclaredSubs)
    as Maybe [ Dir | File ];    ## no critic (ProhibitBitwiseOperators)
coerce 'MaybePath', from ArrayRef, via { to_Dir($ARG) };
coerce 'MaybePath', from Str,      via { to_Dir($ARG) };

with 'MooseX::OneArgNew' => {
    ## no critic (ProhibitBitwiseOperators)
    type => Maybe [ Str | Dir | File ],
    init_arg => 'value',
};

sub BUILD {
    my $self = shift;
    $self->add_event_handler(
        { value => sub { $self->_set_path( $self->_build_path ) }, },
    );
    return;
}

has value => ( qw(:rw :coerce), isa => 'MaybePath', trigger => \&_set_value );
sub _set_value { $ARG[0]->_tree->set_value( $ARG[1] ); return }
sub set_value { return shift->value(@ARG) }

has path =>
    ( qw(:ro :lazy_build), isa => 'MaybePath', writer => '_set_path' );

sub _build_path {
    my $self = shift;
    my @path = $self->_tree_to_path;
    return $self->value->is_dir ? dir(@path) : file(@path);
}

has _tree => (
    qw(:ro :required),
    isa     => 'Tree',
    default => sub { Tree->new() },
    handles => [
        qw(add_child remove_child mirror traverse
            is_root is_leaf has_child get_index_for
            parent children root height width depth size
            error_handler error last_error
            add_event_handler event),
    ],
);

sub _tree_to_path {
    my $self   = shift;
    my $tree   = shift // $self->_tree;
    my @path   = ( $tree->value );
    my $parent = $tree->parent;
    if ( !$parent->isa('Tree::Null') ) {
        unshift @path, $self->_tree_to_path($parent);
    }
    return @path;
}

__PACKAGE__->meta->make_immutable();
no Moose::Util::TypeConstraints;
no Moose;
1;

# ABSTRACT: Tree for Path::Class objects

=head1 SYNOPSIS

    use Tree::Path::Class;
    use Path::Class;

    my $tree = Tree::Path::Class( file('/path/to/file') );

=head1 DESCRIPTION

This module wraps L<Tree|Tree> to only accept
L<Path::Class::Dir|Path::Class::Dir> or L<Path::Class::File|Path::Class::File>
values, and provides a C<path> attribute for retrieving the full path of a tree
branch or leaf.

=method new

Takes an optional string, array reference or
L<Path::Class::Dir|Path::Class::Dir>/L<Path::Class::File|Path::Class::File>
with which to populate the C<value> of the tree node.

=method BUILD

After construction the object registers an event handler to update the C<path>
attribute every time C<value> is set.

=attr value

Accessor for either a L<Path::Class::Dir|Path::Class::Dir> or
L<Path::Class::File|Path::Class::File> object containing the individual
directory or file name on this node of the tree.

=method set_value

Alternate setter for C<value>, for compatibility with L<Tree|Tree>.

=attr path

A read-only accessor that returns the tree's full
L<Path::Class::Dir|Path::Class::Dir> or L<Path::Class::File|Path::Class::File>
object, with all parents prepended.

=type MaybePath

A type that accepts either an L<undef|undef>,
L<Path::Class::Dir|Path::Class::Dir>
or L<Path::Class::File|Path::Class::File>.  Like the latter two it will coerce
from an array reference or string into a
L<Path::Class::Dir|Path::Class::Dir>.

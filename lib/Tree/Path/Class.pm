use utf8;
use Modern::Perl;

package Tree::Path::Class;
use strict;

# VERSION
use Const::Fast;
use English '-no_match_vars';
use Path::Class;
use Try::Tiny;
use Moose;
use MooseX::Has::Options;
use MooseX::NonMoose;
use MooseX::Types::Path::Class qw(Dir File);
use MooseX::MarkAsMethods autoclean => 1;
extends 'Tree';

const my $ERROR => __PACKAGE__ . '::Error';
Moose::Meta::Class->create(
    $ERROR => ( superclasses => ['Throwable::Error'] ) );

sub FOREIGNBUILDARGS {
    my $value = shift // return;
    return $value if Dir->check($value) or File->check($value);
    try { $value = Dir->assert_coerce($value) }
    catch {
        try { $value = File->assert_coerce($value) }
        catch {
            $ERROR->throw('value is not a file or dir');
        };
    };
    return $value;
}

sub BUILD {
    shift->add_event_handler(
        value => sub { $ARG[0]->_set_path( $ARG[0]->_build__path ) } );
    return;
}

has path => (
    qw(:ro :lazy_build),
    isa    => Dir | File,    ## no critic (Bangs::ProhibitBitwiseOperators)
    writer => '_set_path',
);

sub _build__path {
    my $self = shift;
    my @path = $self->_tree_to_path;
    return $self->is_dir ? dir(@path) : file(@path);
}

sub _tree_to_path {
    my $self   = shift;
    my @path   = ( FOREIGNBUILDARGS( $self->value ) );
    my $parent = $self->parent;
    if ( !$parent->isa('Tree::Null') ) {
        unshift @path, $parent->_tree_to_path;
    }
    return @path;
}

__PACKAGE__->meta->make_immutable();
no Moose;
1;

# ABSTRACT: Tree for Path::Class objects

=head1 SYNOPSIS

    use Tree::Path::Class;
    use Path::Class;

    my $tree = Tree::Path::Class( file('/path/to/file') );

=head1 DESCRIPTION

This module subclasses L<Tree|Tree> to only accept
L<Path::Class::Dir|Path::Class::Dir> or L<Path::Class::File|Path::Class::File>
values, and provides several methods for retrieving the full path of a tree
branch or leaf.

=method FOREIGNBUILDARGS

At construction time any value passed to C<new()> will attempt to be coerced
to a L<Path::Class::Dir|Path::Class::Dir> or
L<Path::Class::File|Path::Class::File> if it isn't one already.  Failure will
result in a thrown exception.

=method BUILD

After construction the object registers an event handler to update the C<path>
attribute every time C<value> is set.

=attr path

A read-only accessor that returns the tree's full
L<Path::Class::Dir|Path::Class::Dir> or L<Path::Class::File|Path::Class::File>
object, with all parents prepended.

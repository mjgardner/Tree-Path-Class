use utf8;
use Modern::Perl;

package Tree::Path::Class;
use strict;

# VERSION
use English '-no_match_vars';
use Path::Class;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Has::Options;
use MooseX::NonMoose;
use MooseX::Types::Path::Class qw(Dir is_Dir to_Dir File is_File to_File);
use MooseX::MarkAsMethods autoclean => 1;
extends 'Tree';

# defang Moose's hashref params
around BUILDARGS => sub { &{ $ARG[0] }( $ARG[1] ) };

sub _value_to_path {
    return if !@ARG;
    my @args = @ARG;
    for my $arg (@args) {
        if ( not( is_Dir($arg) or is_File($arg) ) ) { $arg = to_Dir($arg) }
    }
    return is_File( $args[-1] ) ? to_File( \@args ) : to_Dir( \@args );
}

sub FOREIGNBUILDARGS { return _value_to_path( @ARG[ 1 .. $#ARG ] ) }

has path => (
    qw(:ro :lazy),
    isa => maybe_type( union( [ Dir, File ] ) ),
    writer  => '_set_path',
    default => sub { $ARG[0]->_tree_to_path },
);

around set_value => sub {
    my ( $orig, $self ) = splice @ARG, 0, 2;
    my $new_path = _value_to_path(@ARG);
    $self->$orig($new_path);
    $self->_set_path( $self->_tree_to_path );
    return $self;
};

after add_child => sub {
    my $self = shift;
    for my $child ( $self->children ) {
        $child->_set_path( $child->_tree_to_path );
    }
    return;
};

sub _tree_to_path {
    my $self   = shift;
    my @path   = ( $self->value );
    my $parent = $self->parent;
    if ( !$parent->isa('Tree::Null') ) {
        unshift @path, $parent->_tree_to_path;
    }
    return _value_to_path(@path);
}

__PACKAGE__->meta->make_immutable();
no Moose::Util::TypeConstraints;
no Moose;
1;

# ABSTRACT: Tree for Path::Class objects

=head1 SYNOPSIS

    use Tree::Path::Class;
    use Path::Class;

    my $tree  = Tree::Path::Class->new( dir('/parent/dir') );
    my $child = Tree::Path::Class->new( file('child/file') );
    $tree->add_child($child);

    print $child->path->stringify;
    # /parent/dir/child/file

=head1 DESCRIPTION

This module subclasses L<Tree|Tree> to only accept
L<Path::Class::Dir|Path::Class::Dir> or L<Path::Class::File|Path::Class::File>
values, and provides a C<path> attribute for retrieving the full path of a tree
branch or leaf.

=method FOREIGNBUILDARGS

Coerces the parameter passed to C<new()> into a
L<Path::Class::Dir|Path::Class::Dir> or L<Path::Class::File|Path::Class::File>
before passing it on to the superclass constructor.

=attr path

A read-only accessor that returns the tree's full
L<Path::Class::Dir|Path::Class::Dir> or L<Path::Class::File|Path::Class::File>
object, with all parents prepended.

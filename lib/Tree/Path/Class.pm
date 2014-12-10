use utf8;
use Modern::Perl;

package Tree::Path::Class;
use strict;

# VERSION
use Path::Class;
use Moose;
use MooseX::Has::Options;
use MooseX::NonMoose;
use Tree::Path::Class::Types qw(TreePath TreePathValue);
use MooseX::MarkAsMethods autoclean => 1;
extends 'Tree';

# defang Moose's hashref params
around BUILDARGS => sub { &{ $_[0] }( $_[1] ) };

# coerce constructor arguments to Dir or File
sub FOREIGNBUILDARGS {
    my @args = @_;
    return _value_to_path( @args[ 1 .. $#args ] );
}

has path => (
    qw(:ro :lazy :coerce),
    isa      => TreePathValue,
    init_arg => undef,
    writer   => '_set_path',
    default  => sub { $_[0]->_tree_to_path },
);

# update path every time value changes
around set_value => sub {
    my ( $orig, $self ) = splice @_, 0, 2;
    $self->$orig( _value_to_path(@_) );
    $self->_set_path( $self->_tree_to_path );
    return $self;
};

around add_child => sub {
    my ( $orig, $self, @nodes ) = @_;

    my $options_ref;
    if ( 'HASH' eq ref $nodes[0] and not blessed $nodes[0] ) {
        $options_ref = shift @nodes;
    }

    for (@nodes) {
        if ( !TreePath->check($_) ) { $_ = TreePath->assert_coerce($_) }
    }

    if ($options_ref) { unshift @nodes, $options_ref }
    return $self->$orig(@nodes);
};

after add_child => sub {
    for my $child ( shift->children ) {
        $child->_set_path( $child->_tree_to_path );
    }
};

# recursively derive path from current and parents' values
sub _tree_to_path {
    my $self   = shift;
    my @path   = $self->value;
    my $parent = $self->parent;
    if ( !$parent->isa('Tree::Null') ) {
        unshift @path, $parent->_tree_to_path;
    }
    return _value_to_path(@path);
}

# coerce a value to a Dir or File if necessary
sub _value_to_path {
    my @args = @_;
    return TreePathValue->check( \@args )
        ? @args
        : TreePathValue->assert_coerce( \@args );
}

__PACKAGE__->meta->make_immutable();
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

=method add_child

Works just like L<the superclass' method|Tree/add_child>.  Plain L<Tree|Tree>
nodes will be recursively recreated as C<Tree::Path::Class>
nodes when added.

=method meta

Unlike L<Tree|Tree>, this method provides access to the underlying
L<Moose|Moose> meta-object rather than a hashref of arbitrary metadata.

=attr path

A read-only accessor that returns the tree's full
L<Path::Class::Dir|Path::Class::Dir> or L<Path::Class::File|Path::Class::File>
object, with all parents prepended.

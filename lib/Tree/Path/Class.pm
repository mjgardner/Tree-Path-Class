use utf8;
use Modern::Perl;

package Tree::Path::Class;
use strict;

# VERSION
use Const::Fast;
use English '-no_match_vars';
use Path::Class;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Has::Options;
use MooseX::NonMoose;
use MooseX::Types::Path::Class qw(Dir is_Dir to_Dir File is_File to_File);
use MooseX::MarkAsMethods autoclean => 1;
extends 'Tree';

# make our own error class for throwing exceptions
const my $ERROR => __PACKAGE__ . '::Error';
Moose::Meta::Class->create(
    $ERROR => ( superclasses => ['Throwable::Error'] ) );

# defang Moose's hashref params
around BUILDARGS => sub { &{ $ARG[0] }( $ARG[1] ) };

# coerce constructor arguments to Dir or File
sub FOREIGNBUILDARGS { return _value_to_path( @ARG[ 1 .. $#ARG ] ) }

has path => (
    qw(:ro :lazy),
    isa => maybe_type( union( [ Dir, File ] ) ),
    init_arg => undef,
    writer   => '_set_path',
    default  => sub { $ARG[0]->_tree_to_path },
);

# update path every time value changes
around set_value => sub {
    my ( $orig, $self ) = splice @ARG, 0, 2;
    $self->$orig( _value_to_path(@ARG) );
    $self->_set_path( $self->_tree_to_path );
    return $self;
};

around add_child => sub {
    my ( $orig, $self, @nodes ) = @ARG;

    my $options_ref;
    if ( ref $nodes[0] eq 'HASH' and not blessed $nodes[0] ) {
        $options_ref = shift @nodes;
    }

    for my $node (@nodes) {
        given ( blessed $node) {
            when (__PACKAGE__) {next}
            when ('Tree') { $node = _tree_to_tpc($node) }
            default {
                $ERROR->throw(
                    'can only add ' . __PACKAGE__ . ' or Tree children' );
            }
        }
    }
    if ($options_ref) { unshift @nodes, $options_ref }
    return $self->$orig(@nodes);
};

after add_child => sub {
    for my $child ( shift->children ) {
        $child->_set_path( $child->_tree_to_path );
    }
};

# recursively convert Tree and children into Tree::Path::Classes
sub _tree_to_tpc {
    my $tree = shift;
    my $tpc  = __PACKAGE__->new( $tree->value );
    if ( $tree->meta ) { $tpc->meta( $tree->meta ) }
    for ( $tree->children ) { $tpc->add_child($ARG) }
    return $tpc;
}

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
    return if !@ARG;
    my @args = @ARG;
    for my $arg ( grep {$ARG} @args ) {
        if ( not( is_Dir($arg) or is_File($arg) ) ) {
            $arg = to_Dir($arg) or $ERROR->throw(q{couldn't coerce to a dir});
        }
    }
    return is_File( $args[-1] ) ? to_File( \@args ) : to_Dir( \@args );
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

=method add_child

Works just like L<the superclass' method|Tree/add_child>.  Plain L<Tree|Tree>
nodes will be recursively recreated as C<Tree::Path::Class>
nodes when added.

=attr path

A read-only accessor that returns the tree's full
L<Path::Class::Dir|Path::Class::Dir> or L<Path::Class::File|Path::Class::File>
object, with all parents prepended.

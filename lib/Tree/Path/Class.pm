use utf8;
use Modern::Perl;

package Tree::Path::Class;
use strict;

# VERSION
use Const::Fast;
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

__PACKAGE__->meta->make_immutable();
no Moose;
1;

# ABSTRACT: Main module for Tree-Path-Class

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

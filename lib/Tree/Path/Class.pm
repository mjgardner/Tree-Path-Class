use utf8;
use Modern::Perl;

package Tree::Path::Class;
{
    $Tree::Path::Class::DIST = 'Tree-Path-Class';
}
use strict;

our $VERSION = '0.001';    # VERSION
use Const::Fast;
use Path::Class;
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

__END__

=pod

=for :stopwords Mark Gardner cpan testmatrix url annocpan anno bugtracker rt cpants
kwalitee diff irc mailto metadata placeholders metacpan

=encoding utf8

=head1 NAME

Tree::Path::Class - Main module for Tree-Path-Class

=head1 VERSION

version 0.001

=head1 SYNOPSIS

    use Tree::Path::Class;
    use Path::Class;

    my $tree = Tree::Path::Class( file('/path/to/file') );

=head1 DESCRIPTION

This module subclasses L<Tree|Tree> to only accept
L<Path::Class::Dir|Path::Class::Dir> or L<Path::Class::File|Path::Class::File>
values, and provides several methods for retrieving the full path of a tree
branch or leaf.

=head1 METHODS

=head2 FOREIGNBUILDARGS

At construction time any value passed to C<new()> will attempt to be coerced
to a L<Path::Class::Dir|Path::Class::Dir> or
L<Path::Class::File|Path::Class::File> if it isn't one already.  Failure will
result in a thrown exception.

=head1 SUPPORT

=head2 Perldoc

You can find documentation for this module with the perldoc command.

  perldoc Tree::Path::Class

=head2 Websites

The following websites have more information about this module, and may be of help to you. As always,
in addition to those websites please use your favorite search engine to discover more resources.

=over 4

=item *

Search CPAN

The default CPAN search engine, useful to view POD in HTML format.

L<http://search.cpan.org/dist/Tree-Path-Class>

=item *

AnnoCPAN

The AnnoCPAN is a website that allows community annotations of Perl module documentation.

L<http://annocpan.org/dist/Tree-Path-Class>

=item *

CPAN Ratings

The CPAN Ratings is a website that allows community ratings and reviews of Perl modules.

L<http://cpanratings.perl.org/d/Tree-Path-Class>

=item *

CPANTS

The CPANTS is a website that analyzes the Kwalitee ( code metrics ) of a distribution.

L<http://cpants.perl.org/dist/overview/Tree-Path-Class>

=item *

CPAN Testers

The CPAN Testers is a network of smokers who run automated tests on uploaded CPAN distributions.

L<http://www.cpantesters.org/distro/T/Tree-Path-Class>

=item *

CPAN Testers Matrix

The CPAN Testers Matrix is a website that provides a visual overview of the test results for a distribution on various Perls/platforms.

L<http://matrix.cpantesters.org/?dist=Tree-Path-Class>

=item *

CPAN Testers Dependencies

The CPAN Testers Dependencies is a website that shows a chart of the test results of all dependencies for a distribution.

L<http://deps.cpantesters.org/?module=Tree::Path::Class>

=back

=head2 Bugs / Feature Requests

Please report any bugs or feature requests through the web
interface at L<https://github.com/mjgardner/Tree-Path-Class/issues>. You will be automatically notified of any
progress on the request by the system.

=head2 Source Code

The code is open to the world, and available for you to hack on. Please feel free to browse it and play
with it, or whatever. If you want to contribute patches, please send me a diff or prod me to pull
from your repository :)

L<https://github.com/mjgardner/Tree-Path-Class>

  git clone git://github.com/mjgardner/Tree-Path-Class.git

=head1 AUTHOR

Mark Gardner <mjgardner@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Mark Gardner.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

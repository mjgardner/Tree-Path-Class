
use strict;
use warnings;

use 5.010;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Tree for Path::Class objects",
  "AUTHOR" => "Mark Gardner <mjgardner\@cpan.org>",
  "BUILD_REQUIRES" => {
    "Carp" => 0,
    "File::Find" => 0,
    "File::Temp" => 0,
    "Scalar::Util" => 0,
    "Test::More" => "0.94",
    "Test::Most" => 0,
    "Test::Requires" => 0,
    "warnings" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Tree-Path-Class",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Tree::Path::Class",
  "PREREQ_PM" => {
    "Const::Fast" => 0,
    "English" => 0,
    "Modern::Perl" => 0,
    "Moose" => 0,
    "Moose::Util::TypeConstraints" => 0,
    "MooseX::Has::Options" => 0,
    "MooseX::MarkAsMethods" => 0,
    "MooseX::NonMoose" => 0,
    "MooseX::Types::Path::Class" => 0,
    "Path::Class" => 0,
    "Throwable::Error" => 0,
    "Tree" => 0,
    "Try::Tiny" => 0,
    "strict" => 0,
    "utf8" => 0
  },
  "VERSION" => "0.001",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);




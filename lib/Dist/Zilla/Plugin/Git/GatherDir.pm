use strict;
use warnings;
package Dist::Zilla::Plugin::Git::GatherDir;
{
  $Dist::Zilla::Plugin::Git::GatherDir::VERSION = '0.003';
}
{
  $Dist::Zilla::Plugin::Git::GatherDir::DIST = 'Dist-Zilla-Plugin-Git-GatherDir';
}
# ABSTRACT: uses git ls-files to decide what to gather for the build


use Moose;
use Moose::Autobox;
use MooseX::Types::Path::Class qw(Dir File);
#with 'Dist::Zilla::Role::FileGatherer';
with 'Dist::Zilla::Role::Git::Repo';
extends 'Dist::Zilla::Plugin::GatherDir';
use Git::Wrapper;
use Data::Dumper;
use File::Find::Rule;
use File::HomeDir;
use File::Spec;
use Path::Class;

use namespace::autoclean;

override gather_files => sub {
  my ($self) = @_;

  my $root = "" . $self->root;
  $root =~ s{^~([\\/])}{File::HomeDir->my_home . $1}e;
  $root = Path::Class::dir($root);

  my @files;
  my $git  = Git::Wrapper->new( $self->repo_root );
  FILE: for my $filename ($git->ls_files()) {
    my $file = file($filename)->relative($root);

    unless ($self->include_dotfiles) {
      next FILE if $file->basename =~ qr/^\./;
      next FILE if grep { /^\.[^.]/ } $file->dir->dir_list;
    }

    my $exclude_regex = qr/\000/;
    $exclude_regex = qr/$exclude_regex|$_/
      for ($self->exclude_match->flatten);
    # \b\Q$_\E\b should also handle the `eq` check
    $exclude_regex = qr/$exclude_regex|\b\Q$_\E\b/
      for ($self->exclude_filename->flatten);
    next if $file =~ $exclude_regex;

    push @files, $self->_file_from_filename($filename);
  }

  for my $file (@files) {
    (my $newname = $file->name) =~ s{\A\Q$root\E[\\/]}{}g;
    $newname = File::Spec->catdir($self->prefix, $newname) if $self->prefix;
    $newname = Path::Class::dir($newname)->as_foreign('Unix')->stringify;

    $file->name($newname);
    $self->add_file($file);
  }

  return;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;


=pod

=head1 NAME

Dist::Zilla::Plugin::Git::GatherDir - uses git ls-files to decide what to gather for the build

=head1 VERSION

version 0.003

=head1 AUTHOR

Stephen R. Scaffidi <sscaffid@akamai.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Akamai Technologies.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 EXTENDS

=over 4

=item * L<Dist::Zilla::Plugin::GatherDir>

=back

=head1 CONSUMES

=over 4

=item * L<Dist::Zilla::Role::Git::Repo>

=back

=for :stopwords cpan testmatrix url annocpan anno bugtracker rt cpants kwalitee diff irc mailto metadata placeholders metacpan

=head1 SUPPORT

=head2 Perldoc

You can find documentation for this module with the perldoc command.

  perldoc Dist::Zilla::Plugin::Git::GatherDir

=head2 Websites

The following websites have more information about this module, and may be of help to you. As always,
in addition to those websites please use your favorite search engine to discover more resources.

=over 4

=item *

MetaCPAN

A modern, open-source CPAN search engine, useful to view POD in HTML format.

L<http://metacpan.org/release/Dist-Zilla-Plugin-Git-GatherDir>

=item *

Search CPAN

The default CPAN search engine, useful to view POD in HTML format.

L<http://search.cpan.org/dist/Dist-Zilla-Plugin-Git-GatherDir>

=item *

RT: CPAN's Bug Tracker

The RT ( Request Tracker ) website is the default bug/issue tracking system for CPAN.

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Dist-Zilla-Plugin-Git-GatherDir>

=item *

AnnoCPAN

The AnnoCPAN is a website that allows community annotations of Perl module documentation.

L<http://annocpan.org/dist/Dist-Zilla-Plugin-Git-GatherDir>

=item *

CPAN Ratings

The CPAN Ratings is a website that allows community ratings and reviews of Perl modules.

L<http://cpanratings.perl.org/d/Dist-Zilla-Plugin-Git-GatherDir>

=item *

CPAN Forum

The CPAN Forum is a web forum for discussing Perl modules.

L<http://cpanforum.com/dist/Dist-Zilla-Plugin-Git-GatherDir>

=item *

CPANTS

The CPANTS is a website that analyzes the Kwalitee ( code metrics ) of a distribution.

L<http://cpants.perl.org/dist/overview/Dist-Zilla-Plugin-Git-GatherDir>

=item *

CPAN Testers

The CPAN Testers is a network of smokers who run automated tests on uploaded CPAN distributions.

L<http://www.cpantesters.org/distro/D/Dist-Zilla-Plugin-Git-GatherDir>

=item *

CPAN Testers Matrix

The CPAN Testers Matrix is a website that provides a visual overview of the test results for a distribution on various Perls/platforms.

L<http://matrix.cpantesters.org/?dist=Dist-Zilla-Plugin-Git-GatherDir>

=item *

CPAN Testers Dependencies

The CPAN Testers Dependencies is a website that shows a chart of the test results of all dependencies for a distribution.

L<http://deps.cpantesters.org/?module=Dist::Zilla::Plugin::Git::GatherDir>

=back

=head2 Bugs / Feature Requests

Please report any bugs or feature requests by email to C<bug-dist-zilla-plugin-git-gatherdir at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dist-Zilla-Plugin-Git-GatherDir>. You will be automatically notified of any
progress on the request by the system.

=head2 Source Code

The code is open to the world, and available for you to hack on. Please feel free to browse it and play
with it, or whatever. If you want to contribute patches, please send me a diff or prod me to pull
from your repository :)

L<https://github.com/Hercynium/Dist-Zilla-Plugin-Git-GatherDir>

  git clone https://github.com/Hercynium/Dist-Zilla-Plugin-Git-GatherDir.git

=head1 BUGS

Please report any bugs or feature requests to bug-dist-zilla-plugin-git-gatherdir@rt.cpan.org or through the web interface at:
 http://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-Plugin-Git-GatherDir

=cut


__END__

package Dist::Zilla::Plugin::PodInherit;
# ABSTRACT: autogenerate inherited POD sections for Dist::Zilla distributions
use strict;
use warnings;
use Moose;
use Pod::Inherit;

our $VERSION = '0.004';

=head1 NAME

Dist::Zilla::Plugin::PodInherit - use L<Pod::Inherit> to provide C<INHERITED METHODS> sections in POD

=head1 VERSION

version 0.004

=head1 SYNOPSIS

Just add [PodInherit] to dist.ini. Currently there's no config options at all.

=head1 DESCRIPTION

Simple wrapper around L<Pod::Inherit> to provide an 'inherited methods' section for
any modules in this distribution. See the documentation for L<Pod::Inherit> for more
details.

=cut

with 'Dist::Zilla::Role::FileInjector';
with 'Dist::Zilla::Role::FileMunger';
with 'Dist::Zilla::Role::FileFinderUser' => {
	default_finders => [ qw( :InstallModules ) ],
};

=head1 METHODS

=cut

=head2 munge_file

Called for each matching file (using :InstallModules so we expect
to find all the .pm files), we'll attempt to do pod generation for
the ones which end in .pm (case insensitive, will also match .PM).

=cut

sub munge_file {
	my ($self, $file) = @_;
	$self->process_pod($file) if $file->name =~ /\.pm$/i;
}

=head2 process_pod

Calls L<Pod::Inherit> to generate the merged C<.pod> documentation files.

=cut

sub process_pod {
	my ($self, $file) = @_;
	$self->log("Generating inherited pod files");
	local @INC = ('lib/', @INC);
	my $cfg = Pod::Inherit->new({
		input_files => [$file->name],
		skip_underscored => 1,
		method_format => 'L<%m|%c/%m>',
		debug => 0,
	});
	$cfg->write_pod or return;
	(my $pod = $file->name) =~ s{\.pm$}{.pod}i;
	return unless -r $pod;
	$self->add_file(Dist::Zilla::File::OnDisk->new( { name => $pod } ))
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=head1 BUGS

Some of the path and extension handling may be non-portable, should probably
use L<File::Basename> and L<File::Spec>.

Also, generating an entire .pod output file which is identical apart from the
extra inherited methods section seems suboptimal, other plugins such as
L<Dist::Zilla::Plugin::PodVersion> manage to update the source .pm file
directly so perhaps that would be a better approach.

=head1 SEE ALSO

=over 4

=item * L<Pod::POM>

=item * L<Pod::Inherit>

=back

=head1 AUTHOR

Tom Molesworth <cpan@entitymodel.com>

=head1 LICENSE

Copyright Tom Molesworth 2012-2013. Licensed under the same terms as Perl itself.

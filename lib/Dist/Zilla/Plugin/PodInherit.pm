package Dist::Zilla::Plugin::PodInherit;
# ABSTRACT: autogenerate inherited POD sections for Dist::Zilla distributions
use strict;
use warnings;
use Moose;
use Pod::Inherit;

our $VERSION = '0.003';

=head1 NAME

Dist::Zilla::Plugin::PodInherit - use L<Pod::Inherit> to provide C<INHERITED METHODS> sections in POD

=head1 VERSION

version 0.003

=head1 SYNOPSIS

Just add [PodInherit] to dist.ini. Currently there's no config options at all.

=head1 DESCRIPTION

Simple wrapper around L<Pod::Inherit> to provide an 'inherited methods' section for
any modules in this distribution. See the documentation for L<Pod::Inherit> for more
details.

=cut

with 'Dist::Zilla::Role::BeforeBuild';

=head1 METHODS

=cut

=head2 before_build

Calls L<Pod::Inherit> to generate the merged C<.pod> documentation files.

=cut

sub before_build {
	my $self = shift;
	$self->log("Generating inherited pod files");
	local @INC = ('lib/', @INC);
	my $cfg = Pod::Inherit->new({
		input_files => ['lib/'],
		out_dir => 'lib/',
		skip_underscored => 1,
		method_format => 'L<%m|%c/%m>',
		debug => 0,
	});
	$cfg->write_pod;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=head1 SEE ALSO

=over 4

=item * L<Pod::POM>

=item * L<Pod::Inherit>

=back

=head1 AUTHOR

Tom Molesworth <cpan@entitymodel.com>

=head1 LICENSE

Copyright Tom Molesworth 2012-2013. Licensed under the same terms as Perl itself.

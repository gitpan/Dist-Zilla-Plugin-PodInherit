use strict;
use warnings;
use Test::DZil;
use Pod::POM;
use Test::More;

{
	my $tzil = Builder->from_config({
		dist_root => 't/dist'
	}, {
		add_files => {
			'source/dist.ini' => simple_ini('GatherDir', 'MetaJSON', 'Prereqs::FromCPANfile', 'PodInherit'),
		}
	});
	$tzil->build;
	ok(my $subclass = $tzil->slurp_file('source/lib/ExampleClass/Subclass.pod'), 'read output POD');
	my $parser = Pod::POM->new;
	ok(my $pom = $parser->parse_text($subclass), 'parse POD') or die $parser->error;
	my ($inherited, @extra) = (grep $_->title eq 'INHERITED METHODS', $pom->head1);
	is(@extra, 0, 'have single inherited methods section');
	like($inherited->content, qr/subclassed_method/, 'have subclass method link');
	like($inherited->content, qr/inherited_method/, 'have parent method link');
	unlike($inherited->content, qr/_private_method/, 'no private method link');
}
done_testing;

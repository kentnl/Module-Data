use strict;
use warnings;

use Test::More;

# FILENAME: 02_version.t
# CREATED: 24/03/12 04:29:05 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: Test version lookup

use Module::Runtime;
my $realinc = {%INC};
my $newinc  = {};
my @whitelist;
push @whitelist, qw( Module::Data Test::More Data::Dumper warnings );
push @whitelist, qw( Module::Runtime overload );

# Simulates an empty %INC somewhat.
for my $lib (@whitelist) {
	Module::Runtime::require_module($lib);
	my $nn = Module::Runtime::module_notional_filename($lib);
	$newinc->{$nn} = $realinc->{$nn};
}

{
	unshift @INC, sub {
		my ( $code, $filename ) = @_;
		if ( not exists $newinc->{$filename} ) {
			die "$filename requested but not whitelisted";
		}
		return;
	};
	local %INC;

	%INC = ( %{$newinc} );

	my $module = Module::Data->new('Test::More');    # because we know its loaded already

	isnt( $module->version, undef, 'Module->version  works' );

	note explain [ $module->version ];
}
done_testing;


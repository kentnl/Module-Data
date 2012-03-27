use strict;
use warnings;

use Test::More;

# FILENAME: 03_fake_system.t
# CREATED: 26/03/12 13:28:04 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: Simulate a Fake Installed System and test no-require features

use Test::Fatal;
use Module::Data;
use FindBin;
use Path::Class qw( dir );

my $tlib = dir($FindBin::RealBin)->subdir('03_t');

# Load All modules we really need early to stop @INC messes.

require File::Spec;
require Try::Tiny;
require Scalar::Util;
require Data::Dump;
require Carp;
require Path::ScanINC;
require Module::Runtime;
require Module::Metadata;
require version;
require Data::Dumper;

my $realinc = {%INC};
my $newinc  = {};

# Simulates an empty %INC somewhat.
for my $lib (
	'overload',   'warnings',         'Module::Runtime', 'Path::Class::File', 'Path::ScanINC', 'Scalar::Util',
	'File::Spec', 'Module::Metadata', 'version',         'strict',            'Data::Dumper',
	)
{
	my $nn = Module::Runtime::module_notional_filename($lib);
	$newinc->{$nn} = $realinc->{$nn};
}

{
	local @INC;
	local %INC;
	%INC = ( %{$newinc} );

	@INC = (
		$tlib->subdir('lib/site_perl/VERSION/ARCH-linux')->stringify, $tlib->subdir('lib/site_perl/VERSION')->stringify,
		$tlib->subdir('lib/VERSION/ARCH-linux')->stringify,           $tlib->subdir('lib/VERSION')->stringify,
	);

	my @mods;
	for my $mod (qw( Test::A Test::B Test::C Test::D )) {
		is(
			exception {
				push @mods, Module::Data->new($mod);
			},
			undef,
			"Making MD for $mod works"
		);
	}

	for my $mod (qw( Test::A Test::B Test::C Test::D )) {
		my $key = Module::Runtime::module_notional_filename($mod);
		is( $INC{$key}, undef, "Module $mod wasn't loaded into global context" );
	}

	for my $mod (@mods) {
		my $path;
		is(
			exception {
				$path = $mod->path;
			},
			undef,
			"->path works for " . $mod->package
		);

		#		note $path;
	}

	for my $mod (qw( Test::A Test::B Test::C Test::D )) {
		my $key = Module::Runtime::module_notional_filename($mod);
		is( $INC{$key}, undef, "Module $mod wasn't loaded into global context" );
	}

	for my $mod (@mods) {
		my $root;
		is(
			exception {
				$root = $mod->root;
			},
			undef,
			"->root works for " . $mod->package
		);

		#		note $root;
	}

	for my $mod (qw( Test::A Test::B Test::C Test::D )) {
		my $key = Module::Runtime::module_notional_filename($mod);
		is( $INC{$key}, undef, "Module $mod wasn't loaded into global context" );
	}

	for my $mod (@mods) {
		my $version;
		is(
			exception {
				$version = $mod->version;
			},
			undef,
			"->version works for " . $mod->package
		);

		#		note $version;
	}

	for my $mod (qw( Test::A Test::B Test::C Test::D )) {
		my $key = Module::Runtime::module_notional_filename($mod);
		is( $INC{$key}, undef, "Module $mod wasn't loaded into global context" );
	}

	for my $mod (@mods) {
		my $version;
		is(
			exception {
				$version = $mod->_version_perl;
			},
			undef,
			"->_version_perl works for " . $mod->package
		);

		#		note $version;
	}
	for my $mod (qw( Test::A Test::B Test::C Test::D )) {
		my $key = Module::Runtime::module_notional_filename($mod);
		isnt( $INC{$key}, undef, "Module $mod WAS loaded into global context" );
	}
	for my $mod (qw( Test::A Test::B Test::C Test::D )) {
		my $e = $mod;
		$e =~ s/^Test:://;
		my $v;
		is(
			exception {
				$v = $mod->example();
			},
			undef,
			"Calls to $mod Work ( mod is definately loaded )"
		);
		is( $v, $e, "Value is as expected from $mod" );

		#		note explain { got => $v, want => $e };
	}
}

done_testing;


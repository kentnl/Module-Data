use strict;
use warnings;

use Test::More;

# FILENAME: 03_fake_system.t
# CREATED: 26/03/12 13:28:04 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: Simulate a Fake Installed System and test no-require features

use Test::Fatal;
use FindBin;
use Path::Class qw( dir );

my $tlib = dir($FindBin::RealBin)->subdir('03_t');

my $realinc = {%INC};
my $newinc  = {};

my $module_whitelist;

my @whitelist;
my @noload_whitelist;

push @whitelist,        qw( Module::Data Test::More Data::Dumper warnings );
push @whitelist,        qw( Module::Runtime overload Path::Class::File );
push @whitelist,        qw( Path::ScanINC Scalar::Util File::Spec Cwd );
push @whitelist,        qw( Module::Metadata strict version );
push @noload_whitelist, qw( Test::A Test::B Test::C Test::D );

require Module::Runtime;

for my $lib (@whitelist) {
	Module::Runtime::require_module($lib);
	my $nn = Module::Runtime::module_notional_filename($lib);
	$newinc->{$nn}           = $realinc->{$nn};
	$module_whitelist->{$nn} = 1;
}
for my $lib (@noload_whitelist) {
	my $nn = Module::Runtime::module_notional_filename($lib);
	$module_whitelist->{$nn} = 1;
}

{
	local %INC;
	%INC = ( %{$newinc} );

	@INC = (
		sub {
			my ( $code, $filename ) = @_;
			if ( not exists $module_whitelist->{$filename} ) {
				die "$filename requested but not whitelisted";
			}
			return;
		},

		$tlib->subdir('lib/site_perl/VERSION/ARCH-linux')->stringify,
		$tlib->subdir('lib/site_perl/VERSION')->stringify,
		$tlib->subdir('lib/VERSION/ARCH-linux')->stringify,
		$tlib->subdir('lib/VERSION')->stringify,
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


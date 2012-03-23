use strict;
use warnings;

package Module::Data;

# ABSTRACT: Introspect context information about modules in @INC

use Moo;
use Sub::Quote;
use Module::Runtime qw();
use Path::Class::File;
use Path::Class::Dir;

around BUILDARGS => sub {
	my ( $orig, $class, @args ) = @_;

	unshift @args, 'package' if @args % 2 == 1;

	return $class->$orig(@args);
};

=head1 SYNOPSIS

    use Module::Data;

    my $d = Module::Data->new( 'Package::Stash' );

    $d->path; # returns the path to where Package::Stash was found in @INC

    $d->root; # returns the root directory in @INC that 'Package::Stash' was found inside. 

    # Convenient trick to discern if you're in a development environment

    my $d = Module::Data->new( 'Module::Im::Developing' );

    if ( -e $d->root->parent->dir('share') ) {
        # Yep, this dir exists, so we're in a dev context.
        # because we know in the development context all modules are in lib/*/*
        # so if the modules are anywhere else, its not a dev context.
        # see File::ShareDir::ProjectDistDir for more.
    }

	# Helpful sugar. 

	my $v = $d->version; 

Presently all the guts are running of Perl INC{} magic, but work is in progress and this is just an early release for some base functionality. 

=cut

## no critic ( ProhibitImplicitNewlines )

=method package

Returns the package the C<Module::Data> instance was created for.

	my $package = $md->package 

=cut

has package => (
	required => 1,
	is       => 'ro',
	isa      => quote_sub q{
        die "given undef for 'package' , expects a Str/module name" if not defined $_[0];
        die " ( 'package' => $_[0] ) is not a Str/module name, got a ref : " . ref $_[0] if ref $_[0];
        Module::Runtime::check_module_name( $_[0] );
    },
);

has _notional_name => (
	is      => 'ro',
	lazy    => 1,
	default => quote_sub q{
        return Module::Runtime::module_notional_filename( $_[0]->package );
    },
);

has _inc_path => (
	is      => 'ro',
	lazy    => 1,
	default => quote_sub q|
        Module::Runtime::require_module( $_[0]->package );
        return $INC{ $_[0]->_notional_name };
    |,
);

## use critic

=method path

A Path::Class::File with the absolute path to the found module.

	my $path = $md->path;

=cut

has path => (
	is       => 'ro',
	lazy     => 1,
	init_arg => undef,
	builder  => '_build_path',
);

sub _build_path {
	return Path::Class::File->new( $_[0]->_inc_path )->absolute;
}

=method root

Returns the base directory of the tree the module was found at. 
( Probably from @INC );

	my $root = $md->root

=cut

has root => (
	is       => 'ro',
	lazy     => 1,
	init_arg => undef,
	builder  => '_build_root',
);

sub _build_root {
	my (@bits) = split /::/, $_[0]->package;
	$bits[-1] .= '.pm';
	my ($path) = $_[0]->path;

	# Parent ne Self is the only cross-platform way
	# I can think of that will stop at the top of a tree
	# as / is not applicable on windows.
	while ( $path->parent->absolute ne $path->absolute ) {
		if ( not $path->is_dir ) {
			$path = $path->parent;
			next;
		}
		if ( $path->file(@bits)->absolute eq $_[0]->path->absolute ) {
			return $path->absolute;
		}
		$path = $path->parent;
	}
	return;

}

=method version

	my $v = $md->version;

	# really just shorthand convenience for $PACKAGE->VERSION 
	# will be possibly extracted out without loading the module first in a future release. 

=cut

sub version {
	my ( $self, @junk ) = @_;
	return $self->package->VERSION;
}
no Moo;

1;

use strict;
use warnings;

package Module::Data;

# ABSTRACT: Introspect context information about modules in @INC

use Moose;

=head1 SYNOPSIS

    use Module::Data;

    my $d = Module::Data->new( 'Package::Stash' );

    $d->path; # returns the path to where Package::Stash was found in @INC

    $d->root; # returns the root directory in @INC that 'Package::Stash' was found inside. 


=cut

__PACKAGE__->meta->make_immutable;
no Moose;

1;

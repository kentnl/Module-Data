use strict;
use warnings;

use Test::More;

# FILENAME: 02_version.t
# CREATED: 24/03/12 04:29:05 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: Test version lookup

use Module::Data;

my $module = Module::Data->new( 'Test::More' ); # because we know its loaded already

isnt( $module->version, undef , 'Module->version  works' ); 

note explain [ $module->version ];

done_testing;



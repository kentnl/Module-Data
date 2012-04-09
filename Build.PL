
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Data::Dump" => 0,
    "File::Find" => 0,
    "File::Temp" => 0,
    "FindBin" => 0,
    "Module::Build" => "0.3601",
    "Path::Class" => 0,
    "Test::Fatal" => 0,
    "Test::More" => "0.96"
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Introspect context information about modules in \@INC",
  "dist_author" => [
    "Kent Fredric <kentnl\@cpan.org>"
  ],
  "dist_name" => "Module-Data",
  "dist_version" => "0.002",
  "license" => "perl",
  "module_name" => "Module::Data",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Module::Metadata" => 0,
    "Module::Runtime" => 0,
    "Moo" => 0,
    "Path::Class::File" => 0,
    "Path::ScanINC" => 0,
    "Sub::Quote" => 0,
    "perl" => "5.006",
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;

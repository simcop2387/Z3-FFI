package Z3::FFI;

use Moo;
use warnings;

use Data::Dumper;
use FFI::Platypus;
use FFI::CheckLib qw//;
use File::ShareDir qw/dist_dir/;
use Path::Tiny;

my $search_path = path(dist_dir('Alien-Z3'))->child('dynamic');
my $ffi_lib = FFI::CheckLib::find_lib_or_die(lib => 'z3', libpath => $search_path);
my $ffi = FFI::Platypus->new();
$ffi->lib($ffi_lib);



1;

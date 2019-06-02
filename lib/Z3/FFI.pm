package Z3::FFI;

use Moo;
use warnings;

use Data::Dumper;
use FFI::Platypus;
use FFI::CheckLib qw//;
use FFI::Platypus::API qw/arguments_get_string/;
use File::ShareDir qw/dist_dir/;
use Path::Tiny;

use constant {
  # Z3_lbool
  Z3_L_FALSE => -1,
  Z3_L_UNDEF => 0,
  Z3_L_TRUE => 1,
  # Z3_symbol_kind
  Z3_INT_SYMBOL => 0,
  Z3_STRING_SYMBOL => 1,
  # Z3_paramter_kind
  Z3_PARAMETER_INT => 0,
  Z3_PARAMETER_DOUBLE => 1,
  Z3_PARAMETER_RATIONAL => 2,
  Z3_PARAMETER_SYMBOL => 3,
  Z3_PARAMETER_SORT => 4,
  Z3_PARAMETER_AST => 5,
  Z3_PARAMETER_FUNC_DECL => 6,


};

my $search_path = path(dist_dir('Alien-Z3'))->child('dynamic');
my $ffi_lib = FFI::CheckLib::find_lib_or_die(lib => 'z3', libpath => $search_path);
my $ffi = FFI::Platypus->new();
$ffi->lib($ffi_lib);

my $opaque_types = [map {"Z3_$_"} qw/config context symbol ast sort func_decl app pattern constructor constructor_list params param_descrs model func_interp func_entry fixedpoint optimize ast_vector ast_map goal tactic probe apply_result solver stats/];

my $functions = [
  [[Z3_get_full_version => 'get_full_version'] => [] => 'string'],
];

my $real_types = {
};

for my $type (@$opaque_types) {
  $ffi->custom_type($type => {
    native_type => 'opaque',
    native_to_perl => sub {
      my $class = arguments_get_string(0);
      print $class, "\n";
      bless \$_[0], $class;
    },
    perl_to_native => sub {${$_[0]}},
  });
}

for my $type_name (keys %$real_types) {

}

for my $function (@$functions) {
  $ffi->attach(@$function);
}

print get_full_version();

1;

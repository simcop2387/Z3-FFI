use Test::More;

use strict;
use warnings;

use_ok("Z3::FFI");

# Use Z3 to prove demorgan's law.

sub check_type {
    my ($input, $type, $message) = @_;
    is(ref($input), "Z3::FFI::Types::".$type, $message);
}

my $config = Z3::FFI::mk_config();
check_type($config, "Z3_config", "Config comes back as correct type");
my $context = Z3::FFI::mk_context($config);
check_type($context, "Z3_context", "Context comes back as correct type");
Z3::FFI::del_config($config); # delete config, like the c example does

my $bool_sort = Z3::FFI::mk_bool_sort($ctx);
check_type($bool_sort, "Z3_sort", "Bool sort comes back as correct type");

my $x_sym = Z3::FFI::mk_int_symbol($ctx, 0);
my $y_sym = Z3::FFI::mk_int_symbol($ctx, 1);
check_type($x_sym, "Z3_symbol", "Symbol comes back as correct type");
check_type($y_sym, "Z3_symbol", "Symbol comes back as correct type");


done_testing;

1;

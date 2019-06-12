use Test::More;

use strict;
use warnings;
use Data::Dumper;
use lib './';
use t::lib::helpers;

use_ok("Z3::FFI");

my $ctx = mk_context();
my $solver = mk_solver($ctx);

my $U_name = Z3::FFI::mk_string_symbol($ctx, "U");
my $U = Z3::FFI::mk_uninterpreted_sort($ctx, $U_name);

done_testing;

1;

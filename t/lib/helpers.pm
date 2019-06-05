package t::lib::helpers;

use Exporter qw/import/;

our @EXPORT=qw/check_type mk_var mk_bool_var mk_int_var mk_int mk_solver check/;

sub check_type {
    my ($input, $type, $message) = @_;
    is(ref($input), "Z3::FFI::Types::".$type, $message);
}

sub mk_solver {
  my ($ctx) = @_;
  my $solver = Z3::FFI::mk_solver($ctx);
  Z3::FFI::solver_inc_ref($ctx, $solver);
  check_type($solver, "Z3_solver", "Solver is correct type");
  return $solver;
}

sub mk_var {
    my ($ctx, $name, $sort) = @_;

    my $sym = Z3::FFI::mk_string_symbol($ctx, $name);
    check_type($sym, "Z3_symbol", "Symbol for $name");
    my $ast = Z3::FFI::mk_const($ctx, $sym, $sort);
    check_type($ast, "Z3_ast", "AST for $name");
    return $ast;
}

sub mk_bool_var {
    my ($ctx, $name) = @_;

    my $ty = Z3::FFI::mk_bool_sort($ctx);
    check_type($ty, "Z3_sort", "Bool sort for $name");
    my $var = mk_var($ctx, $name, $ty);
    check_type($var, "Z3_ast", "Bool var for $name");
    return $var;
}

sub mk_int_var {
    my ($ctx, $name) = @_;

    my $ty = Z3::FFI::mk_int_sort($ctx);
    check_type($ty, "Z3_sort", "Int sort for $name");
    my $var = mk_var($ctx, $name, $ty);
    check_type($var, "Z3_ast", "Int var for $name");
    return $var;
}

sub mk_int {
    my ($ctx, $value) = @_;
    my $ty = Z3::FFI::mk_int_sort($ctx);
    check_type($ty, "Z3_sort", "Int sort for int value");
    my $val = Z3::FFI::mk_int($ctx, $value, $ty);
    check_type($val, "Z3_ast", "Int value for int value");
    return $val;
}

sub check {
    my ($ctx, $solver, $exp_result, $model_name, $model_test) = @_;

    my $result = Z3::FFI::solver_check($ctx, $solver);
    if ($result == Z3::FFI::Z3_L_FALSE()) {
        pass("Unable to satisfy model, $model_name");
    } elsif ($result == Z3::FFI::Z3_L_UNDEF()) {
        pass("Potential model found, $model_name");
    } elsif ($result == Z3::FFI::Z3_L_TRUE()) {
        pass("Model found, $model_name");
    } else {
        fail("Unknown value from solver_check, $model_name, ".$result);
        exit(-1); # Bail out entirely, something is really wrong.
    }

    is($result, $exp_result, "Model result matches expected");
    
    if ($exp_result != Z3::FFI::Z3_L_FALSE()) {
        my $model = Z3::FFI::solver_get_model($ctx, $solver);
        warn Dumper($model);
        check_type($model, "Z3_model", "Model comes back successfully");
        Z3::FFI::model_inc_ref($ctx, $model);

        my $model_string = Z3::FFI::model_to_string($ctx, $model);
        is($model_string, $model_test, "Model for $model_name matches");
        Z3::FFI::model_dec_ref($ctx, $model);
    } else {
        pass("No model to attempt to display");
    }
}


1;
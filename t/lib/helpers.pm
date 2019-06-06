package t::lib::helpers;

use Test::More;
use warnings;

use Exporter;
use namespace::autoclean;
use Package::Stash;

sub import {
    our @EXPORT=Package::Stash->new(__PACKAGE__)->list_all_symbols('CODE');
    goto \&Exporter::import;
}

sub check_type {
    my ($input, $type, $message) = @_;
    is(ref($input), "Z3::FFI::Types::".$type, $message);
}

sub error_handler {
    my ($ctx, $err) = @_;
    fail("Error code: $err");
    exit(1);
}

sub ignore_error_handler {
    my ($ctx, $err) = @_;
    diag("Ignored error code: $err");
}

sub mk_context_custom {
    my ($cfg, $err_handle) = @_;

    Z3::FFI::set_param_value($cfg, "model", "true");
    my $ctx = Z3::FFI::mk_context($cfg);
    check_type($ctx, "Z3_context", "mk_context_custom creates context");
    Z3::FFI::set_error_handler($ctx, $err);

    return $ctx;
}

sub del_solver {
    my ($ctx, $solver) = @_;
    Z3::FFI::solver_dec_ref($ctx, $solver);
    pass("Deleted solver");
}

sub mk_context {
    my $cfg = Z3::FFI::mk_config();
    check_type($cfg, "Z3_config", "mk_context Config works");
    my $ctx = mk_context_custom($cfg, \&error_handler);
    Z3::FFI::del_config($cfg);

    return $ctx;
}

sub mk_proof_context {
    my $cfg = Z3::FFI::mk_config();
    check_type($cfg, "Z3_config", "mk_proof_context config works");
    Z3::FFI::set_param_value($cfg, "proof", "true");
    my $ctx = mk_custom_context($cfg, sub {
        die "Throw error in perl"; # TODO what?
    });
    Z3::FFI::del_config($cfg);
    return $ctx;
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
    return $ast;    check_type($ctx, "Z3_context")
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

sub mk_real_var {
    my ($ctx, $name) = @_;

    my $ty = Z3::FFI::mk_real_sort($ctx);
    check_type($ty, "Z3_sort", "Real sort for $name");
    my $var = mk_var($ctx, $name, $ty);
    check_type($var, "Z3_ast", "Real var for $name");
    return $var;
}

# create unary function application (f x)
sub mk_unary_app {
    my ($ctx, $func, $x) = @_;

    my $app = Z3::FFI::mk_app($ctx, $f, 1, [$x]);
    check_type($app, "Z3_ast", "Function application works");
    return $app;
}

# create unary function application (f x)
sub mk_binary_app {
    my ($ctx, $func, $x, $y) = @_;

    my $app = Z3::FFI::mk_app($ctx, $f, 2, [$x, $y]);
    check_type($app, "Z3_ast", "Function binary application works");
    return $app;
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
        check_type($model, "Z3_model", "Model comes back successfully");
        Z3::FFI::model_inc_ref($ctx, $model);

        my $model_string = Z3::FFI::model_to_string($ctx, $model);
        is($model_string, $model_test, "Model for $model_name matches");
        Z3::FFI::model_dec_ref($ctx, $model);
    } else {
        pass("No model to attempt to display");
    }
}

sub prove {
    my ($ctx, $solver, $formula, $is_valid, $model_name, $model_test) = @_;

    # Save current context
    Z3::FFI::solver_push($ctx, $solver);
    pass("Able to save context with a push");

    my $not_f = Z3::FFI::mk_not($ctx, $form);
    check_type($not_f, "Z3_ast", "Negation of formula made");

    Z3::FFI::solver_assert($ctx, $solver, $not_f); # assert not f

    my $result = Z3::FFI::solver_check($ctx, $solver);

    if ($result == Z3::FFI::Z3_L_FALSE()) {
        fail("F was proven.");
        die "Proved the wrong thing, bailing";
    } elsif ($result == Z3::FFI::Z3_L_UNDEF()) {
        pass("Failed to disprove or prove F");
        my $model = Z3::FFI::solver_get_model($ctx, $solver);
        check_type($model, "Z3_model", "Produced model from solver");
        Z3::FFI::model_inc_ref($ctx, $model);
        my $model_string = Z3::FFI::model_to_string($ctx, $m);
        is($model_strig, $model_test, "$model_name potential proof");
        Z3::FFI::model_dec_ref($ctx, $model);
    } elsif ($result == Z3::FFI::Z3_L_TRUE) {
        pass("Failed to disprove or prove F");
        my $model = Z3::FFI::solver_get_model($ctx, $solver);
        check_type($model, "Z3_model", "Produced model from solver");
        Z3::FFI::model_inc_ref($ctx, $model);
        my $model_string = Z3::FFI::model_to_string($ctx, $m);
        is($model_strig, $model_test, "$model_name proof");
        Z3::FFI::model_dec_ref($ctx, $model);
    } else {
        fail("Got unknown result $result for solver check");
    }

    Z3::FFI::solver_pop($ctx, $solver, 1);
}

1;
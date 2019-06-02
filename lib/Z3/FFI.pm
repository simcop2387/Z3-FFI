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
  # Z3_bool
  Z3_TRUE => 1,
  Z3_FALSE => 0,
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
  # Z3_sort_kind
  Z3_UNINTERRUPTED_SORT => 0,
  Z3_BOOL_SORT => 1,
  Z3_INT_SORT => 2,
  Z3_REAL_SORT => 3,
  Z3_BV_SORT => 4,
  Z3_ARRAY_SORT => 5,
  Z3_DATATYPE_SORT => 6,
  Z3_RELATION_SORT => 7,
  Z3_FINITE_DOMAIN_SORT => 8,
  Z3_FLOATING_POINT_SORT => 9,
  Z3_ROUNDING_MODE_SORT => 10,
  Z3_SEQ_SORT => 11,
  Z3_RE_SORT => 12,
  Z3_UNKNOWN_SORT => 1000,
  # Z3_ast_kind
  Z3_NUMERAL_AST => 0,
  Z3_APP_AST => 1,
  Z3_VAR_AST => 2,
  Z3_QUANTIFIER_AST => 3,
  Z3_SORT_AST => 4,
  Z3_FUNC_DECL_AST => 5,
  Z3_UNKNOWN_AST => 1000,
  # Z3_param_kind
  Z3_PK_UINT => 0,
  Z3_PK_BOOL => 1,
  Z3_PK_DOUBLE => 2,
  Z3_PK_SYMBOL => 3,
  Z3_PK_STRING => 4,
  Z3_PK_OTHER => 5,
  Z3_PK_INVALID => 6,
  # Z3_ast_print_mode
  Z3_PRINT_SMTLIB_FULL => 0,
  Z3_PRINT_LOW_LEVEL => 1,
  Z3_PRINT_SMTLIB2_COMPLIANT => 2,
  # Z3_error_code
  Z3_OK => 0,
  Z3_SORT_ERROR => 1,
  Z3_IOB => 2,
  Z3_INVALID_ARG => 3,
  Z3_PARSER_ERROR => 4,
  Z3_NO_PARSER => 5,
  Z3_INVALID_PATTERN => 6,
  Z3_MEMOUT_FAIL => 7,
  Z3_FILE_ACCESS_ERROR => 8,
  Z3_INTERNAL_FATAL => 9,
  Z3_INVALID_USAGE => 10,
  Z3_DEC_REF_ERROR => 11,
  Z3_EXCEPTION => 12,
  # Z3_goal_prec
  Z3_GOAL_PRECISE => 0,
  Z3_GOAL_UNDER => 1,
  Z3_GOAL_OVER => 2,
  Z3_GOAL_UNDER_OVER => 3,
  # Z3_decl_kind
  Z3_OP_TRUE => 256, Z3_OP_FALSE => 257, Z3_OP_EQ => 258, Z3_OP_DISTINCT => 259, 
  Z3_OP_ITE => 260, Z3_OP_AND => 261, Z3_OP_OR => 262, Z3_OP_IFF => 263, 
  Z3_OP_XOR => 264, Z3_OP_NOT => 265, Z3_OP_IMPLIES => 266, Z3_OP_OEQ => 267, 
  Z3_OP_ANUM => 512, Z3_OP_AGNUM => 513, Z3_OP_LE => 514, Z3_OP_GE => 515, 
  Z3_OP_LT => 516, Z3_OP_GT => 517, Z3_OP_ADD => 518, Z3_OP_SUB => 519, 
  Z3_OP_UMINUS => 520, Z3_OP_MUL => 521, Z3_OP_DIV => 522, Z3_OP_IDIV => 523, 
  Z3_OP_REM => 524, Z3_OP_MOD => 525, Z3_OP_TO_REAL => 526, Z3_OP_TO_INT => 527, 
  Z3_OP_IS_INT => 528, Z3_OP_POWER => 529, Z3_OP_STORE => 768, Z3_OP_SELECT => 769, 
  Z3_OP_CONST_ARRAY => 770, Z3_OP_ARRAY_MAP => 771, Z3_OP_ARRAY_DEFAULT => 772, Z3_OP_SET_UNION => 773, 
  Z3_OP_SET_INTERSECT => 774, Z3_OP_SET_DIFFERENCE => 775, Z3_OP_SET_COMPLEMENT => 776, Z3_OP_SET_SUBSET => 777, 
  Z3_OP_AS_ARRAY => 778, Z3_OP_ARRAY_EXT => 779, Z3_OP_BNUM => 1024, Z3_OP_BIT1 => 1025, 
  Z3_OP_BIT0 => 1026, Z3_OP_BNEG => 1027, Z3_OP_BADD => 1028, Z3_OP_BSUB => 1029, 
  Z3_OP_BMUL => 1030, Z3_OP_BSDIV => 1031, Z3_OP_BUDIV => 1032, Z3_OP_BSREM => 1033, 
  Z3_OP_BUREM => 1034, Z3_OP_BSMOD => 1035, Z3_OP_BSDIV0 => 1036, Z3_OP_BUDIV0 => 1037, 
  Z3_OP_BSREM0 => 1038, Z3_OP_BUREM0 => 1039, Z3_OP_BSMOD0 => 1040, Z3_OP_ULEQ => 1041, 
  Z3_OP_SLEQ => 1042, Z3_OP_UGEQ => 1043, Z3_OP_SGEQ => 1044, Z3_OP_ULT => 1045, 
  Z3_OP_SLT => 1046, Z3_OP_UGT => 1047, Z3_OP_SGT => 1048, Z3_OP_BAND => 1049, 
  Z3_OP_BOR => 1050, Z3_OP_BNOT => 1051, Z3_OP_BXOR => 1052, Z3_OP_BNAND => 1053, 
  Z3_OP_BNOR => 1054, Z3_OP_BXNOR => 1055, Z3_OP_CONCAT => 1056, Z3_OP_SIGN_EXT => 1057, 
  Z3_OP_ZERO_EXT => 1058, Z3_OP_EXTRACT => 1059, Z3_OP_REPEAT => 1060, Z3_OP_BREDOR => 1061, 
  Z3_OP_BREDAND => 1062, Z3_OP_BCOMP => 1063, Z3_OP_BSHL => 1064, Z3_OP_BLSHR => 1065, 
  Z3_OP_BASHR => 1066, Z3_OP_ROTATE_LEFT => 1067, Z3_OP_ROTATE_RIGHT => 1068, Z3_OP_EXT_ROTATE_LEFT => 1069, 
  Z3_OP_EXT_ROTATE_RIGHT => 1070, Z3_OP_BIT2BOOL => 1071, Z3_OP_INT2BV => 1072, Z3_OP_BV2INT => 1073, 
  Z3_OP_CARRY => 1074, Z3_OP_XOR3 => 1075, Z3_OP_BSMUL_NO_OVFL => 1076, Z3_OP_BUMUL_NO_OVFL => 1077, 
  Z3_OP_BSMUL_NO_UDFL => 1078, Z3_OP_BSDIV_I => 1079, Z3_OP_BUDIV_I => 1080, Z3_OP_BSREM_I => 1081, 
  Z3_OP_BUREM_I => 1082, Z3_OP_BSMOD_I => 1083, Z3_OP_PR_UNDEF => 1280, Z3_OP_PR_TRUE => 1281, 
  Z3_OP_PR_ASSERTED => 1282, Z3_OP_PR_GOAL => 1283, Z3_OP_PR_MODUS_PONENS => 1284, Z3_OP_PR_REFLEXIVITY => 1285, 
  Z3_OP_PR_SYMMETRY => 1286, Z3_OP_PR_TRANSITIVITY => 1287, Z3_OP_PR_TRANSITIVITY_STAR => 1288, Z3_OP_PR_MONOTONICITY => 1289, 
  Z3_OP_PR_QUANT_INTRO => 1290, Z3_OP_PR_BIND => 1291, Z3_OP_PR_DISTRIBUTIVITY => 1292, Z3_OP_PR_AND_ELIM => 1293, 
  Z3_OP_PR_NOT_OR_ELIM => 1294, Z3_OP_PR_REWRITE => 1295, Z3_OP_PR_REWRITE_STAR => 1296, Z3_OP_PR_PULL_QUANT => 1297, 
  Z3_OP_PR_PUSH_QUANT => 1298, Z3_OP_PR_ELIM_UNUSED_VARS => 1299, Z3_OP_PR_DER => 1300, Z3_OP_PR_QUANT_INST => 1301, 
  Z3_OP_PR_HYPOTHESIS => 1302, Z3_OP_PR_LEMMA => 1303, Z3_OP_PR_UNIT_RESOLUTION => 1304, Z3_OP_PR_IFF_TRUE => 1305, 
  Z3_OP_PR_IFF_FALSE => 1306, Z3_OP_PR_COMMUTATIVITY => 1307, Z3_OP_PR_DEF_AXIOM => 1308, Z3_OP_PR_DEF_INTRO => 1309, 
  Z3_OP_PR_APPLY_DEF => 1310, Z3_OP_PR_IFF_OEQ => 1311, Z3_OP_PR_NNF_POS => 1312, Z3_OP_PR_NNF_NEG => 1313, 
  Z3_OP_PR_SKOLEMIZE => 1314, Z3_OP_PR_MODUS_PONENS_OEQ => 1315, Z3_OP_PR_TH_LEMMA => 1316, Z3_OP_PR_HYPER_RESOLVE => 1317, 
  Z3_OP_RA_STORE => 1536, Z3_OP_RA_EMPTY => 1537, Z3_OP_RA_IS_EMPTY => 1538, Z3_OP_RA_JOIN => 1539, 
  Z3_OP_RA_UNION => 1540, Z3_OP_RA_WIDEN => 1541, Z3_OP_RA_PROJECT => 1542, Z3_OP_RA_FILTER => 1543, 
  Z3_OP_RA_NEGATION_FILTER => 1544, Z3_OP_RA_RENAME => 1545, Z3_OP_RA_COMPLEMENT => 1546, Z3_OP_RA_SELECT => 1547, 
  Z3_OP_RA_CLONE => 1548, Z3_OP_FD_CONSTANT => 1549, Z3_OP_FD_LT => 1550, Z3_OP_SEQ_UNIT => 1551, 
  Z3_OP_SEQ_EMPTY => 1552, Z3_OP_SEQ_CONCAT => 1553, Z3_OP_SEQ_PREFIX => 1554, Z3_OP_SEQ_SUFFIX => 1555, 
  Z3_OP_SEQ_CONTAINS => 1556, Z3_OP_SEQ_EXTRACT => 1557, Z3_OP_SEQ_REPLACE => 1558, Z3_OP_SEQ_AT => 1559, 
  Z3_OP_SEQ_LENGTH => 1560, Z3_OP_SEQ_INDEX => 1561, Z3_OP_SEQ_TO_RE => 1562, Z3_OP_SEQ_IN_RE => 1563, 
  Z3_OP_STR_TO_INT => 1564, Z3_OP_INT_TO_STR => 1565, Z3_OP_RE_PLUS => 1566, Z3_OP_RE_STAR => 1567, 
  Z3_OP_RE_OPTION => 1568, Z3_OP_RE_CONCAT => 1569, Z3_OP_RE_UNION => 1570, Z3_OP_RE_RANGE => 1571, 
  Z3_OP_RE_LOOP => 1572, Z3_OP_RE_INTERSECT => 1573, Z3_OP_RE_EMPTY_SET => 1574, Z3_OP_RE_FULL_SET => 1575, 
  Z3_OP_RE_COMPLEMENT => 1576, Z3_OP_LABEL => 1792, Z3_OP_LABEL_LIT => 1793, Z3_OP_DT_CONSTRUCTOR => 2048, 
  Z3_OP_DT_RECOGNISER => 2049, Z3_OP_DT_IS => 2050, Z3_OP_DT_ACCESSOR => 2051, Z3_OP_DT_UPDATE_FIELD => 2052, 
  Z3_OP_PB_AT_MOST => 2304, Z3_OP_PB_AT_LEAST => 2305, Z3_OP_PB_LE => 2306, Z3_OP_PB_GE => 2307, 
  Z3_OP_PB_EQ => 2308, Z3_OP_FPA_RM_NEAREST_TIES_TO_EVEN => 2309, Z3_OP_FPA_RM_NEAREST_TIES_TO_AWAY => 2310, Z3_OP_FPA_RM_TOWARD_POSITIVE => 2311, 
  Z3_OP_FPA_RM_TOWARD_NEGATIVE => 2312, Z3_OP_FPA_RM_TOWARD_ZERO => 2313, Z3_OP_FPA_NUM => 2314, Z3_OP_FPA_PLUS_INF => 2315, 
  Z3_OP_FPA_MINUS_INF => 2316, Z3_OP_FPA_NAN => 2317, Z3_OP_FPA_PLUS_ZERO => 2318, Z3_OP_FPA_MINUS_ZERO => 2319, 
  Z3_OP_FPA_ADD => 2320, Z3_OP_FPA_SUB => 2321, Z3_OP_FPA_NEG => 2322, Z3_OP_FPA_MUL => 2323, 
  Z3_OP_FPA_DIV => 2324, Z3_OP_FPA_REM => 2325, Z3_OP_FPA_ABS => 2326, Z3_OP_FPA_MIN => 2327, 
  Z3_OP_FPA_MAX => 2328, Z3_OP_FPA_FMA => 2329, Z3_OP_FPA_SQRT => 2330, Z3_OP_FPA_ROUND_TO_INTEGRAL => 2331, 
  Z3_OP_FPA_EQ => 2332, Z3_OP_FPA_LT => 2333, Z3_OP_FPA_GT => 2334, Z3_OP_FPA_LE => 2335, 
  Z3_OP_FPA_GE => 2336, Z3_OP_FPA_IS_NAN => 2337, Z3_OP_FPA_IS_INF => 2338, Z3_OP_FPA_IS_ZERO => 2339, 
  Z3_OP_FPA_IS_NORMAL => 2340, Z3_OP_FPA_IS_SUBNORMAL => 2341, Z3_OP_FPA_IS_NEGATIVE => 2342, Z3_OP_FPA_IS_POSITIVE => 2343, 
  Z3_OP_FPA_FP => 2344, Z3_OP_FPA_TO_FP => 2345, Z3_OP_FPA_TO_FP_UNSIGNED => 2346, Z3_OP_FPA_TO_UBV => 2347, 
  Z3_OP_FPA_TO_SBV => 2348, Z3_OP_FPA_TO_REAL => 2349, Z3_OP_FPA_TO_IEEE_BV => 2350, Z3_OP_FPA_BVWRAP => 2351, 
  Z3_OP_FPA_BV2RM => 2352, Z3_OP_INTERNAL => 2353, Z3_OP_UNINTERPRETED => 2354
};

my $opaque_types = [map {"Z3_$_"} qw/config context symbol ast sort func_decl app pattern constructor constructor_list params param_descrs model func_interp func_entry fixedpoint optimize ast_vector ast_map goal tactic probe apply_result solver stats/];

my $functions = [
  [get_full_version => [] => 'string'],
  # Global Parameters
  [global_param_set => ['Z3_string', 'Z3_string'] => 'void'],
  [global_param_reset_all => [] => 'void'],
  # [global_param_get => ['Z3_string', 'Z3_string_ptr'] => 'Z3_bool'],
  # Create config
  [mk_config => [] => 'Z3_config'],
  [del_config => ['Z3_config'] => 'void'],
  [set_param_value => ['Z3_config', 'Z3_string', 'Z3_string'] => 'void'],
  # Context and AST Ref counting
  [mk_context => ['Z3_config'] => 'Z3_context'],
  [mk_context_rc => ['Z3_config'] => 'Z3_context'],
  [del_context => ['Z3_config'] => 'void'],
  [inc_ref => ['Z3_context', 'Z3_ast'] => 'void'],
  [dec_ref => ['Z3_context', 'Z3_ast'] => 'void'],
  [update_param_value => ['Z3_context', 'Z3_string', 'Z3_string'] => 'void'],
  [interrupt => ['Z3_context'] => 'void'],
  # Parameters
  [mk_params => ['Z3_context'] => 'Z3_params'],
  [params_inc_ref => ['Z3_context', 'Z3_params'] => 'void'],
  [params_dec_ref => ['Z3_context', 'Z3_params'] => 'void'],
  [params_set_bool => ['Z3_context', 'Z3_params', 'Z3_symbol', 'Z3_bool'] => 'void'],
];

my $search_path = path(dist_dir('Alien-Z3'))->child('dynamic');
my $ffi_lib = FFI::CheckLib::find_lib_or_die(lib => 'z3', libpath => $search_path);
my $ffi = FFI::Platypus->new();
$ffi->lib($ffi_lib);

my $real_types = {
  Z3_bool => 'char', # TODO this might actually change on some platforms 
  Z3_string => 'string',
  Z3_string_ptr => 'opaque', # TODO this likely needs some string code, it's likely only used for out parameters by Z3
  # Z3_error_handler => # TODO ...
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
  my $real_type = $real_types->{$type_name};
  $ffi->type($real_type => $type_name);
}

for my $function (@$functions) {
  my $name = shift @$function;
  $ffi->attach(["Z3_$name" => $name], @$function);
}

print get_full_version();

1;

global.g_gml_token_constructors = ["header", "macro_def", "macro_start", "hash", "semico", "comma", "period", "colon", "qmark", "at_sign", "dollar_sign", "keyword", "ident", "undefined_hx", "boolean", "number", "cstring", "un_op", "adjfix", "bin_op", "set_op", "par_open", "par_close", "sqb_open", "sqb_close", "cub_open", "cub_close", "arg_const", "null_co", "null_co_set", "pragma"];
global.g_gml_node_constructors = ["undefined_hx", "boolean", "number", "cstring", "other_const", "enum_ctr", "array_decl", "object_decl", "ensure_array_for_local", "ensure_array_for_global", "ensure_array_for_field", "ensure_array_for_index", "ensure_array_for_index2d", "ident", "self_hx", "other_hx", "global_ref", "script", "native_script", "const", "arg_const", "arg_index", "arg_count", "call", "call_script", "call_script_at", "call_script_id", "call_script_with_array", "call_field", "call_func", "call_func_at", "construct", "func_literal", "prefix", "postfix", "un_op", "bin_op", "set_op", "delete_hx", "null_co", "to_bool", "from_bool", "in", "local_hx", "local_set", "local_aop", "static_hx", "static_set", "static_aop", "global_hx", "global_set", "global_aop", "script_static", "script_static_set", "script_static_aop", "field", "field_set", "field_aop", "env", "env_set", "env_aop", "env_fd", "env_fd_set", "env_fd_aop", "env1d", "env1d_set", "env1d_aop", "alarm", "alarm_set_hx", "alarm_aop", "index", "index_set", "index_aop", "index2d", "index2d_set", "index2d_aop", "raw_id", "raw_id_set", "raw_id_aop", "raw_id2d", "raw_id2d_set", "raw_id2d_aop", "ds_list", "ds_list_set_hx", "ds_list_aop", "ds_map", "ds_map_set_hx", "ds_map_aop", "ds_grid", "ds_grid_set_hx", "ds_grid_aop", "key_id", "key_id_set", "key_id_aop", "var_decl", "block", "if_then", "ternary", "switch_hx", "wait", "fork", "while_hx", "do_until", "do_while", "repeat_hx", "for_hx", "with_hx", "once", "return_hx", "exit_hx", "break_hx", "continue_hx", "debugger", "try_catch", "throw_hx"];
global.mq_gml_thread_scope = [undefined, undefined, 0, undefined, undefined, undefined, undefined, undefined, undefined, undefined, undefined];
global.gml_std_haxe_type_markerValue = [];
(function()
{})();

function gml_std_enum_toString()
{}

function gml_std_enum_getIndex()
{}

function gml_std_Date(arg0, arg1, arg2, arg3, arg4, arg5) constructor
{}

function gml_std_Date_now()
{}

function gml_builder(arg0, arg1) constructor
{}

function gml_std_Type_getEnumConstructs(arg0)
{}

function gml_std_Type_enumConstructor(arg0)
{}

function gml_std_Type_enumParameters(arg0)
{}

function gml_std_Type_enumIndex(arg0)
{}

function gml_std_StringTools_startsWith(arg0, arg1)
{}

function gml_std_StringTools_endsWith(arg0, arg1)
{}

function gml_std_StringTools_trim(arg0)
{}

function compile_groups_gml_compile_group_literal_proc_lf(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_literal_proc_lf1(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_literal_proc(arg0, arg1, arg2)
{}

function compile_groups_gml_compile_group_literal_init()
{}

function mc_gml_action() constructor
{}

function mc_gml_action_discard() : mc_gml_action() constructor
{}

function gml_action_discard(arg0)
{}

function mc_gml_action_dup() : mc_gml_action() constructor
{}

function gml_action_dup(arg0)
{}

function mc_gml_action_dup2x() : mc_gml_action() constructor
{}

function gml_action_dup2x(arg0)
{}

function mc_gml_action_dup3x() : mc_gml_action() constructor
{}

function gml_action_dup3x(arg0)
{}

function mc_gml_action_dup_in() : mc_gml_action() constructor
{}

function gml_action_dup_in(arg0, arg1)
{}

function mc_gml_action_undefined_hx() : mc_gml_action() constructor
{}

function gml_action_undefined_hx(arg0)
{}

function mc_gml_action_number() : mc_gml_action() constructor
{}

function gml_action_number(arg0, arg1)
{}

function mc_gml_action_cstring() : mc_gml_action() constructor
{}

function gml_action_cstring(arg0, arg1)
{}

function mc_gml_action_array_decl() : mc_gml_action() constructor
{}

function gml_action_array_decl(arg0, arg1)
{}

function mc_gml_action_object_decl() : mc_gml_action() constructor
{}

function gml_action_object_decl(arg0, arg1)
{}

function mc_gml_action_const() : mc_gml_action() constructor
{}

function gml_action_const(arg0, arg1)
{}

function mc_gml_action_self_hx() : mc_gml_action() constructor
{}

function gml_action_self_hx(arg0)
{}

function mc_gml_action_other_hx() : mc_gml_action() constructor
{}

function gml_action_other_hx(arg0)
{}

function mc_gml_action_local_hx() : mc_gml_action() constructor
{}

function gml_action_local_hx(arg0, arg1, arg2)
{}

function mc_gml_action_local_set() : mc_gml_action() constructor
{}

function gml_action_local_set(arg0, arg1, arg2)
{}

function mc_gml_action_local_aop() : mc_gml_action() constructor
{}

function gml_action_local_aop(arg0, arg1, arg2, arg3)
{}

function mc_gml_action_global_hx() : mc_gml_action() constructor
{}

function gml_action_global_hx(arg0, arg1)
{}

function mc_gml_action_global_set() : mc_gml_action() constructor
{}

function gml_action_global_set(arg0, arg1)
{}

function mc_gml_action_global_aop() : mc_gml_action() constructor
{}

function gml_action_global_aop(arg0, arg1, arg2)
{}

function mc_gml_action_field() : mc_gml_action() constructor
{}

function gml_action_field(arg0, arg1)
{}

function mc_gml_action_field_set() : mc_gml_action() constructor
{}

function gml_action_field_set(arg0, arg1)
{}

function mc_gml_action_field_aop() : mc_gml_action() constructor
{}

function gml_action_field_aop(arg0, arg1, arg2)
{}

function mc_gml_action_fast_field_aop() : mc_gml_action() constructor
{}

function gml_action_fast_field_aop(arg0, arg1, arg2, arg3)
{}

function mc_gml_action_self_field() : mc_gml_action() constructor
{}

function gml_action_self_field(arg0, arg1)
{}

function mc_gml_action_self_field_set() : mc_gml_action() constructor
{}

function gml_action_self_field_set(arg0, arg1)
{}

function mc_gml_action_self_field_aop() : mc_gml_action() constructor
{}

function gml_action_self_field_aop(arg0, arg1, arg2)
{}

function mc_gml_action_fast_self_field() : mc_gml_action() constructor
{}

function gml_action_fast_self_field(arg0, arg1)
{}

function mc_gml_action_fast_self_field_set() : mc_gml_action() constructor
{}

function gml_action_fast_self_field_set(arg0, arg1)
{}

function mc_gml_action_fast_self_field_aop() : mc_gml_action() constructor
{}

function gml_action_fast_self_field_aop(arg0, arg1, arg2, arg3)
{}

function mc_gml_action_local_field() : mc_gml_action() constructor
{}

function gml_action_local_field(arg0, arg1, arg2)
{}

function mc_gml_action_local_field_set() : mc_gml_action() constructor
{}

function gml_action_local_field_set(arg0, arg1, arg2)
{}

function mc_gml_action_local_field_aop() : mc_gml_action() constructor
{}

function gml_action_local_field_aop(arg0, arg1, arg2, arg3)
{}

function mc_gml_action_fast_local_field() : mc_gml_action() constructor
{}

function gml_action_fast_local_field(arg0, arg1, arg2)
{}

function mc_gml_action_fast_local_field_set() : mc_gml_action() constructor
{}

function gml_action_fast_local_field_set(arg0, arg1, arg2)
{}

function mc_gml_action_fast_local_field_aop() : mc_gml_action() constructor
{}

function gml_action_fast_local_field_aop(arg0, arg1, arg2, arg3, arg4)
{}

function mc_gml_action_index() : mc_gml_action() constructor
{}

function gml_action_index(arg0)
{}

function mc_gml_action_index_set() : mc_gml_action() constructor
{}

function gml_action_index_set(arg0)
{}

function mc_gml_action_index_aop() : mc_gml_action() constructor
{}

function gml_action_index_aop(arg0, arg1)
{}

function mc_gml_action_index2d() : mc_gml_action() constructor
{}

function gml_action_index2d(arg0)
{}

function mc_gml_action_index2d_set() : mc_gml_action() constructor
{}

function gml_action_index2d_set(arg0)
{}

function mc_gml_action_index2d_aop() : mc_gml_action() constructor
{}

function gml_action_index2d_aop(arg0, arg1)
{}

function mc_gml_action_env() : mc_gml_action() constructor
{}

function gml_action_env(arg0, arg1)
{}

function mc_gml_action_env_set() : mc_gml_action() constructor
{}

function gml_action_env_set(arg0, arg1, arg2)
{}

function mc_gml_action_env_aop() : mc_gml_action() constructor
{}

function gml_action_env_aop(arg0, arg1, arg2)
{}

function mc_gml_action_env1d() : mc_gml_action() constructor
{}

function gml_action_env1d(arg0, arg1)
{}

function mc_gml_action_env1d_set() : mc_gml_action() constructor
{}

function gml_action_env1d_set(arg0, arg1, arg2)
{}

function mc_gml_action_env1d_aop() : mc_gml_action() constructor
{}

function gml_action_env1d_aop(arg0, arg1, arg2)
{}

function mc_gml_action_ds_aop() : mc_gml_action() constructor
{}

function gml_action_ds_aop(arg0, arg1, arg2, arg3, arg4, arg5)
{}

function mc_gml_action_arg_const() : mc_gml_action() constructor
{}

function gml_action_arg_const(arg0, arg1)
{}

function mc_gml_action_arg_const_set() : mc_gml_action() constructor
{}

function gml_action_arg_const_set(arg0, arg1)
{}

function mc_gml_action_arg_const_aop() : mc_gml_action() constructor
{}

function gml_action_arg_const_aop(arg0, arg1, arg2)
{}

function mc_gml_action_arg_index() : mc_gml_action() constructor
{}

function gml_action_arg_index(arg0)
{}

function mc_gml_action_arg_index_set() : mc_gml_action() constructor
{}

function gml_action_arg_index_set(arg0)
{}

function mc_gml_action_arg_index_aop() : mc_gml_action() constructor
{}

function gml_action_arg_index_aop(arg0, arg1)
{}

function mc_gml_action_arg_count() : mc_gml_action() constructor
{}

function gml_action_arg_count(arg0)
{}

function mc_gml_action_add_int() : mc_gml_action() constructor
{}

function gml_action_add_int(arg0, arg1)
{}

function mc_gml_action_equ_op() : mc_gml_action() constructor
{}

function gml_action_equ_op(arg0)
{}

function mc_gml_action_neq_op() : mc_gml_action() constructor
{}

function gml_action_neq_op(arg0)
{}

function mc_gml_action_concat() : mc_gml_action() constructor
{}

function gml_action_concat(arg0)
{}

function mc_gml_action_bin_op() : mc_gml_action() constructor
{}

function gml_action_bin_op(arg0, arg1)
{}

function mc_gml_action_un_op() : mc_gml_action() constructor
{}

function gml_action_un_op(arg0, arg1)
{}

function mc_gml_action_in() : mc_gml_action() constructor
{}

function gml_action_in(arg0, arg1)
{}

function mc_gml_action_in_const() : mc_gml_action() constructor
{}

function gml_action_in_const(arg0, arg1, arg2)
{}

function mc_gml_action_call_script() : mc_gml_action() constructor
{}

function gml_action_call_script(arg0, arg1, arg2)
{}

function mc_gml_action_call_script_id() : mc_gml_action() constructor
{}

function gml_action_call_script_id(arg0, arg1)
{}

function mc_gml_action_call_script_with_array() : mc_gml_action() constructor
{}

function gml_action_call_script_with_array(arg0)
{}

function mc_gml_action_call_func() : mc_gml_action() constructor
{}

function gml_action_call_func(arg0, arg1, arg2, arg3, arg4, arg5, arg6)
{}

function mc_gml_action_call_func0() : mc_gml_action() constructor
{}

function gml_action_call_func0(arg0, arg1)
{}

function mc_gml_action_call_func0o() : mc_gml_action() constructor
{}

function gml_action_call_func0o(arg0, arg1)
{}

function mc_gml_action_call_func1() : mc_gml_action() constructor
{}

function gml_action_call_func1(arg0, arg1)
{}

function mc_gml_action_call_func1o() : mc_gml_action() constructor
{}

function gml_action_call_func1o(arg0, arg1)
{}

function mc_gml_action_call_func2() : mc_gml_action() constructor
{}

function gml_action_call_func2(arg0, arg1)
{}

function mc_gml_action_call_func2o() : mc_gml_action() constructor
{}

function gml_action_call_func2o(arg0, arg1)
{}

function mc_gml_action_call_func3() : mc_gml_action() constructor
{}

function gml_action_call_func3(arg0, arg1)
{}

function mc_gml_action_call_func3o() : mc_gml_action() constructor
{}

function gml_action_call_func3o(arg0, arg1)
{}

function mc_gml_action_call_func4() : mc_gml_action() constructor
{}

function gml_action_call_func4(arg0, arg1)
{}

function mc_gml_action_call_func4o() : mc_gml_action() constructor
{}

function gml_action_call_func4o(arg0, arg1)
{}

function mc_gml_action_call_func_with_local0() : mc_gml_action() constructor
{}

function gml_action_call_func_with_local0(arg0, arg1, arg2)
{}

function mc_gml_action_call_func_with_local0o() : mc_gml_action() constructor
{}

function gml_action_call_func_with_local0o(arg0, arg1, arg2)
{}

function mc_gml_action_call_func_with_local1() : mc_gml_action() constructor
{}

function gml_action_call_func_with_local1(arg0, arg1, arg2)
{}

function mc_gml_action_call_func_with_local1o() : mc_gml_action() constructor
{}

function gml_action_call_func_with_local1o(arg0, arg1, arg2)
{}

function mc_gml_action_call_func_with_local2() : mc_gml_action() constructor
{}

function gml_action_call_func_with_local2(arg0, arg1, arg2)
{}

function mc_gml_action_call_func_with_local2o() : mc_gml_action() constructor
{}

function gml_action_call_func_with_local2o(arg0, arg1, arg2)
{}

function mc_gml_action_call_func_with_local3() : mc_gml_action() constructor
{}

function gml_action_call_func_with_local3(arg0, arg1, arg2)
{}

function mc_gml_action_call_func_with_local3o() : mc_gml_action() constructor
{}

function gml_action_call_func_with_local3o(arg0, arg1, arg2)
{}

function mc_gml_action_call_func_with_local4() : mc_gml_action() constructor
{}

function gml_action_call_func_with_local4(arg0, arg1, arg2)
{}

function mc_gml_action_call_func_with_local4o() : mc_gml_action() constructor
{}

function gml_action_call_func_with_local4o(arg0, arg1, arg2)
{}

function mc_gml_action_call_field() : mc_gml_action() constructor
{}

function gml_action_call_field(arg0, arg1, arg2)
{}

function mc_gml_action_construct() : mc_gml_action() constructor
{}

function gml_action_construct(arg0, arg1)
{}

function mc_gml_action_func_literal() : mc_gml_action() constructor
{}

function gml_action_func_literal(arg0, arg1, arg2)
{}

function mc_gml_action_jump() : mc_gml_action() constructor
{}

function gml_action_jump(arg0, arg1)
{}

function mc_gml_action_jump_if() : mc_gml_action() constructor
{}

function gml_action_jump_if(arg0, arg1)
{}

function mc_gml_action_jump_unless() : mc_gml_action() constructor
{}

function gml_action_jump_unless(arg0, arg1)
{}

function mc_gml_action_jump_placeholder() : mc_gml_action() constructor
{}

function gml_action_jump_placeholder(arg0)
{}

function mc_gml_action_bool_and() : mc_gml_action() constructor
{}

function gml_action_bool_and(arg0, arg1)
{}

function mc_gml_action_bool_or() : mc_gml_action() constructor
{}

function gml_action_bool_or(arg0, arg1)
{}

function mc_gml_action_null_co() : mc_gml_action() constructor
{}

function gml_action_null_co(arg0, arg1)
{}

function mc_gml_action_switch_hx() : mc_gml_action() constructor
{}

function gml_action_switch_hx(arg0, arg1, arg2)
{}

function mc_gml_action_switch_case() : mc_gml_action() constructor
{}

function gml_action_switch_case(arg0, arg1)
{}

function mc_gml_action_repeat_jump() : mc_gml_action() constructor
{}

function gml_action_repeat_jump(arg0, arg1)
{}

function mc_gml_action_repeat_pre() : mc_gml_action() constructor
{}

function gml_action_repeat_pre(arg0, arg1)
{}

function mc_gml_action_with_pre() : mc_gml_action() constructor
{}

function gml_action_with_pre(arg0)
{}

function mc_gml_action_with_next() : mc_gml_action() constructor
{}

function gml_action_with_next(arg0, arg1)
{}

function mc_gml_action_with_post() : mc_gml_action() constructor
{}

function gml_action_with_post(arg0)
{}

function mc_gml_action_break_hx() : mc_gml_action() constructor
{}

function gml_action_break_hx(arg0, arg1)
{}

function mc_gml_action_continue_hx() : mc_gml_action() constructor
{}

function gml_action_continue_hx(arg0, arg1)
{}

function mc_gml_action_return_hx() : mc_gml_action() constructor
{}

function gml_action_return_hx(arg0)
{}

function mc_gml_action_return_const() : mc_gml_action() constructor
{}

function gml_action_return_const(arg0, arg1)
{}

function mc_gml_action_result() : mc_gml_action() constructor
{}

function gml_action_result(arg0)
{}

function mc_gml_action_try_hx() : mc_gml_action() constructor
{}

function gml_action_try_hx(arg0, arg1)
{}

function mc_gml_action_catch_hx() : mc_gml_action() constructor
{}

function gml_action_catch_hx(arg0, arg1)
{}

function mc_gml_action_finally_hx() : mc_gml_action() constructor
{}

function gml_action_finally_hx(arg0, arg1)
{}

function mc_gml_action_throw_hx() : mc_gml_action() constructor
{}

function gml_action_throw_hx(arg0)
{}

function mc_gml_action_wait() : mc_gml_action() constructor
{}

function gml_action_wait(arg0)
{}

function mc_gml_action_fork() : mc_gml_action() constructor
{}

function gml_action_fork(arg0, arg1)
{}

function mc_gml_action_ensure_array_for_local() : mc_gml_action() constructor
{}

function gml_action_ensure_array_for_local(arg0, arg1)
{}

function mc_gml_action_ensure_array_for_global() : mc_gml_action() constructor
{}

function gml_action_ensure_array_for_global(arg0, arg1)
{}

function mc_gml_action_ensure_array_for_field() : mc_gml_action() constructor
{}

function gml_action_ensure_array_for_field(arg0, arg1)
{}

function mc_gml_action_ensure_array_for_index() : mc_gml_action() constructor
{}

function gml_action_ensure_array_for_index(arg0)
{}

function mc_gml_action_ensure_array_for_index2d() : mc_gml_action() constructor
{}

function gml_action_ensure_array_for_index2d(arg0)
{}

function mc_gml_action_alarm() : mc_gml_action() constructor
{}

function gml_action_alarm(arg0)
{}

function mc_gml_action_alarm_set_hx() : mc_gml_action() constructor
{}

function gml_action_alarm_set_hx(arg0)
{}

function mc_gml_action_alarm_aop() : mc_gml_action() constructor
{}

function gml_action_alarm_aop(arg0, arg1)
{}

function mc_gml_action_closure() : mc_gml_action() constructor
{}

function gml_action_closure(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_args_get_simple(arg0)
{}

function compile_gml_compile_args_proc_lf(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_args_proc_lf1(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_args_proc(arg0, arg1, arg2 = 0, arg3 = array_length(arg1))
{}

function gml_func_copy(arg0, arg1, arg2)
{}

function gml_var_add(arg0, arg1)
{}

function gml_remove_var(arg0)
{}

function gml_const_add(arg0, arg1)
{}

function gml_remove_const(arg0)
{}

function gml_asset_add(arg0, arg1)
{}

function compile_gml_compile_call_func_proc_lf(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_call_func_proc_lf1(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_call_func_proc(arg0, arg1, arg2, arg3, arg4)
{}

function vm_v2_gml_action_closure_bind(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_adjfix_proc_lf(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_adjfix_proc_lf1(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_adjfix_proc_lf2(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_adjfix_proc_lf3(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_adjfix_proc(arg0, arg1, arg2, arg3, arg4, arg5)
{}

function compile_groups_gml_compile_group_static_has_statics_init()
{}

function compile_groups_gml_compile_group_static_no_static_writes(arg0)
{}

function compile_groups_gml_compile_group_static_proc_dot_static_lf(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_static_proc_dot_static_lf1(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_static_proc_dot_static_lf2(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_static_proc_dot_static_lf3(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_static_proc_dot_static_lf4(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_static_proc_dot_static_lf5(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_static_proc_dot_static(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_static_proc_dot_static_adjfix_lf(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_static_proc_dot_static_adjfix_lf1(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_static_proc_dot_static_adjfix(arg0, arg1, arg2, arg3, arg4, arg5)
{}

function compile_groups_gml_compile_group_static_proc_static_lf(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_static_proc_static_lf1(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_static_proc_static_lf2(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_static_proc_static(arg0, arg1, arg2)
{}

function compile_groups_gml_compile_group_static_proc_static_adjfix_lf(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_static_proc_static_adjfix_lf1(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_static_proc_static_adjfix_lf2(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_static_proc_static_adjfix_lf3(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_static_proc_static_adjfix(arg0, arg1, arg2, arg3, arg4)
{}

function compile_groups_gml_compile_group_static_proc_script_static(arg0, arg1, arg2)
{}

function compile_groups_gml_compile_group_static_proc_script_static_adjfix(arg0, arg1, arg2, arg3, arg4, arg5)
{}

function compile_groups_gml_compile_group_static_proc_dot_static_init_lf(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_static_proc_dot_static_init_lf1(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_static_proc_dot_static_init(arg0, arg1, arg2)
{}

function compile_groups_gml_compile_group_static_proc_static_init_lf(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_static_proc_static_init_lf1(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_static_proc_static_init(arg0)
{}

function compile_groups_gml_compile_group_static_init()
{}

function gml_func() constructor
{}

function gml_func_add(arg0, arg1)
{}

function gml_func_remove(arg0)
{}

function compile_gml_compile_bin_op_proc_lf(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_bin_op_proc_lf1(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_bin_op_proc_lf2(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_bin_op_proc_lf3(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_bin_op_proc_lf4(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_bin_op_proc_lf5(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_bin_op_proc_lf6(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_bin_op_proc(arg0, arg1, arg2, arg3, arg4)
{}

function gml_value_get_type(arg0)
{}

function gml_value_print(arg0)
{}

function gml_value_dump(arg0)
{}

function vm_value_gml_value_printer_print_rec(arg0, arg1)
{}

function gml_std_Std_stringify(arg0)
{}

function gml_std_Std_parseFloat(arg0)
{}

function gml_std_Std_parseInt(arg0)
{}

function gml_std_string_pos_ext_haxe(arg0, arg1, arg2 = 0)
{}

function gml_std_string_last_pos_haxe(arg0, arg1, arg2)
{}

function gml_std_string_split(arg0, arg1)
{}

function gml_std_string_substr(arg0, arg1, arg2)
{}

function gml_std_string_substring(arg0, arg1, arg2)
{}

function gml_op_is_simple(arg0)
{}

function gml_op_get_priority(arg0)
{}

function gml_op_to_string(arg0)
{}

function gml_op_apply_init_lf(arg0, arg1)
{}

function gml_op_apply_init_lf1(arg0, arg1)
{}

function gml_op_apply_init_lf2(arg0, arg1)
{}

function gml_op_apply_init_lf3(arg0, arg1)
{}

function gml_op_apply_init_lf4(arg0, arg1)
{}

function gml_op_apply_init_lf5(arg0, arg1)
{}

function gml_op_apply_init_lf6(arg0, arg1)
{}

function gml_op_apply_init_lf7(arg0, arg1)
{}

function gml_op_apply_init_lf8(arg0, arg1)
{}

function gml_op_apply_init_lf9(arg0, arg1)
{}

function gml_op_apply_init_lf10(arg0, arg1)
{}

function gml_op_apply_init_lf11(arg0, arg1)
{}

function gml_op_apply_init_lf12(arg0, arg1)
{}

function gml_op_apply_init_lf13(arg0, arg1)
{}

function gml_op_apply_init_lf14(arg0, arg1)
{}

function gml_op_apply_init_lf15(arg0, arg1)
{}

function gml_op_apply_init_lf16(arg0, arg1)
{}

function gml_op_apply_init_lf17(arg0, arg1)
{}

function gml_op_apply_init_lf18(arg0, arg1)
{}

function gml_op_apply_init()
{}

function gml_op_get_name(arg0)
{}

function compile_gml_compile_delete_proc_lf(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_delete_proc_lf1(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_delete_proc_lf2(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_delete_proc_lf3(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_delete_proc_lf4(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_delete_proc_lf5(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_delete_proc_lf6(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_delete_proc_lf7(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_delete_proc_lf8(arg0, arg1, arg2, arg3)
{}

function compile_gml_compile_delete_proc(arg0, arg1, arg2)
{}

function gml_std_haxe_enum_tools_getParameter(arg0, arg1)
{}

function gml_std_haxe_enum_tools_getParameterCount(arg0)
{}

function gml_std_haxe_enum_tools_setParameter(arg0, arg1, arg2)
{}

function gml_std_haxe_enum_tools_setTo(arg0, arg1)
{}

function gml_node_tools_unpack(arg0)
{}

function gml_node_tools_is_statement(arg0)
{}

function gml_node_tools_is_in_block(arg0, arg1)
{}

function gml_node_tools_to_case_value(arg0)
{}

function gml_node_tools_equals_list(arg0, arg1)
{}

function gml_node_tools_equals_lf(arg0, arg1, arg2, arg3)
{}

function gml_node_tools_equals(arg0, arg1)
{}

function gml_node_tools_clone_list(arg0)
{}

function gml_node_tools_clone_case(arg0)
{}

function gml_node_tools_clone(arg0)
{}

function gml_node_tools_seek_all_out(arg0, arg1, arg2, arg3, arg4)
{}

function gml_node_tools_seek_arr(arg0, arg1, arg2)
{}

function gml_node_tools_seek_or2(arg0, arg1, arg2, arg3)
{}

function gml_node_tools_seek_or3(arg0, arg1, arg2, arg3, arg4)
{}

function gml_node_tools_seek_or4(arg0, arg1, arg2, arg3, arg4, arg5)
{}

function gml_node_tools_seek_1or_arr(arg0, arg1, arg2, arg3)
{}

function gml_node_tools_seek_all(arg0, arg1, arg2, arg3)
{}

function gml_node_tools_seek(arg0, arg1, arg2)
{}

function gml_thread(arg0, arg1, arg2, arg3, arg4, arg5, arg6) constructor
{}

function gml_thread_error(arg0)
{}

function compile_groups_gml_compile_group_ds_proc(arg0, arg1, arg2)
{}

function compile_groups_gml_compile_group_ds_init()
{}

function compile_groups_gml_compile_group_array_proc_lf(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_array_proc_lf1(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_array_proc_lf2(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_array_proc_lf3(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_array_proc_lf4(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_array_proc_lf5(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_array_proc_lf6(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_array_proc_lf7(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_array_proc_lf8(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_array_proc_lf9(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_array_proc_lf10(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_array_proc_lf11(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_array_proc_lf12(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_array_proc_lf13(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_array_proc_lf14(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_array_proc_lf15(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_array_proc_lf16(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_array_proc_lf17(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_array_proc(arg0, arg1, arg2)
{}

function compile_groups_gml_compile_group_array_init()
{}

function compile_groups_gml_compile_group_local_proc_lf(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_local_proc_lf1(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_local_proc_lf2(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_local_proc_lf3(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_local_proc_lf4(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_local_proc_lf5(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_local_proc_lf6(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_local_proc_lf7(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_local_proc_lf8(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_local_proc_lf9(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_local_proc_lf10(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_local_proc_lf11(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_local_proc_lf12(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_local_proc_lf13(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_local_proc_lf14(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_local_proc_lf15(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_local_proc_lf16(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_local_proc_lf17(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_local_proc_lf18(arg0, arg1, arg2, arg3)
{}

function compile_groups_gml_compile_group_local_proc(arg0, arg1, arg2)
{}

function compile_groups_gml_compile_group_local_init()
{}

function gml_stack_push(arg0, arg1)
{}

function gml_stack_pop(arg0)
{}

function gml_stack_pop_multi(arg0, arg1)
{}

function gml_stack_discard(arg0)
{}

function gml_stack_discard_multi(arg0, arg1)
{}

function gml_compile_error(arg0, arg1)
{}

function gml_compile_const_val_of(arg0)
{}

function gml_compile_set_handlers(arg0, arg1)
{}

function gml_compile_init()
{}

function gml_compile_node(arg0, arg1, arg2)
{}

function gml_compile_add_exit(arg0)
{}

function gml_compile_script(arg0)
{}

function gml_compile_program(arg0)
{}

function haxe_ds__vector_vector_impl__fill(arg0, arg1)
{}

function api_api_version(arg0) constructor
{}

function api_api_version_create(arg0)
{}

function gml_parser(arg0) constructor
{}

function gml_parser_set_version(arg0)
{}

function gml_parser_buf_sub(arg0, arg1, arg2, arg3)
{}

function gml_parser_char_is_space_init()
{}

function gml_parser_template_state(arg0, arg1, arg2, arg3) constructor
{}

function _gml_parser_gml_parser_string_buf_impl__start()
{}

function _gml_parser_gml_parser_string_buf_impl__add_code_point(arg0, arg1)
{}

function _gml_parser_gml_parser_string_buf_impl__to_string(arg0)
{}

function gml_parser_macro(arg0, arg1, arg2) constructor
{}

function gml_program(arg0) constructor
{}

function gml_std_StringBuf() constructor
{}

function gml_api_parse_name(arg0, arg1)
{}

function api_api_var() constructor
{}

function gml_enum(arg0, arg1) constructor
{}

function gml_enum_create_builtin(arg0)
{}

function gml_enum_ctr(arg0, arg1, arg2) constructor
{}

function gml_macro(arg0, arg1, arg2, arg3) constructor
{}

function ast_gml_macro_proc_patch(arg0, arg1)
{}

function ast_gml_macro_proc_patch_nameof(arg0, arg1)
{}

function ast_gml_macro_proc_run(arg0, arg1)
{}

function ast_gml_node_def_param(arg0, arg1) constructor
{}

function ast_gml_node_def_ctr(arg0, arg1) constructor
{}

function ast_gml_node_tools_ni_concat_pos_iter(arg0, arg1)
{}

function ast_gml_node_tools_ni_concat_pos_rec(arg0, arg1)
{}

function ast_gml_node_tools_ni_get_pos_string(arg0, arg1)
{}

function gml_pos_create(arg0, arg1, arg2, arg3)
{}

function gml_pos_get_source(arg0, arg1)
{}

function gml_pos_copy(arg0)
{}

function gml_pos_concat(arg0, arg1)
{}

function gml_pos_to_string(arg0, arg1)
{}

function gml_pos_to_string_in(arg0, arg1)
{}

function gml_script(arg0, arg1, arg2) constructor
{}

function gml_source(arg0, arg1, arg2, arg3) constructor
{}

function gml_source_init_unknown()
{}

function gml_source_init_builtin()
{}

function data_gml_keyword_mapper_init_v(arg0)
{}

function data_gml_keyword_mapper_init_v1(arg0)
{}

function data_gml_keyword_mapper_init_v2(arg0)
{}

function data_gml_keyword_mapper_init_v3(arg0)
{}

function data_gml_keyword_mapper_init_v4(arg0)
{}

function data_gml_keyword_mapper_init_v5(arg0)
{}

function data_gml_keyword_mapper_init_v6(arg0)
{}

function data_gml_keyword_mapper_init_v7(arg0)
{}

function data_gml_keyword_mapper_init_v8(arg0)
{}

function data_gml_keyword_mapper_init_v9(arg0)
{}

function data_gml_keyword_mapper_init_v10(arg0)
{}

function data_gml_keyword_mapper_init_v11(arg0)
{}

function data_gml_keyword_mapper_init_v12(arg0)
{}

function data_gml_keyword_mapper_init_v13(arg0)
{}

function data_gml_keyword_mapper_init_v14(arg0)
{}

function data_gml_keyword_mapper_init_v15(arg0)
{}

function data_gml_keyword_mapper_init_v16(arg0)
{}

function data_gml_keyword_mapper_init_v17(arg0)
{}

function data_gml_keyword_mapper_init_v18(arg0)
{}

function data_gml_keyword_mapper_init_v19(arg0)
{}

function data_gml_keyword_mapper_init_v20(arg0)
{}

function data_gml_keyword_mapper_init_v21(arg0)
{}

function data_gml_keyword_mapper_init_v22(arg0)
{}

function data_gml_keyword_mapper_init_v23(arg0)
{}

function data_gml_keyword_mapper_init_v24(arg0)
{}

function data_gml_keyword_mapper_init_v25(arg0)
{}

function data_gml_keyword_mapper_init_v26(arg0)
{}

function data_gml_keyword_mapper_init_v27(arg0)
{}

function data_gml_keyword_mapper_init_v28(arg0)
{}

function data_gml_keyword_mapper_init_v29(arg0)
{}

function data_gml_keyword_mapper_init_v30(arg0)
{}

function data_gml_keyword_mapper_init_v31(arg0)
{}

function data_gml_keyword_mapper_init_v32(arg0)
{}

function data_gml_keyword_mapper_init_v33(arg0)
{}

function data_gml_keyword_mapper_init_v34(arg0)
{}

function data_gml_keyword_mapper_init_v35(arg0)
{}

function data_gml_keyword_mapper_init_v36(arg0)
{}

function data_gml_keyword_mapper_init_v37(arg0)
{}

function data_gml_keyword_mapper_init_v38(arg0)
{}

function data_gml_keyword_mapper_init_v39(arg0)
{}

function data_gml_keyword_mapper_init_v40(arg0)
{}

function data_gml_keyword_mapper_init_v41(arg0)
{}

function data_gml_keyword_mapper_init()
{}

function gml_std_haxe_class(arg0, arg1) constructor
{}

function gml_std_haxe_enum(arg0, arg1, arg2, arg3) constructor
{}

function gml_seek_adjfix_proc(arg0, arg1)
{}

function gml_seek_alarms_check(arg0)
{}

function gml_seek_alarms_proc(arg0, arg1)
{}

function gml_seek_arguments_proc(arg0, arg1)
{}

function gml_seek_calls_proc_func(arg0, arg1, arg2, arg3)
{}

function gml_seek_calls_proc(arg0, arg1)
{}

function gml_seek_enum_fields_proc_one(arg0, arg1)
{}

function gml_seek_enum_fields_proc(arg0, arg1)
{}

function gml_seek_enum_values_proc_one(arg0)
{}

function gml_seek_enum_values_proc()
{}

function gml_seek_eval_node_to_value(arg0)
{}

function gml_seek_eval_value_to_node(arg0, arg1)
{}

function gml_seek_eval_proc(arg0, arg1)
{}

function gml_seek_eval_eval(arg0)
{}

function gml_seek_eval_opt()
{}

function gml_seek_fields_proc(arg0, arg1)
{}

function gml_seek_idents_proc(arg0, arg1)
{}

function gml_seek_locals_proc(arg0, arg1)
{}

function gml_seek_self_fields_proc(arg0, arg1)
{}

function gml_seek_set_op_resolve_set_op_rfn(arg0, arg1)
{}

function gml_seek_set_op_proc(arg0, arg1)
{}

function gml_std_gml_internal_ArrayImpl_shift(arg0)
{}

function gml_std_gml_internal_ArrayImpl_splice(arg0, arg1, arg2)
{}

function gml_std_gml_internal_ArrayImpl_indexOf(arg0, arg1, arg2 = 0)
{}

function gml_std_gml_internal_ArrayImpl_concatFront(arg0, arg1)
{}

function gml_std_gml_internal_ArrayImpl_join(arg0, arg1)
{}

function gml_std_gml_internal_ArrayImpl_copy(arg0)
{}

function haxe__dynamic_access_dynamic_access_impl__copy(arg0)
{}

function gml_std_haxe_Exception_new(arg0, arg1, arg2)
{}

function gml_std_haxe_Exception(arg0, arg1, arg2) constructor
{}

function gml_std_haxe_Exception_caught(arg0)
{}

function gml_std_haxe_Exception_thrown(arg0)
{}

function gml_std_haxe_Exception_h_unwrap()
{}

function gml_std_haxe_Exception_h_toString()
{}

function haxe_ds_basic_map_new()
{}

function haxe_ds_basic_map() constructor
{}

function haxe_ds_string_map() constructor
{}

function live_set_live_impl(arg0, arg1, arg2, arg3, arg4)
{}

function live_set_live_simple(arg0, arg1, arg2, arg3, arg4)
{}

function sprite_set_live(arg0, arg1)
{}

function path_set_live(arg0, arg1)
{}

function animcurve_set_live(arg0, arg1, arg2 = 16)
{}

function file_set_live(arg0, arg1, arg2)
{}

function room_set_live(arg0, arg1)
{}

function room_goto_live(arg0)
{}

function live_get_update_tail()
{}

function live_default_update(arg0)
{}

function live_room_updated_impl(arg0)
{}

function live_proc_call_origin(arg0)
{}

function live_proc_call_impl(arg0, arg1, arg2)
{}

function live_call()
{}

function live_defcall()
{}

function live_call_ext(arg0)
{}

function live_defcall_ext(arg0, arg1)
{}

function live_auto_call_1()
{}

function live_auto_call_2(arg0)
{}

function live_async_http_0(arg0)
{}

function live_async_http_1(arg0)
{}

function live_async_http_check(arg0)
{}

function live_async_http(arg0 = async_load)
{}

function live_gmlive_patcher_add_source(arg0, arg1, arg2, arg3)
{}

function live_gmlive_patcher_index_rec(arg0, arg1, arg2, arg3)
{}

function live_gmlive_patcher_patch_live_patch_source_rec(arg0, arg1, arg2)
{}

function live_gmlive_patcher_compile_ex(arg0, arg1)
{}

function live_shader_updated_default()
{}

function shader_set_live(arg0, arg1)
{}

function live_validate_scripts()
{}

function live_cache_data_create()
{}

function tools__dictionary_dictionary_impl__clear(arg0)
{}

function live_method(arg0, arg1)
{}

function live_method_get_self(arg0)
{}

function gml_thread_method_script()
{}

function vm_v2_gml_thread_group_func_literal_ctr_impl()
{}

function vm_v2_gml_thread_group_func_literal_create_function(arg0, arg1, arg2)
{}

function vm_v2_gml_thread_group_func_literal_on_func_literal(arg0, arg1, arg2, arg3)
{}

function vm_v2_gml_thread_v2_handlers_init_set(arg0, arg1, arg2, arg3)
{}

function vm_v2_gml_thread_v2_handlers_init()
{}

function vm_v2_gml_thread_v2_ready()
{}

function vm_v2_gml_thread_v2_on_unknown(arg0, arg1, arg2, arg3)
{}

function live_temp_path_init()
{}

function live_script_get_index(arg0)
{}

function live_log_impl(arg0, arg1)
{}

function live_log(arg0, arg1)
{}

function live_update_script_impl(arg0, arg1, arg2)
{}

function live_constant_add(arg0, arg1)
{}

function live_constant_delete(arg0)
{}

function live_variable_add(arg0, arg1)
{}

function live_variable_delete(arg0)
{}

function live_function_add(arg0, arg1)
{}

function live_function_delete(arg0)
{}

function live_throw_error(arg0)
{}

function live_execute_string(arg0)
{}

function live_snippet_create(arg0, arg1 = "snippet")
{}

function live_snippet_destroy(arg0)
{}

function live_snippet_call(arg0)
{}

function live_update()
{}

function live_init(arg0, arg1, arg2)
{}

function live_preinit_project_fake_call()
{}

function live_preinit_project_lf(arg0, arg1)
{}

function live_preinit_project()
{}

function live_room_loader_run_cc(arg0, arg1)
{}

function live_room_loader_init_physics(arg0)
{}

function live_room_loader_anim_speed(arg0, arg1)
{}

function live_room_loader_run_yy_inst_cc(arg0, arg1)
{}

function live_room_loader_add_layer(arg0)
{}

function live_room_loader_run_impl2(arg0)
{}

function live_room_start()
{}

function live_bits_gmlive_indexer_add_assets()
{}

function live_bits_gmlive_indexer_add_scripts()
{}

function live_bits_gmlive_ready_run()
{}

function gml_link(arg0, arg1) constructor
{}

function gml_action_list_print_action_value(arg0)
{}

function gml_action_list_print_action_get_func_name(arg0)
{}

function gml_action_list_print_action(arg0)
{}

function gml_action_list_print(arg0)
{}

function gml_thread_scope_create(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
{}

function vm_gml_thread_exec_slice_longcall(arg0, arg1, arg2, arg3)
{}

function vm_gml_thread_exec_slice_init()
{}

function vm_gml_thread_exec_slice_with0(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with1(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with2(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with3(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with4(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with5(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with6(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with7(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with8(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with9(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with10(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with11(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with12(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with13(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with14(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with15(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with16(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with17(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with18(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with19(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with20(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with21(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with22(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with23(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with24(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with25(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with26(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with27(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with28(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with29(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with30(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with31(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with32(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with33(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with34(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with35(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with36(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with37(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with38(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with39(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with40(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with41(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with42(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with43(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with44(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with45(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with46(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with47(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with48(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with49(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with50(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with51(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with52(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with53(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with54(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with55(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with56(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with57(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with58(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with59(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with60(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with61(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with62(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with63(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with64(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with65(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with66(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with67(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with68(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with69(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with70(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with71(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with72(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with73(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with74(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with75(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with76(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with77(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with78(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with79(arg0, arg1, arg2)
{}

function vm_gml_thread_exec_slice_with80(arg0, arg1, arg2)
{}

function gml_type_check_init()
{}

function gml_type_check_any(arg0)
{}

function gml_type_check_number(arg0)
{}

function gml_type_check_int(arg0)
{}

function gml_type_check_index(arg0)
{}

function gml_type_check_string(arg0)
{}

function gml_type_check_array(arg0)
{}

function gml_type_check_z_number(arg0)
{}

function gml_type_check_z_string(arg0)
{}

function gml_type_check_z_array(arg0)
{}

function gml_value_list_copy(arg0)
{}

function gml_value_list_pad_to_size_with_null(arg0, arg1)
{}

function vm__gml_value_map_gml_value_map_impl__print(arg0)
{}

function gml_with_scope(arg0, arg1) constructor
{}

function gml_with_scope_copy(arg0)
{}

function gml_with_scope_destroy(arg0)
{}

function vm__gml_with_data_gml_with_data_impl__init()
{}

function vm__gml_with_data_gml_with_data_impl__alloc(arg0)
{}

function vm__gml_with_data_gml_with_data_impl__destroy(arg0)
{}

function gml_type_ref(arg0, arg1) constructor
{}

function gml_type_ref_init()
{}

function vm_impl_gml_thread_construct_error()
{}

function vm_impl_gml_thread_construct_init()
{}

function vm_impl_gml_thread_construct_with0(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with1(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with2(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with3(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with4(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with5(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with6(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with7(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with8(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with9(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with10(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with11(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with12(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with13(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with14(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with15(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with16(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with17(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with18(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with19(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with20(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with21(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with22(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with23(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with24(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with25(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with26(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with27(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with28(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with29(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with30(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with31(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with32(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with33(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with34(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with35(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with36(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with37(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with38(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with39(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with40(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with41(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with42(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with43(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with44(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with45(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with46(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with47(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with48(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with49(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with50(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with51(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with52(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with53(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with54(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with55(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with56(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with57(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with58(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with59(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with60(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with61(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with62(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with63(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with64(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with65(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with66(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with67(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with68(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with69(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with70(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with71(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with72(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with73(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with74(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with75(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with76(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with77(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with78(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with79(arg0, arg1, arg2)
{}

function vm_impl_gml_thread_construct_with80(arg0, arg1, arg2)
{}

function vm_group_alarm_on_alarm(arg0, arg1, arg2, arg3)
{}

function vm_group_alarm_on_alarm_set(arg0, arg1, arg2, arg3)
{}

function vm_group_alarm_on_alarm_aop(arg0, arg1, arg2, arg3)
{}

function vm_group_arg_on_arg_count(arg0, arg1, arg2, arg3)
{}

function vm_group_arg_on_arg_const(arg0, arg1, arg2, arg3)
{}

function vm_group_arg_on_arg_const_set(arg0, arg1, arg2, arg3)
{}

function vm_group_arg_on_arg_const_aop(arg0, arg1, arg2, arg3)
{}

function vm_group_arg_on_arg_index(arg0, arg1, arg2, arg3)
{}

function vm_group_arg_on_arg_index_set(arg0, arg1, arg2, arg3)
{}

function vm_group_arg_on_arg_index_aop(arg0, arg1, arg2, arg3)
{}

function vm_group_array_on_index(arg0, arg1, arg2, arg3)
{}

function vm_group_array_on_index_set(arg0, arg1, arg2, arg3)
{}

function vm_group_array_on_index_aop(arg0, arg1, arg2, arg3)
{}

function vm_group_array_on_index2d(arg0, arg1, arg2, arg3)
{}

function vm_group_array_on_index2d_set(arg0, arg1, arg2, arg3)
{}

function vm_group_array_on_index2d_aop(arg0, arg1, arg2, arg3)
{}

function vm_group_call_call_value(arg0, arg1, arg2, arg3, arg4, arg5)
{}

function vm_group_call_on_call_script(arg0, arg1, arg2, arg3)
{}

function vm_group_call_on_call_script_id(arg0, arg1, arg2, arg3)
{}

function vm_group_call_on_call_field(arg0, arg1, arg2, arg3)
{}

function vm_group_call_on_construct(arg0, arg1, arg2, arg3)
{}

function vm_group_call_on_call_script_with_array(arg0, arg1, arg2, arg3)
{}

function vm_group_call_on_call_func(arg0, arg1, arg2, arg3)
{}

function vm_v2_GmlStructBase() constructor
{}

function vm_v2_gml_thread_group_call_gml23_init()
{}

function vm_v2_gml_thread_group_call_gml23_call_unknown(arg0, arg1, arg2, arg3, arg4, arg5)
{}

function vm_v2_gml_thread_group_call_gml23_call_basic(arg0, arg1, arg2, arg3, arg4, arg5)
{}

function vm_v2_gml_thread_group_call_gml23_call_self_other_soft(arg0, arg1, arg2, arg3, arg4, arg5)
{}

function vm_v2_gml_thread_group_call_gml23_call_self(arg0, arg1, arg2, arg3, arg4, arg5)
{}

function vm_v2_gml_thread_group_call_gml23_call_construct(arg0, arg1, arg2, arg3, arg4, arg5)
{}

function vm_v2_gml_thread_group_call_gml23_call_raw(arg0, arg1, arg2, arg3, arg4, arg5)
{}

function vm_group_ensure_plus_on_ensure_array_for_local(arg0, arg1, arg2, arg3)
{}

function vm_group_ensure_plus_on_ensure_array_for_global(arg0, arg1, arg2, arg3)
{}

function vm_group_ensure_plus_on_ensure_array_for_field(arg0, arg1, arg2, arg3)
{}

function vm_group_ensure_plus_on_ensure_array_for_index(arg0, arg1, arg2, arg3)
{}

function vm_group_ensure_plus_on_ensure_array_for_index2d(arg0, arg1, arg2, arg3)
{}

function vm_group_env_on_env(arg0, arg1, arg2, arg3)
{}

function vm_group_env_on_env_set(arg0, arg1, arg2, arg3)
{}

function vm_group_env_on_env_aop(arg0, arg1, arg2, arg3)
{}

function vm_group_env_on_env1d(arg0, arg1, arg2, arg3)
{}

function vm_group_env_on_env1d_set(arg0, arg1, arg2, arg3)
{}

function vm_group_env_on_env1d_aop(arg0, arg1, arg2, arg3)
{}

function vm_group_fast_call_on_call_func0(arg0, arg1, arg2, arg3)
{}

function vm_group_fast_call_on_call_func0o(arg0, arg1, arg2, arg3)
{}

function vm_group_fast_call_on_call_func1(arg0, arg1, arg2, arg3)
{}

function vm_group_fast_call_on_call_func1o(arg0, arg1, arg2, arg3)
{}

function vm_group_fast_call_on_call_func2(arg0, arg1, arg2, arg3)
{}

function vm_group_fast_call_on_call_func2o(arg0, arg1, arg2, arg3)
{}

function vm_group_fast_call_on_call_func3(arg0, arg1, arg2, arg3)
{}

function vm_group_fast_call_on_call_func3o(arg0, arg1, arg2, arg3)
{}

function vm_group_fast_call_on_call_func4(arg0, arg1, arg2, arg3)
{}

function vm_group_fast_call_on_call_func4o(arg0, arg1, arg2, arg3)
{}

function vm_v2_gml_thread_group_fast_call_with_local_on_call_func_with_local0(arg0, arg1, arg2, arg3)
{}

function vm_v2_gml_thread_group_fast_call_with_local_on_call_func_with_local0o(arg0, arg1, arg2, arg3)
{}

function vm_v2_gml_thread_group_fast_call_with_local_on_call_func_with_local1(arg0, arg1, arg2, arg3)
{}

function vm_v2_gml_thread_group_fast_call_with_local_on_call_func_with_local1o(arg0, arg1, arg2, arg3)
{}

function vm_v2_gml_thread_group_fast_call_with_local_on_call_func_with_local2(arg0, arg1, arg2, arg3)
{}

function vm_v2_gml_thread_group_fast_call_with_local_on_call_func_with_local2o(arg0, arg1, arg2, arg3)
{}

function vm_v2_gml_thread_group_fast_call_with_local_on_call_func_with_local3(arg0, arg1, arg2, arg3)
{}

function vm_v2_gml_thread_group_fast_call_with_local_on_call_func_with_local3o(arg0, arg1, arg2, arg3)
{}

function vm_v2_gml_thread_group_fast_call_with_local_on_call_func_with_local4(arg0, arg1, arg2, arg3)
{}

function vm_v2_gml_thread_group_fast_call_with_local_on_call_func_with_local4o(arg0, arg1, arg2, arg3)
{}

function vm_group_field_dump_no_var(arg0, arg1, arg2, arg3)
{}

function vm_group_field_on_field(arg0, arg1, arg2, arg3)
{}

function vm_group_field_on_field_set(arg0, arg1, arg2, arg3)
{}

function vm_group_field_on_fast_field_aop(arg0, arg1, arg2, arg3)
{}

function vm_group_field_on_field_aop(arg0, arg1, arg2, arg3)
{}

function vm_group_field_on_self_field(arg0, arg1, arg2, arg3)
{}

function vm_group_field_on_self_field_set(arg0, arg1, arg2, arg3)
{}

function vm_group_field_on_self_field_aop(arg0, arg1, arg2, arg3)
{}

function vm_group_field_on_fast_self_field(arg0, arg1, arg2, arg3)
{}

function vm_group_field_on_fast_self_field_set(arg0, arg1, arg2, arg3)
{}

function vm_group_field_on_fast_self_field_aop(arg0, arg1, arg2, arg3)
{}

function vm_group_field_on_local_field(arg0, arg1, arg2, arg3)
{}

function vm_group_field_on_local_field_set(arg0, arg1, arg2, arg3)
{}

function vm_group_field_on_local_field_aop(arg0, arg1, arg2, arg3)
{}

function vm_group_field_on_fast_local_field(arg0, arg1, arg2, arg3)
{}

function vm_group_field_on_fast_local_field_set(arg0, arg1, arg2, arg3)
{}

function vm_group_field_on_fast_local_field_aop(arg0, arg1, arg2, arg3)
{}

function vm_group_field_on_in(arg0, arg1, arg2, arg3)
{}

function vm_group_field_on_in_const(arg0, arg1, arg2, arg3)
{}

function vm_group_global_on_global(arg0, arg1, arg2, arg3)
{}

function vm_group_global_on_global_set(arg0, arg1, arg2, arg3)
{}

function vm_group_global_on_global_aop(arg0, arg1, arg2, arg3)
{}

function vm_group_jump_on_jump(arg0, arg1, arg2, arg3)
{}

function vm_group_jump_on_jump_if(arg0, arg1, arg2, arg3)
{}

function vm_group_jump_on_jump_unless(arg0, arg1, arg2, arg3)
{}

function vm_group_jump_on_bool_and(arg0, arg1, arg2, arg3)
{}

function vm_group_jump_on_bool_or(arg0, arg1, arg2, arg3)
{}

function vm_group_jump_on_switch(arg0, arg1, arg2, arg3)
{}

function vm_group_jump_on_switch_case(arg0, arg1, arg2, arg3)
{}

function vm_group_jump_on_null_co(arg0, arg1, arg2, arg3)
{}

function vm_group_jump_on_repeat_pre(arg0, arg1, arg2, arg3)
{}

function vm_group_jump_on_repeat_jump(arg0, arg1, arg2, arg3)
{}

function vm_group_jump_on_break(arg0, arg1, arg2, arg3)
{}

function vm_group_jump_on_continue(arg0, arg1, arg2, arg3)
{}

function vm_group_jump_on_return(arg0, arg1, arg2, arg3)
{}

function vm_group_jump_on_return_const(arg0, arg1, arg2, arg3)
{}

function vm_group_literal_on_undefined(arg0, arg1, arg2, arg3)
{}

function vm_group_literal_on_number(arg0, arg1, arg2, arg3)
{}

function vm_group_literal_on_cstring(arg0, arg1, arg2, arg3)
{}

function vm_group_literal_on_const(arg0, arg1, arg2, arg3)
{}

function vm_group_literal_on_self(arg0, arg1, arg2, arg3)
{}

function vm_group_literal_on_other(arg0, arg1, arg2, arg3)
{}

function vm_group_literal_on_result(arg0, arg1, arg2, arg3)
{}

function vm_group_literal_on_array_decl(arg0, arg1, arg2, arg3)
{}

function vm_group_literal_on_object_decl(arg0, arg1, arg2, arg3)
{}

function vm_group_local_on_local(arg0, arg1, arg2, arg3)
{}

function vm_group_local_on_local_set(arg0, arg1, arg2, arg3)
{}

function vm_group_local_on_local_aop(arg0, arg1, arg2, arg3)
{}

function vm_group_op_impl_unknown(arg0, arg1)
{}

function vm_group_op_impl_add(arg0, arg1)
{}

function vm_group_op_impl_sub(arg0, arg1)
{}

function vm_group_op_impl_mul(arg0, arg1)
{}

function vm_group_op_impl_div1(arg0, arg1)
{}

function vm_group_op_impl_mod(arg0, arg1)
{}

function vm_group_op_impl_idiv(arg0, arg1)
{}

function vm_group_op_impl_and(arg0, arg1)
{}

function vm_group_op_impl_or(arg0, arg1)
{}

function vm_group_op_impl_xor(arg0, arg1)
{}

function vm_group_op_impl_shl(arg0, arg1)
{}

function vm_group_op_impl_shr(arg0, arg1)
{}

function vm_group_op_impl_eq(arg0, arg1)
{}

function vm_group_op_impl_ne(arg0, arg1)
{}

function vm_group_op_impl_gt(arg0, arg1)
{}

function vm_group_op_impl_ge(arg0, arg1)
{}

function vm_group_op_impl_lt(arg0, arg1)
{}

function vm_group_op_impl_le(arg0, arg1)
{}

function vm_group_op_impl()
{}

function vm_group_op_on_bin_op(arg0, arg1, arg2, arg3)
{}

function vm_group_op_on_un_op(arg0, arg1, arg2, arg3)
{}

function vm_group_op_on_equ_op(arg0, arg1, arg2, arg3)
{}

function vm_group_op_on_neq_op(arg0, arg1, arg2, arg3)
{}

function vm_group_op_on_add_int(arg0, arg1, arg2, arg3)
{}

function vm_group_op_on_concat(arg0, arg1, arg2, arg3)
{}

function vm_group_op_on_ds_aop(arg0, arg1, arg2, arg3)
{}

function vm_group_special_on_wait(arg0, arg1, arg2, arg3)
{}

function vm_group_special_on_fork(arg0, arg1, arg2, arg3)
{}

function vm_group_special_on_try(arg0, arg1, arg2, arg3)
{}

function vm_group_special_on_catch(arg0, arg1, arg2, arg3)
{}

function vm_group_special_on_finally(arg0, arg1, arg2, arg3)
{}

function vm_group_special_on_throw(arg0, arg1, arg2, arg3)
{}

function vm_group_stack_on_discard(arg0, arg1, arg2, arg3)
{}

function vm_group_stack_on_dup(arg0, arg1, arg2, arg3)
{}

function vm_group_stack_on_dup2x(arg0, arg1, arg2, arg3)
{}

function vm_group_stack_on_dup3x(arg0, arg1, arg2, arg3)
{}

function vm_group_stack_on_dup_in(arg0, arg1, arg2, arg3)
{}

function vm_group_with_on_with_pre(arg0, arg1, arg2, arg3)
{}

function vm_group_with_on_with_next(arg0, arg1, arg2, arg3)
{}

function vm_group_with_on_with_post(arg0, arg1, arg2, arg3)
{}

global.gml_func_name = ds_map_create();
global.gml_func_script_id = {};
global.gml_const_map = {};
global.gml_const_val = {};
global.gml_asset_index = {};
global.gml_enum_map = {};
global.compile_groups_gml_compile_group_static_has_statics = compile_groups_gml_compile_group_static_has_statics_init();
global.gml_func_map = {};
global.vm_value_gml_value_printer_print_refs = ds_map_create();
global.vm_value_gml_value_printer_print_num = 0;
global.gml_op_apply_fns = gml_op_apply_init();
global.gml_thread_default_callback = undefined;
global.gml_thread_verbose_stack_traces = false;
global.gml_thread_allow_exceptions = false;
global.gml_thread_current = undefined;
global.gml_stack_fill_value_arr = array_create(1024, 0);
global.gml_compile_curr_script = gml_compile_init();
global.gml_compile_curr_break = -1;
global.gml_compile_curr_continue = -1;
global.api_api_version_v1 = api_api_version_create(14);
global.api_api_version_v2 = api_api_version_create(22);
global.api_api_version_v23 = api_api_version_create(23);
global.gml_parser_template_func = "string";
global.gml_parser_default_version = global.api_api_version_v23;
global.gml_parser_curr_version = undefined;
global.gml_parser_token_acc = ds_list_create();
global.gml_parser_fast_buf = buffer_create(1024, buffer_fast, 1);
global.gml_parser_str_buf = buffer_create(1024, buffer_grow, 1);
global.gml_parser_buf_sub_buf = buffer_create(1024, buffer_grow, 1);
global.gml_parser_char_is_space = gml_parser_char_is_space_init();
global._gml_parser_gml_parser_string_buf_impl____buf = buffer_create(1024, buffer_grow, 1);
global.gml_std_StringBuf_buffer = buffer_create(128, buffer_grow, 1);
global.gml_fast_field_getters = {};
global.gml_fast_field_setters = {};
global.api_api_var_map = {};
global.ast_gml_macro_proc_list = ds_list_create();
global.ast_gml_macro_proc_map = {};
global.ast_gml_macro_proc_exclude_map = {};
global.ast_gml_macro_proc_next_exclude_list = ds_list_create();
global.ast_gml_macro_proc_next_exclude_map = {};
global.ast_gml_node_def_info_array = [new ast_gml_node_def_ctr("Undefined", [new ast_gml_node_def_param("pos", 2)]), new ast_gml_node_def_ctr("Boolean", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("value", 13)]), new ast_gml_node_def_ctr("Number", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("value", 13), new ast_gml_node_def_param("src", 13)]), new ast_gml_node_def_ctr("CString", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("value", 13)]), new ast_gml_node_def_ctr("OtherConst", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("value", 13)]), new ast_gml_node_def_ctr("EnumCtr", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("e", 6), new ast_gml_node_def_param("ctr", 7)]), new ast_gml_node_def_ctr("ArrayDecl", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("values", 1)]), new ast_gml_node_def_ctr("ObjectDecl", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("keys", 14), new ast_gml_node_def_param("values", 1)]), new ast_gml_node_def_ctr("EnsureArrayForLocal", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("name", 13)]), new ast_gml_node_def_ctr("EnsureArrayForGlobal", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("name", 13)]), new ast_gml_node_def_ctr("EnsureArrayForField", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("obj", 0), new ast_gml_node_def_param("fd", 13)]), new ast_gml_node_def_ctr("EnsureArrayForIndex", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("arr", 0), new ast_gml_node_def_param("ind", 0)]), new ast_gml_node_def_ctr("EnsureArrayForIndex2d", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("arr", 0), new ast_gml_node_def_param("ind1", 0), new ast_gml_node_def_param("ind2", 0)]), new ast_gml_node_def_ctr("Ident", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("id", 13)]), new ast_gml_node_def_ctr("Self", [new ast_gml_node_def_param("pos", 2)]), new ast_gml_node_def_ctr("Other", [new ast_gml_node_def_param("pos", 2)]), new ast_gml_node_def_ctr("GlobalRef", [new ast_gml_node_def_param("pos", 2)]), new ast_gml_node_def_ctr("Script", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("ref", 5)]), new ast_gml_node_def_ctr("NativeScript", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("name", 13), new ast_gml_node_def_param("id", 12)]), new ast_gml_node_def_ctr("Const", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("name", 13)]), new ast_gml_node_def_ctr("ArgConst", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("index", 13)]), new ast_gml_node_def_ctr("ArgIndex", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("index", 0)]), new ast_gml_node_def_ctr("ArgCount", [new ast_gml_node_def_param("pos", 2)]), new ast_gml_node_def_ctr("Call", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("expr", 0), new ast_gml_node_def_param("args", 1)]), new ast_gml_node_def_ctr("CallScript", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("name", 13), new ast_gml_node_def_param("args", 1)]), new ast_gml_node_def_ctr("CallScriptAt", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("inst", 0), new ast_gml_node_def_param("script", 13), new ast_gml_node_def_param("args", 1)]), new ast_gml_node_def_ctr("CallScriptId", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("index", 0), new ast_gml_node_def_param("args", 1)]), new ast_gml_node_def_ctr("CallScriptWithArray", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("index", 0), new ast_gml_node_def_param("array", 0)]), new ast_gml_node_def_ctr("CallField", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("obj", 0), new ast_gml_node_def_param("field", 13), new ast_gml_node_def_param("args", 1)]), new ast_gml_node_def_ctr("CallFunc", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("func", 11), new ast_gml_node_def_param("args", 1)]), new ast_gml_node_def_ctr("CallFuncAt", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("expr", 0), new ast_gml_node_def_param("fname", 13), new ast_gml_node_def_param("args", 1)]), new ast_gml_node_def_ctr("Construct", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("ctr", 0), new ast_gml_node_def_param("args", 1)]), new ast_gml_node_def_ctr("FuncLiteral", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("name", 13), new ast_gml_node_def_param("unbound", 13)]), new ast_gml_node_def_ctr("Prefix", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("expr", 0), new ast_gml_node_def_param("inc", 13)]), new ast_gml_node_def_ctr("Postfix", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("expr", 0), new ast_gml_node_def_param("inc", 13)]), new ast_gml_node_def_ctr("UnOp", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("expr", 0), new ast_gml_node_def_param("op", 8)]), new ast_gml_node_def_ctr("BinOp", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("op", 9), new ast_gml_node_def_param("a", 0), new ast_gml_node_def_param("b", 0)]), new ast_gml_node_def_ctr("SetOp", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("op", 9), new ast_gml_node_def_param("a", 0), new ast_gml_node_def_param("b", 0)]), new ast_gml_node_def_ctr("Delete", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("expr", 0)]), new ast_gml_node_def_ctr("NullCo", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("a", 0), new ast_gml_node_def_param("b", 0)]), new ast_gml_node_def_ctr("ToBool", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("FromBool", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("In", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("fd", 0), new ast_gml_node_def_param("obj", 0), new ast_gml_node_def_param("not", 13)]), new ast_gml_node_def_ctr("Local", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("name", 13)]), new ast_gml_node_def_ctr("LocalSet", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("name", 13), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("LocalAop", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("name", 13), new ast_gml_node_def_param("op", 9), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("Static", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("name", 13)]), new ast_gml_node_def_ctr("StaticSet", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("name", 13), new ast_gml_node_def_param("val", 0), new ast_gml_node_def_param("isInit", 13)]), new ast_gml_node_def_ctr("StaticAop", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("name", 13), new ast_gml_node_def_param("op", 9), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("Global", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("name", 13)]), new ast_gml_node_def_ctr("GlobalSet", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("name", 13), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("GlobalAop", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("name", 13), new ast_gml_node_def_param("op", 9), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("ScriptStatic", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("scr", 13), new ast_gml_node_def_param("name", 13)]), new ast_gml_node_def_ctr("ScriptStaticSet", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("scr", 13), new ast_gml_node_def_param("name", 13), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("ScriptStaticAop", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("scr", 13), new ast_gml_node_def_param("name", 13), new ast_gml_node_def_param("op", 9), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("Field", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("obj", 0), new ast_gml_node_def_param("field", 13)]), new ast_gml_node_def_ctr("FieldSet", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("obj", 0), new ast_gml_node_def_param("field", 13), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("FieldAop", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("obj", 0), new ast_gml_node_def_param("field", 13), new ast_gml_node_def_param("op", 9), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("Env", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("v", 10)]), new ast_gml_node_def_ctr("EnvSet", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("v", 10), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("EnvAop", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("v", 10), new ast_gml_node_def_param("op", 9), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("EnvFd", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("obj", 0), new ast_gml_node_def_param("v", 10)]), new ast_gml_node_def_ctr("EnvFdSet", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("obj", 0), new ast_gml_node_def_param("v", 10), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("EnvFdAop", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("obj", 0), new ast_gml_node_def_param("v", 10), new ast_gml_node_def_param("op", 9), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("Env1d", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("v", 10), new ast_gml_node_def_param("index", 0)]), new ast_gml_node_def_ctr("Env1dSet", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("v", 10), new ast_gml_node_def_param("index", 0), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("Env1dAop", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("v", 10), new ast_gml_node_def_param("index", 0), new ast_gml_node_def_param("op", 9), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("Alarm", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("obj", 0), new ast_gml_node_def_param("index", 0)]), new ast_gml_node_def_ctr("AlarmSet", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("obj", 0), new ast_gml_node_def_param("index", 0), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("AlarmAop", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("obj", 0), new ast_gml_node_def_param("index", 0), new ast_gml_node_def_param("op", 9), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("Index", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("arr", 0), new ast_gml_node_def_param("index", 0)]), new ast_gml_node_def_ctr("IndexSet", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("arr", 0), new ast_gml_node_def_param("index", 0), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("IndexAop", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("arr", 0), new ast_gml_node_def_param("index", 0), new ast_gml_node_def_param("op", 9), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("Index2d", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("arr", 0), new ast_gml_node_def_param("index1", 0), new ast_gml_node_def_param("index2", 0)]), new ast_gml_node_def_ctr("Index2dSet", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("arr", 0), new ast_gml_node_def_param("index1", 0), new ast_gml_node_def_param("index2", 0), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("Index2dAop", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("arr", 0), new ast_gml_node_def_param("index1", 0), new ast_gml_node_def_param("index2", 0), new ast_gml_node_def_param("op", 9), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("RawId", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("arr", 0), new ast_gml_node_def_param("index", 0)]), new ast_gml_node_def_ctr("RawIdSet", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("arr", 0), new ast_gml_node_def_param("index", 0), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("RawIdAop", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("arr", 0), new ast_gml_node_def_param("index", 0), new ast_gml_node_def_param("op", 9), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("RawId2d", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("arr", 0), new ast_gml_node_def_param("index1", 0), new ast_gml_node_def_param("index2", 0)]), new ast_gml_node_def_ctr("RawId2dSet", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("arr", 0), new ast_gml_node_def_param("index1", 0), new ast_gml_node_def_param("index2", 0), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("RawId2dAop", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("arr", 0), new ast_gml_node_def_param("index1", 0), new ast_gml_node_def_param("index2", 0), new ast_gml_node_def_param("op", 9), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("DsList", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("list", 0), new ast_gml_node_def_param("index", 0)]), new ast_gml_node_def_ctr("DsListSet", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("list", 0), new ast_gml_node_def_param("index", 0), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("DsListAop", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("list", 0), new ast_gml_node_def_param("index", 0), new ast_gml_node_def_param("op", 9), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("DsMap", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("map", 0), new ast_gml_node_def_param("key", 0)]), new ast_gml_node_def_ctr("DsMapSet", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("map", 0), new ast_gml_node_def_param("key", 0), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("DsMapAop", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("map", 0), new ast_gml_node_def_param("key", 0), new ast_gml_node_def_param("op", 9), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("DsGrid", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("grid", 0), new ast_gml_node_def_param("index1", 0), new ast_gml_node_def_param("index2", 0)]), new ast_gml_node_def_ctr("DsGridSet", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("grid", 0), new ast_gml_node_def_param("index1", 0), new ast_gml_node_def_param("index2", 0), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("DsGridAop", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("grid", 0), new ast_gml_node_def_param("index1", 0), new ast_gml_node_def_param("index2", 0), new ast_gml_node_def_param("op", 9), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("KeyId", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("obj", 0), new ast_gml_node_def_param("key", 0)]), new ast_gml_node_def_ctr("KeyIdSet", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("obj", 0), new ast_gml_node_def_param("key", 0), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("KeyIdAop", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("obj", 0), new ast_gml_node_def_param("key", 0), new ast_gml_node_def_param("op", 9), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("VarDecl", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("name", 13), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("Block", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("nodes", 1)]), new ast_gml_node_def_ctr("IfThen", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("cond", 0), new ast_gml_node_def_param("then", 0), new ast_gml_node_def_param("not", 0)]), new ast_gml_node_def_ctr("Ternary", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("cond", 0), new ast_gml_node_def_param("then", 0), new ast_gml_node_def_param("not", 0)]), new ast_gml_node_def_ctr("Switch", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("expr", 0), new ast_gml_node_def_param("cases", 4), new ast_gml_node_def_param("def", 0)]), new ast_gml_node_def_ctr("Wait", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("time", 0)]), new ast_gml_node_def_ctr("Fork", [new ast_gml_node_def_param("pos", 2)]), new ast_gml_node_def_ctr("While", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("cond", 0), new ast_gml_node_def_param("loop", 0)]), new ast_gml_node_def_ctr("DoUntil", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("loop", 0), new ast_gml_node_def_param("cond", 0)]), new ast_gml_node_def_ctr("DoWhile", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("loop", 0), new ast_gml_node_def_param("cond", 0)]), new ast_gml_node_def_ctr("Repeat", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("times", 0), new ast_gml_node_def_param("loop", 0)]), new ast_gml_node_def_ctr("For", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("pre", 0), new ast_gml_node_def_param("cond", 0), new ast_gml_node_def_param("post", 0), new ast_gml_node_def_param("loop", 0)]), new ast_gml_node_def_ctr("With", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("ctx", 0), new ast_gml_node_def_param("loop", 0)]), new ast_gml_node_def_ctr("Once", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("loop", 0)]), new ast_gml_node_def_ctr("Return", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("val", 0)]), new ast_gml_node_def_ctr("Exit", [new ast_gml_node_def_param("pos", 2)]), new ast_gml_node_def_ctr("Break", [new ast_gml_node_def_param("pos", 2)]), new ast_gml_node_def_ctr("Continue", [new ast_gml_node_def_param("pos", 2)]), new ast_gml_node_def_ctr("Debugger", [new ast_gml_node_def_param("pos", 2)]), new ast_gml_node_def_ctr("TryCatch", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("block", 0), new ast_gml_node_def_param("capvar", 13), new ast_gml_node_def_param("catcher", 0)]), new ast_gml_node_def_ctr("Throw", [new ast_gml_node_def_param("pos", 2), new ast_gml_node_def_param("err", 0)])];
global.gml_script_index_offset = 0;
global.gml_source_unknown = gml_source_init_unknown();
global.gml_source_builtin = gml_source_init_builtin();
global.data_gml_keyword_mapper_map = data_gml_keyword_mapper_init();
global.gml_seek_eval_eval_thread = undefined;
global.gml_seek_eval_eval_actions = ds_list_create();
global.gml_seek_eval_invalid_value = [];
global.gml_std_gml_internal_ArrayImpl_join_buf = undefined;
global.gml_std_haxe_boot_isJS = false;
global.live_live_sprites = ds_map_create();
global.live_live_sprites_start = ds_list_create();
global.live_live_sprites_stop = ds_list_create();
global.live_live_point_paths = ds_map_create();
global.live_live_point_paths_start = ds_list_create();
global.live_live_point_paths_stop = ds_list_create();
global.live_live_anim_curves = ds_map_create();
global.live_live_anim_curves_start = ds_list_create();
global.live_live_anim_curves_stop = ds_list_create();
global.live_live_included_files = ds_map_create();
global.live_live_included_files_start = ds_list_create();
global.live_live_included_files_stop = ds_list_create();
global.live_live_room = -1;
global.live_live_room_data = ds_map_create();
global.live_live_rooms = ds_map_create();
global.live_live_rooms_start = ds_list_create();
global.live_live_rooms_stop = ds_list_create();
global.live_blank_object = -1;
global.live_blank_room = -1;
global.live_sprite_updated = live_default_update;
global.live_path_updated = live_default_update;
global.live_animcurve_updated = live_default_update;
global.live_code_updated = live_default_update;
global.live_room_updated = live_room_updated_impl;
global.live_last_warn_at = 0;
global.live_async_http_1_found = {};
global.live_async_http_1_acc = ds_list_create();
global.live_shader_updated = live_shader_updated_default;
global.live_shader_live_shaders = ds_map_create();
global.live_shader_live_shaders_start = ds_list_create();
global.live_shader_live_shaders_stop = ds_list_create();
global.live_log_impl_levels = ["info", "WARN", "ERROR"];
global.live_is_ready = false;
global.live_request_url = undefined;
global.live_request_guid = undefined;
global.live_request_id = undefined;
global.live_config = undefined;
global.live_runtime_version = "";
global.live_build_date = 0;
global.live_request_time = -100000;
global.live_request_rate = 1;
global.live_request_password = "";
global.live_result = "";
global.live_allow_trailing_args = true;
global.live_init_timeout = 30;
global.live_init_attempts = 5;
global.live_live_map = {};
global.live_live_enums = {};
global.live_live_macros = {};
global.live_live_globals = undefined;
global.live_temp_path = live_temp_path_init();
global.live_log_script = live_log_impl;
global.live_update_script = live_update_script_impl;
global.live_name = undefined;
global.live_custom_self = undefined;
global.live_custom_other = undefined;
global.live_last_update_at = 0;
global.live_warned_about_init_timeout = false;
global.live_room_loader_object_cache = ds_map_create();
global.live_room_loader_sprite_cache = ds_map_create();
global.live_room_loader_use_physics = false;
global.live_room_loader_room_x = 0;
global.live_room_loader_room_y = 0;
global.live_room_loader_apply_backgrounds = true;
global.live_room_loader_apply_instances = true;
global.live_room_loader_apply_tiles = true;
global.live_room_loader_apply_views = true;
global.live_room_loader_apply_settings = true;
global.live_room_loader_apply_sprites = true;
global.live_room_loader_apply_filters = true;
global.live_room_loader_inst_map_gml = ds_map_create();
global.live_room_loader_inst_map_yy = ds_map_create();
global.gml_thread_current_kind = 0;
global.gml_type_check_map = gml_type_check_init();
global.vm__gml_with_data_gml_with_data_impl__pools = vm__gml_with_data_gml_with_data_impl__init();
global.gml_type_ref_root = gml_type_ref_init();
global.vm_v2_gml_thread_group_call_gml23_funcs = vm_v2_gml_thread_group_call_gml23_init();
live_validate_scripts();
gml_parser_set_version(23);
live_bits_gmlive_ready_run();
live_preinit_api();
live_preinit_project();

enum UnknownEnum
{
    Value_0,
    Value_1,
    Value_2,
    Value_3,
    Value_4,
    Value_5,
    Value_6,
    Value_7,
    Value_8,
    Value_9,
    Value_10,
    Value_11,
    Value_12,
    Value_13,
    Value_14,
    Value_15,
    Value_16,
    Value_17,
    Value_18,
    Value_19,
    Value_20,
    Value_21,
    Value_22,
    Value_23,
    Value_24,
    Value_25,
    Value_26,
    Value_27,
    Value_28,
    Value_29,
    Value_30,
    Value_31,
    Value_32,
    Value_33,
    Value_34,
    Value_35,
    Value_36,
    Value_37,
    Value_38,
    Value_39,
    Value_40,
    Value_41,
    Value_42,
    Value_43,
    Value_44,
    Value_45,
    Value_46,
    Value_47,
    Value_48,
    Value_49,
    Value_50,
    Value_51,
    Value_52,
    Value_53,
    Value_54,
    Value_55,
    Value_56,
    Value_57,
    Value_58,
    Value_59,
    Value_60,
    Value_61,
    Value_62,
    Value_63,
    Value_64,
    Value_65,
    Value_66,
    Value_67,
    Value_68,
    Value_69,
    Value_70,
    Value_71,
    Value_72,
    Value_73,
    Value_74,
    Value_75,
    Value_76,
    Value_77,
    Value_78,
    Value_79,
    Value_80,
    Value_81,
    Value_82,
    Value_83,
    Value_84,
    Value_85,
    Value_86,
    Value_87,
    Value_88,
    Value_89,
    Value_90,
    Value_91,
    Value_92,
    Value_93,
    Value_94,
    Value_95,
    Value_96,
    Value_97,
    Value_98,
    Value_99,
    Value_100,
    Value_101,
    Value_102,
    Value_103,
    Value_104,
    Value_105,
    Value_106,
    Value_107,
    Value_108,
    Value_109,
    Value_110,
    Value_111,
    Value_112,
    Value_113,
    Value_114
}

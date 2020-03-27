@echo off
rem
rem   BUILD_LIB [-dbg]
rem
rem   Build the STRING library.
rem
setlocal
call build_pasinit

call src_insall %srcdir% %libname%

call src_pas %srcdir% %libname%_alloc %1
call src_pas %srcdir% %libname%_append %1
call src_pas %srcdir% %libname%_append_num %1
call src_pas %srcdir% %libname%_cmline_set %1
call src_pas %srcdir% %libname%_cmline_token %1
call src_pas %srcdir% %libname%_date %1
call src_pas %srcdir% %libname%_pathname %1
call src_pas %srcdir% %libname%_progname %1
call src_pas %srcdir% %libname%_prompt %1
call src_pas %srcdir% %libname%_readin %1
call src_pas %srcdir% %libname%_treename_sys %1
call src_pas %srcdir% %libname%_comblock_sys %1
call src_pas %srcdir% %libname%_base64 %1
call src_pas %srcdir% %libname%_bool %1
call src_pas %srcdir% %libname%_c %1
call src_pas %srcdir% %libname%_case %1
call src_pas %srcdir% %libname%_cmline_end_abort %1
call src_pas %srcdir% %libname%_cmline_init %1
call src_pas %srcdir% %libname%_cmline_opt_bad %1
call src_pas %srcdir% %libname%_cmline_parm_check %1
call src_pas %srcdir% %libname%_cmline_req_check %1
call src_pas %srcdir% %libname%_cmline_reuse %1
call src_pas %srcdir% %libname%_cmline_token_fp %1
call src_pas %srcdir% %libname%_cmline_token_int %1
call src_pas %srcdir% %libname%_compare %1
call src_pas %srcdir% %libname%_copy %1
call src_pas %srcdir% %libname%_debug %1
call src_pas %srcdir% %libname%_eos %1
call src_pas %srcdir% %libname%_equal %1
call src_pas %srcdir% %libname%_f_bits16 %1
call src_pas %srcdir% %libname%_f_bits32 %1
call src_pas %srcdir% %libname%_f_bitsc %1
call src_pas %srcdir% %libname%_f_fp %1
call src_pas %srcdir% %libname%_f_fp_eng %1
call src_pas %srcdir% %libname%_f_int %1
call src_pas %srcdir% %libname%_f_int_max %1
call src_pas %srcdir% %libname%_f_int_max_base %1
call src_pas %srcdir% %libname%_f_int8h %1
call src_pas %srcdir% %libname%_f_int16 %1
call src_pas %srcdir% %libname%_f_int16h %1
call src_pas %srcdir% %libname%_f_int24h %1
call src_pas %srcdir% %libname%_f_int32 %1
call src_pas %srcdir% %libname%_f_int32h %1
call src_pas %srcdir% %libname%_f_intco %1
call src_pas %srcdir% %libname%_f_intrj %1
call src_pas %srcdir% %libname%_f_macadr %1
call src_pas %srcdir% %libname%_fifo %1
call src_pas %srcdir% %libname%_fill %1
call src_pas %srcdir% %libname%_find %1
call src_pas %srcdir% %libname%_find_real_format %1
call src_pas %srcdir% %libname%_fnam_extend %1
call src_pas %srcdir% %libname%_fnam_unextend %1
call src_pas %srcdir% %libname%_generic_tnam %1
call src_pas %srcdir% %libname%_fnam_within %1
call src_pas %srcdir% %libname%_hash_subs %1
call src_pas %srcdir% %libname%_inet %1
call src_pas %srcdir% %libname%_len %1
call src_pas %srcdir% %libname%_list %1
call src_pas %srcdir% %libname%_lj %1
call src_pas %srcdir% %libname%_message %1
call src_pas %srcdir% %libname%_match %1
call src_pas %srcdir% %libname%_pad %1
call src_pas %srcdir% %libname%_parity_off %1
call src_pas %srcdir% %libname%_prepend %1
call src_pas %srcdir% %libname%_screen %1
call src_pas %srcdir% %libname%_seq %1
call src_pas %srcdir% %libname%_size %1
call src_pas %srcdir% %libname%_slen %1
call src_pas %srcdir% %libname%_substr %1
call src_pas %srcdir% %libname%_t_bitsc %1
call src_pas %srcdir% %libname%_t_fp %1
call src_pas %srcdir% %libname%_t_int %1
call src_pas %srcdir% %libname%_t_int_max %1
call src_pas %srcdir% %libname%_t_int_max_base %1
call src_pas %srcdir% %libname%_t_int16o %1
call src_pas %srcdir% %libname%_t_int32h %1
call src_pas %srcdir% %libname%_time %1
call src_pas %srcdir% %libname%_tkpick %1
call src_pas %srcdir% %libname%_tkpick_s %1
call src_pas %srcdir% %libname%_tkpick80 %1
call src_pas %srcdir% %libname%_tkpick80m %1
call src_pas %srcdir% %libname%_tkpickm %1
call src_pas %srcdir% %libname%_token %1
call src_pas %srcdir% %libname%_token_fp %1
call src_pas %srcdir% %libname%_token_int %1
call src_pas %srcdir% %libname%_treename %1
call src_pas %srcdir% %libname%_unpad %1
call src_pas %srcdir% %libname%_v %1
call src_pas %srcdir% %libname%_v%libname% %1
call src_pas %srcdir% %libname%_window %1
call src_pas %srcdir% %libname%_wipe %1
call src_pas %srcdir% %libname%_write %1
call src_pas %srcdir% %libname%_write_blank %1
call src_pas %srcdir% %libname%_comblock %1

call src_lib %srcdir% %libname%
call src_msg %srcdir% %libname%

copya string4.ins.pas (cog)lib/string4.ins.pas
copya string16.ins.pas (cog)lib/string16.ins.pas
copya string32.ins.pas (cog)lib/string32.ins.pas
copya string80.ins.pas (cog)lib/string80.ins.pas
copya string132.ins.pas (cog)lib/string132.ins.pas
copya string256.ins.pas (cog)lib/string256.ins.pas
copya string8192.ins.pas (cog)lib/string8192.ins.pas
copya string_leafname.ins.pas (cog)lib/string_leafname.ins.pas
copya string_treename.ins.pas (cog)lib/string_treename.ins.pas

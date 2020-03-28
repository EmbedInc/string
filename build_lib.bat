@echo off
rem
rem   BUILD_LIB [-dbg]
rem
rem   Build the STRING library.
rem
setlocal
call build_pasinit

call src_insall %srcdir% %libname%

call src_pas %srcdir% %libname%_alloc
call src_pas %srcdir% %libname%_append
call src_pas %srcdir% %libname%_append_num
call src_pas %srcdir% %libname%_cmline_set
call src_pas %srcdir% %libname%_cmline_token
call src_pas %srcdir% %libname%_date
call src_pas %srcdir% %libname%_pathname
call src_pas %srcdir% %libname%_progname
call src_pas %srcdir% %libname%_prompt
call src_pas %srcdir% %libname%_readin
call src_pas %srcdir% %libname%_treename_sys
call src_pas %srcdir% %libname%_comblock_sys
call src_pas %srcdir% %libname%_base64
call src_pas %srcdir% %libname%_bool
call src_pas %srcdir% %libname%_c
call src_pas %srcdir% %libname%_case
call src_pas %srcdir% %libname%_cmline_end_abort
call src_pas %srcdir% %libname%_cmline_init
call src_pas %srcdir% %libname%_cmline_opt_bad
call src_pas %srcdir% %libname%_cmline_parm_check
call src_pas %srcdir% %libname%_cmline_req_check
call src_pas %srcdir% %libname%_cmline_reuse
call src_pas %srcdir% %libname%_cmline_token_fp
call src_pas %srcdir% %libname%_cmline_token_int
call src_pas %srcdir% %libname%_compare
call src_pas %srcdir% %libname%_copy
call src_pas %srcdir% %libname%_debug
call src_pas %srcdir% %libname%_eos
call src_pas %srcdir% %libname%_equal
call src_pas %srcdir% %libname%_f_bits16
call src_pas %srcdir% %libname%_f_bits32
call src_pas %srcdir% %libname%_f_bitsc
call src_pas %srcdir% %libname%_f_fp
call src_pas %srcdir% %libname%_f_fp_eng
call src_pas %srcdir% %libname%_f_int
call src_pas %srcdir% %libname%_f_int_max
call src_pas %srcdir% %libname%_f_int_max_base
call src_pas %srcdir% %libname%_f_int8h
call src_pas %srcdir% %libname%_f_int16
call src_pas %srcdir% %libname%_f_int16h
call src_pas %srcdir% %libname%_f_int24h
call src_pas %srcdir% %libname%_f_int32
call src_pas %srcdir% %libname%_f_int32h
call src_pas %srcdir% %libname%_f_intco
call src_pas %srcdir% %libname%_f_intrj
call src_pas %srcdir% %libname%_f_macadr
call src_pas %srcdir% %libname%_fifo
call src_pas %srcdir% %libname%_fill
call src_pas %srcdir% %libname%_find
call src_pas %srcdir% %libname%_find_real_format
call src_pas %srcdir% %libname%_fnam_extend
call src_pas %srcdir% %libname%_fnam_unextend
call src_pas %srcdir% %libname%_generic_tnam
call src_pas %srcdir% %libname%_fnam_within
call src_pas %srcdir% %libname%_hash_subs
call src_pas %srcdir% %libname%_inet
call src_pas %srcdir% %libname%_len
call src_pas %srcdir% %libname%_list
call src_pas %srcdir% %libname%_lj
call src_pas %srcdir% %libname%_message
call src_pas %srcdir% %libname%_match
call src_pas %srcdir% %libname%_pad
call src_pas %srcdir% %libname%_parity_off
call src_pas %srcdir% %libname%_prepend
call src_pas %srcdir% %libname%_screen
call src_pas %srcdir% %libname%_seq
call src_pas %srcdir% %libname%_size
call src_pas %srcdir% %libname%_slen
call src_pas %srcdir% %libname%_substr
call src_pas %srcdir% %libname%_t_bitsc
call src_pas %srcdir% %libname%_t_fp
call src_pas %srcdir% %libname%_t_int
call src_pas %srcdir% %libname%_t_int_max
call src_pas %srcdir% %libname%_t_int_max_base
call src_pas %srcdir% %libname%_t_int16o
call src_pas %srcdir% %libname%_t_int32h
call src_pas %srcdir% %libname%_time
call src_pas %srcdir% %libname%_tkpick
call src_pas %srcdir% %libname%_tkpick_s
call src_pas %srcdir% %libname%_tkpick80
call src_pas %srcdir% %libname%_tkpick80m
call src_pas %srcdir% %libname%_tkpickm
call src_pas %srcdir% %libname%_token
call src_pas %srcdir% %libname%_token_fp
call src_pas %srcdir% %libname%_token_int
call src_pas %srcdir% %libname%_treename
call src_pas %srcdir% %libname%_unpad
call src_pas %srcdir% %libname%_v
call src_pas %srcdir% %libname%_v%libname%
call src_pas %srcdir% %libname%_window
call src_pas %srcdir% %libname%_wipe
call src_pas %srcdir% %libname%_write
call src_pas %srcdir% %libname%_write_blank
call src_pas %srcdir% %libname%_comblock

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

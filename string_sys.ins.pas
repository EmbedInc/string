{   Private include file for system-dependent routines in STRING library.
*
*   This version is for any system where the command line arguments can
*   be accessed by the standard ARGN and ARGP arguments to the C function MAIN.
}
%include 'sys_sys2.ins.pas';

type
  cmline_argp_t =                      {array of pointers to command line arguments}
    array[0..0] of ^string;            {each entry points to null-terminated string}

  cmline_argp_p_t =                    {points to list of argument pointers}
    ^cmline_argp_t;

var (string_sys)
  cmline_n_args: sys_int_machine_t;    {number of command line arguments}
  cmline_argp_p: cmline_argp_p_t;      {points to cmline args pointers array}

{   Private insert file for all the string library pascal source modules.
}
%include '/cognivision_links/dsee_libs/sys/sys.ins.pas';
%include '/cognivision_links/dsee_libs/util/util.ins.pas';
%include '/cognivision_links/dsee_libs/string/string.ins.pas';

var (string2)
  cmline_next_n: sys_int_machine_t;    {number of next command line token}
  cmline_token_last: string_treename_t; {last token parsed from command line}
  prog_name: string_leafname_t;        {name of program running this process}
  nodename: string_var32_t;            {cached name of this machine}
  cmline_reuse: boolean;               {re-use token in CMLINE_TOKEN_LAST if TRUE}
  cmline_last_eos: boolean;            {last command line token returned EOS}

var (string3)
  progname_set: boolean := false;      {TRUE when PROG_NAME all set}
  nodename_set: boolean := false;      {TRUE when NODENAME all set}

procedure string_set_nodename;         {set NODENAME and NODENAME_SET in com block}
  extern;

procedure string_treename_local (      {translate pathname on local machine only}
  in      inam: univ string_var_arg_t; {input path name}
  in      opts: string_tnamopt_t;      {set of option flags}
  in out  tnam: univ string_var_arg_t; {output tree name}
  out     tstat: string_tnstat_k_t);   {translation result status}
  val_param; extern;

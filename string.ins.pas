{   Pascal include file to define the public data structures and entry points
*   for the string library.
}
const
  string_subsys_k = -2;                {subsystem ID for STRING library}
  string_len_nullterm_k = -1;          {no explicit str len, string is null-term}
  string_hash_max_name_len_k = 80;     {max characters allowed in hash table names}

  string_hash_max_namei_len_k =        {max machine integers needed for hash name}
    (string_hash_max_name_len_k + sizeof(sys_int_machine_t) - 1)
    div sizeof(sys_int_machine_t);
{
*   Mnemonics for status values unique to the STRING subsystem.
}
  string_stat_eos_k = 1;               {end of string, no more tokens found}
  string_stat_bad_int_k = 2;           {string was not a legal integer}
  string_stat_bad_real_k = 3;          {string was not a legal real number}
  string_stat_ffp_no_fmt_k = 4;        {no string->FP format satifies all constraints}
  string_stat_ovfl_i_k = 5;            {string to integer conversion overflow}
  string_stat_null_tk_k = 6;           {token is NULL string}
  string_stat_sign_k = 7;              {unexpected sign in number string}
  string_stat_bad_yesno_k = 8;         {bad yes/no specifier string}
  string_stat_bad_onoff_k = 9;         {bad on/off specifier string}
  string_stat_no_endquote_k = 10;      {unterminated quoted token}
  string_stat_bad_quote_k = 11;        {illegal quoted string syntax}
  string_stat_tfp_bad_k = 12;          {bad STRING_TFP_xxx_K values specified}
  string_stat_fw_too_sml_k = 13;       {field width too small in str->num routine}
  string_stat_bad_fmt_k = 14;          {bad format on converting from string}
  string_stat_extra_tk_k = 15;         {extra token encountered}
  string_stat_bad_inetadr_k = 16;      {bad dot notation internet address}
  string_stat_after_quote_k = 17;      {illegal token character after quoted string}
  string_stat_fnam_remote_k = 18;      {pathname isn't to object on this system}
  string_stat_bad_truefalse_k = 19;    {bad true/false specifier string}
  string_stat_parm_cmd_bad_k = 20;     {invalid parameter to specific command}
  string_stat_err_on_line_k = 21;      {error on specific line of specific file}
  string_stat_date_bad_k = 22;         {bad date/time string}
  string_stat_nothex_k = 23;           {not hexadecimal character}
  string_stat_nhexb_k = 24;            {not whole bytes of hexadecimal characters}
  string_stat_hexlong_k = 25;          {hexadecimal string is too long}

type
  string_fi_k_t = (                    {flags for converting integer to string}
    string_fi_leadz_k,                 {create leading zeros}
    string_fi_plus_k,                  {create plus sign if signed and > 0}
    string_fi_unsig_k);                {input number should be treated as unsigned}
  string_fi_t =                        {all the FI flags in one set}
    set of string_fi_k_t;

  string_ti_k_t = (                    {flags for converting string to integer}
    string_ti_unsig_k,                 {output number is unsigned}
    string_ti_null_z_k,                {null string has value zero}
    string_ti_null_def_k);             {null string is default, value not altered}
  string_ti_t =                        {all the TI flags in one set}
    set of string_ti_k_t;

  string_ffp_k_t = (                   {flags for converting float to string}
    string_ffp_exp_no_k,               {exponential notation is not allowed}
    string_ffp_exp_k,                  {exponential notation is required}
    string_ffp_exp_eng_k,              {make exp multiple of 3, if used at all}
    string_ffp_point_k,                {force point, even if no digits to right}
    string_ffp_nz_bef_k,               {don't write 0 before point as only char}
    string_ffp_z_aft_k,                {write 0 after point if not digits otherwise}
    string_ffp_leadz_k,                {write leading zeros to fill full field}
    string_ffp_plus_man_k,             {write "+" in front of mantissa if > 0}
    string_ffp_plus_exp_k,             {write "+" in front of exponent if > 0}
    string_ffp_group_k);               {separate digits in groups according to lang}
  string_ffp_t =                       {all the FFP flags in one set}
    set of string_ffp_k_t;

  string_tfp_k_t = (                   {flags for converting string to float}
    string_tfp_null_z_k,               {null string has value zero}
    string_tfp_null_def_k,             {null string is default, value not altered}
    string_tfp_group_k);               {allow digits in groups, according to lang}
  string_tfp_t =                       {all the TFP flags in one set}
    set of string_tfp_k_t;

  string_tnamopt_k_t = (               {treename finding control options}
    string_tnamopt_flink_k,            {follow symbolic links}
    string_tnamopt_remote_k,           {continue on remote system if needed}
    string_tnamopt_proc_k,             {translate from point of view of this process}
    string_tnamopt_native_k);          {use native naming instead of Cognivision}
  string_tnamopt_t = set of string_tnamopt_k_t;

  string_tnstat_k_t = (                {status of treename translation result}
    string_tnstat_native_k,            {done as requested, name in native OS format}
    string_tnstat_cog_k,               {done as requested, name in Cognivison format}
    string_tnstat_remote_k,            {resolved to pathname on another machine}
    string_tnstat_proc_k);             {further translation requrired by owning proc}

  string_tkopt_k_t = (                 {options for parsing tokens from string}
    string_tkopt_quoteq_k,             {token may be string within quotes ("...")}
    string_tkopt_quotea_k,             {token may be string in apostrophies ('...')}
    string_tkopt_padsp_k);             {strip leading/trailing blank padding}
  string_tkopt_t = set of string_tkopt_k_t;

  string_comp_k_t = (                  {flags for comparing strings}
    string_comp_ncase_k,               {ignore character case}
    string_comp_lcase_k,               {lower case letter right before upper same}
    string_comp_num_k);                {compare numeric fields numerically}
  string_comp_t = set of string_comp_k_t;

  string_tftype_k_t = (                {types of TRUE/FALSE responses}
    string_tftype_tf_k,                {TRUE / FALSE}
    string_tftype_yesno_k,             {YES / NO}
    string_tftype_onoff_k);            {ON / OFF}
  string_tftype_t = set of string_tftype_k_t;

  string_seq_k_t = (                   {options for getting sequence number}
    string_seq_after_k);               {get the number after increment, default is before}
  string_seq_t = set of string_seq_k_t;

  string_seqcond_k_t = (               {conditionals for updating sequence number file}
    string_seqcond_gt_k,               {new number must be greater than current}
    string_seqcond_lt_k);              {new number must be less than current}
  string_seqcond_t = set of string_seqcond_k_t;
{
*   Note: The data types STRING_VAR32_T, STRING_VAR80_T, and STRING_VAR_ARG_T
*   are declared in SYS.INS.PAS.
}
  string_var4_t = record               {4 char max variable string}
    max: string_index_t;
    len: string_index_t;
    str: array[1..4] of char;
    end;
  string_var4_p_t = ^string_var4_t;

  string_var16_t = record              {16 char max variable string}
    max: string_index_t;
    len: string_index_t;
    str: array[1..16] of char;
    end;
  string_var16_p_t = ^string_var16_t;

  string_var132_t = record             {132 char max variable string}
    max: string_index_t;
    len: string_index_t;
    str: array[1..132] of char;
    end;
  string_var132_p_t = ^string_var132_t;

  string_var256_t = record             {256 char max variable string}
    max: string_index_t;
    len: string_index_t;
    str: array[1..256] of char;
    end;
  string_var256_p_t = ^string_var256_t;

  string_var512_t = record             {512 char max variable string}
    max: string_index_t;
    len: string_index_t;
    str: array[1..512] of char;
    end;
  string_var512_p_t = ^string_var512_t;

  string_var1024_t = record            {1024 char max variable string}
    max: string_index_t;
    len: string_index_t;
    str: array[1..1024] of char;
    end;
  string_var1024_p_t = ^string_var1024_t;

  string_var2048_t = record            {2048 char max variable string}
    max: string_index_t;
    len: string_index_t;
    str: array[1..2048] of char;
    end;
  string_var2048_p_t = ^string_var2048_t;

  string_var4096_t = record            {4096 char max variable string}
    max: string_index_t;
    len: string_index_t;
    str: array[1..4096] of char;
    end;
  string_var4096_p_t = ^string_var4096_t;

  string_var8192_t = record            {8192 char max variable string}
    max: string_index_t;
    len: string_index_t;
    str: array[1..8192] of char;
    end;
  string_var8192_p_t = ^string_var8192_t;

  string_var16384_t = record           {16384 char max variable string}
    max: string_index_t;
    len: string_index_t;
    str: array[1..16384] of char;
    end;
  string_var16384_p_t = ^string_var16384_t;

  string_var32767_t = record           {32767 char max variable string}
    max: string_index_t;
    len: string_index_t;
    str: array[1..32767] of char;
    end;
  string_var32767_p_t = ^string_var32767_t;

  string_var_max_t = string_var32767_t;
  string_var_max_p_t = ^string_var_max_t;

  string_cogname_t = record            {pathname in Cognivision standard format}
    max: string_index_t;
    len: string_index_t;
    str: array[1..1024] of char;
    end;
  string_cogname_p_t = ^string_cogname_t;

  string_bytebuf_t = array[0..65535] of int8u_t; {arbitrary length byte buffer}

  string_chain_ent_p_t = ^string_chain_ent_t;
  string_chain_ent_t = record          {one entry in linked list of var strings}
    next_p: string_chain_ent_p_t;      {pointer to next entry in chain}
    prev_p: string_chain_ent_p_t;      {pointer to previous entry in chain}
    s: string_var132_t;                {text string at this chain entry}
    end;

  string_list_p_t = ^string_list_t;
  string_list_t = record               {control block for linked list of strings}
    {
    *   User writeable fields.  These fields are set to default values when
    *   the strings list is created.
    }
    size: sys_int_adr_t;               {chars in next string allocated, def = 132}
    deallocable: boolean;              {deleted string will be deallocated, may
                                        not be changed after first string created}
    {
    *   User readable fields.  It is OK for application programs to READ these
    *   fields.
    }
    n: sys_int_machine_t;              {number of strings in list}
    curr: sys_int_machine_t;           {number of current line, first = 1}
    str_p: string_var_p_t;             {pointer to string of current line}
    {
    *   Private fields.  Application programs should not access these
    *   fields in any way.
    }
    first_p: string_chain_ent_p_t;     {pointer to first chain entry}
    last_p: string_chain_ent_p_t;      {pointer to last chain entry}
    ent_p: string_chain_ent_p_t;       {pointer to chain entry indicated by CURR}
    mem_p: util_mem_context_p_t;       {pointer to memory context used for strings}
    end;
{
*   Data structures for hash tables.  The application program should NEVER
*   read from or write to any of these structures directly.  Interactions with
*   these data structures should always be thru the STRING_HASH_xxx calls.
}
  string_hashcre_k_t = (               {flag values for STRING_HASH_CREATE}
    string_hashcre_memdir_k,           {indicates to use parent mem context directly}
    string_hashcre_nodel_k);           {won't need to inidividually dealloc mem}

  string_hashcre_t =                   {all the STRING_HASH_CREATE flags in one word}
    set of string_hashcre_k_t;

  string_hash_entry_p_t = ^string_hash_entry_t;
  string_hash_entry_t = record         {template for one hash table entry}
    prev_p: string_hash_entry_p_t;     {pointer to previous entry this bucket}
    next_p: string_hash_entry_p_t;     {pointer to next entry this bucket}
    namei_len: sys_int_machine_t;      {number of machine ints in name string}
    case integer of
      1: (                             {name as regular var string}
        name: string_var80_t);         {size arbitrary, good size for debugger}
      2: (                             {used to access name chars as int array}
        unused1: string_index_t;
        unused2: string_index_t;
        namei:                         {name characters as machine integer array}
          array[1..1] of sys_int_machine_t);
    end;

  string_hash_bucket_t = record        {template for one hash table bucket}
    first_p: string_hash_entry_p_t;    {points to first entry in this bucket}
    mid_p: string_hash_entry_p_t;      {points to middle of chain for this bucket}
    last_p: string_hash_entry_p_t;     {points to last entry in this bucket}
    n: sys_int_machine_t;              {current number of entries this bucket}
    n_after: sys_int_machine_t;        {number of entries at or after chain midpoint}
    end;

  string_hash_p_t = ^string_hash_t;
  string_hash_t = record               {root data structure for a hash table}
    n_buckets: sys_int_machine_t;      {number of bucket divisions, power of 2}
    mask: sys_int_machine_t;           {bucket selection mask, = N_BUCKETS - 1}
    max_name_len: sys_int_machine_t;   {max bytes allowed in entry name}
    entry_size: sys_int_adr_t;         {memory needed for one entry}
    data_offset: sys_int_adr_t;        {addresses into entry for user data}
    free_p: string_hash_entry_p_t;     {pointer to first hash entry on free chain}
    mem_p: util_mem_context_p_t;       {points to mem context for this hash table}
    flags: string_hashcre_t;           {FLAGS from STRING_HASH_CREATE argument}
    func:                              {hash function used to translate characters}
      array[0..255] of sys_int_machine_t; {random value used in hash function}
    bucket:                            {one entry for each bucket}
      array[0..0] of string_hash_bucket_t;
    end;


  string_hash_pos_t = record           {desciptor for a position in a hash table}
    hash_p: string_hash_p_t;           {points to master block for this hash table}
    bucket: sys_int_machine_t;         {bucket number within hash table}
    prev_p: string_hash_entry_p_t;     {pointer to previous entry, if exists}
    next_p: string_hash_entry_p_t;     {pointer to next entry, if exists}
    entry_p: string_hash_entry_p_t;    {points to curr entry, NIL if entry not exist}
    name_len: string_index_t;          {length of name in characters}
    namei_len: sys_int_machine_t;      {name size in machine ints}
    namei:                             {name characters as machine integers}
      array[1..string_hash_max_namei_len_k] of sys_int_machine_t;
    after: boolean;                    {TRUE if pos is at or after bucket midpoint}
    end;

  string_hash_handle_t =               {user handle to a hash table}
    string_hash_p_t;

  string_fifo_p_t = ^string_fifo_t;
  string_fifo_t = record               {first in first out (FIFO) queue of bytes}
    mem_p: util_mem_context_p_t;       {points to mem this structure allocated under}
    size: sys_int_adr_t;               {max number of bytes the FIFO can hold}
    lock: sys_sys_threadlock_t;        {multi-thread lock for accessing FIFO structures}
    ev_avail: sys_sys_event_id_t;      {signalled when byte available in the FIFO}
    ev_nfull: sys_sys_event_id_t;      {signalled when room to write byte into the FIFO}
    nbytes: sys_int_adr_t;             {number of bytes currently in the FIFO}
    putind: sys_int_adr_t;             {buffer index where to write next byte}
    getind: sys_int_adr_t;             {buffer index where to read next byte}
    buf: string_bytebuf_t;             {data buffer, allocated to SIZE exactly}
    end;

  string_fwlist_p_t = ^string_fwlist_t;
  string_fwlist_t = record             {one forward-only string list entry}
    next_p: string_fwlist_p_t;         {points to next list entry}
    str_p: string_var_p_t;             {points to string for this list entry}
    end;
{
*   Entry point definitions.
}
procedure string_alloc (               {allocate a string given its size in chars}
  in      len: string_index_t;         {number of characters needed in the string}
  in out  mem: util_mem_context_t;     {memory context to allocate string under}
  in      ind: boolean;                {TRUE if need to individually dealloc string}
  out     str_p: univ_ptr);            {pointer to var string.  MAX, LEN filled in}
  val_param; extern;

procedure string_append (              {append one string onto another}
  in out  s1: univ string_var_arg_t;   {string to append to}
  in      s2: univ string_var_arg_t);  {string that is appended to S1}
  extern;

procedure string_append_bin (          {append binary integer to string}
  in out  str: univ string_var_arg_t;  {string to append to}
  in      ii: sys_int_machine_t;       {integer value to append in low NB bits}
  in      nb: sys_int_machine_t);      {number of bits, higher bits in II ignored}
  val_param; extern;

procedure string_append_eng (          {append number in engineering notation}
  in out  str: univ string_var_arg_t;  {string to append to}
  in      fp: sys_fp_max_t;            {input floating point number}
  in      min_sig: sys_int_machine_t); {min required significant digits}
  val_param; extern;

procedure string_append_fp_fixed (     {append fixed-format floating point to string}
  in out  str: univ string_var_arg_t;  {string to append to}
  in      fp: sys_fp_max_t;            {input floating point number}
  in      fw: sys_int_machine_t;       {total field width, 0 for min left of point}
  in      dig_right: sys_int_machine_t); {digits to right of decimal point}
  val_param; extern;

procedure string_append_fp_free (      {append free-format floating point to string}
  in out  str: univ string_var_arg_t;  {string to append to}
  in      fp: sys_fp_max_t;            {input floating point number}
  in      min_sig: sys_int_machine_t); {min required significant digits}
  val_param; extern;

procedure string_append_hex (          {append hexadecimal integer to string}
  in out  str: univ string_var_arg_t;  {string to append to}
  in      ii: sys_int_machine_t;       {integer value to append in low NB bits}
  in      nb: sys_int_machine_t);      {number of bits, higher bits in II ignored}
  val_param; extern;

procedure string_append_ints (         {append signed decimal integer to string}
  in out  str: univ string_var_arg_t;  {string to append to}
  in      ii: sys_int_machine_t;       {integer value to append}
  in      fw: sys_int_machine_t);      {fixed field width, or 0 for min required}
  val_param; extern;

procedure string_append_intu (         {append unsigned decimal integer to string}
  in out  str: univ string_var_arg_t;  {string to append to}
  in      ii: sys_int_machine_t;       {integer value to append}
  in      fw: sys_int_machine_t);      {fixed field width, or 0 for min required}
  val_param; extern;

procedure string_append_token (        {append single token using STRING_TOKEN rules}
  in out  str: univ string_var_arg_t;  {string to append to}
  in      tk: univ string_var_arg_t);  {string to append as individual token}
  val_param; extern;

procedure string_append1 (             {append one char to end of string}
  in out  s: univ string_var_arg_t;    {string to append to}
  in      chr: char);                  {character to append}
  val_param; extern;

procedure string_appendn (             {append N characters to end of string}
  in out  s: univ string_var_arg_t;    {string to append to}
  in      chars: univ string;          {characters to append to string}
  in      n: string_index_t);          {number of characters to append}
  val_param; extern;

procedure string_appends (             {append PASCAL STRING to variable length string}
  in out  s: univ string_var_arg_t;    {string to append to}
  in      chars: string);              {append these chars up to trailing blanks}
  extern;

function string_char_printable (       {test whether character is normal printable}
  in      c: char)                     {character to test}
  :boolean;                            {TRUE if printable, FALSE if control char}
  val_param; extern;

procedure string_cmline_end_abort;     {abort if unread tokens left on command line}
  extern;

procedure string_cmline_init;          {init command line parsing for this program}
  extern;

procedure string_cmline_opt_bad;       {indicate last cmd line token was bad}
  options (extern, noreturn);

procedure string_cmline_parm_check (   {check for bad parameter to cmd line option}
  in      stat: sys_err_t;             {status code for reading or using parm}
  in      opt: univ string_var_arg_t); {name of cmd line option parm belongs to}
  extern;

procedure string_cmline_req_check (    {test err after reading required cmd line arg}
  in      stat: sys_err_t);            {status code from getting command line arg}
  extern;

procedure string_cmline_reuse;         {re-use last token from from command line}
  extern;

procedure string_cmline_token (        {get next token from command line}
  in out  token: univ string_var_arg_t; {returned token}
  out     stat: sys_err_t);            {completion status, used to signal end}
  extern;

procedure string_cmline_token_fp1 (    {read next cmd line token as single prec FP}
  out     fp: sys_fp1_t;               {returned floating point value}
  out     stat: sys_err_t);            {completion status code}
  extern;

procedure string_cmline_token_fp2 (    {read next cmd line token as double prec FP}
  out     fp: sys_fp2_t;               {returned floating point value}
  out     stat: sys_err_t);            {completion status code}
  extern;

procedure string_cmline_token_fpm (    {read next cmd line token as machine FP}
  out     fp: real;                    {returned floating point value}
  out     stat: sys_err_t);            {completion status code}
  extern;

procedure string_cmline_token_int (    {read next command line token as machine int}
  out     i: univ sys_int_machine_t;   {returned integer value}
  out     stat: sys_err_t);            {completion status code}
  extern;

function string_compare (              {compares string relative dictionary positions}
  in      s1: univ string_var_arg_t;   {input string 1}
  in      s2: univ string_var_arg_t)   {input string 2}
  :sys_int_machine_t;                  {-1 = (s1<s2), 0 = (s1=s2), 1 = (s1>s2)}
  extern;

function string_compare_opts (         {compares strings, collate sequence control}
  in      s1: univ string_var_arg_t;   {input string 1}
  in      s2: univ string_var_arg_t;   {input string 2}
  in      opts: string_comp_t)         {option flags for collating seqence, etc}
  :sys_int_machine_t;                  {-1 = (s1<s2), 0 = (s1=s2), 1 = (s1>s2)}
  val_param; extern;

procedure string_copy (                {copy one string into another}
  in      s1: univ string_var_arg_t;   {input string}
  in out  s2: univ string_var_arg_t);  {output string}
  extern;

procedure string_debug (               {print length, max, and contents of string}
  in      s: univ string_var_arg_t);   {string to print data of}
  extern;

procedure string_downcase (            {change all upper case chars to lower case}
  in out  s: univ string_var_arg_t);   {string to convert in place}
  extern;

function string_downcase_char (        {make lower case version of char}
  in      c: char)                     {character to return lower case of}
  :char;                               {always lower case}
  val_param; extern;

function string_eos (                  {test for END OF STRING status}
  in out  stat: sys_err_t)             {status code, reset to no error on EOS}
  :boolean;                            {TRUE if STAT indicated END OF STRING}
  extern;

function string_equal (                {check for string same (lengths equal)}
  in      token: univ string_var_arg_t; {first string}
  in      patt: univ string_var_arg_t) {second string}
  :boolean;                            {true if strings are equal}
  extern;

procedure string_f_base64 (            {decode BASE64 string to clear text}
  in      si: univ string_var_arg_t;   {input string, one BASE64 encoded line}
  out     so: univ string_var_arg_t);  {output string, clear text}
  val_param; extern;

procedure string_f_bits16 (            {16 digit binary string from 16 bit integer}
  in out  s: univ string_var_arg_t;    {output string}
  in      bits: sys_int_min16_t);      {input integer, uses low 16 bits}
  val_param; extern;

procedure string_f_bits32 (            {32 digit binary string from 32 bit integer}
  in out  s: univ string_var_arg_t;    {output string}
  in      bits: sys_int_min32_t);      {input integer, uses low 32 bits}
  val_param; extern;

procedure string_f_bitsc (             {make 8 digit binary string from character}
  in out  s: univ string_var_arg_t;    {output string}
  in      bits: char);                 {input byte}
  val_param; extern;

procedure string_f_bool (              {make string from TRUE/FALSE value}
  in out  s: univ string_var_arg_t;    {output string}
  in      t: boolean;                  {input TRUE/FALSE value}
  in      tftype: string_tftype_k_t);  {selects T/F string type}
  val_param; extern;

procedure string_f_fp_eng (            {engineering notation string from floating point}
  in out  s: univ string_var_arg_t;    {output string, always 1-3 digits left of point}
  in      fp: sys_fp_max_t;            {input floating point number}
  in      sig: sys_int_machine_t;      {minimum significant digits required}
  out     un: univ string_var_arg_t);  {units prefix, like M K m u p, etc}
  val_param; extern;

procedure string_f_fp_free (           {free form string from floating point number}
  in out  s: univ string_var_arg_t;    {output string}
  in      fp: sys_fp_max_t;            {input floating point number}
  in      min_sig: sys_int_machine_t); {minimum required significant digits}
  val_param; extern;

procedure string_f_fp_fixed (          {fixed point string from floating point num}
  in out  s: univ string_var_arg_t;    {output string}
  in      fp: sys_fp_max_t;            {input floating point number}
  in      dig_right: string_index_t);  {digits to right of decimal point}
  val_param; extern;

procedure string_f_fp_ftn (            {string from floating point num, FTN controls}
  in out  s: univ string_var_arg_t;    {output string}
  in      fp: sys_fp_max_t;            {input floating point number}
  in      fw: string_index_t;          {total field width}
  in      dig_right: string_index_t);  {digits to right of decimal point}
  val_param; extern;

procedure string_f_fp (                {make string from FP number, full features}
  in out  s: univ string_var_arg_t;    {output string}
  in      fp: sys_fp_max_t;            {input floating point number}
  in      fw: string_index_t;          {total field width, use 0 for free form}
  in      fw_exp: string_index_t;      {exp field width when used, 0 = free form}
  in      min_sig: sys_int_machine_t;  {minimum required total significant digits}
  in      max_left: sys_int_machine_t; {max allowed digits left of point}
  in      min_right: sys_int_machine_t; {min required digits right of point}
  in      max_right: sys_int_machine_t; {max allowed digits right of point}
  in      flags: string_ffp_t;         {additional option flags}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure string_f_inetadr (           {binary internet address to dot notation str}
  in out  s: univ string_var_arg_t;    {output string}
  in      adr: sys_inet_adr_node_t);   {input internet node address}
  val_param; extern;

procedure string_f_int (               {make string from machine integer}
  in out  s: univ string_var_arg_t;    {output string, no leading zeros}
  in      i: sys_int_machine_t);       {input integer}
  val_param; extern;

procedure string_f_int_max (           {make string from largest available integer}
  in out  s: univ string_var_arg_t;    {output string, no leading zeros}
  in      i: sys_int_max_t);           {input integer}
  val_param; extern;

procedure string_f_int_max_base (      {make string from max integer, base supplied}
  in out  s: univ string_var_arg_t;    {output string}
  in      i: sys_int_max_t;            {input integer}
  in      base: sys_int_machine_t;     {number base for output string}
  in      fw: string_index_t;          {field width, use 0 for free form}
  in      flags: string_fi_t;          {addtional option flags}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure string_f_int8h (             {make HEX string from 8 bit integer}
  in out  s: univ string_var_arg_t;    {output string}
  in      i: sys_int_max_t);           {input integer, uses low 8 bits}
  val_param; extern;

procedure string_f_int16 (             {make string from 16 bit integer}
  in out  s: univ string_var_arg_t;    {output string, no leading zeros}
  in      i: sys_int_min16_t);         {input integer, uses low 16 bits}
  val_param; extern;

procedure string_f_int16h (            {make HEX string from 16 bit integer}
  in out  s: univ string_var_arg_t;    {output string}
  in      i: sys_int_conv16_t);        {input integer, uses low 16 bits}
  val_param; extern;

procedure string_f_int20h (            {make HEX string from 20 bit integer}
  in out  s: univ string_var_arg_t;    {output string}
  in      i: sys_int_conv20_t);        {input integer, uses low 20 bits}
  val_param; extern;

procedure string_f_int24h (            {make HEX string from 24 bit integer}
  in out  s: univ string_var_arg_t;    {output string}
  in      i: sys_int_max_t);           {input integer, uses low 24 bits}
  val_param; extern;

procedure string_f_int32 (             {make string from 32 bit integer}
  in out  s: univ string_var_arg_t;    {output string}
  in      i: sys_int_min32_t);         {input integer, uses low 32 bits}
  val_param; extern;

procedure string_f_int32h (            {make HEX string from 32 bit integer}
  in out  s: univ string_var_arg_t;    {output string}
  in      i: sys_int_min32_t);         {input integer, uses low 32 bits}
  val_param; extern;

procedure string_f_intco (             {make 3 char octal from character}
  in out  s: univ string_var_arg_t;    {output string}
  in      byte: char);                 {input byte}
  val_param; extern;

procedure string_f_intrj (             {right-justified string from machine integer}
  in out  s: univ string_var_arg_t;    {output string}
  in      i: sys_int_machine_t;        {input integer}
  in      fw: string_index_t;          {width of output field in string S}
  out     stat: sys_err_t);            {completion code}
  val_param; extern;

procedure string_f_macadr (            {make string from ethernet MAC address}
  in out  s: univ string_var_arg_t;    {output string}
  in      macadr: sys_macadr_t);       {input MAC address}
  val_param; extern;

procedure string_f_message (           {expand MSG file message into single string}
  in out  s: univ string_var_arg_t;    {out string, default subsys and msg names}
  in      subsys: string;              {name of subsystem, used to find message file}
  in      msg: string;                 {message name within subsystem file}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t); {number of parameters in PARMS}
  val_param; extern;

function string_f_messaget (           {test for msg, expand to string}
  in out  s: univ string_var_arg_t;    {output string, trashed on message not found}
  in      subsys: univ string_var_arg_t; {subsystem name (generic msg file name)}
  in      msg: univ string_var_arg_t;  {message name within message file}
  in      parms: univ sys_parm_msg_ar_t; {array of parameter descriptors}
  in      n_parms: sys_int_machine_t)  {number of parameters in PARMS}
  :boolean;                            {TRUE if message found and S set}
  val_param; extern;

procedure string_f_screen (            {convert system screen handle to a string}
  in out  s: univ string_var_arg_t;    {output string}
  in      screen: sys_screen_t);       {input handle to the screen}
  val_param; extern;

procedure string_f_window (            {convert system window handle to a string}
  in out  s: univ string_var_arg_t;    {output string}
  in      window: sys_window_t);       {input handle to the window}
  val_param; extern;

procedure string_fifo_create (         {create a first in first out (FIFO) byte queue}
  in out  mem: util_mem_context_t;     {context to allocate new memory under}
  in      maxbytes: sys_int_adr_t;     {max bytes the FIFO will be able to hold}
  out     fifo_p: string_fifo_p_t);    {returned pointer to the FIFO}
  val_param; extern;

procedure string_fifo_delete (         {delete FIFO and all its system resources}
  in out  fifo_p: string_fifo_p_t);    {pointer to the FIFO, returned NIL}
  val_param; extern;

function string_fifo_get (             {get next byte from FIFO, blocks until available}
  in out  fifo: string_fifo_t)         {the FIFO}
  :sys_int_machine_t;                  {0-255 byte value}
  val_param; extern;

function string_fifo_get_tout (        {get next byte from FIFO or timeout}
  in out  fifo: string_fifo_t;         {the FIFO}
  in      tout: real;                  {max seconds to wait, or SYS_TIMEOUT_xxx_K}
  out     b: sys_int_machine_t)        {0-255 byte value, 0 on timeout}
  :boolean;                            {TRUE on timeout, FALSE on returning with byte}
  val_param; extern;

procedure string_fifo_lock (           {acquire exclusive access to a FIFO}
  in out  fifo: string_fifo_t);        {the FIFO}
  val_param; extern;

function string_fifo_nempty (          {returns how much room is in a FIFO}
  in out  fifo: string_fifo_t)         {the FIFO}
  :sys_int_adr_t;                      {number of additional bytes that can be written}
  val_param; extern;

function string_fifo_nfull (           {returns number of bytes in a FIFO}
  in out  fifo: string_fifo_t)         {the FIFO}
  :sys_int_adr_t;                      {number of bytes available to read immediately}
  val_param; extern;

procedure string_fifo_put (            {write byte to FIFO, blocks until room}
  in out  fifo: string_fifo_t;         {the FIFO}
  in      b: int8u_t);                 {the byte to write}
  val_param; extern;

procedure string_fifo_putbuf (         {write buffer of bytes to FIFO, blocks}
  in out  fifo: string_fifo_t;         {the FIFO}
  in      buf: univ string_bytebuf_t;  {buffer of bytes to write}
  in      n: sys_int_machine_t);       {number of bytes to write starting with BUF[0]}
  val_param; extern;

procedure string_fifo_reset (          {reset a FIFO to empty, existing data discarded}
  in out  fifo: string_fifo_t);        {the FIFO to reset}
  val_param; extern;

procedure string_fifo_unlock (         {release exclusive access to a FIFO}
  in out  fifo: string_fifo_t);        {the FIFO}
  val_param; extern;

procedure string_fill (                {fill unused string space with blanks}
  in out  s: univ string_var_arg_t);   {string to fill, length not altered}
  extern;

procedure string_find (                {find substring in a reference string}
  in      token: univ string_var_arg_t; {substring to look for}
  in      s: univ string_var_arg_t;    {string to look for substring in}
  out     i: string_index_t);          {substring start index, 0 = not found}
  extern;

procedure string_find_real_format (    {get format spec for real number string}
  in      rmin: real;                  {min value real number could have}
  in      rmax: real;                  {max value real number could have}
  in      sd: sys_int_machine_t;       {min required significant digits in string}
  in      eng_notation: boolean;       {engineering notation for exponent?}
  out     fw: string_index_t;          {min required field width of string}
  out     nd: sys_int_machine_t;       {min required digits below decimal point}
  out     exp: sys_int_machine_t);     {power of ten exponent value}
  val_param; extern;

procedure string_fnam_extend (         {make filename with extension}
  in      innam: univ string_var_arg_t; {input file name (may already have extension)}
  in      extension: string;           {file name extension}
  in out  ofnam: univ string_var_arg_t); {output file name that will have extension}
  extern;

procedure string_fnam_unextend (       {remove filename extension if there}
  in      innam: univ string_var_arg_t; {input file name (OK if no extension)}
  in      extensions: string;          {list of extensions separated by blanks}
  in out  ofnam: univ string_var_arg_t); {output file name that will not have extension}
  extern;

function string_fnam_within (          {check for file within a directory}
  in      fnam: univ string_var_arg_t; {the file to check}
  in      dir: univ string_var_arg_t;  {directory to check for file being within}
  in out  wpath: univ string_var_arg_t) {returned path within DIR}
  :boolean;                            {FNAM is within DIR tree}
  val_param; extern;

procedure string_fnam_cog_loc (        {fnam from Cognivision standard to local form}
  in      cnam: string_cogname_t;      {input file name in Cognivision format}
  in out  lnam: string_treename_t;     {output file name in local format}
  out     stat: sys_err_t);            {returned completion status code}
  val_param; extern;

procedure string_fnam_loc_cog (        {fnam from local to Cognivision standard form}
  in      lnam: univ string_var_arg_t; {input local file name}
  in out  cnam: string_cogname_t);     {output file name in Cognivision format}
  val_param; extern;

procedure string_generic_fnam (        {generic leaf name from file name and extensions}
  in      innam: univ string_var_arg_t; {input file name (may be tree name)}
  in      extensions: string;          {list of extensions separated by blanks}
  in out  fnam: univ string_var_arg_t); {output file name without extension}
  extern;

procedure string_generic_tnam (        {generic tree name from file name and extensions}
  in      innam: univ string_var_arg_t; {input file name (may be tree name)}
  in      extensions: string;          {list of extensions separated by blanks}
  in out  tnam: univ string_var_arg_t); {output tree name without extension}
  extern;

procedure string_hash_create (         {create a hash table}
  out     hash_h: string_hash_handle_t; {hash table to initialize}
  in      n_buck: sys_int_machine_t;   {number of entries in table, (power of 2)}
  in      name_len: sys_int_machine_t; {max allowed size of any entry name}
  in      data_size: sys_int_adr_t;    {amount of user data for each entry}
  in      flags: string_hashcre_t;     {additional modifier flags}
  in out  mem: util_mem_context_t);    {parent memory context to use for this table}
  val_param; extern;

procedure string_hash_ent_add (        {create new entry at given position}
  in out  pos: string_hash_pos_t;      {handle to position in hash table}
  out     name_p: univ_ptr;            {pointer to var string hash table entry name}
  out     data_p: univ_ptr);           {pointer to hash table entry user data area}
  val_param; extern;

procedure string_hash_ent_atpos (      {get entry data from position handle}
  in      pos: string_hash_pos_t;      {position handle, must be at an entry}
  out     name_p: univ_ptr;            {pointer to var string hash table entry name}
  out     data_p: univ_ptr);           {pointer to hash table entry user data area}
  val_param; extern;

procedure string_hash_ent_del (        {delete hash table entry at given position}
  in out  pos: string_hash_pos_t);     {handle to entry position in hash table}
  val_param; extern;

procedure string_hash_ent_lookup (     {get entry data given name}
  in      hash_h: string_hash_handle_t; {handle to hash table}
  in      name: univ string_var_arg_t; {name of entry to get data for}
  out     name_p: univ_ptr;            {pointer to var string hash table entry name}
  out     data_p: univ_ptr);           {pointer to user data area, NIL if not found}
  val_param; extern;

procedure string_hash_delete (         {delete hash table, deallocate resources}
  in out  hash_h: string_hash_handle_t); {hash table to delete, returned invalid}
  val_param; extern;

procedure string_hash_mem_alloc_del (  {allocate mem from hash context, can dealloc}
  in      hash_h: string_hash_handle_t; {handle to hash table}
  in      size: sys_int_adr_t;         {amount of memory to allocate}
  out     p: univ_ptr);                {pointer to start of new mem}
  val_param; extern;

procedure string_hash_mem_alloc_ndel ( {allocate mem from hash context, no dealloc}
  in      hash_h: string_hash_handle_t; {handle to hash table}
  in      size: sys_int_adr_t;         {amount of memory to allocate}
  out     p: univ_ptr);                {pointer to start of new mem}
  val_param; extern;

procedure string_hash_mem_dealloc (    {deallocate mem allocated under hash context}
  in      hash_h: string_hash_handle_t; {handle to hash table}
  in out  p: univ_ptr);                {pointer to start of mem, returned NIL}
  val_param; extern;

procedure string_hash_pos_first (      {return position handle to first entry}
  in      hash_h: string_hash_handle_t; {handle to hash table}
  out     pos: string_hash_pos_t;      {handle to position for this name}
  out     found: boolean);             {TRUE if entry existed}
  val_param; extern;

procedure string_hash_pos_lookup (     {return position handle from entry name}
  in      hash_h: string_hash_handle_t; {handle to hash table}
  in      name: univ string_var_arg_t; {name to find position for}
  out     pos: string_hash_pos_t;      {handle to position for this name}
  out     found: boolean);             {TRUE if entry existed}
  val_param; extern;

procedure string_hash_pos_next (       {advance position to next entry in hash table}
  in out  pos: string_hash_pos_t;      {handle to position for this name}
  out     found: boolean);             {TRUE if entry existed}
  val_param; extern;

procedure string_len (                 {set length by unpadding max length string}
  in out  s: univ string_var_arg_t);   {string}
  extern;

procedure string_list_copy (           {make separate copy of a strings list}
  in      list1: string_list_t;        {handle to input strings list}
  out     list2: string_list_t;        {handle to output strings list}
  in out  mem: util_mem_context_t);    {parent memory context to use}
  extern;

procedure string_list_init (           {init a STRING_LIST_T data structure}
  out     list: string_list_t;         {control block for string list to initialize}
  in out  mem: util_mem_context_t);    {parent memory context to use}
  extern;

procedure string_list_kill (           {delete string, deallocate resources}
  in out  list: string_list_t);        {must be initialized before next use}
  extern;

procedure string_list_line_add (       {insert new line after curr and make it curr}
  in out  list: string_list_t);        {strings list control block}
  extern;

procedure string_list_line_del (       {delete curr line in strings list}
  in out  list: string_list_t;         {strings list control block}
  in      forward: boolean);           {TRUE makes next line curr, FALSE previous}
  val_param; extern;

procedure string_list_pos_abs (        {set new current line number in strings list}
  in out  list: string_list_t;         {strings list control block}
  in      n: sys_int_machine_t);       {number of new current line, first = 1}
  val_param; extern;

procedure string_list_pos_last (       {position to last line, 0 if none there}
  in out  list: string_list_t);        {strings list control block}
  extern;

procedure string_list_pos_rel (        {move forward/backwards in strings list}
  in out  list: string_list_t;         {strings list control block}
  in      n_fwd: sys_int_machine_t);   {lines to move forwards, may be negative}
  val_param; extern;

procedure string_list_pos_start (      {position to before first line in list}
  in out  list: string_list_t);        {strings list control block}
  extern;

procedure string_list_sort (           {sort strings in a strings list}
  in out  list: string_list_t;         {strings list control block}
  in      opts: string_comp_t);        {option flags for collating seqence, etc}
  val_param; extern;

procedure string_list_str_add (        {add new string after curr, make curr}
  in out  list: string_list_t;         {list to add entry to}
  in      str: univ string_var_arg_t); {string to set entry to, will be this size}
  val_param; extern;

procedure string_list_trunc (          {truncate strings list after current line}
  in out  list: string_list_t);        {strings list control block}
  extern;

procedure string_lj (                  {left justify string - eliminate leading spaces}
  in out  s: univ string_var_arg_t);   {string to left justify}
  extern;

function string_match (                {strings same up to length of TOKEN}
  in      token: univ string_var_arg_t; {string being tested}
  in      patt: univ string_var_arg_t) {pattern which can be abbreviated in TOKEN}
  :boolean;                            {TRUE if strings match}
  extern;

procedure string_pad (                 {extend string to max length by adding blanks}
  in out  s: univ string_var_arg_t);   {string}
  extern;

procedure string_pathname_join (       {join directory and leaf name together}
  in      dnam: univ string_treename_t; {directory name}
  in      lnam: univ string_leafname_t; {leaf name}
  out     tnam: univ string_treename_t); {joined treename}
  extern;

procedure string_pathname_split (      {make dir. and leaf name from arbitrary path name}
  in      tnam: univ string_treename_t; {arbitrary path name to split}
  out     dnam: univ string_treename_t; {directory name}
  out     lnam: univ string_leafname_t); {leaf name}
  extern;

procedure string_parity_off (          {turn parity bits off for all chars in string}
  in out  s: univ string_var_arg_t);   {string}
  extern;

procedure string_prepend (             {add one string to front of another}
  in out  str: univ string_var_arg_t;  {the string to add to the front of}
  in      add: univ string_var_arg_t); {the string to add}
  val_param; extern;

procedure string_prependn (            {add N chars to start of string}
  in out  str: univ string_var_arg_t;  {string to add chars to front of}
  in      chars: string;               {characters to add}
  in      n: sys_int_machine_t);       {number of characters to add}
  val_param; extern;

procedure string_prepends (            {add Pascal string to front of var string}
  in out  str: univ string_var_arg_t;  {string to prepend to}
  in      chars: string);              {chars up to NULL or trailing blanks}
  val_param; extern;

procedure string_progname (            {get name of program}
  in out  pname: univ string_var_arg_t); {returned string containing program name}
  extern;

procedure string_prompt (              {string to standard output without newline}
  in      s: univ string_var_arg_t);   {prompt string to write}
  extern;

procedure string_readin (              {read and unpad next line from standard input}
  in out  s: univ string_var_arg_t);   {output string}
  extern;

function string_seq_get (              {get new unique sequential number}
  in      fnam: univ string_var_arg_t; {sequential number file name, ".seq" optional}
  in      incr: sys_int_max_t;         {amount to increment the sequence number by}
  in      first: sys_int_max_t;        {initial value if file not exist}
  in      flags: string_seq_t;         {modifier flags}
  out     stat: sys_err_t)             {returned completion status}
  :sys_int_max_t;                      {returned sequential number}
  val_param; extern;

procedure string_seq_set (             {set sequence number to new value}
  in      fnam: univ string_var_arg_t; {sequence number file name, ".seq" optional}
  in      newseq: sys_int_max_t;       {new sequence number to set to}
  in      cond: string_seqcond_t;      {optional set of condition flags}
  out     result: sys_int_max_t;       {final resulting sequence number}
  out     stat: sys_err_t);            {returned completion status}
  val_param; extern;

function string_size (                 {return memory size of a var string}
  in      len: string_index_t)         {length of var string in characters}
  :sys_int_adr_t;                      {returned min memory requirement of string}
  val_param; extern;

function string_slen (                 {find string length of character sequence}
  in      chars: string;               {chars, blank padded or NULL terminated}
  in      maxlen: sys_int_machine_t)   {max possible length of the char sequence}
  :sys_int_machine_t;                  {0-N string length}
  val_param; extern;

procedure string_substr (              {extract substring from a string}
  in      s1: univ string_var_arg_t;   {input string to extract from}
  in      st: string_index_t;          {start index of substring}
  in      en: string_index_t;          {end index of substring}
  in out  s2: univ string_var_arg_t);  {output substring}
  val_param; extern;

procedure string_t_angle (             {<degrees>:<minutes>:<seconds> to angle}
  in      tk: univ string_var_arg_t;   {input string}
  out     ang: real;                   {resulting angle, radians}
  out     stat: sys_err_t);            {completion status}
  val_param; extern;

procedure string_t_base64 (            {encode clear text string to BASE64}
  in      si: univ string_var_arg_t;   {input string, clear text}
  out     so: univ string_var_arg_t);  {output string, BASE64 encoded}
  val_param; extern;

procedure string_t_bitsc (             {convert 8 digit binary string to character}
  in      s: univ string_var_arg_t;    {input string}
  out     bits: char;                  {output character}
  out     stat: sys_err_t);            {completion status code}
  extern;

procedure string_t_bool (              {convert string to Boolean}
  in      s: univ string_var_arg_t;    {input string}
  in      flags: string_tftype_t;      {selects which T/F types are allowed}
  out     t: boolean;                  {TRUE: true, yes, on, FALSE: false, no, off}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure string_t_date1 (             {make date/time from string}
  in      s: univ string_var_arg_t;    {input string, YYYY/MM/DD.HH:MM:SS.SSS}
  in      local: boolean;              {interpret as local time, not coor univ}
  out     date: sys_date_t;            {returned date/time, filled in for local time}
  out     stat: sys_err_t);            {returned completion status}
  val_param; extern;

procedure string_t_fp1 (               {convert string to single precision float}
  in      s: univ string_var_arg_t;    {input string}
  out     fp: sys_fp1_t;               {output floating point number}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure string_t_fp2 (               {convert string to double precision float}
  in      s: univ string_var_arg_t;    {input string}
  out     fp: sys_fp2_t;               {output floating point number}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure string_t_fpm (               {convert string to machine floating point}
  in      s: univ string_var_arg_t;    {input string}
  out     fp: real;                    {output floating point number}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure string_t_fpmax (             {convert string to max size floating point}
  in      s: univ string_var_arg_t;    {input string}
  in out  fp: sys_fp_max_t;            {output floating point number}
  in      flags: string_tfp_t;         {additional option flags}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure string_t_inetadr (           {dot notation internet node adr to string}
  in      s: univ string_var_arg_t;    {input string}
  out     adr: sys_inet_adr_node_t;    {output binary internet address}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure string_t_int (               {convert string to machine integer}
  in      s: univ string_var_arg_t;    {input string}
  out     val: sys_int_machine_t;      {output integer}
  out     stat: sys_err_t);            {completion status code}
  extern;

procedure string_t_int_max (           {convert string to max size integer}
  in      s: univ string_var_arg_t;    {input string}
  out     val: sys_int_max_t;          {output integer}
  out     stat: sys_err_t);            {completion status code}
  extern;

procedure string_t_int_max_base (      {convert string to max int with full features}
  in      s: univ string_var_arg_t;    {input string}
  in      base: sys_int_machine_t;     {number base of input string}
  in      flags: string_ti_t;          {additional option flags}
  in out  val: sys_int_max_t;          {output integer}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure string_t_int16o (            {convert OCTAL string to 16 bit integer}
  in      s: univ string_var_arg_t;    {input string}
  out     i: sys_int_min16_t;          {output integer, bits will be right justified}
  out     stat: sys_err_t);            {completion status code}
  extern;

procedure string_t_int32h (            {convert HEX string to 32 bit integer}
  in      s: univ string_var_arg_t;    {input string}
  out     i: sys_int_min32_t;          {output integer, bits will be right justified}
  out     stat: sys_err_t);            {completion status code}
  extern;

procedure string_t_c (                 {convert var string to C-style NULL term str}
  in      vstr: univ string_var_arg_t; {input var string}
  out     cstr: univ string;           {returned null terminated C string}
  in      cstr_len: sys_int_machine_t); {max characters allowed to write into CSTR}
  val_param; extern;

procedure string_t_screen (            {convert string to system screen handle}
  in      s: univ string_var_arg_t;    {input string}
  out     screen: sys_screen_t;        {returned handle to the screen}
  out     stat: sys_err_t);            {completion status code}
  extern;

procedure string_t_time1 (             {make time from string}
  in      s: univ string_var_arg_t;    {input string, YYYY/MM/DD.HH:MM:SS.SSS}
  in      local: boolean;              {interpret as local time, not coor univ}
  out     time: sys_clock_t;           {returned absolute time}
  out     stat: sys_err_t);            {returned completion status}
  val_param; extern;

procedure string_t_window (            {convert string to system window handle}
  in      s: univ string_var_arg_t;    {input string}
  out     window: sys_window_t;        {returned handle to the window}
  out     stat: sys_err_t);            {completion status code}
  extern;

procedure string_terminate_null (      {insure .STR field is null-terminated}
  in out  s: univ string_var_arg_t);   {hidden NULL will be added after string body}
  extern;

procedure string_tkpick (              {pick unabbreviated token from list}
  in      token: univ string_var_arg_t; {token}
  in      tlist: univ string_var_arg_t; {list of tokens separated by spaces}
  out     tnum: sys_int_machine_t);    {token number of match (0=no match)}
  extern;

procedure string_tkpick_s (            {pick legal abbrev from any length token list}
  in      token: univ string_var_arg_t; {to try to pick from list}
  in      tlist: univ string;          {list of valid tokens separated by blanks}
  in      len: string_index_t;         {number of chars in TLIST}
  out     pick: sys_int_machine_t);    {token number 1-N, 0=none, -1=not unique}
  val_param; extern;

procedure string_tkpick80 (            {pick unabbreviated token from list}
  in      token: univ string_var_arg_t; {token}
  in      chars: string;               {list of tokens separated by spaces}
  out     tnum: sys_int_machine_t);    {token number of match (0=no match)}
  extern;

procedure string_tkpick80m (           {pick abbreviatable token from list}
  in out  token: univ string_var_arg_t; {token}
  in      chars: string;               {list of tokens separated by spaces}
  out     tnum: sys_int_machine_t);    {token number of match (0=no match)}
  extern;

procedure string_tkpickm (             {pick abbreviatable token from list}
  in      token: univ string_var_arg_t; {token}
  in      tlist: univ string_var_arg_t; {list of tokens separated by spaces}
  out     tnum: sys_int_machine_t);    {token number of match (0=no match)}
  extern;

procedure string_token (               {get next token from string, blank delimeters}
  in      s: univ string_var_arg_t;    {input string}
  in out  p: string_index_t;           {parse index, init to 1 for start of string}
  out     token: univ string_var_arg_t; {output token, null string after last token}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure string_token_anyd (          {like STRING_TOKEN, user supplies delimiters}
  in      s: univ string_var_arg_t;    {input string}
  in out  p: string_index_t;           {parse index, init to 1 for start of string}
  in      delim: univ string;          {list of delimiters between tokens}
  in      n_delim: sys_int_machine_t;  {number of delimiters in DELIM}
  in      n_delim_rept: sys_int_machine_t; {first N delimiters that may be repeated}
  in      flags: string_tkopt_t;       {set of option flags}
  out     token: univ string_var_arg_t; {output token parsed from S}
  out     delim_pick: sys_int_machine_t; {index to main delimeter ending token}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure string_token_bool (          {parse token and convert to boolean}
  in      s: univ string_var_arg_t;    {input string}
  in out  p: string_index_t;           {input string parse index, init to 1 at start}
  in      flags: string_tftype_t;      {selects which T/F types are allowed}
  out     t: boolean;                  {TRUE: true, yes, on, FALSE: false, no, off}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure string_token_comma (         {get token, comma delimiter, blank pad stripped}
  in      s: univ string_var_arg_t;    {input string}
  in out  p: string_index_t;           {parse index, init to 1 for start of string}
  out     token: univ string_var_arg_t; {output token}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure string_token_commasp (       {get token, 1 comma or N blank delimiters}
  in      s: univ string_var_arg_t;    {input string}
  in out  p: string_index_t;           {parse index, init to 1 for start of string}
  out     token: univ string_var_arg_t; {output token}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure string_token_fp1 (           {parse token and convert to single prec FP}
  in      s: univ string_var_arg_t;    {input string}
  in out  p: string_index_t;           {input string parse index, init to 1 at start}
  out     fp: sys_fp1_t;               {output value}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure string_token_fp2 (           {parse token and convert to double prec FP}
  in      s: univ string_var_arg_t;    {input string}
  in out  p: string_index_t;           {input string parse index, init to 1 at start}
  out     fp: sys_fp2_t;               {output value}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure string_token_fpm (           {parse token and convert to machine FP}
  in      s: univ string_var_arg_t;    {input string}
  in out  p: string_index_t;           {input string parse index, init to 1 at start}
  out     fp: real;                    {output value}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure string_token_int (           {get next token and convert to machine integer}
  in      s: univ string_var_arg_t;    {input string}
  in out  p: string_index_t;           {input string parse index, init to 1 at start}
  out     i: sys_int_machine_t;        {output value}
  out     stat: sys_err_t);            {completion status code}
  val_param; extern;

procedure string_token_make (          {make individual token from input string}
  in      str: univ string_var_arg_t;  {input string}
  in out  tk: univ string_var_arg_t);  {will be parsed as one token by STRING_TOKEN}
  val_param; extern;

procedure string_treename (            {make full treename from arbitrary path name}
  in      inam: univ string_var_arg_t; {input arbitrary path name}
  in out  tnam: univ string_var_arg_t); {output full tree name}
  extern;

procedure string_treename_machine (    {get machine name from Cognivision treename}
  in      tnam: univ string_var_arg_t; {treename in Cognivis format, //<name>/<path>}
  out     machine: univ string_var_arg_t); {just the machine name from TNAM}
  extern;

procedure string_treename_opts (       {treename with more control options}
  in      inam: univ string_var_arg_t; {input path name}
  in      opts: string_tnamopt_t;      {set of option flags}
  in out  tnam: univ string_var_arg_t; {output tree name}
  out     tstat: string_tnstat_k_t);   {translation result status}
  val_param; extern;

procedure string_unpad (               {delete all trailing spaces from string}
  in out  s: univ string_var_arg_t);   {string}
  extern;

procedure string_upcase (              {convert all lower case chars to upper case}
  in out  s: univ string_var_arg_t);   {string to upcase}
  extern;

function string_upcase_char (          {make upper case version of char}
  in      c: char)                     {character to return upper case of}
  :char;                               {always upper case}
  val_param; extern;

function string_v (                    {convert Pascal STRING to variable string}
  in      char80: string)              {input of STRING data type}
  :string_var80_t;                     {unpadded variable length string}
  extern;

procedure string_vstring (             {make var string from Pascal, C or FTN string}
  in out  s: univ string_var_arg_t;    {var string to fill in}
  in      in_str: univ string;         {source string characters}
  in      in_len: string_index_t);     {storage length of IN_STR}
  val_param; extern;

procedure string_wipe (                {set string to empty, wipe all chars to NULL}
  in out  s: univ string_var_arg_t);   {string to wipe}
  val_param; extern;

procedure string_write (               {write string to standard output, close line}
  in      s: univ string_var_arg_t);   {string to write}
  extern;

procedure string_write_blank;          {write blank line to standard output}
  extern;

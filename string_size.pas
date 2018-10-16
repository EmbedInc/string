{   Function STRING_SIZE (LEN)
*
*   Returns the amount of memory needed to hold a var string with LEN characters
*   in it.
}
module string_SIZE;
define string_size;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

function string_size (                 {return memory size of a var string}
  in      len: string_index_t)         {length of var string in characters}
  :sys_int_adr_t;                      {returned min memory requirement of string}
  val_param;

var
  s_p: ^string_var16_t;                {pointer to be able to reference data type}

begin
  string_size :=
    sizeof(s_p^) - sizeof(s_p^.str) +  {size of administration fields}
    (len * sizeof(s_p^.str[1]));       {size of raw string}
  end;

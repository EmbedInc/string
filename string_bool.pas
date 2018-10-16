{   Module of routines that convert between strings and boolean values.
}
module string_bool;
define string_t_bool;
define string_f_bool;
%include 'string2.ins.pas';
{
***********************************************************************
*
*   Subroutine STRING_T_BOOL (S, FLAGS, T, STAT)
*
*   Convert the string S to the boolean variable T.  FLAGS indicates
*   which types of boolean string representations are to be allowed
*   in S.  The options within FLAGS are:
*
*     STRING_TFTYPE_TF_K  -  TRUE / FALSE
*
*     STRING_TFTYPE_YESNO_K  -  YES / NO
*
*     STRING_TFTYPE_ONOFF_K  -  ON / OFF
*
*   The string in S is case-insenstive.  S may be a single letter if it
*   uniquely matches the first letter of an enabled T/F string representation
*   type.
}
procedure string_t_bool (              {convert string to Boolean}
  in      s: univ string_var_arg_t;    {input string}
  in      flags: string_tftype_t;      {selects which T/F types are allowed}
  out     t: boolean;                  {TRUE: true, yes, on, FALSE: false, no, off}
  out     stat: sys_err_t);            {completion status code}
  val_param;

var
  su: string_var16_t;                  {upper case version of S}
  pick: sys_int_machine_t;             {number of keyword picked from list}

label
  got_stat;

begin
  su.max := sizeof(su.str);            {init local var string}
  sys_error_none (stat);               {init to no error}

  string_copy (s, su);                 {make local upper case copy of input string}
  string_upcase (su);
  t := false;                          {init returned value}

  if string_tftype_tf_k in flags then begin {TRUE / FALSE enabled ?}
    string_tkpick80 (su, 'TRUE T FALSE F', pick);
    case pick of
1, 2: begin
        t := true;
        return;
        end;
3, 4: return;
      end;
    end;

  if string_tftype_yesno_k in flags then begin {YES / NO enabled ?}
    string_tkpick80 (su, 'YES Y NO N', pick);
    case pick of
1, 2: begin
        t := true;
        return;
        end;
3, 4: return;
      end;
    end;

  if string_tftype_onoff_k in flags then begin {ON / OFF enabled ?}
    string_tkpick80 (su, 'ON OFF', pick);
    case pick of
1: begin
        t := true;
        return;
        end;
2: return;
      end;
    end;
{
*   The input string didn't match any of the selected choices.
}
  if string_tftype_yesno_k in flags then begin {YES / NO enabled ?}
    sys_stat_set (string_subsys_k, string_stat_bad_yesno_k, stat);
    goto got_stat;
    end;

  if string_tftype_onoff_k in flags then begin {ON / OFF enabled ?}
    sys_stat_set (string_subsys_k, string_stat_bad_onoff_k, stat);
    goto got_stat;
    end;

  sys_stat_set (string_subsys_k, string_stat_bad_truefalse_k, stat);
got_stat:                              {common exit with STAT set to error}
  sys_stat_parm_vstr (su, stat);
  end;
{
***********************************************************************
*
*   Subroutine STRING_F_BOOL (S, T, TFTYPE)
*
*   Set S to the string representation of the boolean value T.  TFTYPE
*   selects the types of boolean string representations.  Choices for
*   TFTYPE are:
*
*     STRING_TFTYPE_TF_K  -  True, False
*
*     STRING_TFTYPE_YESNO_K  -  Yes, No
*
*     STRING_TFTYPE_ONOFF_K  -  On, Off
*
*   S is always returned with one of the strings shown, up to its maximum
*   length.  The first letter is upper case, and the remaining letters
*   are lower case.
}
procedure string_f_bool (              {make string from TRUE/FALSE value}
  in out  s: univ string_var_arg_t;    {output string}
  in      t: boolean;                  {input TRUE/FALSE value}
  in      tftype: string_tftype_k_t);  {selects T/F string type}
  val_param;

begin
  case tftype of                       {which boolean string representation ?}
string_tftype_tf_k: begin
      if t
        then string_vstring (s, 'True', 4)
        else string_vstring (s, 'False', 5);
      end;
string_tftype_yesno_k: begin
      if t
        then string_vstring (s, 'Yes', 3)
        else string_vstring (s, 'No', 2);
      end;
string_tftype_onoff_k: begin
      if t
        then string_vstring (s, 'On', 2)
        else string_vstring (s, 'Off', 3);
      end;
otherwise                              {this shouldn't happen}
    if t
      then string_vstring (s, 'True', 4)
      else string_vstring (s, 'False', 5);
    end;
  end;

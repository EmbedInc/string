{   Subroutine STRING_FIND_REAL_FORMAT (RMIN, RMAX, SD, ENG_NOTATION, FW, ND, EXP)
*
*   Determine the fixed format for a range of reals.
*   RMIN and RMAX is the mininum/maximum range of real values.
*   SD is the number of significant digits required. ENG_NOTATION is
*   true if powers of three are desired in the EXP. FW is
*   the minimum field width to adequately represent the range of real values.
*   ND is the number of decimal digits used in the field length.
*   EXP is the value of the exponent for powers of 10.
}
module string_find_real_format;
define string_find_real_format;
%include '/cognivision_links/dsee_libs/string/string2.ins.pas';

procedure string_find_real_format (    {get format spec for real number string}
  in      rmin: real;                  {min value real number could have}
  in      rmax: real;                  {max value real number could have}
  in      sd: sys_int_machine_t;       {min required significant digits in string}
  in      eng_notation: boolean;       {engineering notation for exponent?}
  out     fw: string_index_t;          {min required field width of string}
  out     nd: sys_int_machine_t;       {min required digits below decimal point}
  out     exp: sys_int_machine_t);     {power of ten exponent value}
  val_param;

var
  abs_val: real;                       {maximum absolute value of range}
  mag: real;                           {magnitude of range}
  imag: sys_int_machine_t;             {magnitude of range}
  sw: sys_int_machine_t;               {size of whole part of real values}

begin
  abs_val := max(abs(rmin), abs(rmax)); {find the absolute value of the range}
  mag := ln(abs_val)/ln(10);           {find the magnitude of the absolute value}

  exp := trunc(mag);
  imag := exp;
  if eng_notation                      {determine the exponent}
    then begin
      if mag < 0.0 then exp := exp - 3;
      exp := (exp div 3)*3;            {make exponent increment by three}
      end
    else begin
      if exp < 0 then exp := exp - 1;
      end
    ;

  if mag < 0
    then sw := imag - exp              {size of whole part for less than 1}
    else sw := imag - exp + 1;         {size of whole part for more than 1}
  if sw >= sd
    then begin
      nd := 0;                         {no decimal places required}
      fw := sw;                        {length of field is whole part}
      end
    else begin
      nd := sd - sw;                   {number decimal places required}
      fw := sd + 1;                    {provide for decimal point}
      end
    ;
  if rmin < 0.0 then fw := fw + 1;     {provide for "-" sign in field}
  end;

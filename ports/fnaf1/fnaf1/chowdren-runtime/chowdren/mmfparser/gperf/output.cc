/* Output routines.
   Copyright (C) 1989-1998, 2000, 2002-2004, 2006-2007, 2009 Free Software Foundation, Inc.
   Written by Douglas C. Schmidt <schmidt@ics.uci.edu>
   and Bruno Haible <bruno@clisp.org>.

   This file is part of GNU GPERF.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* Specification. */
#include "output.h"

#include <stdio.h>
#include <string.h> /* declares strncpy(), strchr() */
#include <ctype.h>  /* declares isprint() */
#include <assert.h> /* defines assert() */
#include <limits.h> /* defines SCHAR_MAX etc. */
#include "options.h"
#include "version.h"


static std::ostringstream stream;

static void print_out(const char * format, ...)
{
  char dest[1024 * 16];
  va_list argptr;
  va_start(argptr, format);
  vsprintf(dest, format, argptr);
  va_end(argptr);
  stream << dest;
}

static void put_char(int c)
{
  stream.put(c);
}

/* The "const " qualifier.  */
static const char *const_always;

/* The "const " qualifier, for read-only arrays.  */
static const char *const_readonly_array;

/* The "const " qualifier, for the array type.  */
static const char *const_for_struct;

/* Returns the smallest unsigned C type capable of holding integers
   up to N.  */

static const char *
smallest_integral_type (int n)
{
  if (n <= UCHAR_MAX) return "unsigned char";
  if (n <= USHRT_MAX) return "unsigned short";
  return "unsigned int";
}

/* Returns the smallest signed C type capable of holding integers
   from MIN to MAX.  */

static const char *
smallest_integral_type (int min, int max)
{
  if (option[ANSIC] | option[CPLUSPLUS])
    if (min >= SCHAR_MIN && max <= SCHAR_MAX) return "signed char";
  if (min >= SHRT_MIN && max <= SHRT_MAX) return "short";
  return "int";
}

/* ------------------------------------------------------------------------- */

/* Constructor.
   Note about the keyword list starting at head:
   - The list is ordered by increasing _hash_value.  This has been achieved
     by Search::sort().
   - Duplicates, i.e. keywords with the same _selchars set, are chained
     through the _duplicate_link pointer.  Only one representative per
     duplicate equivalence class remains on the linear keyword list.
   - Accidental duplicates, i.e. keywords for which the _asso_values[] search
     couldn't achieve different hash values, cannot occur on the linear
     keyword list.  Search::optimize would catch this mistake.
 */
Output::Output (KeywordExt_List *head, const char *struct_decl,
                unsigned int struct_decl_lineno, const char *return_type,
                const char *struct_tag, const char *verbatim_declarations,
                const char *verbatim_declarations_end,
                unsigned int verbatim_declarations_lineno,
                const char *verbatim_code, const char *verbatim_code_end,
                unsigned int verbatim_code_lineno, bool charset_dependent,
                int total_keys, int max_key_len, int min_key_len,
                bool hash_includes_len, const Positions& positions,
                const unsigned int *alpha_inc, int total_duplicates,
                unsigned int alpha_size, const int *asso_values)
  : _head (head), _struct_decl (struct_decl),
    _struct_decl_lineno (struct_decl_lineno), _return_type (return_type),
    _struct_tag (struct_tag),
    _verbatim_declarations (verbatim_declarations),
    _verbatim_declarations_end (verbatim_declarations_end),
    _verbatim_declarations_lineno (verbatim_declarations_lineno),
    _verbatim_code (verbatim_code),
    _verbatim_code_end (verbatim_code_end),
    _verbatim_code_lineno (verbatim_code_lineno),
    _charset_dependent (charset_dependent),
    _total_keys (total_keys),
    _max_key_len (max_key_len), _min_key_len (min_key_len),
    _hash_includes_len (hash_includes_len),
    _key_positions (positions), _alpha_inc (alpha_inc),
    _total_duplicates (total_duplicates), _alpha_size (alpha_size),
    _asso_values (asso_values)
{
  stream.str("");
  stream.clear();
}

/* ------------------------------------------------------------------------- */

/* Computes the minimum and maximum hash values, and stores them
   in _min_hash_value and _max_hash_value.  */

void
Output::compute_min_max ()
{
  /* Since the list is already sorted by hash value all we need to do is
     to look at the first and the last element of the list.  */

  _min_hash_value = _head->first()->_hash_value;

  KeywordExt_List *temp;
  for (temp = _head; temp->rest(); temp = temp->rest())
    ;
  _max_hash_value = temp->first()->_hash_value;
}

/* ------------------------------------------------------------------------- */

/* Returns the number of different hash values.  */

int
Output::num_hash_values () const
{
  /* Since the list is already sorted by hash value and doesn't contain
     duplicates, we can simply count the number of keywords on the list.  */
  int count = 0;
  for (KeywordExt_List *temp = _head; temp; temp = temp->rest())
    count++;
  return count;
}

/* -------------------- Output_Constants and subclasses -------------------- */

/* This class outputs an enumeration defining some constants.  */

struct Output_Constants
{
  virtual void          output_start () = 0;
  virtual void          output_item (const char *name, int value) = 0;
  virtual void          output_end () = 0;
                        Output_Constants () {}
  virtual               ~Output_Constants () {}
};

/* This class outputs an enumeration in #define syntax.  */

struct Output_Defines : public Output_Constants
{
  virtual void          output_start ();
  virtual void          output_item (const char *name, int value);
  virtual void          output_end ();
                        Output_Defines () {}
  virtual               ~Output_Defines () {}
};

void Output_Defines::output_start ()
{
  print_out ("\n");
}

void Output_Defines::output_item (const char *name, int value)
{
  print_out ("#define %s %d\n", name, value);
}

void Output_Defines::output_end ()
{
}

/* This class outputs an enumeration using 'enum'.  */

struct Output_Enum : public Output_Constants
{
  virtual void          output_start ();
  virtual void          output_item (const char *name, int value);
  virtual void          output_end ();
                        Output_Enum (const char *indent)
                          : _indentation (indent) {}
  virtual               ~Output_Enum () {}
private:
  const char *_indentation;
  bool _pending_comma;
};

void Output_Enum::output_start ()
{
  print_out ("%senum\n"
          "%s  {\n",
          _indentation, _indentation);
  _pending_comma = false;
}

void Output_Enum::output_item (const char *name, int value)
{
  if (_pending_comma)
    print_out (",\n");
  print_out ("%s    %s = %d", _indentation, name, value);
  _pending_comma = true;
}

void Output_Enum::output_end ()
{
  if (_pending_comma)
    print_out ("\n");
  print_out ("%s  };\n\n", _indentation);
}

/* Outputs the maximum and minimum hash values etc.  */

void
Output::output_constants (struct Output_Constants& style) const
{
  // style.output_start ();
  // style.output_item ("TOTAL_KEYWORDS", _total_keys);
  // style.output_item ("MIN_WORD_LENGTH", _min_key_len);
  // style.output_item ("MAX_WORD_LENGTH", _max_key_len);
  // style.output_item ("MIN_HASH_VALUE", _min_hash_value);
  // style.output_item ("MAX_HASH_VALUE", _max_hash_value);
  // style.output_end ();
}

/* ------------------------------------------------------------------------- */

/* We use a downcase table because when called repeatedly, the code
       gperf_downcase[c]
   is faster than
       if (c >= 'A' && c <= 'Z')
         c += 'a' - 'A';
 */
#define USE_DOWNCASE_TABLE 1

#if USE_DOWNCASE_TABLE

/* Output gperf's ASCII-downcase table.  */

static void
output_upperlower_table ()
{
  unsigned int c;

  print_out ("#ifndef GPERF_DOWNCASE\n"
          "#define GPERF_DOWNCASE 1\n"
          "static unsigned char gperf_downcase[256] =\n"
          "  {");
  for (c = 0; c < 256; c++)
    {
      if ((c % 15) == 0)
        print_out ("\n   ");
      print_out (" %3d", c >= 'A' && c <= 'Z' ? c + 'a' - 'A' : c);
      if (c < 255)
        print_out (",");
    }
  print_out ("\n"
          "  };\n"
          "#endif\n\n");
}

#endif

/* Output gperf's ASCII-case insensitive strcmp replacement.  */

static void
output_upperlower_strcmp ()
{
  print_out ("#ifndef GPERF_CASE_STRCMP\n"
          "#define GPERF_CASE_STRCMP 1\n"
          "static int\n"
          "gperf_case_strcmp ");
  print_out (option[KRC] ?
               "(s1, s2)\n"
          "     register char *s1;\n"
          "     register char *s2;\n" :
          option[C] ?
               "(s1, s2)\n"
          "     register const char *s1;\n"
          "     register const char *s2;\n" :
          option[ANSIC] | option[CPLUSPLUS] ?
               "(register const char *s1, register const char *s2)\n" :
          "");
  #if USE_DOWNCASE_TABLE
  print_out ("{\n"
          "  for (;;)\n"
          "    {\n"
          "      unsigned char c1 = gperf_downcase[(unsigned char)*s1++];\n"
          "      unsigned char c2 = gperf_downcase[(unsigned char)*s2++];\n"
          "      if (c1 != 0 && c1 == c2)\n"
          "        continue;\n"
          "      return (int)c1 - (int)c2;\n"
          "    }\n"
          "}\n");
  #else
  print_out ("{\n"
          "  for (;;)\n"
          "    {\n"
          "      unsigned char c1 = *s1++;\n"
          "      unsigned char c2 = *s2++;\n"
          "      if (c1 >= 'A' && c1 <= 'Z')\n"
          "        c1 += 'a' - 'A';\n"
          "      if (c2 >= 'A' && c2 <= 'Z')\n"
          "        c2 += 'a' - 'A';\n"
          "      if (c1 != 0 && c1 == c2)\n"
          "        continue;\n"
          "      return (int)c1 - (int)c2;\n"
          "    }\n"
          "}\n");
  #endif
  print_out ("#endif\n\n");
}

/* Output gperf's ASCII-case insensitive strncmp replacement.  */

static void
output_upperlower_strncmp ()
{
  print_out ("#ifndef GPERF_CASE_STRNCMP\n"
          "#define GPERF_CASE_STRNCMP 1\n"
          "static int\n"
          "gperf_case_strncmp ");
  print_out (option[KRC] ?
               "(s1, s2, n)\n"
          "     register char *s1;\n"
          "     register char *s2;\n"
          "     register unsigned int n;\n" :
          option[C] ?
               "(s1, s2, n)\n"
          "     register const char *s1;\n"
          "     register const char *s2;\n"
          "     register unsigned int n;\n" :
          option[ANSIC] | option[CPLUSPLUS] ?
               "(register const char *s1, register const char *s2, register unsigned int n)\n" :
          "");
  #if USE_DOWNCASE_TABLE
  print_out ("{\n"
          "  for (; n > 0;)\n"
          "    {\n"
          "      unsigned char c1 = gperf_downcase[(unsigned char)*s1++];\n"
          "      unsigned char c2 = gperf_downcase[(unsigned char)*s2++];\n"
          "      if (c1 != 0 && c1 == c2)\n"
          "        {\n"
          "          n--;\n"
          "          continue;\n"
          "        }\n"
          "      return (int)c1 - (int)c2;\n"
          "    }\n"
          "  return 0;\n"
          "}\n");
  #else
  print_out ("{\n"
          "  for (; n > 0;)\n"
          "    {\n"
          "      unsigned char c1 = *s1++;\n"
          "      unsigned char c2 = *s2++;\n"
          "      if (c1 >= 'A' && c1 <= 'Z')\n"
          "        c1 += 'a' - 'A';\n"
          "      if (c2 >= 'A' && c2 <= 'Z')\n"
          "        c2 += 'a' - 'A';\n"
          "      if (c1 != 0 && c1 == c2)\n"
          "        {\n"
          "          n--;\n"
          "          continue;\n"
          "        }\n"
          "      return (int)c1 - (int)c2;\n"
          "    }\n"
          "  return 0;\n"
          "}\n");
  #endif
  print_out ("#endif\n\n");
}

/* Output gperf's ASCII-case insensitive memcmp replacement.  */

static void
output_upperlower_memcmp ()
{
  print_out ("#ifndef GPERF_CASE_MEMCMP\n"
          "#define GPERF_CASE_MEMCMP 1\n"
          "static int\n"
          "gperf_case_memcmp ");
  print_out (option[KRC] ?
               "(s1, s2, n)\n"
          "     register char *s1;\n"
          "     register char *s2;\n"
          "     register unsigned int n;\n" :
          option[C] ?
               "(s1, s2, n)\n"
          "     register const char *s1;\n"
          "     register const char *s2;\n"
          "     register unsigned int n;\n" :
          option[ANSIC] | option[CPLUSPLUS] ?
               "(register const char *s1, register const char *s2, register unsigned int n)\n" :
          "");
  #if USE_DOWNCASE_TABLE
  print_out ("{\n"
          "  for (; n > 0;)\n"
          "    {\n"
          "      unsigned char c1 = gperf_downcase[(unsigned char)*s1++];\n"
          "      unsigned char c2 = gperf_downcase[(unsigned char)*s2++];\n"
          "      if (c1 == c2)\n"
          "        {\n"
          "          n--;\n"
          "          continue;\n"
          "        }\n"
          "      return (int)c1 - (int)c2;\n"
          "    }\n"
          "  return 0;\n"
          "}\n");
  #else
  print_out ("{\n"
          "  for (; n > 0;)\n"
          "    {\n"
          "      unsigned char c1 = *s1++;\n"
          "      unsigned char c2 = *s2++;\n"
          "      if (c1 >= 'A' && c1 <= 'Z')\n"
          "        c1 += 'a' - 'A';\n"
          "      if (c2 >= 'A' && c2 <= 'Z')\n"
          "        c2 += 'a' - 'A';\n"
          "      if (c1 == c2)\n"
          "        {\n"
          "          n--;\n"
          "          continue;\n"
          "        }\n"
          "      return (int)c1 - (int)c2;\n"
          "    }\n"
          "  return 0;\n"
          "}\n");
  #endif
  print_out ("#endif\n\n");
}

/* ------------------------------------------------------------------------- */

/* Outputs a keyword, as a string: enclosed in double quotes, escaping
   backslashes, double quote and unprintable characters.  */

static void
output_string (const char *key, int len)
{
  put_char ('"');
  for (; len > 0; len--)
    {
      unsigned char c = static_cast<unsigned char>(*key++);
      if (isprint (c))
        {
          if (c == '"' || c == '\\')
            put_char ('\\');
          put_char (c);
        }
      else
        {
          /* Use octal escapes, not hexadecimal escapes, because some old
             C compilers didn't understand hexadecimal escapes, and because
             hexadecimal escapes are not limited to 2 digits, thus needing
             special care if the following character happens to be a digit.  */
          put_char ('\\');
          put_char ('0' + ((c >> 6) & 7));
          put_char ('0' + ((c >> 3) & 7));
          put_char ('0' + (c & 7));
        }
    }
  put_char ('"');
}

/* ------------------------------------------------------------------------- */

/* Outputs a #line directive, referring to the given line number.  */

static void
output_line_directive (unsigned int lineno)
{
  const char *file_name = option.get_input_file_name ();
  if (file_name != NULL)
    {
      print_out ("#line %u ", lineno);
      output_string (file_name, strlen (file_name));
      print_out ("\n");
    }
}

/* ------------------------------------------------------------------------- */

/* Outputs a type and a const specifier (i.e. "const " or "").
   The output is terminated with a space.  */

static void
output_const_type (const char *const_string, const char *type_string)
{
  if (type_string[strlen(type_string)-1] == '*')
    /* For pointer types, put the 'const' after the type.  */
    print_out ("%s %s", type_string, const_string);
  else
    /* For scalar or struct types, put the 'const' before the type.  */
    print_out ("%s%s ", const_string, type_string);
}

/* ----------------------- Output_Expr and subclasses ----------------------- */

/* This class outputs a general expression.  */

struct Output_Expr
{
  virtual void          output_expr () const = 0;
                        Output_Expr () {}
  virtual               ~Output_Expr () {}
};

/* This class outputs an expression formed by a single string.  */

struct Output_Expr1 : public Output_Expr
{
  virtual void          output_expr () const;
                        Output_Expr1 (const char *piece1) : _p1 (piece1) {}
  virtual               ~Output_Expr1 () {}
private:
  const char *_p1;
};

void Output_Expr1::output_expr () const
{
  print_out ("%s", _p1);
}

#if 0 /* unused */

/* This class outputs an expression formed by the concatenation of two
   strings.  */

struct Output_Expr2 : public Output_Expr
{
  virtual void          output_expr () const;
                        Output_Expr2 (const char *piece1, const char *piece2)
                          : _p1 (piece1), _p2 (piece2) {}
  virtual               ~Output_Expr2 () {}
private:
  const char *_p1;
  const char *_p2;
};

void Output_Expr2::output_expr () const
{
  print_out ("%s%s", _p1, _p2);
}

#endif

/* --------------------- Output_Compare and subclasses --------------------- */

/* This class outputs a comparison expression.  */

struct Output_Compare
{
  /* Outputs the comparison expression.
     expr1 outputs a simple expression of type 'const char *' referring to
     the string being looked up.  expr2 outputs a simple expression of type
     'const char *' referring to the constant string stored in the gperf
     generated hash table.  */
  virtual void          output_comparison (const Output_Expr& expr1,
                                           const Output_Expr& expr2) const = 0;
  /* Outputs the comparison expression for the first byte.
     Returns true if the this comparison is complete.  */
  bool                  output_firstchar_comparison (const Output_Expr& expr1,
                                                     const Output_Expr& expr2) const;
                        Output_Compare () {}
  virtual               ~Output_Compare () {}
};

bool Output_Compare::output_firstchar_comparison (const Output_Expr& expr1,
                                                  const Output_Expr& expr2) const
{
  /* First, we emit a comparison of the first byte of the two strings.
     This catches most cases where the string being looked up is not in the
     hash table but happens to have the same hash code as an element of the
     hash table.  */
  if (option[UPPERLOWER])
    {
      /* Incomplete comparison, just for speedup.  */
      print_out ("(((unsigned char)*");
      expr1.output_expr ();
      print_out (" ^ (unsigned char)*");
      expr2.output_expr ();
      print_out (") & ~32) == 0");
      return false;
    }
  else
    {
      /* Complete comparison.  */
      print_out ("*");
      expr1.output_expr ();
      print_out (" == *");
      expr2.output_expr ();
      return true;
    }
}

/* This class outputs a comparison using strcmp.  */

struct Output_Compare_Strcmp : public Output_Compare
{
  virtual void          output_comparison (const Output_Expr& expr1,
                                           const Output_Expr& expr2) const;
                        Output_Compare_Strcmp () {}
  virtual               ~Output_Compare_Strcmp () {}
};

void Output_Compare_Strcmp::output_comparison (const Output_Expr& expr1,
                                               const Output_Expr& expr2) const
{
  bool firstchar_done = output_firstchar_comparison (expr1, expr2);
  print_out (" && !");
  if (option[UPPERLOWER])
    print_out ("gperf_case_");
  print_out ("strcmp (");
  if (firstchar_done)
    {
      expr1.output_expr ();
      print_out (" + 1, ");
      expr2.output_expr ();
      print_out (" + 1");
    }
  else
    {
      expr1.output_expr ();
      print_out (", ");
      expr2.output_expr ();
    }
  print_out (")");
}

/* This class outputs a comparison using strncmp.
   Note that the length of expr1 will be available through the local variable
   'len'.  */

struct Output_Compare_Strncmp : public Output_Compare
{
  virtual void          output_comparison (const Output_Expr& expr1,
                                           const Output_Expr& expr2) const;
                        Output_Compare_Strncmp () {}
  virtual               ~Output_Compare_Strncmp () {}
};

void Output_Compare_Strncmp::output_comparison (const Output_Expr& expr1,
                                                const Output_Expr& expr2) const
{
  bool firstchar_done = output_firstchar_comparison (expr1, expr2);
  print_out (" && !");
  if (option[UPPERLOWER])
    print_out ("gperf_case_");
  print_out ("strncmp (");
  if (firstchar_done)
    {
      expr1.output_expr ();
      print_out (" + 1, ");
      expr2.output_expr ();
      print_out (" + 1, len - 1");
    }
  else
    {
      expr1.output_expr ();
      print_out (", ");
      expr2.output_expr ();
      print_out (", len");
    }
  print_out (") && ");
  expr2.output_expr ();
  print_out ("[len] == '\\0'");
}

/* This class outputs a comparison using memcmp.
   Note that the length of expr1 (available through the local variable 'len')
   must be verified to be equal to the length of expr2 prior to this
   comparison.  */

struct Output_Compare_Memcmp : public Output_Compare
{
  virtual void          output_comparison (const Output_Expr& expr1,
                                           const Output_Expr& expr2) const;
                        Output_Compare_Memcmp () {}
  virtual               ~Output_Compare_Memcmp () {}
};

void Output_Compare_Memcmp::output_comparison (const Output_Expr& expr1,
                                               const Output_Expr& expr2) const
{
  bool firstchar_done = output_firstchar_comparison (expr1, expr2);
  print_out (" && !");
  if (option[UPPERLOWER])
    print_out ("gperf_case_");
  print_out ("memcmp (");
  if (firstchar_done)
    {
      expr1.output_expr ();
      print_out (" + 1, ");
      expr2.output_expr ();
      print_out (" + 1, len - 1");
    }
  else
    {
      expr1.output_expr ();
      print_out (", ");
      expr2.output_expr ();
      print_out (", len");
    }
  print_out (")");
}

/* ------------------------------------------------------------------------- */

/* Generates a C expression for an asso_values[] reference.  */

void
Output::output_asso_values_ref (int pos) const
{
  print_out ("asso_values[");
  /* Always cast to unsigned char.  This is necessary when the alpha_inc
     is nonzero, and also avoids a gcc warning "subscript has type 'char'".  */
  print_out ("(unsigned char)");
  if (pos == Positions::LASTCHAR)
    print_out ("str[len - 1]");
  else
    {
      print_out ("str[%d]", pos);
      if (_alpha_inc[pos])
        print_out ("+%u", _alpha_inc[pos]);
    }
  print_out ("]");
}

/* Generates C code for the hash function that returns the
   proper encoding for each keyword.
   The hash function has the signature
     unsigned int <hash> (const char *str, unsigned int len).  */

void
Output::output_hash_function () const
{
  /* Output the function's head.  */
  // if (option[CPLUSPLUS])
  //   print_out ("inline ");
  // else if (option[KRC] | option[C] | option[ANSIC])
  //   print_out ("#ifdef __GNUC__\n"
  //           "__inline\n"
  //           "#else\n"
  //           "#ifdef __cplusplus\n"
  //           "inline\n"
  //           "#endif\n"
  //           "#endif\n");
  print_out ("inline ");

  if (/* The function does not use the 'str' argument?  */
      _key_positions.get_size() == 0
      || /* The function uses 'str', but not the 'len' argument?  */
         (!_hash_includes_len
          && _key_positions[0] < _min_key_len
          && _key_positions[_key_positions.get_size() - 1] != Positions::LASTCHAR))
    /* Pacify lint.  */
    // print_out ("/*ARGSUSED*/\n");

  if (option[KRC] | option[C] | option[ANSIC])
    print_out ("static ");
  print_out ("unsigned int\n");
  if (option[CPLUSPLUS])
    print_out ("%s::", option.get_class_name ());
  print_out ("%s ", option.get_hash_name ());
  // print_out (option[KRC] ?
  //                "(str, len)\n"
  //           "     register char *str;\n"
  //           "     register unsigned int len;\n" :
  //         option[C] ?
  //                "(str, len)\n"
  //           "     register const char *str;\n"
  //           "     register unsigned int len;\n" :
  //         option[ANSIC] | option[CPLUSPLUS] ?
  //                "(register const char *str, register unsigned int len)\n" :
  //         "");

  print_out("(register const char *str, register unsigned int len)\n");

  /* Note that when the hash function is called, it has already been verified
     that  min_key_len <= len <= max_key_len.  */

  /* Output the function's body.  */
  print_out ("{\n");

  /* First the asso_values array.  */
  if (_key_positions.get_size() > 0)
    {
      print_out ("  static %s%s asso_values[] =\n"
              "    {",
              const_readonly_array,
              smallest_integral_type (_max_hash_value + 1));

      const int columns = 10;

      /* Calculate maximum number of digits required for MAX_HASH_VALUE.  */
      int field_width = 2;
      for (int trunc = _max_hash_value; (trunc /= 10) > 0;)
        field_width++;

      for (unsigned int count = 0; count < _alpha_size; count++)
        {
          if (count > 0)
            print_out (",");
          if ((count % columns) == 0)
            print_out ("\n     ");
          print_out ("%*d", field_width, _asso_values[count]);
        }

      print_out ("\n"
              "    };\n");
    }

  if (_key_positions.get_size() == 0)
    {
      /* Trivial case: No key positions at all.  */
      print_out ("  return %s;\n",
              _hash_includes_len ? "len" : "0");
    }
  else
    {
      /* Iterate through the key positions.  Remember that Positions::sort()
         has sorted them in decreasing order, with Positions::LASTCHAR coming
         last.  */
      PositionIterator iter = _key_positions.iterator(_max_key_len);
      int key_pos;

      /* Get the highest key position.  */
      key_pos = iter.next ();

      if (key_pos == Positions::LASTCHAR || key_pos < _min_key_len)
        {
          /* We can perform additional optimizations here:
             Write it out as a single expression. Note that the values
             are added as 'int's even though the asso_values array may
             contain 'unsigned char's or 'unsigned short's.  */

          print_out ("  return %s",
                  _hash_includes_len ? "len + " : "");

          if (_key_positions.get_size() == 2
              && _key_positions[0] == 0
              && _key_positions[1] == Positions::LASTCHAR)
            /* Optimize special case of "-k 1,$".  */
            {
              output_asso_values_ref (Positions::LASTCHAR);
              print_out (" + ");
              output_asso_values_ref (0);
            }
          else
            {
              for (; key_pos != Positions::LASTCHAR; )
                {
                  output_asso_values_ref (key_pos);
                  if ((key_pos = iter.next ()) != PositionIterator::EOS)
                    print_out (" + ");
                  else
                    break;
                }

              if (key_pos == Positions::LASTCHAR)
                output_asso_values_ref (Positions::LASTCHAR);
            }

          print_out (";\n");
        }
      else
        {
          /* We've got to use the correct, but brute force, technique.  */
          print_out ("  register int hval = %s;\n\n"
                  "  switch (%s)\n"
                  "    {\n"
                  "      default:\n",
                  _hash_includes_len ? "len" : "0",
                  _hash_includes_len ? "hval" : "len");

          while (key_pos != Positions::LASTCHAR && key_pos >= _max_key_len)
            if ((key_pos = iter.next ()) == PositionIterator::EOS)
              break;

          if (key_pos != PositionIterator::EOS && key_pos != Positions::LASTCHAR)
            {
              int i = key_pos;
              do
                {
                  if (i > key_pos)
                    print_out ("      /*FALLTHROUGH*/\n"); /* Pacify lint.  */
                  for ( ; i > key_pos; i--)
                    print_out ("      case %d:\n", i);

                  print_out ("        hval += ");
                  output_asso_values_ref (key_pos);
                  print_out (";\n");

                  key_pos = iter.next ();
                }
              while (key_pos != PositionIterator::EOS && key_pos != Positions::LASTCHAR);

              if (i >= _min_key_len)
                print_out ("      /*FALLTHROUGH*/\n"); /* Pacify lint.  */
              for ( ; i >= _min_key_len; i--)
                print_out ("      case %d:\n", i);
            }

          print_out ("        break;\n"
                  "    }\n"
                  "  return hval");
          if (key_pos == Positions::LASTCHAR)
            {
              print_out (" + ");
              output_asso_values_ref (Positions::LASTCHAR);
            }
          print_out (";\n");
        }
    }
  print_out ("}\n\n");
}

/* ------------------------------------------------------------------------- */

/* Prints out a table of keyword lengths, for use with the
   comparison code in generated function 'in_word_set'.
   Only called if option[LENTABLE].  */

void
Output::output_keylength_table () const
{
  const int columns = 14;
  const char * const indent = option[GLOBAL] ? "" : "  ";

  print_out ("%sstatic %s%s %s[] =\n"
          "%s  {",
          indent, const_readonly_array,
          smallest_integral_type (_max_key_len),
          option.get_lengthtable_name (),
          indent);

  /* Generate an array of lengths, similar to output_keyword_table.  */
  int index;
  int column;
  KeywordExt_List *temp;

  column = 0;
  for (temp = _head, index = 0; temp; temp = temp->rest())
    {
      KeywordExt *keyword = temp->first();

      /* If generating a switch statement, and there is no user defined type,
         we generate non-duplicates directly in the code.  Only duplicates go
         into the table.  */
      if (option[SWITCH] && !option[TYPE] && !keyword->_duplicate_link)
        continue;

      if (index < keyword->_hash_value && !option[SWITCH] && !option[DUP])
        {
          /* Some blank entries.  */
          for ( ; index < keyword->_hash_value; index++)
            {
              if (index > 0)
                print_out (",");
              if ((column++ % columns) == 0)
                print_out ("\n%s   ", indent);
              print_out ("%3d", 0);
            }
        }

      if (index > 0)
        print_out (",");
      if ((column++ % columns) == 0)
        print_out("\n%s   ", indent);
      print_out ("%3d", keyword->_allchars_length);
      index++;

      /* Deal with duplicates specially.  */
      if (keyword->_duplicate_link) // implies option[DUP]
        for (KeywordExt *links = keyword->_duplicate_link; links; links = links->_duplicate_link)
          {
            print_out (",");
            if ((column++ % columns) == 0)
              print_out("\n%s   ", indent);
            print_out ("%3d", links->_allchars_length);
            index++;
          }
    }

  print_out ("\n%s  };\n", indent);
  if (option[GLOBAL])
    print_out ("\n");
}

/* ------------------------------------------------------------------------- */

/* Prints out the string pool, containing the strings of the keyword table.
   Only called if option[SHAREDLIB].  */

void
Output::output_string_pool () const
{
  const char * const indent = option[TYPE] || option[GLOBAL] ? "" : "  ";
  int index;
  KeywordExt_List *temp;

  print_out ("%sstruct %s_t\n"
          "%s  {\n",
          indent, option.get_stringpool_name (), indent);
  for (temp = _head, index = 0; temp; temp = temp->rest())
    {
      KeywordExt *keyword = temp->first();

      /* If generating a switch statement, and there is no user defined type,
         we generate non-duplicates directly in the code.  Only duplicates go
         into the table.  */
      if (option[SWITCH] && !option[TYPE] && !keyword->_duplicate_link)
        continue;

      if (!option[SWITCH] && !option[DUP])
        index = keyword->_hash_value;

      print_out ("%s    char %s_str%d[sizeof(",
              indent, option.get_stringpool_name (), index);
      output_string (keyword->_allchars, keyword->_allchars_length);
      print_out (")];\n");

      /* Deal with duplicates specially.  */
      if (keyword->_duplicate_link) // implies option[DUP]
        for (KeywordExt *links = keyword->_duplicate_link; links; links = links->_duplicate_link)
          if (!(links->_allchars_length == keyword->_allchars_length
                && memcmp (links->_allchars, keyword->_allchars,
                           keyword->_allchars_length) == 0))
            {
              index++;
              print_out ("%s    char %s_str%d[sizeof(",
                      indent, option.get_stringpool_name (), index);
              output_string (links->_allchars, links->_allchars_length);
              print_out (")];\n");
            }

      index++;
    }
  print_out ("%s  };\n",
          indent);

  print_out ("%sstatic %sstruct %s_t %s_contents =\n"
          "%s  {\n",
          indent, const_readonly_array, option.get_stringpool_name (),
          option.get_stringpool_name (), indent);
  for (temp = _head, index = 0; temp; temp = temp->rest())
    {
      KeywordExt *keyword = temp->first();

      /* If generating a switch statement, and there is no user defined type,
         we generate non-duplicates directly in the code.  Only duplicates go
         into the table.  */
      if (option[SWITCH] && !option[TYPE] && !keyword->_duplicate_link)
        continue;

      if (index > 0)
        print_out (",\n");

      if (!option[SWITCH] && !option[DUP])
        index = keyword->_hash_value;

      print_out ("%s    ",
              indent);
      output_string (keyword->_allchars, keyword->_allchars_length);

      /* Deal with duplicates specially.  */
      if (keyword->_duplicate_link) // implies option[DUP]
        for (KeywordExt *links = keyword->_duplicate_link; links; links = links->_duplicate_link)
          if (!(links->_allchars_length == keyword->_allchars_length
                && memcmp (links->_allchars, keyword->_allchars,
                           keyword->_allchars_length) == 0))
            {
              index++;
              print_out (",\n");
              print_out ("%s    ",
                      indent);
              output_string (links->_allchars, links->_allchars_length);
            }

      index++;
    }
  if (index > 0)
    print_out ("\n");
  print_out ("%s  };\n",
          indent);
  print_out ("%s#define %s ((%schar *) &%s_contents)\n",
          indent, option.get_stringpool_name (), const_always,
          option.get_stringpool_name ());
  if (option[GLOBAL])
    print_out ("\n");
}

/* ------------------------------------------------------------------------- */

static void
output_keyword_entry (KeywordExt *temp, int stringpool_index, const char *indent)
{
  if (option[TYPE])
    output_line_directive (temp->_lineno);
  print_out ("%s    ", indent);
  if (option[TYPE])
    print_out ("{");
  if (option[SHAREDLIB])
    print_out ("(int)(long)&((struct %s_t *)0)->%s_str%d",
            option.get_stringpool_name (), option.get_stringpool_name (),
            stringpool_index);
  else
    output_string (temp->_allchars, temp->_allchars_length);
  if (option[TYPE])
    {
      if (strlen (temp->_rest) > 0)
        print_out (",%s", temp->_rest);
      print_out ("}");
    }
  if (option[DEBUG])
    print_out (" /* hash value = %d, index = %d */",
            temp->_hash_value, temp->_final_index);
}

static void
output_keyword_blank_entries (int count, const char *indent)
{
  int columns;
  if (option[TYPE])
    {
      columns = 58 / (4 + (option[SHAREDLIB] ? 2 : option[NULLSTRINGS] ? 8 : 2)
                        + strlen (option.get_initializer_suffix()));
      if (columns == 0)
        columns = 1;
    }
  else
    {
      columns = (option[SHAREDLIB] ? 9 : option[NULLSTRINGS] ? 4 : 9);
    }
  int column = 0;
  for (int i = 0; i < count; i++)
    {
      if ((column % columns) == 0)
        {
          if (i > 0)
            print_out (",\n");
          print_out ("%s    ", indent);
        }
      else
        {
          if (i > 0)
            print_out (", ");
        }
      if (option[TYPE])
        print_out ("{");
      if (option[SHAREDLIB])
        print_out ("-1");
      else
        {
          if (option[NULLSTRINGS])
            print_out ("(char*)0");
          else
            print_out ("\"\"");
        }
      if (option[TYPE])
        print_out ("%s}", option.get_initializer_suffix());
      column++;
    }
}

/* Prints out the array containing the keywords for the hash function.  */

void
Output::output_keyword_table () const
{
  const char *indent  = option[GLOBAL] ? "" : "  ";
  int index;
  KeywordExt_List *temp;

  print_out ("%sstatic ",
          indent);
  output_const_type (const_readonly_array, _wordlist_eltype);
  print_out ("%s[] =\n"
          "%s  {\n",
          option.get_wordlist_name (),
          indent);

  /* Generate an array of reserved words at appropriate locations.  */

  for (temp = _head, index = 0; temp; temp = temp->rest())
    {
      KeywordExt *keyword = temp->first();

      /* If generating a switch statement, and there is no user defined type,
         we generate non-duplicates directly in the code.  Only duplicates go
         into the table.  */
      if (option[SWITCH] && !option[TYPE] && !keyword->_duplicate_link)
        continue;

      if (index > 0)
        print_out (",\n");

      if (index < keyword->_hash_value && !option[SWITCH] && !option[DUP])
        {
          /* Some blank entries.  */
          output_keyword_blank_entries (keyword->_hash_value - index, indent);
          print_out (",\n");
          index = keyword->_hash_value;
        }

      keyword->_final_index = index;

      output_keyword_entry (keyword, index, indent);

      /* Deal with duplicates specially.  */
      if (keyword->_duplicate_link) // implies option[DUP]
        for (KeywordExt *links = keyword->_duplicate_link; links; links = links->_duplicate_link)
          {
            links->_final_index = ++index;
            print_out (",\n");
            int stringpool_index =
              (links->_allchars_length == keyword->_allchars_length
               && memcmp (links->_allchars, keyword->_allchars,
                          keyword->_allchars_length) == 0
               ? keyword->_final_index
               : links->_final_index);
            output_keyword_entry (links, stringpool_index, indent);
          }

      index++;
    }
  if (index > 0)
    print_out ("\n");

  print_out ("%s  };\n\n", indent);
}

/* ------------------------------------------------------------------------- */

/* Generates the large, sparse table that maps hash values into
   the smaller, contiguous range of the keyword table.  */

void
Output::output_lookup_array () const
{
  if (option[DUP])
    {
      const int DEFAULT_VALUE = -1;

      /* Because of the way output_keyword_table works, every duplicate set is
         stored contiguously in the wordlist array.  */
      struct duplicate_entry
        {
          int hash_value; /* Hash value for this particular duplicate set.  */
          int index;      /* Index into the main keyword storage array.  */
          int count;      /* Number of consecutive duplicates at this index.  */
        };

      duplicate_entry *duplicates = new duplicate_entry[_total_duplicates];
      int *lookup_array = new int[_max_hash_value + 1 + 2*_total_duplicates];
      int lookup_array_size = _max_hash_value + 1;
      duplicate_entry *dup_ptr = &duplicates[0];
      int *lookup_ptr = &lookup_array[_max_hash_value + 1 + 2*_total_duplicates];

      while (lookup_ptr > lookup_array)
        *--lookup_ptr = DEFAULT_VALUE;

      /* Now dup_ptr = &duplicates[0] and lookup_ptr = &lookup_array[0].  */

      for (KeywordExt_List *temp = _head; temp; temp = temp->rest())
        {
          int hash_value = temp->first()->_hash_value;
          lookup_array[hash_value] = temp->first()->_final_index;
          if (option[DEBUG])
            fprintf (stderr, "keyword = %.*s, index = %d\n",
                     temp->first()->_allchars_length, temp->first()->_allchars, temp->first()->_final_index);
          if (temp->first()->_duplicate_link)
            {
              /* Start a duplicate entry.  */
              dup_ptr->hash_value = hash_value;
              dup_ptr->index = temp->first()->_final_index;
              dup_ptr->count = 1;

              for (KeywordExt *ptr = temp->first()->_duplicate_link; ptr; ptr = ptr->_duplicate_link)
                {
                  dup_ptr->count++;
                  if (option[DEBUG])
                    fprintf (stderr,
                             "static linked keyword = %.*s, index = %d\n",
                             ptr->_allchars_length, ptr->_allchars, ptr->_final_index);
                }
              assert (dup_ptr->count >= 2);
              dup_ptr++;
            }
        }

      while (dup_ptr > duplicates)
        {
          dup_ptr--;

          if (option[DEBUG])
            fprintf (stderr,
                     "dup_ptr[%d]: hash_value = %d, index = %d, count = %d\n",
                     dup_ptr - duplicates,
                     dup_ptr->hash_value, dup_ptr->index, dup_ptr->count);

          int i;
          /* Start searching for available space towards the right part
             of the lookup array.  */
          for (i = dup_ptr->hash_value; i < lookup_array_size-1; i++)
            if (lookup_array[i] == DEFAULT_VALUE
                && lookup_array[i + 1] == DEFAULT_VALUE)
              goto found_i;
          /* If we didn't find it to the right look to the left instead...  */
          for (i = dup_ptr->hash_value-1; i >= 0; i--)
            if (lookup_array[i] == DEFAULT_VALUE
                && lookup_array[i + 1] == DEFAULT_VALUE)
              goto found_i;
          /* Append to the end of lookup_array.  */
          i = lookup_array_size;
          lookup_array_size += 2;
        found_i:
          /* Put in an indirection from dup_ptr->_hash_value to i.
             At i and i+1 store dup_ptr->_final_index and dup_ptr->count.  */
          assert (lookup_array[dup_ptr->hash_value] == dup_ptr->index);
          lookup_array[dup_ptr->hash_value] = - 1 - _total_keys - i;
          lookup_array[i] = - _total_keys + dup_ptr->index;
          lookup_array[i + 1] = - dup_ptr->count;
          /* All these three values are <= -2, distinct from DEFAULT_VALUE.  */
        }

      /* The values of the lookup array are now known.  */

      int min = INT_MAX;
      int max = INT_MIN;
      lookup_ptr = lookup_array + lookup_array_size;
      while (lookup_ptr > lookup_array)
        {
          int val = *--lookup_ptr;
          if (min > val)
            min = val;
          if (max < val)
            max = val;
        }

      const char *indent = option[GLOBAL] ? "" : "  ";
      print_out ("%sstatic %s%s lookup[] =\n"
              "%s  {",
              indent, const_readonly_array, smallest_integral_type (min, max),
              indent);

      int field_width;
      /* Calculate maximum number of digits required for MIN..MAX.  */
      {
        field_width = 2;
        for (int trunc = max; (trunc /= 10) > 0;)
          field_width++;
      }
      if (min < 0)
        {
          int neg_field_width = 2;
          for (int trunc = -min; (trunc /= 10) > 0;)
            neg_field_width++;
          neg_field_width++; /* account for the minus sign */
          if (field_width < neg_field_width)
            field_width = neg_field_width;
        }

      const int columns = 42 / field_width;
      int column;

      column = 0;
      for (int i = 0; i < lookup_array_size; i++)
        {
          if (i > 0)
            print_out (",");
          if ((column++ % columns) == 0)
            print_out("\n%s   ", indent);
          print_out ("%*d", field_width, lookup_array[i]);
        }
      print_out ("\n%s  };\n\n", indent);

      delete[] duplicates;
      delete[] lookup_array;
    }
}

/* ------------------------------------------------------------------------- */

/* Generate all pools needed for the lookup function.  */

void
Output::output_lookup_pools () const
{
  if (option[SWITCH])
    {
      if (option[TYPE] || (option[DUP] && _total_duplicates > 0))
        output_string_pool ();
    }
  else
    {
      output_string_pool ();
    }
}

/* Generate all the tables needed for the lookup function.  */

void
Output::output_lookup_tables () const
{
  if (option[SWITCH])
    {
      /* Use the switch in place of lookup table.  */
      if (option[LENTABLE] && (option[DUP] && _total_duplicates > 0))
        output_keylength_table ();
      if (option[TYPE] || (option[DUP] && _total_duplicates > 0))
        output_keyword_table ();
    }
  else
    {
      /* Use the lookup table, in place of switch.  */
      if (option[LENTABLE])
        output_keylength_table ();
      output_keyword_table ();
      output_lookup_array ();
    }
}

/* ------------------------------------------------------------------------- */

/* Output a single switch case (including duplicates).  Advance list.  */

static KeywordExt_List *
output_switch_case (KeywordExt_List *list, int indent, int *jumps_away)
{
  if (option[DEBUG])
    print_out ("%*s/* hash value = %4d, keyword = \"%.*s\" */\n",
            indent, "", list->first()->_hash_value, list->first()->_allchars_length, list->first()->_allchars);

  if (option[DUP] && list->first()->_duplicate_link)
    {
      if (option[LENTABLE])
        print_out ("%*slengthptr = &%s[%d];\n",
                indent, "", option.get_lengthtable_name (), list->first()->_final_index);
      print_out ("%*swordptr = &%s[%d];\n",
              indent, "", option.get_wordlist_name (), list->first()->_final_index);

      int count = 0;
      for (KeywordExt *links = list->first(); links; links = links->_duplicate_link)
        count++;

      print_out ("%*swordendptr = wordptr + %d;\n"
              "%*sgoto multicompare;\n",
              indent, "", count,
              indent, "");
      *jumps_away = 1;
    }
  else
    {
      if (option[LENTABLE])
        {
          print_out ("%*sif (len == %d)\n"
                  "%*s  {\n",
                  indent, "", list->first()->_allchars_length,
                  indent, "");
          indent += 4;
        }
      print_out ("%*sresword = ",
              indent, "");
      if (option[TYPE])
        print_out ("&%s[%d]", option.get_wordlist_name (), list->first()->_final_index);
      else
        output_string (list->first()->_allchars, list->first()->_allchars_length);
      print_out (";\n");
      print_out ("%*sgoto compare;\n",
              indent, "");
      if (option[LENTABLE])
        {
          indent -= 4;
          print_out ("%*s  }\n",
                  indent, "");
        }
      else
        *jumps_away = 1;
    }

  return list->rest();
}

/* Output a total of size cases, grouped into num_switches switch statements,
   where 0 < num_switches <= size.  */

static void
output_switches (KeywordExt_List *list, int num_switches, int size, int min_hash_value, int max_hash_value, int indent)
{
  if (option[DEBUG])
    print_out ("%*s/* know %d <= key <= %d, contains %d cases */\n",
            indent, "", min_hash_value, max_hash_value, size);

  if (num_switches > 1)
    {
      int part1 = num_switches / 2;
      int part2 = num_switches - part1;
      int size1 = static_cast<int>(static_cast<double>(size) / static_cast<double>(num_switches) * static_cast<double>(part1) + 0.5);
      int size2 = size - size1;

      KeywordExt_List *temp = list;
      for (int count = size1; count > 0; count--)
        temp = temp->rest();

      print_out ("%*sif (key < %d)\n"
              "%*s  {\n",
              indent, "", temp->first()->_hash_value,
              indent, "");

      output_switches (list, part1, size1, min_hash_value, temp->first()->_hash_value-1, indent+4);

      print_out ("%*s  }\n"
              "%*selse\n"
              "%*s  {\n",
              indent, "", indent, "", indent, "");

      output_switches (temp, part2, size2, temp->first()->_hash_value, max_hash_value, indent+4);

      print_out ("%*s  }\n",
              indent, "");
    }
  else
    {
      /* Output a single switch.  */
      int lowest_case_value = list->first()->_hash_value;
      if (size == 1)
        {
          int jumps_away = 0;
          assert (min_hash_value <= lowest_case_value);
          assert (lowest_case_value <= max_hash_value);
          if (min_hash_value == max_hash_value)
            output_switch_case (list, indent, &jumps_away);
          else
            {
              print_out ("%*sif (key == %d)\n"
                      "%*s  {\n",
                      indent, "", lowest_case_value,
                      indent, "");
              output_switch_case (list, indent+4, &jumps_away);
              print_out ("%*s  }\n",
                      indent, "");
            }
        }
      else
        {
          if (lowest_case_value == 0)
            print_out ("%*sswitch (key)\n", indent, "");
          else
            print_out ("%*sswitch (key - %d)\n", indent, "", lowest_case_value);
          print_out ("%*s  {\n",
                  indent, "");
          for (; size > 0; size--)
            {
              int jumps_away = 0;
              print_out ("%*s    case %d:\n",
                      indent, "", list->first()->_hash_value - lowest_case_value);
              list = output_switch_case (list, indent+6, &jumps_away);
              if (!jumps_away)
                print_out ("%*s      break;\n",
                        indent, "");
            }
          print_out ("%*s  }\n",
                  indent, "");
        }
    }
}

/* Generates C code to perform the keyword lookup.  */

void
Output::output_lookup_function_body (const Output_Compare& comparison) const
{
  print_out ("  if (len <= MAX_WORD_LENGTH && len >= MIN_WORD_LENGTH)\n"
          "    {\n"
          "      register int key = %s (str, len);\n\n",
          option.get_hash_name ());

  if (option[SWITCH])
    {
      int switch_size = num_hash_values ();
      int num_switches = option.get_total_switches ();
      if (num_switches > switch_size)
        num_switches = switch_size;

      print_out ("      if (key <= MAX_HASH_VALUE && key >= MIN_HASH_VALUE)\n"
              "        {\n");
      if (option[DUP] && _total_duplicates > 0)
        {
          if (option[LENTABLE])
            print_out ("          register %s%s *lengthptr;\n",
                    const_always, smallest_integral_type (_max_key_len));
          print_out ("          register ");
          output_const_type (const_readonly_array, _wordlist_eltype);
          print_out ("*wordptr;\n");
          print_out ("          register ");
          output_const_type (const_readonly_array, _wordlist_eltype);
          print_out ("*wordendptr;\n");
        }
      if (option[TYPE])
        {
          print_out ("          register ");
          output_const_type (const_readonly_array, _struct_tag);
          print_out ("*resword;\n\n");
        }
      else
        print_out ("          register %sresword;\n\n",
                _struct_tag);

      output_switches (_head, num_switches, switch_size, _min_hash_value, _max_hash_value, 10);

      print_out ("          return 0;\n");
      if (option[DUP] && _total_duplicates > 0)
        {
          int indent = 8;
          print_out ("%*smulticompare:\n"
                  "%*s  while (wordptr < wordendptr)\n"
                  "%*s    {\n",
                  indent, "", indent, "", indent, "");
          if (option[LENTABLE])
            {
              print_out ("%*s      if (len == *lengthptr)\n"
                      "%*s        {\n",
                      indent, "", indent, "");
              indent += 4;
            }
          print_out ("%*s      register %schar *s = ",
                  indent, "", const_always);
          if (option[TYPE])
            print_out ("wordptr->%s", option.get_slot_name ());
          else
            print_out ("*wordptr");
          if (option[SHAREDLIB])
            print_out (" + %s",
                    option.get_stringpool_name ());
          print_out (";\n\n"
                  "%*s      if (",
                  indent, "");
          comparison.output_comparison (Output_Expr1 ("str"), Output_Expr1 ("s"));
          print_out (")\n"
                  "%*s        return %s;\n",
                  indent, "",
                  option[TYPE] ? "wordptr" : "s");
          if (option[LENTABLE])
            {
              indent -= 4;
              print_out ("%*s        }\n",
                      indent, "");
            }
          if (option[LENTABLE])
            print_out ("%*s      lengthptr++;\n",
                    indent, "");
          print_out ("%*s      wordptr++;\n"
                  "%*s    }\n"
                  "%*s  return 0;\n",
                  indent, "", indent, "", indent, "");
        }
      print_out ("        compare:\n");
      if (option[TYPE])
        {
          print_out ("          {\n"
                  "            register %schar *s = resword->%s",
                  const_always, option.get_slot_name ());
          if (option[SHAREDLIB])
            print_out (" + %s",
                    option.get_stringpool_name ());
          print_out (";\n\n"
                  "            if (");
          comparison.output_comparison (Output_Expr1 ("str"), Output_Expr1 ("s"));
          print_out (")\n"
                  "              return resword;\n"
                  "          }\n");
        }
      else
        {
          print_out ("          if (");
          comparison.output_comparison (Output_Expr1 ("str"), Output_Expr1 ("resword"));
          print_out (")\n"
                  "            return resword;\n");
        }
      print_out ("        }\n");
    }
  else
    {
      print_out ("      if (key <= MAX_HASH_VALUE && key >= 0)\n");

      if (option[DUP])
        {
          int indent = 8;
          print_out ("%*s{\n"
                  "%*s  register int index = lookup[key];\n\n"
                  "%*s  if (index >= 0)\n",
                  indent, "", indent, "", indent, "");
          if (option[LENTABLE])
            {
              print_out ("%*s    {\n"
                      "%*s      if (len == %s[index])\n",
                      indent, "", indent, "", option.get_lengthtable_name ());
              indent += 4;
            }
          print_out ("%*s    {\n"
                  "%*s      register %schar *s = %s[index]",
                  indent, "",
                  indent, "", const_always, option.get_wordlist_name ());
          if (option[TYPE])
            print_out (".%s", option.get_slot_name ());
          if (option[SHAREDLIB])
            print_out (" + %s",
                    option.get_stringpool_name ());
          print_out (";\n\n"
                  "%*s      if (",
                  indent, "");
          comparison.output_comparison (Output_Expr1 ("str"), Output_Expr1 ("s"));
          print_out (")\n"
                  "%*s        return ",
                  indent, "");
          if (option[TYPE])
            print_out ("&%s[index]", option.get_wordlist_name ());
          else
            print_out ("s");
          print_out (";\n"
                  "%*s    }\n",
                  indent, "");
          if (option[LENTABLE])
            {
              indent -= 4;
              print_out ("%*s    }\n", indent, "");
            }
          if (_total_duplicates > 0)
            {
              print_out ("%*s  else if (index < -TOTAL_KEYWORDS)\n"
                      "%*s    {\n"
                      "%*s      register int offset = - 1 - TOTAL_KEYWORDS - index;\n",
                      indent, "", indent, "", indent, "");
              if (option[LENTABLE])
                print_out ("%*s      register %s%s *lengthptr = &%s[TOTAL_KEYWORDS + lookup[offset]];\n",
                        indent, "", const_always, smallest_integral_type (_max_key_len),
                        option.get_lengthtable_name ());
              print_out ("%*s      register ",
                      indent, "");
              output_const_type (const_readonly_array, _wordlist_eltype);
              print_out ("*wordptr = &%s[TOTAL_KEYWORDS + lookup[offset]];\n",
                      option.get_wordlist_name ());
              print_out ("%*s      register ",
                      indent, "");
              output_const_type (const_readonly_array, _wordlist_eltype);
              print_out ("*wordendptr = wordptr + -lookup[offset + 1];\n\n");
              print_out ("%*s      while (wordptr < wordendptr)\n"
                      "%*s        {\n",
                      indent, "", indent, "");
              if (option[LENTABLE])
                {
                  print_out ("%*s          if (len == *lengthptr)\n"
                          "%*s            {\n",
                          indent, "", indent, "");
                  indent += 4;
                }
              print_out ("%*s          register %schar *s = ",
                      indent, "", const_always);
              if (option[TYPE])
                print_out ("wordptr->%s", option.get_slot_name ());
              else
                print_out ("*wordptr");
              if (option[SHAREDLIB])
                print_out (" + %s",
                        option.get_stringpool_name ());
              print_out (";\n\n"
                      "%*s          if (",
                      indent, "");
              comparison.output_comparison (Output_Expr1 ("str"), Output_Expr1 ("s"));
              print_out (")\n"
                      "%*s            return %s;\n",
                      indent, "",
                      option[TYPE] ? "wordptr" : "s");
              if (option[LENTABLE])
                {
                  indent -= 4;
                  print_out ("%*s            }\n",
                          indent, "");
                }
              if (option[LENTABLE])
                print_out ("%*s          lengthptr++;\n",
                        indent, "");
              print_out ("%*s          wordptr++;\n"
                      "%*s        }\n"
                      "%*s    }\n",
                      indent, "", indent, "", indent, "");
            }
          print_out ("%*s}\n",
                  indent, "");
        }
      else
        {
          int indent = 8;
          if (option[LENTABLE])
            {
              print_out ("%*sif (len == %s[key])\n",
                      indent, "", option.get_lengthtable_name ());
              indent += 2;
            }

          if (option[SHAREDLIB])
            {
              if (!option[LENTABLE])
                {
                  print_out ("%*s{\n"
                          "%*s  register int o = %s[key]",
                          indent, "",
                          indent, "", option.get_wordlist_name ());
                  if (option[TYPE])
                    print_out (".%s", option.get_slot_name ());
                  print_out (";\n"
                          "%*s  if (o >= 0)\n"
                          "%*s    {\n",
                          indent, "",
                          indent, "");
                  indent += 4;
                  print_out ("%*s  register %schar *s = o",
                          indent, "", const_always);
                }
              else
                {
                  /* No need for the (o >= 0) test, because the
                     (len == lengthtable[key]) test already guarantees that
                     key points to nonempty table entry.  */
                  print_out ("%*s{\n"
                          "%*s  register %schar *s = %s[key]",
                          indent, "",
                          indent, "", const_always,
                          option.get_wordlist_name ());
                  if (option[TYPE])
                    print_out (".%s", option.get_slot_name ());
                }
              print_out (" + %s",
                      option.get_stringpool_name ());
            }
          else
            {
              print_out ("%*s{\n"
                      "%*s  register %schar *s = %s[key]",
                      indent, "",
                      indent, "", const_always, option.get_wordlist_name ());
              if (option[TYPE])
                print_out (".%s", option.get_slot_name ());
            }

          print_out (";\n\n"
                  "%*s  if (",
                  indent, "");
          if (!option[SHAREDLIB] && option[NULLSTRINGS])
            print_out ("s && ");
          comparison.output_comparison (Output_Expr1 ("str"), Output_Expr1 ("s"));
          print_out (")\n"
                  "%*s    return ",
                  indent, "");
          if (option[TYPE])
            print_out ("&%s[key]", option.get_wordlist_name ());
          else
            print_out ("s");
          print_out (";\n");
          if (option[SHAREDLIB] && !option[LENTABLE])
            {
              indent -= 4;
              print_out ("%*s    }\n",
                      indent, "");
            }
          print_out ("%*s}\n",
                  indent, "");
        }
    }
  print_out ("    }\n"
          "  return 0;\n");
}

/* Generates C code for the lookup function.  */

void
Output::output_lookup_function () const
{
  /* Output the function's head.  */
  if (option[KRC] | option[C] | option[ANSIC])
    /* GCC 4.3 and above with -std=c99 or -std=gnu99 implements ISO C99
       inline semantics, unless -fgnu89-inline is used.  It defines a macro
       __GNUC_STDC_INLINE__ to indicate this situation or a macro
       __GNUC_GNU_INLINE__ to indicate the opposite situation.
       GCC 4.2 with -std=c99 or -std=gnu99 implements the GNU C inline
       semantics but warns, unless -fgnu89-inline is used:
         warning: C99 inline functions are not supported; using GNU89
         warning: to disable this warning use -fgnu89-inline or the gnu_inline function attribute
       It defines a macro __GNUC_GNU_INLINE__ to indicate this situation.  */
    print_out ("#ifdef __GNUC__\n"
            "__inline\n"
            "#if defined __GNUC_STDC_INLINE__ || defined __GNUC_GNU_INLINE__\n"
            "__attribute__ ((__gnu_inline__))\n"
            "#endif\n"
            "#endif\n");

  print_out ("%s%s\n",
          const_for_struct, _return_type);
  if (option[CPLUSPLUS])
    print_out ("%s::", option.get_class_name ());
  print_out ("%s ", option.get_function_name ());
  print_out (option[KRC] ?
                 "(str, len)\n"
            "     register char *str;\n"
            "     register unsigned int len;\n" :
          option[C] ?
                 "(str, len)\n"
            "     register const char *str;\n"
            "     register unsigned int len;\n" :
          option[ANSIC] | option[CPLUSPLUS] ?
                 "(register const char *str, register unsigned int len)\n" :
          "");

  /* Output the function's body.  */
  print_out ("{\n");

  if (option[ENUM] && !option[GLOBAL])
    {
      Output_Enum style ("  ");
      output_constants (style);
    }

  if (option[SHAREDLIB] && !(option[GLOBAL] || option[TYPE]))
    output_lookup_pools ();
  if (!option[GLOBAL])
    output_lookup_tables ();

  if (option[LENTABLE])
    output_lookup_function_body (Output_Compare_Memcmp ());
  else
    {
      if (option[COMP])
        output_lookup_function_body (Output_Compare_Strncmp ());
      else
        output_lookup_function_body (Output_Compare_Strcmp ());
    }

  print_out ("}\n");
}

/* ------------------------------------------------------------------------- */

/* Generates the hash function and the key word recognizer function
   based upon the user's Options.  */

void
Output::output ()
{
  compute_min_max ();

  if (option[C] | option[ANSIC] | option[CPLUSPLUS])
    {
      const_always = "const ";
      const_readonly_array = (option[CONST] ? "const " : "");
      const_for_struct = ((option[CONST] && option[TYPE]) ? "const " : "");
    }
  else
    {
      const_always = "";
      const_readonly_array = "";
      const_for_struct = "";
    }

  if (!option[TYPE])
    {
      _return_type = (const_always[0] ? "const char *" : "char *");
      _struct_tag = (const_always[0] ? "const char *" : "char *");
    }

  _wordlist_eltype = (option[SHAREDLIB] && !option[TYPE] ? "int" : _struct_tag);

  // print_out ("/* ");
  // if (option[KRC])
  //   print_out ("KR-C");
  // else if (option[C])
  //   print_out ("C");
  // else if (option[ANSIC])
  //   print_out ("ANSI-C");
  // else if (option[CPLUSPLUS])
  //   print_out ("C++");
  // print_out (" code produced by gperf version %s */\n", version_string);
  // option.print_options ();
  // print_out ("\n");
  // if (!option[POSITIONS])
  //   {
  //     print_out ("/* Computed positions: -k'");
  //     _key_positions.print();
  //     print_out ("' */\n");
  //   }
  // print_out ("\n");

  if (_charset_dependent
      && (_key_positions.get_size() > 0 || option[UPPERLOWER]))
    {
      /* The generated tables assume that the execution character set is
         based on ISO-646, not EBCDIC.  */
      print_out ("#if !((' ' == 32) && ('!' == 33) && ('\"' == 34) && ('#' == 35) \\\n"
              "      && ('%%' == 37) && ('&' == 38) && ('\\'' == 39) && ('(' == 40) \\\n"
              "      && (')' == 41) && ('*' == 42) && ('+' == 43) && (',' == 44) \\\n"
              "      && ('-' == 45) && ('.' == 46) && ('/' == 47) && ('0' == 48) \\\n"
              "      && ('1' == 49) && ('2' == 50) && ('3' == 51) && ('4' == 52) \\\n"
              "      && ('5' == 53) && ('6' == 54) && ('7' == 55) && ('8' == 56) \\\n"
              "      && ('9' == 57) && (':' == 58) && (';' == 59) && ('<' == 60) \\\n"
              "      && ('=' == 61) && ('>' == 62) && ('?' == 63) && ('A' == 65) \\\n"
              "      && ('B' == 66) && ('C' == 67) && ('D' == 68) && ('E' == 69) \\\n"
              "      && ('F' == 70) && ('G' == 71) && ('H' == 72) && ('I' == 73) \\\n"
              "      && ('J' == 74) && ('K' == 75) && ('L' == 76) && ('M' == 77) \\\n"
              "      && ('N' == 78) && ('O' == 79) && ('P' == 80) && ('Q' == 81) \\\n"
              "      && ('R' == 82) && ('S' == 83) && ('T' == 84) && ('U' == 85) \\\n"
              "      && ('V' == 86) && ('W' == 87) && ('X' == 88) && ('Y' == 89) \\\n"
              "      && ('Z' == 90) && ('[' == 91) && ('\\\\' == 92) && (']' == 93) \\\n"
              "      && ('^' == 94) && ('_' == 95) && ('a' == 97) && ('b' == 98) \\\n"
              "      && ('c' == 99) && ('d' == 100) && ('e' == 101) && ('f' == 102) \\\n"
              "      && ('g' == 103) && ('h' == 104) && ('i' == 105) && ('j' == 106) \\\n"
              "      && ('k' == 107) && ('l' == 108) && ('m' == 109) && ('n' == 110) \\\n"
              "      && ('o' == 111) && ('p' == 112) && ('q' == 113) && ('r' == 114) \\\n"
              "      && ('s' == 115) && ('t' == 116) && ('u' == 117) && ('v' == 118) \\\n"
              "      && ('w' == 119) && ('x' == 120) && ('y' == 121) && ('z' == 122) \\\n"
              "      && ('{' == 123) && ('|' == 124) && ('}' == 125) && ('~' == 126))\n"
              "/* The character set is not based on ISO-646.  */\n");
      print_out ("%s \"gperf generated tables don't work with this execution character set. Please report a bug to <bug-gnu-gperf@gnu.org>.\"\n", option[KRC] || option[C] ? "error" : "#error");
      print_out ("#endif\n\n");
    }

  // if (_verbatim_declarations < _verbatim_declarations_end)
  //   {
  //     output_line_directive (_verbatim_declarations_lineno);
  //     fwrite (_verbatim_declarations, 1,
  //             _verbatim_declarations_end - _verbatim_declarations, stdout);
  //   }

  if (option[TYPE] && !option[NOTYPE]) /* Output type declaration now, reference it later on.... */
    {
      output_line_directive (_struct_decl_lineno);
      print_out ("%s\n", _struct_decl);
    }

  if (option[INCLUDE])
    print_out ("#include <string.h>\n"); /* Declare strlen(), strcmp(), strncmp(). */

  if (!option[ENUM])
    {
      Output_Defines style;
      output_constants (style);
    }
  else if (option[GLOBAL])
    {
      Output_Enum style ("");
      output_constants (style);
    }

  // print_out ("/* maximum key range = %d, duplicates = %d */\n\n",
  //         _max_hash_value - _min_hash_value + 1, _total_duplicates);

  // if (option[UPPERLOWER])
  //   {
  //     #if USE_DOWNCASE_TABLE
  //     output_upperlower_table ();
  //     #endif

  //     if (option[LENTABLE])
  //       output_upperlower_memcmp ();
  //     else
  //       {
  //         if (option[COMP])
  //           output_upperlower_strncmp ();
  //         else
  //           output_upperlower_strcmp ();
  //       }
  //   }

  if (option[CPLUSPLUS])
    print_out ("class %s\n"
            "{\n"
            "private:\n"
            "  static inline unsigned int %s (const char *str, unsigned int len);\n"
            "public:\n"
            "  static %s%s%s (const char *str, unsigned int len);\n"
            "};\n"
            "\n",
            option.get_class_name (), option.get_hash_name (),
            const_for_struct, _return_type, option.get_function_name ());

  output_hash_function ();

  // if (option[SHAREDLIB] && (option[GLOBAL] || option[TYPE]))
  //   output_lookup_pools ();
  // if (option[GLOBAL])
  //   output_lookup_tables ();

  // output_lookup_function ();

  // if (_verbatim_code < _verbatim_code_end)
  //   {
  //     output_line_directive (_verbatim_code_lineno);
  //     fwrite (_verbatim_code, 1, _verbatim_code_end - _verbatim_code, stdout);
  //   }
}

std::string Output::get_str()
{
  return stream.str();
}

/*
 * Augmented BNF for Syntax Specifications: ABNF
 *
 * http://tools.ietf.org/html/rfc5234
 *
 * @append ietf/rfc5234-core-abnf.pegjs
 */

/* http://tools.ietf.org/html/rfc5234#section-4 ABNF Definition of ABNF */
rulelist
  = ( rule
    / c_wsp* c_nl
    )+

// continues if next line starts
// with white space
rule
  = rulename defined_as elements c_nl

rulename
  = $(ALPHA (ALPHA / DIGIT / "-")*)

// basic rules definition and
// incremental alternatives
defined_as
  = c_wsp* $("=" / "=/") c_wsp*

elements
  = alternation c_wsp*

c_wsp
  = WSP
  / c_nl WSP

// comment or newline
c_nl
  = comment
  / CRLF

comment
  = ";" $(WSP / VCHAR)* CRLF

alternation
  = concatenation (c_wsp* "/" c_wsp* concatenation)*

concatenation
  = repetition (c_wsp+ repetition)*

repetition
  = repeat? element

// CHANGE order in reverse for greedy matching
repeat
  = $(DIGIT*) "*" $(DIGIT*)
  / $(DIGIT+)

element
  = rulename
  / group
  / option
  / char_val
  / num_val
  / prose_val

group
  = "(" c_wsp* alternation c_wsp* ")"

option
  = "[" c_wsp* alternation c_wsp* "]"

// quoted string of SP and VCHAR
// without DQUOTE
char_val
  = DQUOTE ([\x20-\x21] / [\x23-\x7E])* DQUOTE

num_val
  = "%" (bin_val / dec_val / hex_val)

// series of concatenated bit values
// or single ONEOF range
bin_val
  = "b" BIT+ (("." BIT+)+ / ("-" BIT+))?

dec_val
  = "d" DIGIT+ (("." DIGIT+)+ / ("-" DIGIT+))?

hex_val
  = "x" HEXDIG+ (("." HEXDIG+)+ / ("-" HEXDIG+))?

// bracketed string of SP and VCHAR
// without angles
// prose description, to be used as
// last resort
prose_val
  = "<" ([\x20-\x3D] / [\x3F-\x7E])* ">"
/*
 * Augmented BNF for Syntax Specifications: ABNF
 *
 * http://tools.ietf.org/html/rfc5234
 */

/* http://tools.ietf.org/html/rfc5234#appendix-B Core ABNF of ABNF */
ALPHA
  = [\x41-\x5A]
  / [\x61-\x7A]

BIT
  = "0"
  / "1"

CHAR
  = [\x01-\x7F]

CR
  = "\x0D"

CRLF
  = CR LF

CTL
  = [\x00-\x1F]
  / "\x7F"

DIGIT
  = [\x30-\x39]

DQUOTE
  = [\x22]

HEXDIG
  = DIGIT
  / "A"i
  / "B"i
  / "C"i
  / "D"i
  / "E"i
  / "F"i

HTAB
  = "\x09"

LF
  = "\x0A"

LWSP
  = $(WSP / CRLF WSP)*

OCTET
  = [\x00-\xFF]

SP
  = "\x20"

VCHAR
  = [\x21-\x7E]

WSP
  = SP
  / HTAB

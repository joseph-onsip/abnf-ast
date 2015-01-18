/*
 * Augmented BNF for Syntax Specifications: ABNF
 *
 * http://tools.ietf.org/html/rfc5234
 *
 * @append ietf/rfc5234-core-abnf.pegjs
 */

{
  var buildList = require('pegjs-utils/buildList');

  function numValHelper (text) {
    text = text.slice(1);
    if (text.indexOf('-') >= 0) {
      var vals = text.split('-');
      var min = vals[0];
      var max = vals[1];

      return {
        "type": "range",
        "min": min,
        "max": max
      };
    }
    else {
      return {
        "type": "series",
        "values": text.split('.')
      };
    }
  }
}

/* http://tools.ietf.org/html/rfc5234#section-4 ABNF Definition of ABNF */
rulelist
  = items: ( rule
    / c_wsp* c_nl
    )+
    {
      var rules = items.filter(function (item) {
        return item.type === 'rule'
      });

      return {
        "type": "rulelist",
        "rules": rules
      };
    }

// continues if next line starts
// with white space
rule
  = rulename: rulename defined_as: defined_as elements: elements c_nl
    {
      return {
        "type": "rule",
        "rulename": rulename,
        "defined_as": defined_as,
        "elements": elements
      };
    }

rulename
  = $(ALPHA (ALPHA / DIGIT / "-")*)

// basic rules definition and
// incremental alternatives
defined_as
  = c_wsp* value: $("=" / "=/") c_wsp*
    {return value;}

elements
  = value: alternation c_wsp*
    {return value;}

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
  = first: concatenation rest: (c_wsp* "/" c_wsp* concatenation)*
    {
      return {
        "type": "alternation",
        "elements": buildList(first, rest, 3)
      };
    }

concatenation
  = first: repetition rest: (c_wsp+ repetition)*
    {
      return {
        "type": "concatenation",
        "elements": buildList(first, rest, 1)
      };
    }

repetition
  = repeat: repeat? element: element
    {
      return {
        "type": "repetition",
        "repeat": repeat,
        "element": element
      };
    }

// CHANGE order in reverse for greedy matching
repeat
  = least: $(DIGIT*) "*" most: $(DIGIT*)
    {
      return {
        "type": "repeat",
        "least": least,
        "most": most
      };
    }
  / $(DIGIT+)
    {
      return {
        "type": "repeat",
        "specific": text()
      };
    }

element
  = rulename
  / group
  / option
  / char_val
  / num_val
  / prose_val

group
  = "(" c_wsp* element: alternation c_wsp* ")"
    {
      return {
        "type": "group",
        "element": element
      };
    }

option
  = "[" c_wsp* element: alternation c_wsp* "]"
    {
      return {
        "type": "option",
        "element": element
      };
    }

// quoted string of SP and VCHAR
// without DQUOTE
char_val
  = DQUOTE ([\x20-\x21] / [\x23-\x7E])* DQUOTE
    {
      return {
        "type": "char_val",
        "value": text().slice(1, -1)
      };
    }

num_val
  = "%" value: (bin_val / dec_val / hex_val)
    {
      return {
        "type": "num_val",
        "value": value
      };
    }

// series of concatenated bit values
// or single ONEOF range
bin_val
  = "b" BIT+ (("." BIT+)+ / ("-" BIT+))?
    {
      return {
        "type": "bin_val",
        "value": numValHelper(text())
      };
    }

dec_val
  = "d" DIGIT+ (("." DIGIT+)+ / ("-" DIGIT+))?
    {
      return {
        "type": "dec_val",
        "value": numValHelper(text())
      };
    }

hex_val
  = "x" HEXDIG+ (("." HEXDIG+)+ / ("-" HEXDIG+))?
    {
      return {
        "type": "hex_val",
        "value": numValHelper(text())
      };
    }

// bracketed string of SP and VCHAR
// without angles
// prose description, to be used as
// last resort
prose_val
  = "<" ([\x20-\x3D] / [\x3F-\x7E])* ">"
    {
      return {
        "type": "prose_val",
        "value": text().slice(1, -1)
      };
    }
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

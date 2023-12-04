// $antlr-format alignTrailingComments true, columnLimit 150, minEmptyLines 1, maxEmptyLinesToKeep 1, reflowComments false, useTab false
// $antlr-format allowShortRulesOnASingleLine false, allowShortBlocksOnASingleLine true, alignSemicolons hanging, alignColons hanging

grammar NixFlake;

flake
    : LCURLY description? inputs? RCURLY EOF
    ;

description: DESCRIPTION_LITERAL EQUAL STRING SEMI;

inputs: INPUTS_LITERAL EQUAL REC_LITERAL? LCURLY input+ RCURLY SEMI;

input: input_url_assignment
     | input_obj;

input_url_assignment : IDENTIFIER DOT URL_LITERAL EQUAL STRING SEMI;

input_obj : IDENTIFIER EQUAL LCURLY input_pin* url RCURLY SEMI;

input_pin:
    INPUTS_LITERAL DOT IDENTIFIER DOT FOLLOWS_LITERAL EQUAL STRING SEMI;

url:
    URL_LITERAL EQUAL STRING SEMI;

// Lexer

SINGLE_LINE_COMMENT
    : '#' .*? (NEWLINE | EOF) -> skip
    ;

DESCRIPTION_LITERAL: 'description';
INPUTS_LITERAL: 'inputs';
FOLLOWS_LITERAL: 'follows';
REC_LITERAL: 'rec';
URL_LITERAL: 'url';

STRING
    : '"' DOUBLE_QUOTE_CHAR* '"'
    | '\'' SINGLE_QUOTE_CHAR* '\''
    ;

fragment DOUBLE_QUOTE_CHAR
    : ~["\\\r\n]
    | ESCAPE_SEQUENCE
    ;

fragment SINGLE_QUOTE_CHAR
    : ~['\\\r\n]
    | ESCAPE_SEQUENCE
    ;

fragment ESCAPE_SEQUENCE
    : '\\' (
        NEWLINE
        | UNICODE_SEQUENCE       // \u1234
        | ['"\\/bfnrtv]          // single escape char
        | ~['"\\bfnrtv0-9xu\r\n] // non escape char
        | '0'                    // \0
        | 'x' HEX HEX            // \x3a
    )
    ;

NUMBER
    : INT ('.' [0-9]*)? EXP? // +1.e2, 1234, 1234.5
    | '.' [0-9]+ EXP?        // -.2e3
    | '0' [xX] HEX+          // 0x12345678
    ;

LCURLY: '{';
RCURLY: '}';
EQUAL: '=';
SEMI : ';';
DOT : '.';

SYMBOL
    : '+'
    | '-'
    ;

fragment HEX
    : [0-9a-fA-F]
    ;

fragment INT
    : '0'
    | [1-9] [0-9]*
    ;

fragment EXP
    : [Ee] SYMBOL? [0-9]*
    ;

IDENTIFIER
    : IDENTIFIER_START IDENTIFIER_PART*
    ;

fragment IDENTIFIER_START
    : [\p{L}]
    | '$'
    | '_'
    | '\\' UNICODE_SEQUENCE
    ;

fragment IDENTIFIER_PART
    : IDENTIFIER_START
    | [\p{M}]
    | [\p{N}]
    | [\p{Pc}]
    | '\u200C'
    | '\u200D'
    | '-'
    ;

fragment UNICODE_SEQUENCE
    : 'u' HEX HEX HEX HEX
    ;

fragment NEWLINE
    : '\r\n'
    | [\r\n\u2028\u2029]
    ;

WS
    : [ \t\n\r\u00A0\uFEFF\u2003]+ -> skip
    ;

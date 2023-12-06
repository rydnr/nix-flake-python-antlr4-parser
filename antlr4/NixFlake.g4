// antlr4/NixFlake.g4
//
// This file defines the experimental ANTLR4 grammar for parsing Nix flakes.
//
// Copyright (C) 2023-today rydnr's rydnr/nix-flake-python-antlr4-parser
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
// $antlr-format alignTrailingComments true, columnLimit 150, minEmptyLines 1, maxEmptyLinesToKeep 1, reflowComments false, useTab false
// $antlr-format allowShortRulesOnASingleLine false, allowShortBlocksOnASingleLine true, alignSemicolons hanging, alignColons hanging

grammar NixFlake;

flake
    : '{' description? inputs? outputs? '}' EOF
    ;

description: 'description' '=' STRING ';';

inputs: 'inputs' '=' 'rec'? '{' input+ '}' ';';

input: input_url_assignment
     | input_obj;

input_url_assignment : IDENTIFIER '.url' '=' STRING ';';

input_obj : IDENTIFIER '=' '{' input_pin* url '}' ';';

input_pin:
    'inputs.' IDENTIFIER '.follows' '=' STRING ';';

url: 'url' '=' STRING ';';

outputs: 'outputs' '=' .*?;

// Lexer

SINGLE_LINE_COMMENT
    : '#' .*? (NEWLINE | EOF) -> skip
    ;

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

fragment HEX
    : [0-9a-fA-F]
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

FILTER
 : . -> skip
 ;

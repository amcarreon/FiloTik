# FiloTik

## Creators

- John Benedict B. Aparicio ([erratic-behaviour])
- Angel Mae T. Carreon ([amcarreon])


## Overview

FiloTiknology (FiloTik) Language is a programming language designed specifically for Filipino netizens, and is inspired by Filipino online slang and TikTok humor vocal stims. The syntax is similar with Java and C, but has the readability of Python. This language aims to make programming understandable and fun despite having minimal technical knowledge. As long as you have spent time scrolling down the internet, you can code. “Kaka-cellphone mo’yan” finally pays off. No to doomscrolling, yes to code & scrolling.

## Host language and build

- Host language: Dart SDK version: 3.13.2
- Version metadata: pubspec.yaml
- Build: `./build.sh`
- [Anything a fresh clone needs to know.]

## Running it


| Command | What it does |
|---|---|
| `./run <file>` | Executes a program. Available from Lab 4. |
| `./run --tokenize <file>` | Prints the token stream. |
| `./run --parse <file>` | Prints the parsed tree. |
| `./run --eval <file>` | Evaluates each expression and prints its value. |
| `./run` | Starts the REPL. |


Exit codes: 0 when file was scanned clean, 65 when scanner rejected the file before running, 70 when the scan started then died.

## File extension

`.filo`

## Lexical structure

### Keywords


| Keyword | Purpose |
|---|---|
| ang| Var declaration|
| avisala | Function declaration |
| yoohoo | Function call |
| ohsimon | Returning a value from a function |
| omsim | Boolean value: True |
| nonsince | Boolean value: False |
| pwidi, piro, dipindi | Conditional statements: if, else if, and else |
| forda | For loops |
| whiletch | While loops |
| oops | Continue loop |
| aynakatulog | Break loop |
| imnida | Print statement |
| sabihinmona | User input |
| waley | nil value |
| o | Logical OR |
| at | Logical AND |
| mama_mo | Logical NOT |


### Operators
Precedence: 1=loosest

| Operator | Category | Operands | Associativity | Precedence |
|---|---|---|---|---|
| Parentheses (()) | grouping | - | none | 10 |
| Logical NOT (mama_mo) | logical | unary | right | 9 |
| Exponent (^) | arithmetic | binary | right | 8 |
| Multiply (*), Divide (/), Modulo (%) | arithmetic | binary | left | 7 |
| Add (+), Subtract (-) | arithmetic | binary | left | 6 |
| Less than (<), Less than or equal (<=), More than (>), More than or equal (>=) | comparison | binary | left | 5 |
| Equality (==), Inequality (!=) | comparison | binary | left | 4 |
| Logical AND (at) | logical | binary | left | 3 |
| Logical OR (o) | logical | binary | left | 2 |
| Equals (=) | assignment | binary | right | 1 |



### Literals


| Kind | Syntax | Produces |
|---|---|---|
| number | 42 (int), 3.14 (double) | [what runtime value] |
| string | "Uy, Philippines!" | [what runtime value] |
| boolean | omsim = true, nonsince = false | [what runtime value] |
| null/None | waley | [what runtime value] |


### Identifiers

- Start characters: small or capital letters from A to Z
- Continue characters: can contain numbers, letters, underscore (_)
- Case-sensitive: no
- Cannot contain reserved keywords and whitespaces
- Cannot contain special characters (&, $, #, @, etc.), except underscore (_)

### Comments

- Line comments: `SKL; This is a line comment.`
- Block comments: `SKL: This is a block comment. IYKYK`
- Nesting: not supported
- Harness note: comment_prefix in tests/lab*/manifest.json is set to the token above.

## Whitespace and termination

- Whitespace significant: no
- Statement terminator: ;;
- Block delimiters: curly braces
- Grouping delimiters: parentheses

## Token output format

```
Token(type: TokenType.number, lexeme: 4, literal: 4.0, line: 1) 
```

[What each field means. Frozen as of Lab 1; changes are recorded in the
changelog.]

## Grammar

```
program       → declaration* EOF

declaration   → var_decl | func_decl | statement
var_decl      → "ang" IDENTIFIER "=" expression ";;"
func_decl      → "avisala" IDENTIFIER "(" parameters? ")" block
parameters    → IDENTIFIER ( "," IDENTIFIER )*

statement     → expr_stmt
                | print_stmt 
                | cond_stmt 
                | while_stmt 
                | for_stmt
                | return_stmt
                | break_stmt
                | continue_stmt
                | block
expr_stmt     → expression ";;"
print_stmt    → "sabihinmona" expression ";;"
cond_stmt     → "pwidi" "(" expression ")" statement
                ( "piro" "(" expression ")" statement )*
                ( "dipindi" statement )?
while_stmt    → "whiletch" "(" expression ")" statement
for_stmt      → "forda" "(" ( var_decl | expr_stmt | ";;" )
                 expression? ";;" expression? ")" statement
return_stmt   → "ohsimon" expression? ";;"
break_stmt    → "aynakatulog" ";;"
continue_stmt → "oops" ";;"
block         → "{" declaration* "}"

expression    → assignment
assignment    → IDENTIFIER "=" assignment | logicalOR
logicalOR     → logicalAND ( "o" logicalAND )*
logicalAND    → equality ( "at" equality )*
equality      → comparison ( ( "!=" | "==" ) comparison )*
comparison    → term ( ( ">" | ">=" | "<" | "<=" ) term )*
term          → factor ( ( "-" | "+" ) factor )*
factor        → exponent ( ( "/" | "*" | "%" ) exponent )*
exponent      → unary "^" exponent | unary
unary         → "mama_mo" unary | primary
primary       → NUMBER | STRING | IDENTIFIER | "omsim" | "nonsince" | "waley"
                | func_call | input | "(" expression ")"
func_call      → "yoohoo" IDENTIFIER "(" arguments? ")"
arguments     → expression ( "," expression )*
input         → "imnida" "(" expression? ")"
```

## Parse output format

```
(+ 1.0 (* 2.0 3.0))
```

- Groupings print as: [form]
- Numbers print as: [form]

## Semantics

### Values and types

[What runtime values exist, and how they are represented in the host
language.]

### Value printing

- Numbers: [e.g. 5 rather than 5.0]
- Nil: [spelling]
- Strings: [with or without quotes]

### Truthiness

[The complete rule. Which values are false in a condition; everything else is
true.]

### Operator semantics

- Arithmetic: number value [operator] number value, `2 + 3`
- `+` on strings: concatenation, `"Uy!" + "Philippines" = "Uy!Philippines"`
- Mixed types: If the operands have different types, such as number and word, it will return an error. `"depende kung" + 3`
- Comparison: number value [operator] number value, `2 < 3`
- Equality across types: Equality in numbers evaluates whether they are the same value. 
- Division by zero: runtime error

### Scope and bindings

- Redeclaration in the same scope: [allowed or an error]
- Uninitialized variable holds: [value]
- Shadowing: [behavior]
- Undefined name: [static error with exit 65, or runtime error with exit 70]

### Control flow and functions

- Logical operators return: booleans
- Dangling else binds to: [which if]
- Closure capture of a loop variable: [per iteration, or shared]
- Function with no return statement produces: [value]
- Arity mismatch: [message and exit code]

## Native functions


| Name | Arguments | Returns | Notes |
|---|---|---|---|
| [name] | [count and types] | [type] | [caveats] |


## Errors and diagnostics

Message format:

```
[one real static error]
[one real runtime error]
```


| Failure | Exit code |
|---|---|
| lexical error | 65 |
| syntax error | 65 |
| runtime error | 70 |


## Testing conventions


| Folder | Activity | Mode | Flag |
|---|---|---|---|
| tests/lab1 | Scanner | sidecar | `--tokenize` |
| tests/lab2 | Parser | sidecar | `--parse` |
| tests/lab3 | Evaluator | inline | `--eval` |
| tests/lab4 | Context | inline | none |
| tests/lab5 | Functions | inline | none |


```
tests/lab0
  tests/lab0/hello.bro

tests/lab1
  tests/lab1/strings
    tests/lab1/strings/escapes.filo
    tests/lab1/strings/unterminated.filo
  tests/lab1/comments_at_eof.filo
  tests/lab1/declaration.filo
  tests/lab1/empty.filo
  tests/lab1/keywords.filo
  tests/lab1/numbers.filo
  tests/lab1/operators.filo
```

Run locally with:

```bash
curl -sSL https://raw.githubusercontent.com/WhiteLicorice/cmsc-124-harness/v1.1/run_tests.py -o run_tests.py
./build.sh
python3 run_tests.py tests/lab1
```

## Sample code

```
[a short program]
```

Output:

```
[its output]
```

## Design rationale

[Why the language is the way it is. Cover the choices that surprised you, the
features you cut, and the decisions you reversed. Specific reasons, not
approval of your own work.]

## Known limitations

- [What doesn't work, what is unimplemented, where behavior is worse than you
  would like.]

## Changelog


| Activity | What changed in the language |
|---|---|
| Lab 1 | added scanner |
| Lab 2 | added grammar |

import 'dart:convert';
import 'dart:io';

enum TokenType {
  // Delimiters
  // Grouping Delimiters
  parenL, parenR,
  // Block Delimiteers
  curlyL, curlyR,
  // Literal Deelimiter
  bracketL,bracketR,

  // Arithmetic
  add, sub, mult, div, modulo, exponent,

  // Relational Operators
  equalEqual, notEqual, less, lessEqual, greater, greaterEqual, 

  // Assignments
  equal, not,

  // Types and null
  identifier, string, number_int, number_float, typeNull,

  // Variable Declaration
  varDeclare,

  // conditionals
  condIf, condElse, condIfelse,

  // loops
  repFor, repWhile, repContinue, repBreak,

  //functions
  funcDeclare, funcReturn, funcCall, funcPrint, funcScan,

  // logic
  logicAnd, logicOr, logicNot,

  // bools
  boolTrue, boolFalse,

  // comments
  commentLine, commentMultiLineStart, commentMultiLineEnd, commentMark,

  // EOF, Statemeent teerminator, 
  termFile, termStatement, termLine, 

  // error types
  unkCHAR, unterminatedString,
}

// symbols/lexemes for lookup
const Map<String, TokenType> Symbols = {
  // Grouping Delimiters
  "(": TokenType.parenL,
  ")": TokenType.parenR,

  // Block Delimiters
  "{": TokenType.curlyL,
  "}": TokenType.curlyR,

  // Literal Delimiters
  "[": TokenType.bracketL,
  "]": TokenType.bracketR,

  // Arithmetic
  "+": TokenType.add,
  "-": TokenType.sub,
  "*": TokenType.mult,
  "/": TokenType.div,
  "%": TokenType.modulo,
  "^": TokenType.exponent,

  // Relational Operators
  "==": TokenType.equalEqual,
  "!=": TokenType.notEqual,
  "<": TokenType.less,
  "<=": TokenType.lessEqual,
  ">": TokenType.greater,
  ">=": TokenType.greaterEqual,

  // Assignments
  "=": TokenType.equal,
  "!": TokenType.not,

  // Statement terminators
  ";;": TokenType.termStatement,
  "\n": TokenType.termLine,
};

// Reserved identifiers for lookup
const Map<String, TokenType> Keywords = {
  // Types and null
  "waley": TokenType.typeNull,

  // Variable Declaration
  "ang": TokenType.varDeclare,

  // Conditionals
  "pwidi": TokenType.condIf,
  "dipindi": TokenType.condElse,
  "piro": TokenType.condIfelse, 

  // Loops
  "forda": TokenType.repFor,
  "whiletch": TokenType.repWhile,

  // loop commands
  "oops": TokenType.repContinue,
  "aynakatulog": TokenType.repBreak,

  // functions
  "avisala": TokenType.funcDeclare,
  "ohsimon": TokenType.funcReturn,
  "yoohoo": TokenType.funcCall,
  "imnida": TokenType.funcPrint,
  "sabihinmona": TokenType.funcScan,

  // logic
  "at": TokenType.logicAnd,
  "o": TokenType.logicOr,
  "mama_mo": TokenType.logicNot,

  // comment
  "SKL;": TokenType.commentLine,
  "SKL:": TokenType.commentMultiLineStart,
  ":IYKYK": TokenType.commentMultiLineEnd,


  // Bools
  "omsim": TokenType.boolTrue,
  "nonsince": TokenType.boolFalse,
};

class Token {
  final TokenType type;
  final String lexeme;
  final Object? literal;
  final int line;

  const Token(this.type, this.lexeme, this.literal, this.line);

  @override
  String toString(){
    if (lexeme == '\n') {
      return 'Token(type:$type, lexeme:\\n, literal:$literal, line:$line)';
    }
    return 'Token(type:$type, lexeme:$lexeme, literal:$literal, line:$line)';
    }
}

class Scanner {
    /* 
    Changed current to column to make it clear if we are referring to
    the character before/on/after the current character.
    In this case, we refer to the character ON.
    */
    final String source;
    int start = 0;
    int column = 0;
    int line = 1;

    bool errorFlag = false;
    List<int> errorTypes = []; 

    List<(int, int, String)> errorLines = [];
    List<Token> tokens = [];

    Scanner(this.source);

    void scanTokens(){
        // start marks thee beginning of thee next token before scanning it
        while(!_isAtEnd()){
            start = column;
            scanToken();
        }

        // EOF is added after every character in thee source has been checked
        tokens.add(Token(TokenType.termFile, '', null, line));
    }

    void scanToken(){
        final character = _advance();

        if (_isDigit(character)){
            _scanNumber();
            return;
        }
        
        if (_isAlphabet(character)){
            _scanIdentifier();
            return;
        }
        
        if (character == '"'){
            _scanString();
            return;
        }

        _scanSymbol(character);
    }

    void _addToken(TokenType type, [Object? literal]){
        // thee lexeme is thee exact source text, while literal is its converted value
        final lexeme = source.substring(start, column); 
        var token;
        if (type == TokenType.number_int || type == TokenType.number_float || type == TokenType.string){
            token = Token(type, lexeme, literal, line);
        }else{
            token = Token(type, lexeme, null, line);
        }
        
        tokens.add(token);
    }

    void _scanSymbol(String character){
        switch(character){
            // these charactrs do not createe tokens by themselves
            case ' ':
                break;
            case '\r':
            case '\t':
                break;
            case '\n':
                line++;
                break;
            // a written \n is treated as a line break in the source
            case '\\':
                if (_peek() == 'n') {
                    line++;
                    _advance();
                }
                break;
            case '=':
                _addToken(_match('=') ? TokenType.equalEqual : TokenType.equal, character);
                break;
            case '!':
                _addToken(_match('=') ? TokenType.notEqual : TokenType.not, character);
                break;
            case '<':
                _addToken(_match('=') ? TokenType.lessEqual : TokenType.less, character);
                break;
            case '>':
                _addToken(_match('=') ? TokenType.greaterEqual : TokenType.greater, character);
                break;
            case ';':
                if (_match(';')) {
                  _addToken(TokenType.termStatement);
                  break;
                }
                // if it iss not ;;, continue checking whether it starts a comment
            case ':':
                if (_isAlphabet(_peek())) {
                  _scanIdentifier();
                  break;
                }
            // others
            default:
                // anything not recognized by the scanner is an error
                final tokenType = Symbols[character];
                if (tokenType != null) {
                  _addToken(tokenType, character);
                  break;
                }
                errorFlag = true;
                // (errorType, line, character)
                errorLines.add((1,line, character));
                if (errorTypes.contains(1) == false) {
                  errorTypes.add(1);
                }
                _addToken(TokenType.unkCHAR, character);
        }
    }

    void _scanNumber(){
        // keep reading so integers and decimals stay in one token
        while(_isDigit(_peek()) || _peek() == '.'){
            _advance();
        }
        
        final number = source.substring(start, column);
        if (number.contains('.')){
            final value = double.tryParse(number);
            _addToken(TokenType.number_float, value);
        }
        else
        {
            final value = int.tryParse(number);
            _addToken(TokenType.number_int, value);
        }
    }

    void _scanIdentifier(){
        while(_isAlphabet(_peek()) || _isDigit(_peek()) || "_" == _peek() || ":" == _peek() || ";" == _peek()){
            _advance();
        }

        final identifier = source.substring(start, column);
        final keyword = Keywords[identifier];

        if (keyword == TokenType.commentMultiLineStart) {
            // ignore everything until thee block comment closing marker appears
            while (!_isAtEnd()) {
                if (_peek() == ':' && source.substring(column, column + 6) == ':IYKYK') {
                    for (int i = 0; i < 6; i++) {
                        _advance();
                    }
                    break;
                } else {
                    if (_peek() == '\n') line++;
                    _advance();
                }
            }
            return;
        }
        if (keyword == TokenType.commentLine) {
            while (_peek() != '\n' && !_isAtEnd()) {
                _advance();
            }
            return;
        }

        if(keyword != null){
            _addToken(keyword, identifier);
        } else {
            _addToken(TokenType.identifier, identifier);
        }
    }

    void _scanString(){
        // escaped quotes do not close thee string, so consume them as a pair
        while(_peek() != '"' && !_isAtEnd()){
            if(_peek() == '\\'){
                _advance(); // consume the backslash
                if (_isAtEnd()) {
                    break;
                }
                if (_peek() == 'n') line++;
                if (_peek() == '"'); // quote escape
                if (_peek() == '\\') ; // backslash escape
                _advance();
                
            } else {
                _advance();
            }
        }

        if(_isAtEnd()){
            // reaching EOF here means thee opening quote had no matching quote
            errorFlag = true;
            if (errorTypes.contains(2) == false) {
                errorTypes.add(2);
            }
            errorLines.add((2, line, source.substring(start, column)));
        }else{
            _advance(); // consume closing "
            // remove thee quotes and turn supported escape sequences into values
            var value = source.substring(start + 1, column - 1);
            value = value.replaceAll('\\"', '"');
            value = value.replaceAll('\\\\', '\\');
            value = value.replaceAll('\\n', '\n');
            _addToken(TokenType.string, value);
        }


        
    }

    String _peek() {
        // look at the current character without moving the scanner
        if (_isAtEnd()) return '\u0000';
        return source.substring(column, column + 1);
    }

    String _advance() {
        // return the current character, then move to the next one
        final character = source.substring(column, column + 1);
        column++;
        return character;
    }

    bool _match(String expected){
        // check the current character and consume it only when it matches
        if (_isAtEnd()) return false;
        if (source[column] != expected) return false;

        column++;
        return true;
    }

    bool _isAlphabet(String character){
        final codeUnit = character.codeUnits.first;
        return (codeUnit >= 'a'.codeUnits.first && codeUnit <= 'z'.codeUnits.first) || (codeUnit >= 'A'.codeUnits.first && codeUnit <= 'Z'.codeUnits.first);

    }
    bool _isDigit(String character){
        return character.codeUnits.first >= '0'.codeUnits.first && character.codeUnits.first<= '9'.codeUnits.first;
    }
    bool _isAtEnd(){return column >= source.length;}

}

Never fail_scanner(String message) {
  stderr.writeln('lab1: $message');
  exit(65);
}

Never fail(String message) {
  stderr.writeln('lab0: $message');
  exit(65);
}


void main(List<String> arguments) {
  if (arguments.isEmpty) {
    fail('expected one source-file path');
  }

  final path = arguments.last;
  final command = arguments.first;

  if (command == '--tokenize'){
    try {
    final source = File(path).readAsStringSync(encoding: utf8); 
        final scanner = Scanner(source);
        scanner.scanTokens();

        for (final token in scanner.tokens) {
            if (scanner.errorFlag == true){
                break;
            }
            stdout.writeln(token.toString());
        }

        if (scanner.errorFlag == true) {
          if (scanner.errorTypes.contains(1) == true) {
            stderr.writeln('lab1: unrecognized character(s) at line(s):');
            for (final error in scanner.errorLines) {
              if (error.$1 == 1) {
                stderr.writeln('  ${error.$2}:${error.$3}');
              }
            }
            fail_scanner('tokenization failed: unrecognized character(s)');
          }
          if (scanner.errorTypes.contains(2) == true) {
            stderr.writeln('lab1: unterminated string(s) at line(s):');
            for (final error in scanner.errorLines) {
              if (error.$1 == 2) {
                stderr.writeln('  ${error.$2}:${error.$3}');
              }
            }
          }
          fail_scanner('tokenization failed: unterminated string(s)');
        }
    } on FileSystemException catch (error) {
      fail("cannot read '$path': ${error.message}");
    }
  }else{
    try {
    final source = File(path).readAsStringSync(encoding: utf8);
    stdout.write(source);
    } on FileSystemException catch (error) {
      fail("cannot read '$path': ${error.message}");
    }
  }

  
}

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
  add, sub, mult, div,

  // Relational Operators
  equalEqual, notEqual, less, lessEqual, greater, greaterEqual, 

  // Assignments
  equal, not,

  // Types and null
  identifier, string, number, typeNull,

  // Variable Declaration
  varDeclare,

  // conditionals
  condIf, condElse, condIfelse,

  // loops
  repFor, repWhile, repContinue, repBreak,

  //functions
  funcDeclare, funcReturn, funcPrint, funcScan,

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
      return 'Token(type: $type, lexeme: \\n, literal: $literal, line: $line)';
    }
    return 'Token(type: $type, lexeme: $lexeme, literal: $literal, line: $line)';
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
        while(!_isAtEnd()){
            start = column;
            scanToken();
        }

        tokens.add(Token(TokenType.termFile, 'EOF', null, line));
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
        final lexeme = source.substring(start, column);
        final token = Token(type, lexeme, literal, line);
        tokens.add(token);
    }

    void _scanSymbol(String character){
        switch(character){
            case ' ':
            case '\r':
            case '\t':
                break;
            case '\n':
                line++;
                _addToken(TokenType.termLine);
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
            case ':':
                if (_isAlphabet(_peek())) {
                  _scanIdentifier();
                  break;
                }
            default:
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
        while(_isDigit(_peek())){
            _advance();
        }

        final number = source.substring(start, column);
        final value = double.tryParse(number);

        _addToken(TokenType.number, value);
    }

    void _scanIdentifier(){
        while(_isAlphabet(_peek()) || _isDigit(_peek()) || "_" == _peek() || ":" == _peek() || ";" == _peek()){
            _advance();
        }

        final identifier = source.substring(start, column);
        final keyword = Keywords[identifier];

        if (keyword == TokenType.commentMultiLineStart) {
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
        while(_peek() != '"' && !_isAtEnd()){
            if(_peek() == '\n') line++;
            _advance();
        }

        if(_isAtEnd()){
            errorFlag = true;
            if (errorTypes.contains(2) == false) {
                errorTypes.add(2);
            }
            errorLines.add((2, line, source.substring(start, column)));
        }else{
            _advance(); // consume closing "
            final value = source.substring(start + 1, column - 1);
            _addToken(TokenType.string, value);
        }


        
    }

    String _peek() {
        if (_isAtEnd()) return '\u0000';
        return source.substring(column, column + 1);
    }

    String _advance() {
        final character = source.substring(column, column + 1);
        column++;
        return character;
    }

    bool _match(String expected){
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
          }
          if (scanner.errorTypes.contains(2) == true) {
            stderr.writeln('lab1: unterminated string(s) at line(s):');
            for (final error in scanner.errorLines) {
              if (error.$1 == 2) {
                stderr.writeln('  ${error.$2}:${error.$3}');
              }
            }
          }
          exit(65);
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

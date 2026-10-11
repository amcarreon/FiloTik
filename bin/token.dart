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

  // EOF, Statement terminator, 
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
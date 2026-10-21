import 'token.dart';
import 'astnodes.dart';

class ParseError implements Exception {
  final Token token;
  final String message;
  ParseError(this.token, this.message);

  @override
  String toString() => '[line ${token.line}] Error at '
      "'${token.lexeme}': $message";
}

// printStatement, retStatement, condStatement, etc. - AST nodes, wala ko pa nastrt



class Parser {
  final List<Token> tokens;
  Parser(this.tokens);
  int _current = 0;
  final errors = <ParseError>[];
  
  // helper functions
  Token _peek() => tokens[_current]; // reading current token, not consumed

  Token _previous() => tokens[_current - 1];

  Token _advance() {
      if (!_isAtEnd()) _current++;
      
      return _previous();
  }

  Token _consume(TokenType type, String message) {
      if (_check(type)) return _advance();
      throw ParseError(_peek(), message);
  }

  bool _isAtEnd() => _peek().type == TokenType.termFile; // EOF

  bool _check(TokenType type) {
      if (_isAtEnd()) return false;
      return _peek().type == type;
  }

  bool _match(List<TokenType> types) {
      for (final type in types) {
          if (_check(type)) {
              _advance();
              return true;
          }
      }
      return false;
  }


// parsing

  Program parse() {
    final declarations = <Declaration>[];

    while (!_isAtEnd()) {
      try {
        declarations.add(_parseDeclaration());
      } on ParseError catch (error) {
        errors.add(error);
        _synchronize();
      }
    } 
    
    return Program(declarations);
  }

  void _synchronize() {
    while (!_isAtEnd() && !_check(TokenType.termStatement)) {
      _advance();
    }

    if (!_isAtEnd()) {
      _advance();
    }
  }

// statements
  Declaration _parseDeclaration() {
    if(_match([TokenType.varDeclare])) return _parseVarDeclaration(); // "ang"
    if(_match([TokenType.funcDeclare])) return _parseFuncDeclaration(); // "avisala"
    return _parseStatement();
  }

  Declaration _parseVarDeclaration() {
    //_consume(TokenType.varDeclare, "Expect '${TokenType.varDeclare}'"); // "ang"
    final name = _consume(TokenType.identifier, "Expect variable name");
    _consume(TokenType.equal, "Expect '${TokenType.equal}' after variable name");
  
    final init = _parseExpression();
    _consume(TokenType.termStatement, "Expect '${TokenType.termStatement}' after variable declaration");
    
    return VarDeclaration(name, init);
  }

  Declaration _parseFuncDeclaration() {
    //_consume(TokenType.funcDeclare, "Expect '${TokenType.funcDeclare}'"); // "avisala"
    final name = _consume(TokenType.identifier, "Expected function name"); 
    _consume(TokenType.parenL, "Expect '${TokenType.parenL}' after function name"); 
    
    final params = <Token>[];
    if (!_check(TokenType.parenR)) params.addAll(_parseParams());

    _consume(TokenType.parenR, "Expect '${TokenType.parenR}' after parameters");
  

    _consume(TokenType.curlyL, "Expect '${TokenType.curlyL}' before function block");
    
    final body = BlockStatement(_parseBlock());
    
    return FuncDeclaration(name, params, body);
  }

  List<Token> _parseParams() {
    final params = <Token>[_consume(TokenType.identifier, "Expect parameter name"),];

    // unknown char pa ang comma so idk how to continue this part...
    while (_match([TokenType.comma])) {
      params.add(_consume(TokenType.identifier, "Expect parameter name"));
    }
    
    return params;
  }

  Statement _parseStatement() {
    if (_match([TokenType.funcPrint])) return _parsePrint();
    if (_match([TokenType.condIf])) return _parseCond();
    if (_match([TokenType.repWhile])) return _parseWhileLoop();
    if (_match([TokenType.repFor])) return _parseForLoop();
    if (_match([TokenType.funcReturn])) return _parseReturn();
    if (_match([TokenType.repBreak])) {
      _consume(TokenType.termStatement, "Expect '${TokenType.termStatement}' after '${TokenType.repBreak}'");
      return BreakStatement();
    }
    if (_match([TokenType.repContinue])) {
      _consume(TokenType.termStatement, "Expect '${TokenType.termStatement}' after '${TokenType.repContinue}'");
      return ContStatement();
    }
    if (_match([TokenType.curlyL])) return BlockStatement(_parseBlock());

    return _parseExprStatement();
  }

  Statement _parseExprStatement() {
    final expr = _parseExpression();
    _consume(TokenType.termStatement, "Expect '${TokenType.termStatement}' after expression");

    return ExprStatement(expr);
  }

  Statement _parsePrint() {
    //_consume(TokenType.funcPrint, "Expect '${TokenType.funcPrint}'");
    _consume(TokenType.parenL, "Expect '${TokenType.parenL}' after ${TokenType.funcPrint}");

    final expr = _parseExpression();

    _consume(TokenType.parenR, "Expect '${TokenType.parenR}'");
    _consume(TokenType.termStatement, "Expect '${TokenType.termStatement}' after the statement");

    return PrintStatement(expr);
  }

  Statement _parseCond() {
    //_consume(TokenType.condIf, "Expect'${TokenType.condIf}'");
    _consume(TokenType.parenL, "Expect '${TokenType.parenL}' after ${TokenType.condIf}");
    
    final condition = _parseExpression();

    _consume(TokenType.parenR, "Expect '${TokenType.parenR}' after condition");

    final elifBranches = <(Expression, Statement)>[(condition, _parseStatement()),];
    while (_match([TokenType.condIfelse])) {
      _consume(TokenType.parenL, "Expect '${TokenType.parenL}' after ${TokenType.condIfelse}");

      final nextCond = _parseExpression();

      _consume(TokenType.parenR, "Expect '${TokenType.parenR}' after condition");

      elifBranches.add((nextCond, _parseStatement()));
    }

    Statement? elseBranch;
    if(_match([TokenType.condElse])) elseBranch = _parseStatement();

    return CondStatement(elifBranches, elseBranch);
  }

  Statement _parseWhileLoop() {
    //_consume(TokenType.repWhile, "Expect'${TokenType.repWhile}'");
    _consume(TokenType.parenL, "Expect '${TokenType.parenL}' after ${TokenType.repWhile}");
    
    final condition = _parseExpression();
    _consume(TokenType.parenR, "Expect '${TokenType.parenR}' after condition");

    return WhileStatement(condition, _parseStatement());
  }

  Statement _parseForLoop() {
    //_consume(TokenType.repFor, "Expect'${TokenType.repFor}'");
    _consume(TokenType.parenL, "Expect '${TokenType.parenL}' after ${TokenType.repFor}");
    
    Declaration? init;

    if (_match([TokenType.termStatement])) {
      init = null;
    } else if (_match([TokenType.varDeclare])) {
      init = _parseVarDeclaration();
    } else {
      init = _parseExprStatement();
    }

    Expression? condition;

    if (!_check(TokenType.termStatement)) condition = _parseExpression();
    _consume(TokenType.termStatement, "Expect '${TokenType.termStatement}' after loop condition");

    Expression? step;

    if (!_check(TokenType.termStatement)) step = _parseExpression();
    _consume(TokenType.parenR, "Expect '${TokenType.parenR}' after for clause");

    return ForStatement(init, condition, step, _parseStatement());
  }

  Statement _parseReturn() {
    //_consume(TokenType.funcReturn, "Expect'${TokenType.funcReturn}'");

    Expression? value;
    
    if (!_check(TokenType.termStatement)) value = _parseExpression();

    _consume(TokenType.termStatement, "Expect '${TokenType.termStatement}' after '${TokenType.funcReturn}'");

    return RetStatement(value);
  }


  List<Declaration> _parseBlock() {
    //_consume(TokenType.curlyL, "Expect'${TokenType.curlyL} for function block body'");

    final contents = <Declaration>[];

    while (!_check(TokenType.curlyR) && !_isAtEnd()) {
      try {
        contents.add(_parseDeclaration());
      } on ParseError catch (error) {
        errors.add(error);
        _synchronize();
      }
    }

    _consume(TokenType.curlyR, "Expect'${TokenType.curlyR}' after block body");

    return contents;
  }
  
  // expressions
  Expression _parseExpression() => _parseAssignment();

  Expression _parseAssignment() {
    // assignment → IDENTIFIER "=" assignment | logicalOR
    // Start with _parseLogicalOR(); if the left side is an identifier and
    // an "=" follows, recursively parse the right side as an assignment.
    var expression = _parseLogicalOR();

    if (!_match([TokenType.equal])) return expression;

    final equals = _previous();
    final value = _parseAssignment();

    if (expression is! Variable) {
      throw ParseError(equals, 'Invalid assignment target');
    }

    return Assignment(expression.name, value);
  }

  Expression _parseLogicalOR() {
    // logicalOR → logicalAND ( "o" logicalAND )*
    // Parse the first _parseLogicalAND(), then consume repeated logicOr
    // operators and parse each right operand with _parseLogicalAND().
    
    var expression = _parseLogicalAND();

    while (_match([TokenType.logicOr])){
      final operator = _previous();
      final right = _parseLogicalAND();

      expression = Logical(expression,operator,right);
    }
    return expression;
  }

  Expression _parseLogicalAND() {
    // logicalAND → equality ( "at" equality )*
    // Parse the first _parseEquality(), then consume repeated logicAnd
    // operators and parse each right operand with _parseEquality().
    var expression = _parseEquality();

    while (_match([TokenType.logicAnd])){
      final operator = _previous();
      final right = _parseEquality();

      expression = Logical(expression,operator,right);
    }
    return expression;

  }

  Expression _parseEquality() {
    // equality → comparison ( ( "!=" | "==" ) comparison )*
    // Parse comparison operands and consume TokenType.notEqual or
    // TokenType.equalEqual between them.

    var expression = _parseComparison();

    while (_match([TokenType.notEqual,TokenType.equalEqual])){
      final operator = _previous();
      final right = _parseComparison();

      expression = Binary(expression,operator,right);
    }

    return expression;
  }

  Expression _parseComparison() {
    // comparison → term ( ( ">" | ">=" | "<" | "<=" ) term )*
    // Parse term operands and consume the four relational operator tokens.
    var expression = _parseTerm();

    while (_match([TokenType.greater,
    TokenType.greaterEqual,
    TokenType.less,
    TokenType.lessEqual,
    ]))
    {
      final operator = _previous();
      final right = _parseTerm();

      expression = Binary(expression,operator,right);
    }

    return expression;

  }

  Expression _parseTerm() {
    // term → factor ( ( "-" | "+" ) factor )*
    // Parse factor operands and consume TokenType.sub or TokenType.add.
    var expression = _parseFactor();

    while (_match([TokenType.sub,TokenType.add]))
    {
      final operator = _previous();
      final right = _parseFactor();

      expression = Binary(expression,operator,right);
    }

    return expression;
  }

  Expression _parseFactor() {
    // factor → exponent ( ( "/" | "*" | "%" ) exponent )*
    // Parse exponent operands and consume TokenType.div, mult, or modulo.
    var expression = _parseExponent();

    while (_match([TokenType.div,
    TokenType.mult,
    TokenType.modulo,
    ]))
    {
      final operator = _previous();
      final right = _parseExponent();

      expression = Binary(expression,operator,right);
    }

    return expression;
  
  }

  Expression _parseExponent() {
    // exponent → unary "^" exponent | unary
    // Parse _parseUnary(); for "^", recursively parse the right side with
    // _parseExponent() so exponentiation remains right-associative.

    var expression = _parseUnary();

    if (_match([TokenType.exponent]))
    {
      final operator = _previous();
      final right = _parseExponent();

      expression = Binary(expression,operator,right);
    }

    return expression;
  
  }

  Expression _parseUnary() {
    // unary → "mama_mo" unary | primary
    // If TokenType.logicNot is present, recursively parse _parseUnary();
    // otherwise delegate to _parsePrimary().
    if (_match([TokenType.logicNot]))
    {
      final operator = _previous();
      final right = _parseUnary();

      return Unary(operator,right);
    }

    return _parsePrimary();
  }

  Expression _parsePrimary() {
    // primary → NUMBER_FLOAT | NUMBER_INT | STRING | IDENTIFIER
    //            | "omsim" | "nonsince" | "waley"
    //            | func_call | input | "(" expression ")"
    // Consume literals and identifiers directly; delegate funcCall to
    // _parseFuncCall(), funcScan to _parseInput(), and grouped expressions
    // to _parseExpression() between parentheses.
    
    if (_match([TokenType.funcCall])){
      return _parseFuncCall();
    }

    
    if (_match([TokenType.funcScan])){
      return _parseInput();
    }

    
    if (_match([TokenType.number_float,
    TokenType.number_int,
    TokenType.string
    ])){
      return Literal(_previous().literal);
    }

    
    if (_match([TokenType.boolTrue])){
      return Literal(true);
    }

    
    if (_match([TokenType.boolFalse])){
      return Literal(false);
    }

    
    if (_match([TokenType.typeNull])){
      return Literal(null);
    }

    if (_match([TokenType.identifier])) {
      return Variable(_previous());
    }

    if (_match([TokenType.parenL])) {
      final expression = _parseExpression();

      _consume(
        TokenType.parenR,
        "Expect '${TokenType.parenR}' after expression",
      );

      return Grouping(expression);
    }

    throw ParseError(_peek(), 'Expected expression');
  }

  Expression _parseFuncCall() {
    //_consume(TokenType.funcCall, "Expect '${TokenType.funcCall}'");

    final name = _consume(TokenType.identifier, "Expect function name after '${TokenType.funcCall}'");

    _consume(TokenType.parenL, "Expect '${TokenType.parenL}' after function name");

    var args = <Expression>[];

    if (!_check(TokenType.parenR)) args = _parseArguments();

    _consume(TokenType.parenR, "Expect '${TokenType.parenR}' after arguments");

    return Call(name, args);    
  }

  List<Expression> _parseArguments() {
    // arguments → expression ( "," expression )*
    // Parse one _parseExpression(), then consume each comma and parse the
    // next expression until the closing parenthesis.
    final args = <Expression>[_parseExpression()];

    while(_match([TokenType.comma])){
      args.add(_parseExpression());
    } 
    return args;
  }

  Expression _parseInput() {
    //_consume(TokenType.funcScan, "Expect '${TokenType.funcScan}'");
    _consume(TokenType.parenL, "Expect '${TokenType.parenL}' after '${TokenType.funcScan}'");
    
    Expression? userInput;

    if (!_check(TokenType.parenR)) userInput = _parseExpression();

    _consume(TokenType.parenR, "Expect '${TokenType.parenR}' after input");

    return Input(userInput);
  }
}
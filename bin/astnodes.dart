import 'token.dart';

class Program {
  final List<Declaration> declarations;

  Program(this.declarations);
}

/* 
STATEMENTS 
*/
sealed class Declaration {}

sealed class Statement extends Declaration {}

class VarDeclaration extends Declaration {
  final Token name;
  final Expression initializer;

  VarDeclaration(this.name, this.initializer);
}

class FuncDeclaration extends Declaration {
  final Token name;
  final List<Token> parameters;
  final BlockStatement body;

  FuncDeclaration(this.name, this.parameters, this.body);
}

class ExprStatement extends Statement {
  final Expression expression;

  ExprStatement(this.expression);
}

class PrintStatement extends Statement {
  final Expression expression;

  PrintStatement(this.expression);
}

class CondStatement extends Statement {
  final List<(Expression, Statement)> branches;
  final Statement? elseBranch;

  CondStatement(this.branches, this.elseBranch);
}

class WhileStatement extends Statement {
  final Expression condition;
  final Statement body;

  WhileStatement(this.condition, this.body);
}

class ForStatement extends Statement {
  final Declaration? initializer;
  final Expression? condition;
  final Expression? increment;
  final Statement body;

  ForStatement(
    this.initializer,
    this.condition,
    this.increment,
    this.body,
  );
}

class RetStatement extends Statement {
  final Expression? value;

  RetStatement(this.value);
}

class BreakStatement extends Statement {}

class ContStatement extends Statement {}

class BlockStatement extends Statement {
  final List<Declaration> declarations;

  BlockStatement(this.declarations);
}

/* 
EXPRESSIONS
- The various precedence levels are handled by the stratification of the functions in parser.dart
    to reflect the written grammar in README.md
+ an example of which is the LOGICALAND and LOGICALOR, both are under the logical node
but in the parser,   Expression _parseLogicalOR() sits higher than   Expression _parseLogicalAND() {
*/
sealed class Expression {}

class Assignment extends Expression {
  final Token name;
  final Expression value;

  Assignment(this.name, this.value);
}

class Logical extends Expression {
  final Expression left;
  final Token operator;
  final Expression right;

  Logical(this.left, this.operator, this.right);
}

// Handles all the arithmetic operators and relational operators
class Binary extends Expression {
  final Expression left;
  final Token operator;
  final Expression right;

  Binary(this.left, this.operator, this.right);
}

class Unary extends Expression {
  final Token operator;
  final Expression right;

  Unary(this.operator, this.right);
}

class Grouping extends Expression {
  final Expression expression;

  Grouping(this.expression);
}

class Literal extends Expression {
  final Object? value;

  Literal(this.value);
}

class Variable extends Expression {
  final Token name;

  Variable(this.name);
}

class Call extends Expression {
  final Token name;
  final List<Expression> arguments;

  Call(this.name, this.arguments);
}

class Input extends Expression {
  final Expression? prompt;

  Input(this.prompt);
}

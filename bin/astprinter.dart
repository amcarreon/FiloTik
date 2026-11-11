import 'astnodes.dart';

// (one line parenthesized)

class ASTPrinter() {
    // helper methods
    // string builder for the linked chain of nodes
    String _build (String head, Iterable<String> nodes) {
        final sb = StringBuffer('(')..write(head);
        for (final node in nodes) {
            sb
                ..write(' ')
                ..write(node);
        }
        sb.write(')');
        return sb.toString().trim();
    }

    // for literals
    String _formLiteral (Object? value) {
        if (value == null) return 'waley'; // nil
        if (value is bool) return value ? 'omsim' : 'nonsince'; // true or false
        if (value is num) return value.toString(); // printing of numbers
        if (value is String) return '"$value"'; // printing of strings
        return '$value';
    }

    // parsed list
    String print(Program program) => program.declarations.map(_declaration).join('\n');

    String _declaration(Declaration d) {
        switch (d) {
            case VarDeclaration node: 
            // "ang" IDENTIFIER "=" expression ";;"
                return _build('ang', [node.name.lexeme, _expression(node.initializer)]);

            case FuncDeclaration node:
            // "avisala" IDENTIFIER "(" parameters? ")" block
                final params = '(${node.parameters.map((t) => t.lexeme).join(' ')})';
                final body = _statement(node.body);
                
                return _build('avisala', [node.name.lexeme, params, body]);
            
            case Statement node:
            // statement nodes
                return _statement(node);
        }    
    }

    String _statement(Statement s) {
        switch (s) {
            case ExprStatement node:
            // expression ";;"
                return _expression(node.expression);

            case PrintStatement node:
            // "imnida" expression ";;"
                return _build('imnida', [_expression(node.expression)]);
            
            case CondStatement node:
            /*
              "pwidi" "(" expression ")" statement
              ( "piro" "(" expression ")" statement )*
              ( "dipindi" statement )?
            */
                final parts = <String>[];
                for (var i = 0; i < node.branches.length; i++) {
                    final (condition, body) = node.branches[i];
                    final head;
                    if (i == 0) {
                      head = 'pwidi';
                    } else {
                      head = 'piro';
                    }
                    
                    parts.add(_build(head, [_expression(condition), _statement(body)]));
                }

                if (node.elseBranch != null) parts.add(_build('dipindi', [_statement(node.elseBranch!)]));

                return _build('cond', parts);

            case WhileStatement node:
            // while_stmt    → "whiletch" "(" expression ")" statement
                return _build('whiletch', [_expression(node.condition), _statement(node.body)]);

            case ForStatement node:
            /*
              "forda" "(" ( var_decl | expr_stmt | ";;" )
              expression? ";;" expression? ")" statement
            */
                return _build('forda', [
                    node.initializer == null ? '_' : _declaration(node.initializer!),
                    node.condition == null ? '_' : _expression(node.condition!),
                    node.increment == null? '_' : _expression(node.increment!),
                    _declaration(node.body),
                ]);

            case RetStatement node:
            // "ohsimon" expression? ";;"
                return _build('ohsimon', [if (node.value != null) _expression(node.value!)]);
            
            case BreakStatement():
            // "aynakatulog" ";;"
                return _build('aynakatulog', const []);
             
            case ContStatement():
            // "oops" ";;"
                return _build('oops', const[]);

            case BlockStatement node:
            // "{" declaration* "}"
                return _build('block', node.declarations.map(_declaration));
        }
    }

    // expression building and printing
    String _expression(Expression e) {
        switch (e) {
            case Literal node:
                return _formLiteral(node.value);

            case Variable node:
                return node.name.lexeme;
            
            case Grouping node:
                return _build('grp', [_expression(node.expression)]);
            
            case Unary node:
                return _build(node.operator.lexeme, [_expression(node.right)]);

            case Binary node:
                return _build(node.operator.lexeme, ([_expression(node.left), _expression(node.right)]));

            case Logical node:
                return _build(node.operator.lexeme, ([_expression(node.left), _expression(node.right)]));

            case Assignment node:
                return _build('=', [node.name.lexeme, _expression(node.value)]);
            
            case Call node:
                return _build('yoohoo', [node.name.lexeme, ...node.arguments.map(_expression)]);
            
            case Input node:
                return _build('sabihinmona', [if (node.prompt != null) _expression(node.prompt!)]);
        }
    }

}

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
        if (value == null) return 'waley';
        if (value is bool) return value ? 'omsim' : 'nonsince';
        if (value is num) return value.toString();
        if (value is String) return '"$value"';
        return '$value';
    }

    // parsed list
    String print(Program program) => program.declarations.map(_declaration).join('\n');

    String printExpr(Expression e) => _expression(e);

    String _declaration(Declaration d) {
        switch (d) {
            case VarDeclaration node:
                    return _build('ang', [node.name.lexeme, _expression(node.initializer)]);

            case FuncDeclaration node:
                final params = '(${node.parameters.map((t) => t.lexeme).join(' ')})';
                final body = _statement(node.body);
                
                return _build('avisala', [node.name.lexeme, params, body]);
            
            case Statement node:
                return _statement(node);
        }    
    }

    String _statement(Statement s) {
        switch (s) {
            case ExprStatement node:
                return _expression(node.expression);

            case PrintStatement node:
                return _build('sabihinmona', [_expression(node.expression)]);
            
            case CondStatement node:
                final parts = <String>[];
                for (final (condition, body) in node.branches) {
                    parts.add(_build(_expression(condition), [_statement(body)]));
                }

                if (node.elseBranch != null) parts.add(_build('dipindi', [_statement(node.elseBranch!)]));

                return _build('pwidi', parts);

            case WhileStatement node:
                return _build('whiletch', [_expression(node.condition), _statement(node.body)]);

            case ForStatement node:
                return _build('forda', [
                    node.initializer == null ? '_' : _declaration(node.initializer!),
                    node.condition == null ? '_' : _expression(node.condition!),
                    node.increment == null? '_' : _expression(node.increment!),
                    _declaration(node.body),
                ]);

            case RetStatement node:
                return _build('ohsimon', [if (node.value != null) _expression(node.value!)]);
            
            case BreakStatement():
                return _build('aynakatulog', const []);
             
            case ContStatement():
                return _build('oops', const[]);

            case BlockStatement node:
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
                return _build('imnida', [if (node.prompt != null) _expression(node.prompt!)]);
        }
    }

}

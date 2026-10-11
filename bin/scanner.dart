import 'token.dart';

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
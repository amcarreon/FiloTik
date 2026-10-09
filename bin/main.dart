import 'dart:convert';
import 'dart:io';

import 'token.dart';
import 'scanner.dart';
import 'parser.dart';


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
    // fail('expected one source-file path');
    runrepl();
    return;
  }

  final path = arguments.last;
  final command = arguments.first;

  if (command == '--tokenize'){
    try {
    final source = File(path).readAsStringSync(encoding: utf8); 
        run(source, false);
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
  exit(0);
}

// running the REPL
void runrepl() {
    
    for(;;) {
        stdout.write('> ');
        final line = stdin.readLineSync(encoding: utf8);

        if (line == null || line.trim() == ".exitrepl") {
            stdout.writeln();
            break; // EOF
        }

        run(line, true);        
    }
}

void run(String source, bool replMode) {
    try {
        final scanner = Scanner(source);
        scanner.scanTokens();

        for (final token in scanner.tokens) {  
            // prints tokens except EOF when error
            if (scanner.errorFlag && token.type == TokenType.termFile) break;
            stdout.writeln(token.toString()); 
        }

        if (scanner.errorFlag == true) {
            if (scanner.errorTypes.contains(1) == true) {
                for (final error in scanner.errorLines) {
                    if (error.$1 == 1) {
                        stderr.writeln('lab1: unrecognized character(s) at line ${error.$2}: ${error.$3.trimRight()}');
                    }
                }
            }
            if (scanner.errorTypes.contains(2) == true) {
                for (final error in scanner.errorLines) {
                    if (error.$1 == 2) {
                        stderr.writeln('lab1: unterminated string(s) at line ${error.$2}: ${error.$3.trimRight()}');
                    }
                }
            }

            if (replMode == false){
                fail_scanner('tokenization failed.');
            }

        }      
    } catch (error) {
        stderr.write('lab1: $error');
    }
}

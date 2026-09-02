import 'dart:convert';
import 'dart:io';

Never fail(String message) {
  stderr.writeln('lab0: $message');
  exit(65);
}

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    fail('expected one source-file path');
  }

  final path = arguments.first;

  try {
    final source = File(path).readAsStringSync(encoding: utf8);
    stdout.write(source);
  } on FileSystemException catch (error) {
    fail("cannot read '$path': ${error.message}");
  }
}

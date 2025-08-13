import 'dart:io';

void main() {
  final changed = File('pubspec.yaml').readAsStringSync();
  if (RegExp(r'^version:\s*(\S+)', multiLine: true).hasMatch(changed)) {
    if (!File('CHANGELOG.md').existsSync()) {
      stderr.writeln('CHANGELOG.md missing when version changed.');
      exit(1);
    }
  }
}

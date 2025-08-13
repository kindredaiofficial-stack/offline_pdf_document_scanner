// dart run scripts/bump_version.dart 1.0.1
import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run scripts/bump_version.dart <version>');
    exit(64);
  }
  final version = args.first;
  final pubspec = File('pubspec.yaml');
  final text = pubspec.readAsStringSync();
  final updated = text.replaceFirst(RegExp(r'^version: .+$', multiLine: true), 'version: $version+1');
  pubspec.writeAsStringSync(updated);
  stdout.writeln('Bumped to $version');
}

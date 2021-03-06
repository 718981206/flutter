// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_tools/src/build_system/build_system.dart';
import 'package:flutter_tools/src/build_system/targets/dart.dart';
import 'package:flutter_tools/src/cache.dart';
import 'package:flutter_tools/src/commands/build.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_tools/src/globals.dart' as globals;

import '../../src/common.dart';
import '../../src/mocks.dart';
import '../../src/testbed.dart';

void main() {
  Testbed testbed;

  setUpAll(() {
    Cache.disableLocking();
  });

  tearDownAll(() {
    Cache.enableLocking();
  });

  setUp(() {
    testbed = Testbed(overrides: <Type, Generator>{
      BuildSystem: () => MockBuildSystem(),
    });
  });

  test('invokes assemble for android aot build.', () => testbed.run(() async {
    globals.fs.file('pubspec.yaml').createSync();
    globals.fs.file('.packages').createSync();
    globals.fs.file(globals.fs.path.join('lib', 'main.dart')).createSync(recursive: true);
    when(buildSystem.build(any, any)).thenAnswer((Invocation invocation) async {
      return BuildResult(success: true);
    });
    final BuildCommand command = BuildCommand();
    applyMocksToCommand(command);

    await createTestCommandRunner(command).run(<String>[
      'build',
      'aot',
      '--target-platform=android-arm',
      '--no-pub',
    ]);

    final Environment environment = verify(buildSystem.build(any, captureAny)).captured.single as Environment;
    expect(environment.defines, <String, String>{
      kTargetFile: globals.fs.path.absolute(globals.fs.path.join('lib', 'main.dart')),
      kBuildMode: 'release',
      kTargetPlatform: 'android-arm',
    });
  }));
}

class MockBuildSystem extends Mock implements BuildSystem {}

import 'package:flutter/cupertino.dart';
import 'package:test/test.dart';
import 'package:audioscribe/test_utils/test_constants.dart';
import 'dart:io';

import 'package:audioscribe/utils/file_ops/file_to_txt_converter.dart';

void main() {
  test('fileToTxtConverter runs', () async {
    WidgetsFlutterBinding.ensureInitialized();
    File outputFile = File('$testResourcesOutputsPath/example_pdf.pdf');
    if (outputFile.existsSync()) {
      outputFile.delete();
    }
    await convertFileToTxt('$testResourcesInputsPath/example_pdf.pdf', testResourcesOutputsPath);
    expect(true, true);
  });
}
import 'package:flutter/cupertino.dart';
import 'package:test/test.dart';
import 'package:audioscribe/test_utils/test_constants.dart';

import 'package:audioscribe/services/txt_summary_service.dart';

void main() {
  test('fileToTxtConverter runs', () async {
    WidgetsFlutterBinding.ensureInitialized();
    print(await TxtSummarizerService.txtSummary(
        '$testResourcesInputsPath/example_to_summarize.txt', 5));
    expect(true, true);
  });
}

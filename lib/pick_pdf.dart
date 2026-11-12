import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import 'app_state.dart';
import 'ui.dart';

/// Telefondan PDF tanlatib, ilovaga qo'shadi.
/// [subjectId] va [kind] berilsa, shu fanning bo'limiga qo'shiladi;
/// bo'sh bo'lsa "Shaxsiy kitob" bo'limiga.
Future<bool> pickAndAddPdf(
  BuildContext context, {
  String? subjectId,
  String? kind,
}) async {
  const typeGroup = XTypeGroup(
    label: 'PDF',
    extensions: <String>['pdf'],
    mimeTypes: <String>['application/pdf'],
    uniformTypeIdentifiers: <String>['com.adobe.pdf'],
  );
  try {
    final XFile? file =
        await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file == null) return false;
    await app.addPersonalBook(file, subjectId: subjectId, kind: kind);
    return true;
  } catch (e) {
    if (context.mounted) showSnack(context, errorText(e));
    return false;
  }
}

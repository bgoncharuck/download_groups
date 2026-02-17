import '../model/download_result/download_result.dart';

// ignore: one_member_abstracts
abstract class DownloadStrategy {
  Future<DownloadGroupsResult> downloadFile({
    required String url,
    required String path,
    String? id,
  });
}

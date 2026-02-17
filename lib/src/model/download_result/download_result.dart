import 'status/download_status.dart';

class DownloadGroupsResult {
  const DownloadGroupsResult({
    required this.id,
    required this.url,
    required this.status,
  });

  final String id;
  final String url;
  final DownloadGroupsStatus status;
}

extension DownloadGroupsResultExtension on Iterable<DownloadGroupsResult> {
  DownloadGroupsResult?
  firstOccurrenceOfStatus<S extends DownloadGroupsStatus>() {
    if (any((result) => result.status is S)) {
      return firstWhere(
        (result) => result.status is S,
      );
    }
    return null;
  }
}

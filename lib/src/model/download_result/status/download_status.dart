abstract class DownloadGroupsStatus {
  String get name;
  bool get isError;
}

class DownloadGroupsError implements DownloadGroupsStatus {
  const DownloadGroupsError();

  @override
  String get name => 'error';

  @override
  bool get isError => true;
}

class DownloadGroupsSuccess implements DownloadGroupsStatus {
  const DownloadGroupsSuccess();

  @override
  String get name => 'success';

  @override
  bool get isError => false;
}

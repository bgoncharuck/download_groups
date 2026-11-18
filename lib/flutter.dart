/// A Flutter-only convenience layer for [package:download_groups/download_groups.dart].
///
/// This is optional — import it only if you want Flutter-friendly
/// [ValueNotifier]-based progress tracking. Pure Dart consumers should
/// continue to import [package:download_groups/download_groups.dart].
///
/// Example:
/// ```dart
/// import 'package:download_groups/flutter.dart';
///
/// final helper = DownloadGroupsFlutter(
///   DioDownloadGroupsHandler(logger: AssetDownloaderLogger(debugPrint)),
/// );
/// ```

export 'download_groups.dart';
export 'src/flutter/download_groups_flutter.dart';

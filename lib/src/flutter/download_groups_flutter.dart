import 'package:download_groups/download_groups.dart';
import 'package:flutter/foundation.dart';

/// A Flutter-friendly wrapper around [DownloadGroupsHandler].
///
/// Exposes download progress as [ValueNotifier]s so UI layers can bind to
/// them directly, and provides convenience methods that combine
/// [DownloadGroupsHandler.areAssetsDownloaded] and
/// [DownloadGroupsHandler.syncDownloadGroups] into common app flows.
///
/// This is an optional Flutter-only helper. Pure Dart consumers can continue
/// to use [DownloadGroupsHandler] directly without any Flutter dependency —
/// import [package:download_groups/download_groups.dart] instead of this file.
///
/// Example:
/// ```dart
/// final helper = DownloadGroupsFlutter(assetsDownloader);
///
/// final ready = await helper.checkIfAssetsAreDownloaded(
///   groups: downloadGroups.values,
///   appDomains: appDomains,
/// );
/// if (!ready) {
///   await helper.executeDownload(
///     groups: downloadGroups.values,
///     appDomains: appDomains,
///   );
/// }
///
/// // Bind to UI:
// helper.downloadProgressText;      // '3/10'
// helper.downloadProgressPercentage;// 30
/// ```
class DownloadGroupsFlutter {
  /// Creates a helper wrapping [handler].
  DownloadGroupsFlutter(this.handler);

  /// The underlying download handler.
  final DownloadGroupsHandler handler;

  /// Result of the last download operation.
  final ValueNotifier<DownloadGroupsResult?> downloadResult =
      ValueNotifier<DownloadGroupsResult?>(null);

  /// Text display for download progress, e.g. `'3/10'` or `'0/?'`.
  final ValueNotifier<String> downloadProgressText = ValueNotifier<String>('0/?');

  /// Percentage of download progress, `0`–`100`.
  final ValueNotifier<int> downloadProgressPercentage = ValueNotifier<int>(0);

  /// Callback to pass as [DownloadGroupsHandler.syncDownloadGroups]'s
  /// [onProgress] argument. Updates [downloadProgressText] and
  /// [downloadProgressPercentage].
  void Function(int received, int total) get progressCallback =>
      (completed, total) {
        downloadProgressText.value = '$completed/$total';
        downloadProgressPercentage.value =
            total == 0 ? 0 : (completed / total * 100).toInt();
      };

  /// Checks if all assets in [groups] are already downloaded.
  ///
  /// If [downloadResult] already holds a [DownloadGroupsSuccess], returns
  /// `true` immediately. Otherwise delegates to
  /// [handler.areAssetsDownloaded] and, when assets are present, records a
  /// success result and sets the progress notifiers to `n/n` and `100%`.
  Future<bool> checkIfAssetsAreDownloaded({
    required Iterable<DownloadGroup> groups,
    required List<String> appDomains,
  }) async {
    if (downloadResult.value?.status is DownloadGroupsSuccess) return true;

    final result = await handler.areAssetsDownloaded(groups, appDomains);

    if (result) {
      final count = groups.length;
      downloadResult.value = const DownloadGroupsResult(
        id: 'sync_assets',
        url: '',
        status: DownloadGroupsSuccess(),
      );
      downloadProgressText.value = '$count/$count';
      downloadProgressPercentage.value = 100;
    }
    return result;
  }

  /// Executes the asset download process if assets are not already downloaded.
  ///
  /// Returns `true` when assets are ready (either already downloaded or just
  /// downloaded successfully), `false` otherwise.
  Future<bool> executeDownload({
    required Iterable<DownloadGroup> groups,
    required List<String> appDomains,
  }) async {
    final assetsReady = await checkIfAssetsAreDownloaded(
      groups: groups,
      appDomains: appDomains,
    );
    if (assetsReady) {
      return true;
    }

    await _performDownload(groups: groups, appDomains: appDomains);
    return checkIfAssetsAreDownloaded(
      groups: groups,
      appDomains: appDomains,
    );
  }

  /// Downloads all assets in [groups] and records the [downloadResult].
  Future<void> _performDownload({
    required Iterable<DownloadGroup> groups,
    required List<String> appDomains,
  }) async {
    try {
      final result = await handler.syncDownloadGroups(
        groups: groups,
        appDomains: appDomains,
        onProgress: progressCallback,
      );
      downloadResult.value = result;
    } catch (e) {
      downloadResult.value = const DownloadGroupsResult(
        id: 'sync_assets',
        url: '',
        status: DownloadGroupsError(),
      );
      rethrow;
    }
  }

  /// Disposes the internal [ValueNotifier]s.
  ///
  /// Call this when the helper is no longer needed (e.g. in a controller's
  /// dispose) to avoid memory leaks.
  void dispose() {
    downloadResult.dispose();
    downloadProgressText.dispose();
    downloadProgressPercentage.dispose();
  }
}

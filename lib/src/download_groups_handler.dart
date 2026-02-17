import 'model/asset_group.dart';
import 'model/download_group.dart';
import 'model/download_result/download_result.dart';

/// Abstract interface for handling download groups operations.
///
/// This interface provides the core functionality for downloading and managing
/// groups of assets from remote servers. It supports checking download status,
/// synchronizing assets, and retrieving local file paths.
///
/// Typical usage:
/// ```dart
/// final handler = DioDownloadGroupsHandler(logger: logger);
///
/// // Check if assets are already downloaded
/// final areDownloaded = await handler.areAssetsDownloaded(groups, domains);
///
/// // Download assets with progress tracking
/// final result = await handler.syncDownloadGroups(
///   groups: groups,
///   appDomains: domains,
///   onProgress: (completed, total) => print('Progress: $completed/$total'),
/// );
/// ```
abstract class DownloadGroupsHandler {
  /// Checks if all assets in the specified groups are already downloaded.
  ///
  /// [groups] - Collection of download groups to check
  /// [appDomains] - List of base domains to use for URL resolution
  ///
  /// Returns `true` if all assets exist locally, `false` otherwise.
  Future<bool> areAssetsDownloaded(
    Iterable<DownloadGroup> groups,
    List<String> appDomains,
  );

  /// Synchronously downloads all assets from the specified groups.
  ///
  /// This method downloads assets from multiple groups with progress tracking.
  /// It will attempt to download from the fastest available domain.
  ///
  /// [groups] - Collection of download groups to synchronize
  /// [appDomains] - List of domains to try downloading from (ordered by preference)
  /// [onProgress] - Callback function to track download progress (completed, total)
  /// [id] - Optional identifier for this download operation
  ///
  /// Returns a [DownloadGroupsResult] containing the operation status and details.
  Future<DownloadGroupsResult> syncDownloadGroups({
    required Iterable<DownloadGroup> groups,
    required List<String> appDomains,
    required void Function(int completed, int total) onProgress,
    String? id,
  });

  /// Synchronously downloads all assets from a single asset group.
  ///
  /// [group] - The asset group to download
  /// [id] - Optional identifier for this download operation
  ///
  /// Returns a [DownloadGroupsResult] containing the operation status and details.
  Future<DownloadGroupsResult> syncAssetGroup({
    required AssetGroup group,
    String? id,
  });

  /// Retrieves the local file path for a given asset filename.
  ///
  /// [filename] - The filename of the asset to locate
  ///
  /// Returns the absolute path to the local file if it exists, `null` otherwise.
  String? getAssetPath(String filename);

  /// Retrieves the local file path for an asset given its original URL.
  ///
  /// [url] - The original URL of the downloaded asset
  ///
  /// Returns the absolute path to the local file if it exists, `null` otherwise.
  String? getAssetPathByUrl(String url);
}

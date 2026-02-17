import '../asset_path/asset_path.dart';
import '../domain_connection/interface.dart';
import '../download_groups_handler.dart';
import '../download_strategy/interface.dart';
import '../logger/ass_downloader_logger.dart';
import '../model/asset_group.dart';
import '../model/download_group.dart';
import '../model/download_result/download_result.dart';
import '../model/download_result/status/download_errors.dart';
import '../model/download_result/status/download_status.dart';
import '../model/download_result/status/download_success.dart';

class DIDownloadGroupsHandler implements DownloadGroupsHandler {
  const DIDownloadGroupsHandler({
    required this.connectionChecker,
    required this.download,
    required this.assetPath,
    required this.logger,
    this.maxConcurrentDownloads = 3,
  });

  final ConnectionCheckerStrategy connectionChecker;
  final DownloadStrategy download;
  final AssetPath assetPath;
  final int maxConcurrentDownloads;
  final AssetDownloaderLogger logger;

  @override
  Future<bool> areAssetsDownloaded(
    Iterable<DownloadGroup> groups,
    List<String> appDomains,
  ) async {
    for (final group in groups) {
      group.init(appDomains.first);
    }

    final allUrls =
        groups
            .expand((group) => group.assets.values)
            .expand((assetGroup) => assetGroup.urls)
            .toSet();
    final missingFiles = await findMissingFileUrls(allUrls);

    return missingFiles.isEmpty;
  }

  @override
  Future<DownloadGroupsResult> syncDownloadGroups({
    required Iterable<DownloadGroup> groups,
    required List<String> appDomains,
    required void Function(int completed, int total) onProgress,
    String? id,
  }) async {
    final uniqueId = id ?? groups.join();

    /// select best domain and init download groups with it
    final reachableDomains = await connectionChecker.isConnected(appDomains);
    // debugger();
    if (reachableDomains.isEmpty) {
      /// check if app can be used offline
      final canBeUsedOffline = await checkIfFilesAreAlreadyDownloaded(
        groups: groups,
        appDomains: appDomains,
        id: uniqueId,
      );
      if (canBeUsedOffline != null) {
        return canBeUsedOffline;
      }

      return DownloadGroupsResult(
        id: uniqueId,
        url: '',
        status: DomainsNotReachableError(appDomains),
      );
    }
    final selectedDomain = reachableDomains.first;
    try {
      for (final downloadGroup in groups) {
        downloadGroup.init(selectedDomain);
      }
    } catch (e, t) {
      await logger.exception(e, t);
      return DownloadGroupsResult(
        id: id!,
        url: '',
        status: const DownloadGroupWasNotInitialized(),
      );
    }

    /// create download scenarios
    final downloadScenarios = <AssetGroup>[];
    for (final downloadGroup in groups) {
      downloadScenarios.addAll(downloadGroup.assets.values);
    }

    /// prepare downloads
    final downloads = <Future<DownloadGroupsResult>>[];
    for (final downloadScenario in downloadScenarios) {
      downloads.add(syncAssetGroup(group: downloadScenario));
    }

    /// track have many groups we download
    final downloadsCount = downloads.length;
    var completed = 0;
    onProgress(completed, downloadsCount);
    final trackedDownloads =
        downloads.map((future) async {
          final result = await future;
          completed++;
          onProgress(completed, downloadsCount);
          return result;
        }).toList();

    /// download
    final downloadResults = <DownloadGroupsResult>[];
    try {
      downloadResults.addAll(await Future.wait(trackedDownloads));
    } catch (e, t) {
      await logger.exception(e, t);
      return DownloadGroupsResult(
        id: uniqueId,
        url: '',
        status: const EventLoopOverflowError(),
      );
    }

    /// on any error return the most important one
    if (downloadResults.any((result) => result.status.isError)) {
      return errorPriority(downloadResults, id!);
    }

    return DownloadGroupsResult(
      id: uniqueId,
      url: '',

      /// you can use FilesWereDownloadedSuccessfully if needed
      status: const DownloadGroupsSuccess(),
    );
  }

  Future<DownloadGroupsResult?> checkIfFilesAreAlreadyDownloaded({
    required Iterable<DownloadGroup> groups,
    required List<String> appDomains,
    required String id,
  }) async {
    for (final group in groups) {
      group.init(appDomains.first);
    }
    final listOfFiles = [
      for (final group in groups)
        for (final aGroup in group.assets.values) ...aGroup.urls,
    ];

    final missingFiles = await findMissingFileUrls(listOfFiles);
    if (missingFiles.isEmpty) {
      return DownloadGroupsResult(
        id: id,
        url: '',
        status: FilesAlreadyDownloaded(fileUrls: listOfFiles),
      );
    }
    return null;
  }

  DownloadGroupsResult errorPriority(
    List<DownloadGroupsResult> results,
    String id,
  ) {
    DownloadGroupsResult? orderedResult;

    orderedResult ??=
        results.firstOccurrenceOfStatus<NoUrlsProvidedInAssetGroupError>();
    orderedResult ??=
        results.firstOccurrenceOfStatus<DomainsNotReachableError>();
    orderedResult ??=
        results
            .firstOccurrenceOfStatus<NoFilesWereDownloadedSuccessfullyError>();
    orderedResult ??=
        results.firstOccurrenceOfStatus<SomeFilesWereNotDownloadedError>();

    if (orderedResult != null) {
      return orderedResult;
    }

    return DownloadGroupsResult(
      id: id,
      url: '',
      status: const DownloadGroupsError(),
    );
  }

  @override
  Future<DownloadGroupsResult> syncAssetGroup({
    required AssetGroup group,
    String? id,
  }) async {
    final uniqueId = id ?? group.assets.join();

    if (group.urls.isEmpty) {
      return DownloadGroupsResult(
        id: uniqueId,
        url: '',
        status: const NoUrlsProvidedInAssetGroupError(),
      );
    }

    final missingFiles = await findMissingFileUrls(group.urls);
    if (missingFiles.isEmpty) {
      return DownloadGroupsResult(
        id: uniqueId,
        url: '',
        status: const FilesAlreadyDownloaded(),
      );
    }

    final downloadResults = await downloadFiles(missingFiles);
    final successfullyDownloadedFiles = <String>[];
    final failedDownloads = <String>[];

    for (final result in downloadResults) {
      if (result.status is DownloadGroupsSuccess) {
        successfullyDownloadedFiles.add(result.url);
      } else {
        failedDownloads.add(result.url);
      }
    }

    final savePath = await assetPath.savePath;
    for (final url in successfullyDownloadedFiles) {
      final file = assetPath.getFileNameFromUrl(url);
      final path = '$savePath/$file'..replaceAll('/', '//');
      assetPath.put(file, path);
    }

    if (failedDownloads.isNotEmpty) {
      await logger.message(
        '[DIDownloadGroupsHandler]: Files were not downloaded: ${failedDownloads.join(', ')}',
      );

      if (successfullyDownloadedFiles.isEmpty) {
        return DownloadGroupsResult(
          id: uniqueId,
          url: '',
          status: NoFilesWereDownloadedSuccessfullyError(failedDownloads),
        );
      }

      return DownloadGroupsResult(
        id: uniqueId,
        url: '',
        status: SomeFilesWereNotDownloadedError(failedDownloads),
      );
    }

    return DownloadGroupsResult(
      id: uniqueId,
      url: '',
      status: FilesWereDownloadedSuccessfully(successfullyDownloadedFiles),
    );
  }

  Future<List<DownloadGroupsResult>> downloadFiles(
    Iterable<String> urls,
  ) async {
    final results = <DownloadGroupsResult>[];
    final urlList = urls.toList();

    // Process in chunks to avoid overwhelming the network / event loop
    for (var i = 0; i < urlList.length; i += maxConcurrentDownloads) {
      final chunk = urlList.skip(i).take(maxConcurrentDownloads);

      final chunkFutures =
          chunk.map((url) async {
            final fileName = assetPath.getFileNameFromUrl(url);
            final savePath = await assetPath.fileSavePath(fileName);
            return download.downloadFile(url: url, path: savePath);
          }).toList();

      final chunkResults = await Future.wait(chunkFutures);
      results.addAll(chunkResults);
    }

    return results;
  }

  Future<List<String>> findMissingFileUrls(Iterable<String> urls) async {
    final missingFiles = <String>[];
    for (final url in urls) {
      if (!await fileExists(url)) {
        missingFiles.add(url);
      }
    }
    return missingFiles;
  }

  Future<bool> fileExists(String url) async {
    //
    final fileName = assetPath.getFileNameFromUrl(url);
    final exists = await assetPath.exists(fileName);
    return exists;
  }

  @override
  String? getAssetPath(String filename) => assetPath.getFilePath(filename);

  @override
  String? getAssetPathByUrl(String url) => assetPath.getFilePathByUrl(url);
}

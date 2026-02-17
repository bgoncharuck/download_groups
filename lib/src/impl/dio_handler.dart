import 'package:dio/dio.dart';
import '../asset_path/impl.dart';
import '../domain_connection/impl/dio.dart';
import '../download_strategy/impl/dio.dart';
import '../logger/ass_downloader_logger.dart';
import 'di_handler.dart';

Dio _createSharedDio() {
  final options = BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
  );

  final dio = Dio(options);

  return dio;
}

class DioDownloadGroupsHandler extends DIDownloadGroupsHandler {
  DioDownloadGroupsHandler({AssetDownloaderLogger? logger})
    : this._internal(
        _createSharedDio(),
        logger ?? AssetDownloaderLogger((msg) {}),
      );

  DioDownloadGroupsHandler._internal(
    Dio sharedDio,
    AssetDownloaderLogger logger,
  ) : super(
        logger: logger,
        connectionChecker: DioPingStrategy(logger: logger, dio: sharedDio),
        download: DioDownloadStrategy(logger: logger, dio: sharedDio),
        assetPath: MappedAssetPath(),
        maxConcurrentDownloads: 3,
      );
}

import 'package:dio/dio.dart';
import '../../logger/ass_downloader_logger.dart';
import '../../model/download_result/download_result.dart';
import '../../model/download_result/status/download_status.dart';
import '../interface.dart';

class DioDownloadStrategy implements DownloadStrategy {
  const DioDownloadStrategy({
    required this.dio,
    required this.logger,
    this.maxRetries = 3,
  });

  final AssetDownloaderLogger logger;
  final Dio dio;
  final int maxRetries;

  @override
  Future<DownloadGroupsResult> downloadFile({
    required String url,
    required String path,
    String? id,
  }) async {
    final uniqueId = id ?? '$url:$path';
    var attempt = 0;

    while (attempt < maxRetries) {
      try {
        await dio.download(
          url,
          path,
          // ignore: avoid_redundant_argument_values
          deleteOnError: true, // always add! even if writes "redundant"
        );

        return DownloadGroupsResult(
          id: uniqueId,
          url: url,
          status: const DownloadGroupsSuccess(),
        );
      } on DioException catch (e) {
        attempt++;

        final statusCode = e.response?.statusCode ?? 0;
        final isServerSideError = statusCode >= 500;
        final isNetworkError =
            e.type != DioExceptionType.badResponse &&
            e.type != DioExceptionType.cancel;

        final shouldRetry = isNetworkError || isServerSideError;

        if (attempt >= maxRetries || !shouldRetry) {
          await logger.message(
            'DioDownloadStrategy: Failed after $attempt attempts. Status: $statusCode. URL: $url',
          );
          return DownloadGroupsResult(
            id: uniqueId,
            url: url,
            status: const DownloadGroupsError(),
          );
        }

        // network stabilization for Ukraine
        await Future<void>.delayed(Duration(seconds: attempt * 2));
      } catch (e, t) {
        await logger.exception(e, t);
        break;
      }
    }

    return DownloadGroupsResult(
      id: uniqueId,
      url: url,
      status: const DownloadGroupsError(),
    );
  }
}

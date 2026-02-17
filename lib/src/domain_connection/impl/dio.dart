import 'package:dio/dio.dart';
import '../../logger/ass_downloader_logger.dart';
import '../interface.dart';

class DioPingStrategy implements ConnectionCheckerStrategy {
  const DioPingStrategy({required this.logger, Dio? dio}) : _dio = dio;
  final AssetDownloaderLogger logger;
  final Dio? _dio;

  @override
  Future<List<String>> isConnected(List<String> urls) async {
    final pingDio =
        _dio ??
        Dio(
          BaseOptions(
            connectTimeout: const Duration(
              /// how long to wait
              seconds: 3,
            ),
            receiveTimeout: const Duration(seconds: 3),
          ),
        );

    final futures = urls.map((url) => _checkUrl(pingDio, url)).toList();

    try {
      final results = await Future.wait(futures);
      return results.where((url) => url.isNotEmpty).toList();
    } catch (e, t) {
      await logger.exception(e, t);
      return [];
    }
  }

  Future<String> _checkUrl(Dio dio, String url) async {
    try {
      final response = await dio.head<dynamic>(url);
      return response.statusCode == 200 ? url : '';
    } on DioException {
      return '';
    } catch (e) {
      return '';
    }
  }
}

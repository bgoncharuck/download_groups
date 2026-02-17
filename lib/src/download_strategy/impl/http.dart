// import 'dart:io';
// import '/infra/infra.dart';
// import '../../model/download_result/download_result.dart';
// import '../../model/download_result/status/download_status.dart';
// import '../interface.dart';

// Future<http.Response> httpGetWrapper(String url) async {
//   final httpClient = http.Client() as http.BaseClient;

//   final headers = <String, String>{};
//   headers['Content-Type'] = 'application/json; charset=UTF-8';

//   final result = await httpClient
//       .get(Uri.parse(url), headers: headers)
//       .timeout(
//         const Duration(seconds: 60),
//         onTimeout: () => http.Response('Request Timeout', 408),
//       );

//   httpClient.close();

//   return result;
// }

// class HttpDownloadStrategy implements DownloadStrategy {
//   const HttpDownloadStrategy();

//   @override
//   Future<DownloadGroupsResult> downloadFile({
//     required String url,
//     required String path,
//     String? id,
//   }) async {
//     final uniqueId = id ?? '$url:$path';

//     try {
//       final response = await httpGetWrapper(url);
//       if (response.statusCode != 200) {
//         await logger.message('Download failed, ${response.statusCode}, $path');
//         return DownloadGroupsResult(
//           id: uniqueId,
//           url: url,
//           status: const DownloadGroupsError(),
//         );
//       }

//       final file = await File(
//         path..replaceAll('/', '//'),
//       ).create(recursive: true);
//       await file.writeAsBytes(response.bodyBytes);
//       return DownloadGroupsResult(
//         id: uniqueId,
//         url: url,
//         status: const DownloadGroupsSuccess(),
//       );
//     } catch (e, t) {
//       await logger.exception(e, t);
//     }

//     return DownloadGroupsResult(
//       id: uniqueId,
//       url: url,
//       status: const DownloadGroupsError(),
//     );
//   }
// }

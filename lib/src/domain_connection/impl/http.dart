// import 'package:http/http.dart' as http;

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

// /// Checks the connection status of the provided URLs using HTTP ping.
// class HttpPingStrategy implements ConnectionCheckerStrategy {
//   const HttpPingStrategy();

//   /// Returns a list of URLs that are reachable.
//   /// Returns an empty list if none of the URLs are reachable.
//   @override
//   Future<List<String>> isConnected(List<String> urls) async {
//     final futures = <Future<String>>[];

//     for (final url in urls) {
//       futures.add(_notPing(url));
//     }

//     final availableDomains = <String>[];
//     try {
//       availableDomains.addAll(await Future.wait(futures));
//     } catch (e, t) {
//       await logger.exception(e, t);
//     }
//     return availableDomains.where((domain) => domain.isNotEmpty).toList();
//   }

//   /// Returns the URL if the response status code is 200 (OK),
//   /// otherwise returns an empty string
//   Future<String> _notPing(String url) async {
//     final response = await httpGetWrapper(url);
//     return response.statusCode == 200 ? url : '';
//   }
// }

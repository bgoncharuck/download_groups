/// Download Groups - A robust asset downloading library for Dart/Flutter
///
/// This library provides a powerful, battle-tested solution for downloading
/// and managing groups of assets from remote servers. With over 5 years of
/// production use, it offers reliable performance, flexible configuration,
/// and comprehensive error handling.
///
/// ## Features
///
/// - **Group-based Organization**: Organize assets into logical groups (e.g., images, icons, sounds)
/// - **Multi-domain Support**: Automatically try multiple domains for optimal download speed
/// - **Progress Tracking**: Real-time progress callbacks for download operations
/// - **Error Handling**: Comprehensive error types and recovery strategies
/// - **Caching**: Built-in file path management and caching
/// - **Flexible Logging**: Adaptable logging interface for any logging framework
///
/// ## Quick Start
///
/// ```dart
/// import 'package:download_groups/download_groups.dart';
///
/// // Create a handler
/// final handler = DioDownloadGroupsHandler(
///   logger: AssetDownloaderLogger(debugPrint),
/// );
///
/// // Define your asset groups
/// final groups = {
///   'animals': AnimalImages(),
///   'icons': UIIcons(),
/// };
///
/// // Download assets
/// final result = await handler.syncDownloadGroups(
///   groups: groups.values,
///   appDomains: ['https://cdn1.example.com', 'https://cdn2.example.com'],
///   onProgress: (completed, total) => print('Progress: $completed/$total'),
/// );
/// ```
///
/// ## Core Components
///
/// - [DownloadGroupsHandler] - Main interface for download operations
/// - [DownloadGroup] - Container for related asset groups
/// - [AssetGroup] - Defines a collection of related assets
/// - [AssetDownloaderLogger] - Flexible logging adapter
/// - [DownloadGroupsResult] - Result type for download operations

/// Core handler and implementation classes
export 'src/download_groups_handler.dart';
export 'src/impl/dio_handler.dart';
export 'src/logger/ass_downloader_logger.dart';

/// Model classes for defining download groups and assets
export 'src/model/asset_group.dart';
export 'src/model/download_group.dart';
export 'src/model/download_result/download_result.dart';
export 'src/model/download_result/status/download_errors.dart';
export 'src/model/download_result/status/download_status.dart';
export 'src/model/download_result/status/download_success.dart';

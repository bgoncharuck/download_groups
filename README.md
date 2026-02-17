# Download Groups

A battle-tested Dart/Flutter library for downloading and managing groups of assets from remote servers. With over 5 years of production use, this library provides reliable performance, flexible configuration, and comprehensive error handling.

## Features

- 🗂️ **Group-based Organization** - Organize assets into logical groups (images, icons, sounds, etc.)
- 🌐 **Multi-domain Support** - Automatically try multiple domains for optimal download speed
- 📊 **Progress Tracking** - Real-time progress callbacks for download operations
- 🛡️ **Error Handling** - Comprehensive error types and recovery strategies
- 💾 **Built-in Caching** - File path management and local asset caching
- 📝 **Flexible Logging** - Adaptable logging interface for any logging framework

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  download_groups: ^0.0.1
```

## Quick Start

### 1. Create a Download Handler

```dart
import 'package:download_groups/download_groups.dart';

// Using dependency injection (recommended)
class MyService {
  MyService(this.downloadHandler);
  
  final DownloadGroupsHandler downloadHandler;
}

// Register with your DI container
..registerSingleton<DownloadGroupsHandler>(
  DioDownloadGroupsHandler(
    logger: AssetDownloaderLogger((msg) => debugPrint(msg)),
  ),
)

// Or create directly
DownloadGroupsHandler downloadHandler = DioDownloadGroupsHandler(
  logger: AssetDownloaderLogger(debugPrint),
);
```

### 2. Define Your Asset Groups

```dart
// Define a collection of download groups
Map<String, DownloadGroup> get downloadGroups {
  return {
    'animals': AnimalImages(),
    'icons': UIIcons(),
    'sounds': SoundEffects(),
  };
}

// Example: Animal Images Download Group
class AnimalImages implements DownloadGroup {
  @override
  String get name => 'Animal Images';
  
  @override
  Map<String, AssetGroup> assets = {};
  
  var _initialized = false;
  
  @override
  void init(String domain) {
    if (!_initialized) {
      _initialized = true;
      assets.addAll({
        'mammals': MammalAssetGroup(domain),
        'birds': BirdAssetGroup(domain),
        'reptiles': ReptileAssetGroup(domain),
      });
    }
  }
}

// Example: Specific Asset Group for Dogs
class DogAssetGroup extends ImageAssetGroup {
  DogAssetGroup(String domain)
    : super(
        groupName: 'dogs',
        baseUrl: domain,
        assets: [
          'assets/images/animals/dog/husky.png',
          'assets/images/animals/dog/poodle.png',
          'assets/images/animals/dog/beagle.png',
          'assets/images/animals/dog/labrador.png',
        ],
        width: 120,
        height: 120,
      );
}
```

### 3. Check if Assets Are Already Downloaded

```dart
final areDownloaded = await downloadHandler.areAssetsDownloaded(
  downloadGroups.values,
  ['https://cdn1.example.com', 'https://cdn2.example.com'],
);

if (areDownloaded) {
  alreadyDownloadedActions();
} else {
  downloadActions();
}
```

### 4. Download Assets with Progress Tracking

```dart
try {
  final result = await downloadHandler.syncDownloadGroups(
    groups: downloadGroups.values,
    appDomains: [
      'https://cdn1.example.com',
      'https://cdn2.example.com',
      'https://cdn3.example.com',
    ],
    onProgress: (completed, total) {
      final percentage = (completed / total * 100).toStringAsFixed(1);
      print('Download progress: $percentage% ($completed/$total)');
    },
    id: 'main_asset_download',
  );
  
  if (result.status is DownloadGroupsSuccess) {
    print('Download completed successfully!');
  } else {
    print('Download failed: ${result.status.name}');
  }
} catch (e, stackTrace) {
  await logger.exception(e, stackTrace);
  print('Download failed with exception: $e');
}
```

### 5. Use Downloaded Assets in Your UI

```dart
class CachedAssetImage extends StatefulWidget {
  const CachedAssetImage(
    this.asset, {
    this.width,
    this.height,
    this.fit = BoxFit.fitWidth,
    super.key,
  });
  
  final String asset;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  State<CachedAssetImage> createState() => _CachedAssetImageState();
}

class _CachedAssetImageState extends State<CachedAssetImage> {
  late final Image cachedImage;

  @override
  void initState() {
    super.initState();
    
    // Get the local path for the downloaded asset
    final path = downloadHandler.getAssetPath('/${widget.asset}')
      ?.replaceAll('//', '/');
    
    if (path == null) {
      // Fallback to bundled asset if download failed
      cachedImage = Image.asset(
        'assets/images/placeholder.png',
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
    } else {
      // Use downloaded file
      cachedImage = Image.file(
        File(path),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
    }
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    await precacheImage(cachedImage.image, context);
  }

  @override
  Widget build(BuildContext) => cachedImage;
}
```

## Advanced Usage

### Custom Asset Groups

You can create specialized asset groups for different use cases:

```dart
// For audio files with metadata
class AudioAssetGroup extends DefaultAssetGroup {
  AudioAssetGroup({
    required super.groupName,
    required super.baseUrl,
    required super.assets,
    this.duration,
    this.bitrate,
  });

  final Duration? duration;
  final int? bitrate;
}

// For SVG icons with size specifications
class IconAssetGroup extends DefaultAssetGroup {
  IconAssetGroup({
    required super.groupName,
    required super.baseUrl,
    required super.assets,
    this.size = 24.0,
  });

  final double size;
}
```

### Error Handling

The library provides comprehensive error types:

```dart
switch (result.status) {
  case DownloadGroupsSuccess():
    print('All downloads successful');
    
  case NoUrlsProvidedInAssetGroupError():
    print('No URLs provided in asset group');
    
  case DomainsNotReachableError():
    print('Domains not reachable: ${(result.status as DomainsNotReachableError).domains}');
    
  case SomeFilesWereNotDownloadedError():
    final failedUrls = (result.status as SomeFilesWereNotDownloadedError).urls;
    print('Some files failed to download: $failedUrls');
    
  case NoFilesWereDownloadedSuccessfullyError():
    print('No files were downloaded successfully');
    
  case DownloadGroupWasNotInitialized():
    print('Download group was not initialized');
    
  case EventLoopOverflowError():
    print('Event loop overflow occurred');
}
```

### Custom Logging

Integrate with your existing logging framework:

```dart
// With a custom logger
final logger = AssetDownloaderLogger((message) {
  MyCustomLogger.log('DownloadGroups: $message', level: LogLevel.info);
});

// With structured logging
final logger = AssetDownloaderLogger((message) {
  final structured = {
    'timestamp': DateTime.now().toIso8601String(),
    'component': 'download_groups',
    'message': message,
  };
  StructuredLogger.log(structured);
});

// Silent logging (for production)
final logger = AssetDownloaderLogger((message) {});
```

## API Reference

### Core Classes

- **[DownloadGroupsHandler]** - Main interface for download operations
- **[DownloadGroup]** - Container for related asset groups
- **[AssetGroup]** - Defines a collection of related assets
- **[ImageAssetGroup]** - Provided asset group for images with dimensions
- **[DefaultAssetGroup]** - Basic implementation of AssetGroup
- **[AssetDownloaderLogger]** - Flexible logging adapter
- **[DownloadGroupsResult]** - Result type for download operations

### Error Types

- **[DownloadGroupsError]** - Base error class
- **[NoUrlsProvidedInAssetGroupError]** - No URLs in asset group
- **[DomainsNotReachableError]** - Domains unreachable
- **[SomeFilesWereNotDownloadedError]** - Partial download failure
- **[NoFilesWereDownloadedSuccessfullyError]** - Complete download failure
- **[DownloadGroupWasNotInitialized]** - Group not initialized
- **[EventLoopOverflowError]** - Event loop overflow

## Contributing

This library has been battle-tested in production for over 5 years. When contributing:

1. Preserve the existing API contracts
2. Maintain backward compatibility
3. Add comprehensive tests for new features
4. Update documentation for any API changes


## Author
Initial Creator: Bohdan Honcharuk https://github.com/bgoncharuck

## License
GNU LESSER GENERAL PUBLIC LICENSE Version 2.1
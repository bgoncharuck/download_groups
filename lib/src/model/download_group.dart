import 'asset_group.dart';

/// Represents a collection of related asset groups that can be downloaded together.
///
/// A [DownloadGroup] serves as a container for multiple [AssetGroup] instances,
/// allowing you to organize and manage related assets (e.g., all animal images,
/// all UI icons, all sound effects) as a single logical unit.
///
/// Each download group must be initialized with a base domain before use,
/// which will be passed to all contained asset groups for URL construction.
///
/// Example implementation:
/// ```dart
/// class AnimalImages implements DownloadGroup {
///   @override
///   String get name => 'Animal Images';
///
///   @override
///   Map<String, AssetGroup> assets = {};
///
///   var _initialized = false;
///
///   @override
///   void init(String domain) {
///     if (!_initialized) {
///       _initialized = true;
///       assets.addAll({
///         'mammals': MammalAssetGroup(domain),
///         'birds': BirdAssetGroup(domain),
///         'reptiles': ReptileAssetGroup(domain),
///       });
///     }
///   }
/// }
/// ```
abstract class DownloadGroup {
  /// A human-readable name for this download group.
  ///
  /// This name should be descriptive and unique among all download groups
  /// in your application. It's often used for logging, debugging, and UI display.
  String get name;

  /// A map of asset groups contained within this download group.
  ///
  /// The map keys should be descriptive identifiers for each asset group
  /// (e.g., 'mammals', 'birds', 'icons'), while the values are the
  /// corresponding [AssetGroup] instances.
  ///
  /// This map is populated during the [init] method call.
  Map<String, AssetGroup> get assets;

  /// Initializes the download group with the specified base domain.
  ///
  /// This method should be called once before using the download group.
  /// It initializes all contained asset groups with the provided domain
  /// for constructing download URLs.
  ///
  /// The method should be idempotent - calling it multiple times with
  /// the same domain should not cause issues.
  ///
  /// [domain] - The base domain URL (e.g., 'https://cdn.example.com')
  void init(String domain);
}

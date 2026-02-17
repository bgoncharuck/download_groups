/// Abstract class representing a group of related assets to be downloaded.
///
/// An [AssetGroup] defines a collection of assets that share a common base URL
/// and are typically related by theme, type, or purpose. For example, all animal
/// images, all UI icons, or all sound effects could each be represented as an
/// [AssetGroup].
///
/// This class provides the foundation for organizing assets into logical groups
/// and generating the appropriate download URLs for each asset.
///
/// Example usage:
/// ```dart
/// class DogImages extends DefaultAssetGroup {
///   DogImages(String domain)
///     : super(
///         groupName: 'dogs',
///         baseUrl: domain,
///         assets: [
///           'assets/images/dog/husky.png',
///           'assets/images/dog/poodle.png',
///           'assets/images/dog/beagle.png',
///         ],
///       );
/// }
/// ```
abstract class AssetGroup {
  /// A unique identifier for this asset group.
  ///
  /// The group name should be descriptive and unique within your application.
  /// It's often used for logging, caching, and asset path generation.
  ///
  /// Examples: 'animal_images', 'ui_icons', 'sound_effects'
  String get groupName;

  /// The base URL for constructing download URLs.
  ///
  /// This URL is combined with each asset path to create the complete
  /// download URL. It can be a full domain (https://cdn.example.com) or
  /// a path prefix (/assets/v1).
  ///
  /// The concrete implementation's constructor must provide this value.
  String get baseUrl;

  /// Collection of asset paths relative to the [baseUrl].
  ///
  /// Each entry represents the path to an individual asset within this group.
  /// These paths are combined with [baseUrl] to generate the complete download URLs.
  ///
  /// Examples: 'images/dog/husky.png', 'icons/home.svg', 'sounds/bark.mp3'
  Iterable<String> get assets;

  /// Generated download URLs for all assets in this group.
  ///
  /// This property provides the complete URLs by combining [baseUrl] with
  /// each asset path from the [assets] collection.
  ///
  /// For example, if [baseUrl] is 'https://cdn.example.com' and an asset
  /// path is 'images/dog/husky.png', the resulting URL would be:
  /// 'https://cdn.example.com/images/dog/husky.png'
  Iterable<String> get urls;
}

/// Specialized asset group for image assets with dimension specifications.
///
/// Extends [DefaultAssetGroup] to include width and height properties,
/// making it ideal for image assets where dimensions are important for
/// UI layout, caching strategies, or image processing.
///
/// Example usage:
/// ```dart
/// class AvatarImages extends ImageAssetGroup {
///   AvatarImages(String domain)
///     : super(
///         groupName: 'avatars',
///         baseUrl: domain,
///         assets: ['user1.png', 'user2.png', 'user3.png'],
///         width: 64.0,
///         height: 64.0,
///       );
/// }
/// ```
class ImageAssetGroup extends DefaultAssetGroup {
  /// Creates an image asset group with specified dimensions.
  ///
  /// [groupName] - Unique identifier for this group
  /// [baseUrl] - Base URL for constructing download URLs
  /// [assets] - Collection of image asset paths
  /// [width] - Width of the images in this group
  /// [height] - Height of the images in this group
  ImageAssetGroup({
    required super.groupName,
    required super.baseUrl,
    required super.assets,
    required this.width,
    required this.height,
  });

  /// The width of images in this asset group.
  ///
  /// This value can be used for UI layout calculations, image sizing,
  /// or caching strategies that consider image dimensions.
  final double width;

  /// The height of images in this asset group.
  ///
  /// This value can be used for UI layout calculations, image sizing,
  /// or caching strategies that consider image dimensions.
  final double height;
}

/// Default implementation of [AssetGroup] with standard URL construction.
///
/// This class provides a straightforward implementation that combines
/// a base URL with asset paths to create download URLs. It's suitable
/// for most use cases where simple URL concatenation is sufficient.
///
/// The URL construction follows the pattern: `{baseUrl}/{asset}`
///
/// Example:
/// ```dart
/// final group = DefaultAssetGroup(
///   groupName: 'icons',
///   baseUrl: 'https://cdn.example.com',
///   assets: ['home.svg', 'settings.svg', 'profile.svg'],
/// );
///
/// // Generated URLs:
/// // https://cdn.example.com/home.svg
/// // https://cdn.example.com/settings.svg
/// // https://cdn.example.com/profile.svg
/// ```
class DefaultAssetGroup implements AssetGroup {
  /// Creates a default asset group with the specified parameters.
  ///
  /// [groupName] - Unique identifier for this group
  /// [baseUrl] - Base URL for constructing download URLs
  /// [assets] - Collection of asset paths
  ///
  /// The constructor automatically generates the complete URLs by combining
  /// the base URL with each asset path.
  DefaultAssetGroup({
    required this.groupName,
    required this.baseUrl,
    required this.assets,
  }) {
    for (final asset in assets) {
      _urls.add('$baseUrl/$asset');
    }
  }

  @override
  final String groupName;

  @override
  final String baseUrl;

  @override
  final List<String> assets;

  final List<String> _urls = [];

  @override
  Iterable<String> get urls => _urls;
}

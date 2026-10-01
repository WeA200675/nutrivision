/// Keeps camera/gallery plugins outside the feature and domain layers.
abstract interface class PhotoSource {
  Future<List<int>?> capture();
  Future<List<int>?> pickFromGallery();
}

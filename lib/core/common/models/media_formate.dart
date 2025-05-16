part of 'models.dart';

class MediaFormat {
  String excellent;
  String good;
  String regular;
  MediaFormat({
    required this.excellent,
    required this.good,
    required this.regular,
  });

  toJson() {
    return excellent;
  }
}

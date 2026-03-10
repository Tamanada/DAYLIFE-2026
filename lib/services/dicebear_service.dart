import 'dart:math';
import '../core/constants.dart';

class DiceBearService {
  static String getAvatarUrl(String seed, {String style = 'adventurer', int size = 200}) {
    return AvatarStyles.url(style, seed, size: size);
  }

  static List<String> get styles => AvatarStyles.all;

  static Map<String, String> previewAll(String seed, {int size = 200}) {
    return {
      for (final style in AvatarStyles.all)
        style: AvatarStyles.url(style, seed, size: size),
    };
  }

  static String generateSeed() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  static String styleName(String style) => switch (style) {
    'adventurer' => 'Adventurer',
    'avataaars' => 'Avataaars',
    'bottts' => 'Robots',
    'fun-emoji' => 'Fun Emoji',
    'lorelei' => 'Lorelei',
    'notionists' => 'Notionists',
    'pixel-art' => 'Pixel Art',
    'thumbs' => 'Thumbs',
    _ => style,
  };
}

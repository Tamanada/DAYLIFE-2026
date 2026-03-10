class SloganModel {
  final int id;
  final String text;
  final String language;

  const SloganModel({
    required this.id,
    required this.text,
    this.language = 'en',
  });
}

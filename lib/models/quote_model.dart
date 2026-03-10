class QuoteModel {
  final int id;
  final String text;
  final String language;

  const QuoteModel({
    required this.id,
    required this.text,
    this.language = 'en',
  });
}

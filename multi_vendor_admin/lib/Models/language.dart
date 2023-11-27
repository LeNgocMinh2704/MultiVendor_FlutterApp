class Language {
  final int id;
  final String flag;
  final String languageCode;
  final String name;
  final String country;

  Language(
    this.id,
    this.flag,
    this.languageCode,
    this.name,
    this.country,
  );

  static List<Language> languageList() {
    return <Language>[
      Language(
        1,
        '🇵🇾',
        'es',
        'Spanish',
        'PARAGUAY',
      ),
      Language(
        2,
        '🇺🇸',
        'en',
        'English',
        'USA',
      ),
      Language(
        3,
        '🇧🇷',
        'pt',
        'Portuguese',
        'BRAZIL- PORTUGUÉS',
      ),
    ];
  }
}

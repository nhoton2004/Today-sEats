enum CategoryFilterType {
  all('Tất cả', 'all'),
  vietnamese('Việt Nam', 'vietnamese'),
  asian('Châu Á', 'asian'),
  western('Âu Mỹ', 'western'),
  other('Khác', 'other');

  final String displayName;
  final String value;

  const CategoryFilterType(this.displayName, this.value);

  static CategoryFilterType fromString(String value) {
    return CategoryFilterType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => CategoryFilterType.all,
    );
  }
}

enum MealType {
  breakfast('Sáng', 'breakfast'),
  lunch('Trưa', 'lunch'),
  dinner('Tối', 'dinner'),
  snack('Phụ', 'snack');

  final String displayName;
  final String value;

  const MealType(this.displayName, this.value);

  static MealType fromString(String value) {
    return MealType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MealType.lunch,
    );
  }
}

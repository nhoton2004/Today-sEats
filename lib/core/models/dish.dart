import 'meal_type.dart';
import 'category_filter_type.dart';

class Dish {
  final String id;
  final String name;
  final MealType type;
  final CategoryFilterType category;
  final bool isFavorite;

  Dish({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    this.isFavorite = false,
  });

  // Copy with method for immutable updates
  Dish copyWith({
    String? id,
    String? name,
    MealType? type,
    CategoryFilterType? category,
    bool? isFavorite,
  }) {
    return Dish(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.value,
      'category': category.value,
      'isFavorite': isFavorite,
    };
  }

  // Create from JSON
  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'] as String,
      name: json['name'] as String,
      type: MealType.fromString(json['type'] as String),
      category: CategoryFilterType.fromString(json['category'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dish && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Dish{id: $id, name: $name, type: $type, category: $category, isFavorite: $isFavorite}';
  }
}

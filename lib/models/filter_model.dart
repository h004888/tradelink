class FeedFilter {
  final String? type;
  final double? minPrice;
  final double? maxPrice;
  final String? condition;
  final String sort;

  const FeedFilter({
    this.type,
    this.minPrice,
    this.maxPrice,
    this.condition,
    this.sort = 'newest',
  });

  FeedFilter copyWith({
    String? type,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? sort,
  }) {
    return FeedFilter(
      type: type,
      minPrice: minPrice,
      maxPrice: maxPrice,
      condition: condition,
      sort: sort ?? this.sort,
    );
  }

  Map<String, String> toQuery() {
    final query = <String, String>{};
    if (type != null) query['type'] = type!;
    if (minPrice != null) query['minPrice'] = minPrice.toString();
    if (maxPrice != null) query['maxPrice'] = maxPrice.toString();
    if (condition != null) query['condition'] = condition!;
    if (sort != 'newest') query['sort'] = sort;
    return query;
  }

  bool get hasActiveFilters => type != null || minPrice != null || maxPrice != null || condition != null;

  String get sortLabel {
    switch (sort) {
      case 'price_asc': return 'Giá thấp';
      case 'price_desc': return 'Giá cao';
      case 'popular': return 'Phổ biến';
      default: return 'Mới nhất';
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewItem {
  final String userName;
  final String userAvatar;
  final double rating;
  final String comment;
  final String date;
  final List<String> photos;

  ReviewItem({
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    this.photos = const [],
  });
}

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final _supabase = Supabase.instance.client;

  final Map<String, List<ReviewItem>> _reviews = {};
  bool _loaded = false;

  Future<void> loadReviews() async {
    try {
      final response = await _supabase
          .from('reviews')
          .select('*, properties(name)')
          .order('created_at', ascending: false)
          .limit(50);

      _reviews.clear();
      for (final r in (response as List)) {
        final propertyName = r['properties']?['name'] as String? ?? 'Unknown';
        if (!_reviews.containsKey(propertyName)) {
          _reviews[propertyName] = [];
        }
        _reviews[propertyName]!.add(ReviewItem(
          userName: r['user_id']?.toString().substring(0, 8) ?? 'User',
          userAvatar: (r['user_id']?.toString() ?? 'U')[0].toUpperCase(),
          rating: (r['rating'] as num).toDouble(),
          comment: r['comment'] as String? ?? '',
          date: r['created_at']?.toString().substring(0, 10) ?? '',
        ));
      }
      _loaded = true;
    } catch (e) {
      _loaded = true;
    }
  }

  List<ReviewItem> getReviews(String propertyName) {
    if (!_loaded) return [];
    return _reviews[propertyName] ?? [];
  }

  double getAverageRating(String propertyName) {
    final reviews = getReviews(propertyName);
    if (reviews.isEmpty) return 0.0;
    return reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length;
  }

  Future<void> addReview(String propertyName, ReviewItem review) async {
    // Add locally immediately for instant UI update
    if (!_reviews.containsKey(propertyName)) {
      _reviews[propertyName] = [];
    }
    _reviews[propertyName]!.insert(0, review);

    // Save to Supabase
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Find property ID by name
      final propertyResponse = await _supabase
          .from('properties')
          .select('id')
          .eq('name', propertyName)
          .maybeSingle();

      if (propertyResponse != null) {
        await _supabase.from('reviews').insert({
          'user_id': user.id,
          'property_id': propertyResponse['id'],
          'rating': review.rating.round(),
          'comment': review.comment,
        });
      }
    } catch (e) {
      // Already saved locally, silent fail
    }
  }
}

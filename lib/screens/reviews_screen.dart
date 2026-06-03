import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../services/review_service.dart';

class ReviewsScreen extends StatefulWidget {
  final String propertyName;
  final double rating;
  const ReviewsScreen(
      {super.key, required this.propertyName, required this.rating});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await ReviewService().loadReviews();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final reviews = ReviewService().getReviews(widget.propertyName);
    final avgRating = ReviewService().getAverageRating(widget.propertyName);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                              color: AppColors.bgWhite,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Icon(LucideIcons.arrowLeft,
                              size: 22, color: AppColors.textSecondary))),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Text('${widget.propertyName} Reviews',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary))),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Rating summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04), blurRadius: 10)
                    ]),
                child: _isLoading
                    ? const Center(
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                                color: AppColors.primary)))
                    : Row(
                        children: [
                          Column(
                            children: [
                              Text(avgRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Row(
                                  children: List.generate(
                                      5,
                                      (i) => Icon(
                                          i < avgRating.round()
                                              ? LucideIcons.star
                                              : LucideIcons.star,
                                          color: i < avgRating.round()
                                              ? AppColors.accentGold
                                              : AppColors.tabInactive,
                                          size: 16,
                                          fill: 1.0))),
                              const SizedBox(height: 4),
                              Text('${reviews.length} reviews',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted)),
                            ],
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              children: [5, 4, 3, 2, 1].map((star) {
                                final count = reviews
                                    .where((r) => r.rating.round() == star)
                                    .length;
                                final percent = reviews.isEmpty
                                    ? 0.0
                                    : count / reviews.length;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(children: [
                                    Text('$star',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textMuted)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                        child: Container(
                                            height: 6,
                                            decoration: BoxDecoration(
                                                color: AppColors.tabInactive,
                                                borderRadius:
                                                    BorderRadius.circular(3)),
                                            child: FractionallySizedBox(
                                                alignment: Alignment.centerLeft,
                                                widthFactor: percent,
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        color: AppColors
                                                            .accentGold,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    3)))))),
                                    const SizedBox(width: 6),
                                    Text('$count',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textMuted))
                                  ]),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary))
                  : reviews.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                      color: AppColors.accentBlueLight,
                                      borderRadius: BorderRadius.circular(16)),
                                  child: const Icon(LucideIcons.star,
                                      color: AppColors.primary, size: 28)),
                              const SizedBox(height: 14),
                              const Text('No reviews yet',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              const Text('Be the first to leave a review!',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMuted)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            final review = reviews[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: AppColors.bgWhite,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8)
                                  ]),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFF3B5CF6),
                                                    Color(0xFF8B5CF6)
                                                  ]),
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Center(
                                              child: Text(review.userAvatar,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700)))),
                                      const SizedBox(width: 12),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                            Text(review.userName,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        AppColors.textPrimary)),
                                            Row(
                                                children: List.generate(
                                                    5,
                                                    (i) => Icon(
                                                        i <
                                                                review.rating
                                                                    .round()
                                                            ? LucideIcons.star
                                                            : LucideIcons.star,
                                                        color: i <
                                                                review.rating
                                                                    .round()
                                                            ? AppColors
                                                                .accentGold
                                                            : AppColors
                                                                .tabInactive,
                                                        size: 12,
                                                        fill: 1.0)))
                                          ])),
                                      Text(review.date,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textMuted)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(review.comment,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                          height: 1.5)),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(
                                    duration: 300.ms, delay: (50 * index).ms)
                                .moveY(begin: 10);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../services/review_service.dart';

class WriteReviewScreen extends StatefulWidget {
  final String propertyName;
  const WriteReviewScreen({super.key, required this.propertyName});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_rating == 0) return;
    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(seconds: 1), () {
      ReviewService().addReview(
          widget.propertyName,
          ReviewItem(
            userName: 'You',
            userAvatar: 'Y',
            rating: _rating.toDouble(),
            comment: _commentController.text,
            date: 'Just now',
          ));
      setState(() => _isSubmitting = false);
      context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 24),
              const Text('Write a Review',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(widget.propertyName,
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.textMuted)),
              const SizedBox(height: 28),

              // Stars
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      5,
                      (i) => GestureDetector(
                            onTap: () => setState(() => _rating = i + 1),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(
                                i < _rating
                                    ? LucideIcons.star
                                    : LucideIcons.star,
                                color: i < _rating
                                    ? AppColors.accentGold
                                    : AppColors.tabInactive,
                                size: 44,
                                fill: 1.0,
                              ),
                            ),
                          )),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                  child: Text(
                      _rating == 0
                          ? 'Tap to rate'
                          : _rating == 5
                              ? 'Excellent!'
                              : _rating == 4
                                  ? 'Very Good'
                                  : _rating == 3
                                      ? 'Good'
                                      : _rating == 2
                                          ? 'Fair'
                                          : 'Poor',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _rating == 0
                              ? AppColors.textMuted
                              : AppColors.accentGold))),
              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04), blurRadius: 10)
                    ]),
                child: TextField(
                  controller: _commentController,
                  maxLines: 6,
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Share your experience...',
                    hintStyle: TextStyle(color: AppColors.textPlaceholder),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed:
                      (_rating > 0 && !_isSubmitting) ? _submitReview : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.tabInactive,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Text('Submit Review',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

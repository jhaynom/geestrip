import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  final bool isGuestMode;

  const SplashScreen({super.key, this.isGuestMode = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Initialize video
    _initializeVideo();

    // Fallback: navigate after 8 seconds to match the video length
    Future.delayed(8.seconds, () {
      if (mounted) {
        _navigateToNext();
      }
    });
  }

  void _initializeVideo() {
    try {
      _videoController =
          VideoPlayerController.asset('assets/videos/logo_animation.mp4')
            ..initialize().then((_) {
              if (mounted) {
                setState(() {});
                _videoController.play();
                _videoController.setLooping(false);
                // Slide up text after video starts
                Future.delayed(300.ms, () {
                  if (mounted) _slideController.forward();
                });
              }
            }).catchError((error) {
              debugPrint('Video init error: $error');
              if (mounted) {
                setState(() {
                  _hasError = true;
                  _errorMessage = error.toString();
                });
                // Still navigate after delay
                Future.delayed(3.seconds, () {
                  if (mounted) _navigateToNext();
                });
              }
            });

      // Listen for video completion
      _videoController.addListener(() {
        if (_videoController.value.isInitialized &&
            _videoController.value.position >=
                _videoController.value.duration) {
          _fadeController.forward();
          Future.delayed(800.ms, () {
            if (mounted) {
              _navigateToNext();
            }
          });
        }
      });
    } catch (e) {
      debugPrint('Video controller error: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
        Future.delayed(3.seconds, () {
          if (mounted) _navigateToNext();
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  String get _nextRoute {
    if (widget.isGuestMode) return '/';
    return AuthService().isLoggedIn ? '/' : '/onboarding';
  }

  void _navigateToNext() {
    context.go(_nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B6B),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video background - only show if initialized and no error
          if (!_hasError &&
              _videoController.value.isInitialized &&
              !_videoController.value.hasError)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController.value.size.width,
                height: _videoController.value.size.height,
                child: VideoPlayer(_videoController),
              ),
            ),

          // Loading/Error state
          if (!_videoController.value.isInitialized || _hasError)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D1B6B),
                    Color(0xFF1A237E),
                    Color(0xFF1F3BB3),
                    Color(0xFF3B5CF6),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pulse logo while loading
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .scale(
                          duration: 1500.ms,
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.08, 1.08),
                        ),
                    const SizedBox(height: 32),
                    if (_hasError)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          children: [
                            Text(
                              'Loading...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_errorMessage.isNotEmpty)
                              Text(
                                _errorMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.redAccent.withOpacity(0.9),
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      )
                    else
                      const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // App name overlay at bottom
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _slideController,
                curve: Curves.easeOut,
              )),
              child: FadeTransition(
                opacity: _slideController,
                child: Column(
                  children: [
                    const Text(
                      'GeesTrip',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your Personal Travel Concierge',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Fade to background
          FadeTransition(
            opacity: _fadeController,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D1B6B),
                    Color(0xFF1A237E),
                    Color(0xFF1F3BB3),
                    Color(0xFF3B5CF6),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

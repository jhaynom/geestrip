import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../services/partner_service.dart';

class PartnerRegisterScreen extends StatefulWidget {
  const PartnerRegisterScreen({super.key});

  @override
  State<PartnerRegisterScreen> createState() => _PartnerRegisterScreenState();
}

class _PartnerRegisterScreenState extends State<PartnerRegisterScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1 - Personal Info
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _roleController = TextEditingController();

  // Step 2 - Property Details
  final _propertyNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _weekendPriceController = TextEditingController();
  final _roomsController = TextEditingController();
  String _propertyType = 'hotel';
  String _currency = 'USD';

  // Step 3 - Photos
  final List<String> _photos = [];

  // Step 4 - Amenities
  final Map<String, bool> _amenities = {
    'Free WiFi': false,
    'Swimming Pool': false,
    'Gym': false,
    'Restaurant': false,
    'Room Service': false,
    'Spa': false,
    'Airport Shuttle': false,
    'Parking': false,
    'Air Conditioning': false,
    'Laundry': false,
    'Bar/Lounge': false,
    'Business Center': false,
    'Pet Friendly': false,
    'Beach Access': false,
    'Security': false,
    'Backup Generator': false,
  };

  // Step 5 - OTA Links
  final _bookingLinkController = TextEditingController();
  final _expediaLinkController = TextEditingController();
  final _airbnbLinkController = TextEditingController();
  final _websiteController = TextEditingController();

  // Step 6 - Review
  bool _agreed = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    _propertyNameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _weekendPriceController.dispose();
    _roomsController.dispose();
    _bookingLinkController.dispose();
    _expediaLinkController.dispose();
    _airbnbLinkController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 5) {
      _pageController.nextPage(duration: 300.ms, curve: Curves.easeOutCubic);
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
          duration: 300.ms, curve: Curves.easeOutCubic);
      setState(() => _currentStep--);
    }
  }

  void _addPhoto() {
    showDialog(
      context: context,
      builder: (ctx) {
        final urlController = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.bgWhite,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Photo URL',
              style: TextStyle(fontWeight: FontWeight.w700)),
          content: TextField(
            controller: urlController,
            decoration: InputDecoration(
              hintText: 'https://images.unsplash.com/...',
              filled: true,
              fillColor: AppColors.bgPrimary,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (urlController.text.isNotEmpty) {
                  setState(() => _photos.add(urlController.text));
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _handleSubmit() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        PartnerService().registerPartner(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
        );
        PartnerService().addProperty({
          'name': _propertyNameController.text,
          'type': _propertyType,
          'location': _locationController.text,
          'description': _descriptionController.text,
          'price': int.tryParse(_priceController.text) ?? 0,
          'weekendPrice': int.tryParse(_weekendPriceController.text) ?? 0,
          'rooms': int.tryParse(_roomsController.text) ?? 1,
          'currency': _currency,
          'photos': List.from(_photos),
          'amenities': _amenities.entries
              .where((e) => e.value)
              .map((e) => e.key)
              .toList(),
          'otaLinks': {
            'booking': _bookingLinkController.text,
            'expedia': _expediaLinkController.text,
            'airbnb': _airbnbLinkController.text,
            'website': _websiteController.text,
          },
          'role': _roleController.text,
        });
        setState(() => _isLoading = false);
        context.go('/partner-dashboard');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(color: AppColors.bgWhite, boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2))
              ]),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            _currentStep > 0 ? _prevStep() : context.pop(),
                        child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                                color: AppColors.bgPrimary,
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(LucideIcons.arrowLeft,
                                size: 22, color: AppColors.textSecondary)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Text(_getStepTitle(),
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary))),
                      Text('Step ${_currentStep + 1}/6',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  Row(
                    children: List.generate(
                        6,
                        (i) => Expanded(
                              child: Container(
                                height: 3,
                                margin: EdgeInsets.only(right: i < 5 ? 4 : 0),
                                decoration: BoxDecoration(
                                  color: i <= _currentStep
                                      ? AppColors.primary
                                      : AppColors.tabInactive,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            )),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                  _buildStep5(),
                  _buildStep6(),
                ],
              ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(color: AppColors.bgWhite, boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, -2))
              ]),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: GestureDetector(
                          onTap: _prevStep,
                          child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                  color: AppColors.bgPrimary,
                                  borderRadius: BorderRadius.circular(16)),
                              child: const Center(
                                  child: Text('Back',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary)))),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: _currentStep < 5
                            ? _nextStep
                            : (_agreed && !_isLoading ? _handleSubmit : null),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: _currentStep < 5
                                ? const LinearGradient(colors: [
                                    Color(0xFF1F3BB3),
                                    Color(0xFF3B5CF6)
                                  ])
                                : const LinearGradient(colors: [
                                    AppColors.success,
                                    Color(0xFF4ADE80)
                                  ]),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6))
                            ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5))
                                : Text(
                                    _currentStep < 5
                                        ? 'Continue'
                                        : 'Submit for Review',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Your Information';
      case 1:
        return 'Property Details';
      case 2:
        return 'Add Photos';
      case 3:
        return 'Amenities';
      case 4:
        return 'OTA Links';
      case 5:
        return 'Review & Submit';
      default:
        return '';
    }
  }

  // STEP 1: Personal Info
  Widget _buildStep1() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tell us about yourself',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('This information is for verification purposes only.',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
          const SizedBox(height: 20),
          _InputField(
              controller: _nameController,
              hint: 'Full Name / Business Name',
              icon: LucideIcons.user),
          const SizedBox(height: 14),
          _InputField(
              controller: _emailController,
              hint: 'Email Address',
              icon: LucideIcons.mail,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 14),
          _InputField(
              controller: _phoneController,
              hint: 'Phone Number',
              icon: LucideIcons.phone,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 14),
          _InputField(
              controller: _roleController,
              hint: 'Your Role (Owner, Manager, etc.)',
              icon: LucideIcons.briefcase),
        ],
      ),
    );
  }

  // STEP 2: Property Details
  Widget _buildStep2() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Property Details',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Be as detailed as possible for faster verification.',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
          const SizedBox(height: 20),
          _InputField(
              controller: _propertyNameController,
              hint: 'Property Name',
              icon: LucideIcons.building2),
          const SizedBox(height: 14),
          // Property Type
          Container(
            decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black.withOpacity(0.06))),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _propertyType,
                isExpanded: true,
                icon: const Icon(LucideIcons.chevronDown,
                    size: 18, color: AppColors.textMuted),
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary),
                items: const [
                  DropdownMenuItem(value: 'hotel', child: Text('Hotel')),
                  DropdownMenuItem(
                      value: 'apartment', child: Text('Apartment / Shortlet')),
                  DropdownMenuItem(
                      value: 'resort', child: Text('Resort / Villa')),
                  DropdownMenuItem(
                      value: 'guesthouse', child: Text('Guest House')),
                  DropdownMenuItem(value: 'lodge', child: Text('Lodge')),
                ],
                onChanged: (v) => setState(() => _propertyType = v!),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _InputField(
              controller: _locationController,
              hint: 'Full Address (City, Area, Street)',
              icon: LucideIcons.mapPin),
          const SizedBox(height: 14),
          _InputField(
              controller: _descriptionController,
              hint: 'Describe your property...',
              icon: LucideIcons.fileText,
              maxLines: 4),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _InputField(
                      controller: _priceController,
                      hint: 'Base Price/Night',
                      icon: LucideIcons.dollarSign,
                      keyboardType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(
                  child: _InputField(
                      controller: _weekendPriceController,
                      hint: 'Weekend Price',
                      icon: LucideIcons.dollarSign,
                      keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _InputField(
                      controller: _roomsController,
                      hint: 'No. of Rooms',
                      icon: LucideIcons.bedDouble,
                      keyboardType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.bgPrimary,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: Colors.black.withOpacity(0.06))),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _currency,
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown,
                          size: 18, color: AppColors.textMuted),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary),
                      items: const [
                        DropdownMenuItem(value: 'USD', child: Text('USD \$')),
                        DropdownMenuItem(value: 'NGN', child: Text('NGN ₦')),
                        DropdownMenuItem(value: 'GHS', child: Text('GHS ₵')),
                        DropdownMenuItem(value: 'EUR', child: Text('EUR €')),
                      ],
                      onChanged: (v) => setState(() => _currency = v!),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STEP 3: Photos
  Widget _buildStep3() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Property Photos',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text(
              'Add high-quality photos. First photo will be the cover. You can also send photos via WhatsApp after submission.',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ..._photos.map((url) => Stack(
                    children: [
                      Container(
                        width: (MediaQuery.of(context).size.width - 60) / 2,
                        height: 120,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                                image: NetworkImage(url), fit: BoxFit.cover)),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => setState(() => _photos.remove(url)),
                          child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle),
                              child: const Icon(LucideIcons.x,
                                  color: Colors.white, size: 14)),
                        ),
                      ),
                      if (_photos.indexOf(url) == 0)
                        Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(6)),
                                child: const Text('Cover',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700)))),
                    ],
                  )),
              // Add photo button
              GestureDetector(
                onTap: _addPhoto,
                child: Container(
                  width: (MediaQuery.of(context).size.width - 60) / 2,
                  height: 120,
                  decoration: BoxDecoration(
                      color: AppColors.bgWhite,
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppColors.tabInactive, width: 2)),
                  child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.plus,
                            color: AppColors.textMuted, size: 28),
                        SizedBox(height: 6),
                        Text('Add Photo',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500))
                      ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STEP 4: Amenities
  Widget _buildStep4() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Amenities',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text('Select all amenities available at your property.',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _amenities.entries
                .map((entry) => GestureDetector(
                      onTap: () =>
                          setState(() => _amenities[entry.key] = !entry.value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: entry.value
                              ? AppColors.primary
                              : AppColors.bgWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: entry.value
                                  ? AppColors.primary
                                  : AppColors.tabInactive),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                                entry.value
                                    ? LucideIcons.check
                                    : LucideIcons.plus,
                                color: entry.value
                                    ? Colors.white
                                    : AppColors.textMuted,
                                size: 16),
                            const SizedBox(width: 6),
                            Text(entry.key,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: entry.value
                                        ? Colors.white
                                        : AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // STEP 5: OTA Links
  Widget _buildStep5() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('OTA & Web Links',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text(
              'Help us verify your property by providing links to your listings on other platforms.',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
          const SizedBox(height: 20),
          _InputField(
              controller: _bookingLinkController,
              hint: 'Booking.com link (optional)',
              icon: LucideIcons.globe),
          const SizedBox(height: 14),
          _InputField(
              controller: _expediaLinkController,
              hint: 'Expedia link (optional)',
              icon: LucideIcons.globe),
          const SizedBox(height: 14),
          _InputField(
              controller: _airbnbLinkController,
              hint: 'Airbnb link (optional)',
              icon: LucideIcons.globe),
          const SizedBox(height: 14),
          _InputField(
              controller: _websiteController,
              hint: 'Your website (optional)',
              icon: LucideIcons.link),
        ],
      ),
    );
  }

  // STEP 6: Review & Submit
  Widget _buildStep6() {
    final selectedAmenities =
        _amenities.entries.where((e) => e.value).map((e) => e.key).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Review Your Submission',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          const Text(
              'Please review everything before submitting. Our team will verify within 24 hours.',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
          const SizedBox(height: 20),

          _ReviewCard(
              title: 'Personal Info',
              icon: LucideIcons.user,
              children: [
                _ReviewRow('Name', _nameController.text),
                _ReviewRow('Email', _emailController.text),
                _ReviewRow('Phone', _phoneController.text),
                _ReviewRow('Role', _roleController.text),
              ]),
          const SizedBox(height: 12),

          _ReviewCard(
              title: 'Property Details',
              icon: LucideIcons.building2,
              children: [
                _ReviewRow('Name', _propertyNameController.text),
                _ReviewRow('Type', _propertyType),
                _ReviewRow('Location', _locationController.text),
                _ReviewRow('Price', '\$${_priceController.text} / night'),
                _ReviewRow(
                    'Weekend', '\$${_weekendPriceController.text} / night'),
                _ReviewRow('Rooms', _roomsController.text),
              ]),
          const SizedBox(height: 12),

          _ReviewCard(title: 'Photos', icon: LucideIcons.image, children: [
            _ReviewRow('Count', '${_photos.length} photos added'),
          ]),
          const SizedBox(height: 12),

          _ReviewCard(
              title: 'Amenities',
              icon: LucideIcons.sparkles,
              children: [
                if (selectedAmenities.isEmpty)
                  _ReviewRow('None', 'No amenities selected')
                else
                  _ReviewRow('Selected', selectedAmenities.join(', ')),
              ]),
          const SizedBox(height: 12),

          _ReviewCard(title: 'OTA Links', icon: LucideIcons.link, children: [
            _ReviewRow(
                'Booking.com',
                _bookingLinkController.text.isEmpty
                    ? 'Not provided'
                    : _bookingLinkController.text),
            _ReviewRow(
                'Expedia',
                _expediaLinkController.text.isEmpty
                    ? 'Not provided'
                    : _expediaLinkController.text),
            _ReviewRow(
                'Airbnb',
                _airbnbLinkController.text.isEmpty
                    ? 'Not provided'
                    : _airbnbLinkController.text),
            _ReviewRow(
                'Website',
                _websiteController.text.isEmpty
                    ? 'Not provided'
                    : _websiteController.text),
          ]),
          const SizedBox(height: 20),

          // Agreement
          GestureDetector(
            onTap: () => setState(() => _agreed = !_agreed),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.accentBlueLight,
                  borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                        color: _agreed ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: _agreed
                                ? AppColors.primary
                                : AppColors.textMuted,
                            width: 2)),
                    child: _agreed
                        ? const Icon(LucideIcons.check,
                            color: Colors.white, size: 14)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                      child: Text(
                          'I confirm all information is accurate. GeesTrip will verify and list my property.',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;
  const _InputField(
      {required this.controller,
      required this.hint,
      required this.icon,
      this.keyboardType = TextInputType.text,
      this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.06))),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(fontSize: 15, color: AppColors.textPlaceholder),
          prefixIcon: maxLines > 1
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Icon(icon, color: AppColors.textMuted, size: 20))
              : Icon(icon, color: AppColors.textMuted, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _ReviewCard(
      {required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary))
          ]),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500)),
          Expanded(
              child: Text(value.isNotEmpty ? value : 'Not provided',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: value.isNotEmpty
                          ? AppColors.textPrimary
                          : AppColors.textMuted))),
        ],
      ),
    );
  }
}

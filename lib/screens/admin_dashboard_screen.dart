import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';
import '../services/admin_service.dart';
import '../services/content_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _activeTab = 4;
  List<Map<String, dynamic>> _properties = [];
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _pendingChats = [];
  List<Map<String, dynamic>> _activeChats = [];
  List<Map<String, dynamic>> _cmsEntries = [];
  List<Map<String, dynamic>> _bookings = [];
  final List<String> _contentSections = [
    'all',
    'services',
    'companions',
    'drivers',
    'faq',
    'pages',
  ];
  String _selectedContentSection = 'services';
  bool _isLoading = true;
  bool _hasNewChatAlert = false;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _autoRefreshTimer =
        Timer.periodic(const Duration(seconds: 10), (_) => _loadDataSilently());
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDataSilently() async {
    try {
      final results = await Future.wait([
        AdminService().getAllProperties(),
        AdminService().getAllUsers(),
        AdminService().getPendingChats(),
        AdminService().getActiveChats(),
        AdminService().getCmsEntries(),
        AdminService().getAllBookings(),
      ]);
      if (mounted)
        setState(() {
          _properties = results[0];
          _users = results[1];
          _pendingChats = results[2];
          _activeChats = results[3];
          _cmsEntries = results[4];
          _bookings = results[5];
          _hasNewChatAlert = _pendingChats.isNotEmpty;
        });
    } catch (e) {}
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        AdminService().getAllProperties(),
        AdminService().getAllUsers(),
        AdminService().getPendingChats(),
        AdminService().getActiveChats(),
        AdminService().getCmsEntries(),
        AdminService().getAllBookings(),
      ]);
      if (mounted)
        setState(() {
          _properties = results[0];
          _users = results[1];
          _pendingChats = results[2];
          _activeChats = results[3];
          _cmsEntries = results[4];
          _bookings = results[5];
          _hasNewChatAlert = _pendingChats.isNotEmpty;
          _isLoading = false;
        });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int get _contentTabCount {
    if (_selectedContentSection == 'all') {
      return _getAllCmsEntries().length;
    }
    if (_selectedContentSection == 'services') {
      return ContentService()
          .getMergedServiceEntries(_cmsEntries
              .where((entry) => entry['section']?.toString() == 'services')
              .toList())
          .length;
    }
    return _cmsEntries
        .where(
            (entry) => entry['section']?.toString() == _selectedContentSection)
        .toList()
        .length;
  }

  List<Map<String, dynamic>> _getAllCmsEntries() {
    final serviceEntries = ContentService().getMergedServiceEntries(
      _cmsEntries
          .where((entry) => entry['section']?.toString() == 'services')
          .toList(),
    );
    final otherEntries = _cmsEntries
        .where((entry) => entry['section']?.toString() != 'services')
        .toList();
    return [...serviceEntries, ...otherEntries];
  }

  void _joinChat(Map<String, dynamic> chat) async {
    await AdminService().acceptChatRequest(chat['id']);
    await _loadData();
    if (mounted) {
      context.push('/chat-detail', extra: {
        'index': 0,
        'isAdminView': true,
        'adminUserId': chat['user_id']?.toString(),
        'adminUserName': chat['profiles']?['full_name']?.toString() ?? 'Guest',
      });
    }
  }

  void _resumeChat(Map<String, dynamic> chat) {
    context.push('/chat-detail', extra: {
      'index': 0,
      'isAdminView': true,
      'adminUserId': chat['user_id']?.toString(),
      'adminUserName': chat['profiles']?['full_name']?.toString() ?? 'Guest',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: BoxDecoration(color: AppColors.bgWhite, boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)
            ]),
            child: Row(children: [
              GestureDetector(
                  onTap: () => context.go('/'),
                  child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: AppColors.bgPrimary,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(LucideIcons.arrowLeft,
                          size: 22, color: AppColors.textSecondary))),
              const SizedBox(width: 14),
              Expanded(
                  child: Row(children: [
                const Text('Admin Dashboard',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                if (_hasNewChatAlert) ...[
                  const SizedBox(width: 8),
                  Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.error.withOpacity(0.5),
                                blurRadius: 6)
                          ]))
                ],
              ])),
              GestureDetector(
                  onTap: _loadData,
                  child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: AppColors.bgPrimary,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(LucideIcons.refreshCw,
                          color: AppColors.textSecondary, size: 18))),
            ]),
          ),
          // Tabs - Now 5 tabs with Active Chats
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(children: [
              _TabChip(
                  label: 'Properties',
                  count: _properties.length,
                  isActive: _activeTab == 0,
                  onTap: () => setState(() => _activeTab = 0)),
              const SizedBox(width: 8),
              _TabChip(
                  label: 'Users',
                  count: _users.length,
                  isActive: _activeTab == 1,
                  onTap: () => setState(() => _activeTab = 1)),
              const SizedBox(width: 8),
              _TabChip(
                  label: 'Pending',
                  count: _pendingChats.length,
                  isActive: _activeTab == 2,
                  onTap: () {
                    _hasNewChatAlert = false;
                    setState(() => _activeTab = 2);
                  },
                  highlight: _pendingChats.isNotEmpty,
                  showPulse: _hasNewChatAlert),
              const SizedBox(width: 8),
              _TabChip(
                  label: 'Active',
                  count: _activeChats.length,
                  isActive: _activeTab == 3,
                  onTap: () => setState(() => _activeTab = 3),
                  color: AppColors.success),
              const SizedBox(width: 8),
              _TabChip(
                  label: 'Content',
                  count: _contentTabCount,
                  isActive: _activeTab == 4,
                  onTap: () => setState(() => _activeTab = 4)),
              const SizedBox(width: 8),
              _TabChip(
                  label: 'Bookings',
                  count: _bookings.length,
                  isActive: _activeTab == 5,
                  onTap: () => setState(() => _activeTab = 5)),
            ]),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : _activeTab == 0
                    ? _buildPropertiesList()
                    : _activeTab == 1
                        ? _buildUsersList()
                        : _activeTab == 2
                            ? _buildPendingChatsList()
                            : _activeTab == 3
                                ? _buildActiveChatsList()
                                : _activeTab == 4
                                    ? _buildCmsEntriesList()
                                    : _buildBookingsList(),
          ),
        ]),
      ),
    );
  }

  // ─── PROPERTIES ───
  Widget _buildPropertiesList() {
    final header = Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Properties',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          GestureDetector(
            onTap: () => _showPropertyDialog(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14)),
              child: const Row(children: [
                Icon(LucideIcons.plus, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('New Property',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
          )
        ],
      ),
    );

    if (_properties.isEmpty) {
      return Column(children: [
        header,
        Expanded(
          child: _emptyState('No properties yet', LucideIcons.building2),
        )
      ]);
    }

    return Column(children: [
      header,
      Expanded(
        child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            itemCount: _properties.length,
            itemBuilder: (_, i) {
              final p = _properties[i];
              return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppColors.bgWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8)
                      ]),
                  child: Row(children: [
                    Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(LucideIcons.building2,
                            color: AppColors.primary, size: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(p['name'] ?? '',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          Text(p['location'] ?? '',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textMuted))
                        ])),
                    GestureDetector(
                        onTap: () {
                          AdminService().updatePropertyStatus(p['id'],
                              p['status'] == 'active' ? 'pending' : 'active');
                          _loadData();
                        },
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: p['status'] == 'active'
                                    ? AppColors.accentGreenLight
                                    : AppColors.accentGoldLight,
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(p['status'] ?? 'pending',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: p['status'] == 'active'
                                        ? AppColors.success
                                        : AppColors.accentGold)))),
                    const SizedBox(width: 8),
                    GestureDetector(
                        onTap: () => _showPropertyDialog(property: p),
                        child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Icon(LucideIcons.edit,
                                size: 16, color: AppColors.primary))),
                    const SizedBox(width: 8),
                    GestureDetector(
                        onTap: () => _deleteProperty(p),
                        child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: AppColors.errorLight,
                                borderRadius: BorderRadius.circular(10)),
                            child: const Icon(LucideIcons.trash2,
                                size: 16, color: AppColors.error))),
                  ]));
            }),
      )
    ]);
  }

  Future<void> _showPropertyDialog({Map<String, dynamic>? property}) async {
    final nameController =
        TextEditingController(text: property?['name']?.toString() ?? '');
    final typeController =
        TextEditingController(text: property?['type']?.toString() ?? 'hotel');
    final locationController =
        TextEditingController(text: property?['location']?.toString() ?? '');
    final priceController =
        TextEditingController(text: property?['price']?.toString() ?? '0');
    final weekendPriceController = TextEditingController(
        text: property?['weekend_price']?.toString() ?? '0');
    final roomsController =
        TextEditingController(text: property?['rooms']?.toString() ?? '1');
    final currencyController =
        TextEditingController(text: property?['currency']?.toString() ?? 'USD');
    final descriptionController =
        TextEditingController(text: property?['description']?.toString() ?? '');
    final amenitiesController = TextEditingController(
        text: (property?['amenities'] is List)
            ? (property!['amenities'] as List).join(', ')
            : property?['amenities']?.toString() ?? '');
    final imageController =
        TextEditingController(text: property?['image']?.toString() ?? '');
    final statusController = TextEditingController(
        text: property?['status']?.toString() ?? 'active');
    final controllers = [
      nameController,
      typeController,
      locationController,
      priceController,
      weekendPriceController,
      roomsController,
      currencyController,
      descriptionController,
      amenitiesController,
      imageController,
      statusController,
    ];
    var isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(property != null ? 'Edit Property' : 'New Property'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDialogTextField('Name', nameController),
                _buildDialogTextField('Type', typeController),
                _buildDialogTextField('Location', locationController),
                _buildDialogTextField('Price', priceController),
                _buildDialogTextField('Weekend Price', weekendPriceController),
                _buildDialogTextField('Rooms', roomsController),
                _buildDialogTextField('Currency', currencyController),
                _buildDialogTextField('Description', descriptionController,
                    maxLines: 3),
                _buildDialogTextField(
                    'Amenities (comma-separated)', amenitiesController,
                    maxLines: 2),
                _buildDialogTextField('Image URL', imageController),
                _buildDialogTextField('Status', statusController),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        setDialogState(() => isSaving = true);
                        final amenities = amenitiesController.text
                            .split(',')
                            .map((item) => item.trim())
                            .where((item) => item.isNotEmpty)
                            .toList();
                        final payload = {
                          if (property?['id'] != null) 'id': property!['id'],
                          'name': nameController.text.trim(),
                          'type': typeController.text.trim(),
                          'location': locationController.text.trim(),
                          'description': descriptionController.text.trim(),
                          'price': double.tryParse(priceController.text) ?? 0,
                          'weekend_price':
                              double.tryParse(weekendPriceController.text) ?? 0,
                          'rooms': int.tryParse(roomsController.text) ?? 1,
                          'currency': currencyController.text.trim(),
                          'amenities': amenities,
                          'image': imageController.text.trim(),
                          'status': statusController.text.trim(),
                        };
                        await AdminService().upsertProperty(payload);
                        await _loadData();
                        if (mounted) Navigator.of(dialogContext).pop();
                      },
                child: Text(property != null ? 'Save' : 'Create')),
          ],
        ),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final controller in controllers) {
        controller.dispose();
      }
    });
  }

  Future<void> _deleteProperty(Map<String, dynamic> property) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Property'),
            content:
                const Text('Are you sure you want to delete this property?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete')),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    final id = property['id'];
    if (id != null) {
      await AdminService().deleteProperty(id as int);
      await _loadData();
    }
  }

  // ─── USERS ───
  Widget _buildUsersList() {
    if (_users.isEmpty) return _emptyState('No users yet', LucideIcons.users);
    return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: _users.length,
        itemBuilder: (_, i) {
          final u = _users[i];
          return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.bgWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 8)
                  ]),
              child: Row(children: [
                Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF3B5CF6), Color(0xFF8B5CF6)]),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                        child: Text(
                            (u['full_name']?.toString() ?? 'U')[0]
                                .toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)))),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(u['full_name'] ?? 'User',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      Text(u['email'] ?? '',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted))
                    ])),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(u['role'] ?? 'user',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary))),
              ]));
        });
  }

  // ─── CMS CONTENT ───
  Widget _buildCmsEntriesList() {
    final filteredEntries = _selectedContentSection == 'all'
        ? _getAllCmsEntries()
        : _selectedContentSection == 'services'
            ? ContentService().getMergedServiceEntries(_cmsEntries
                .where((entry) => entry['section']?.toString() == 'services')
                .toList())
            : _cmsEntries
                .where((entry) =>
                    entry['section']?.toString() == _selectedContentSection)
                .toList();

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('CMS Content',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              GestureDetector(
                onTap: () =>
                    _showCmsEntryDialog(section: _selectedContentSection),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    const Icon(LucideIcons.plus, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                        _selectedContentSection == 'all'
                            ? 'New Entry'
                            : 'New ${_selectedContentSection[0].toUpperCase()}${_selectedContentSection.substring(1)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _contentSections.map((section) {
                final isActive = section == _selectedContentSection;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedContentSection = section;
                    }),
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.bgWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.border)),
                        child: Text(section,
                            style: TextStyle(
                                color: isActive
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600))),
                  ),
                );
              }).toList(),
            ),
          )
        ]),
      ),
      Expanded(
        child: filteredEntries.isEmpty
            ? _emptyState(
                'No ${_selectedContentSection} entries yet', LucideIcons.layers,
                subtitle: 'Add a new ${_selectedContentSection} entry')
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: filteredEntries.length,
                itemBuilder: (_, i) {
                  final entry = filteredEntries[i];
                  final metadata = entry['metadata'];
                  final metadataText = metadata is Map
                      ? jsonEncode(metadata)
                      : metadata?.toString() ?? '{}';
                  return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: AppColors.bgWhite,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8)
                          ]),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Text(
                                          entry['title']?.toString() ??
                                              entry['slug']?.toString() ??
                                              'Untitled',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary))),
                                  Row(children: [
                                    GestureDetector(
                                      onTap: () =>
                                          _showCmsEntryDialog(entry: entry),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primarySurface,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(LucideIcons.edit,
                                            size: 16, color: AppColors.primary),
                                      ),
                                    ),
                                    if (entry['id'] != null) ...[
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () => _deleteCmsEntry(entry),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.errorLight,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            LucideIcons.trash2,
                                            size: 16,
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ]),
                                ]),
                            const SizedBox(height: 8),
                            Text(
                                '${entry['section'] ?? 'unknown'} • ${entry['slug'] ?? 'no-slug'}',
                                style: const TextStyle(
                                    fontSize: 12, color: AppColors.textMuted)),
                            if (entry['subtitle'] != null &&
                                entry['subtitle'].toString().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(entry['subtitle'].toString(),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary)),
                            ],
                            if (entry['body'] != null &&
                                entry['body'].toString().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(entry['body'].toString(),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary)),
                            ],
                            if (metadataText.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text('Metadata: $metadataText',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMuted)),
                            ],
                            const SizedBox(height: 8),
                            Text(
                                'Status: ${entry['status'] ?? 'active'} • Order: ${entry['sort_order'] ?? 0}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMuted)),
                          ]));
                }),
      )
    ]);
  }

  Future<void> _showCmsEntryDialog({
    Map<String, dynamic>? entry,
    String? section,
  }) async {
    final existingMetadata = entry != null && entry['metadata'] is Map
        ? Map<String, dynamic>.from(entry['metadata'] as Map)
        : <String, dynamic>{};
    final effectiveSection =
        section == 'all' ? 'services' : (section ?? 'services');
    final sectionController = TextEditingController(
        text: entry?['section']?.toString() ?? effectiveSection);
    final slugController =
        TextEditingController(text: entry?['slug']?.toString() ?? '');
    final titleController =
        TextEditingController(text: entry?['title']?.toString() ?? '');
    final subtitleController =
        TextEditingController(text: entry?['subtitle']?.toString() ?? '');
    final bodyController =
        TextEditingController(text: entry?['body']?.toString() ?? '');
    final metadataController = TextEditingController(
        text: entry != null ? jsonEncode(existingMetadata) : '{}');
    final priceController = TextEditingController(
        text: existingMetadata['price']?.toString() ?? '');
    final categoryController = TextEditingController(
        text: existingMetadata['category']?.toString() ?? '');
    final featuresController = TextEditingController(
        text: existingMetadata['features'] is List
            ? (existingMetadata['features'] as List).join(', ')
            : existingMetadata['features']?.toString() ?? '');
    final gradientController = TextEditingController(
        text: existingMetadata['gradient'] is List
            ? (existingMetadata['gradient'] as List)
                .map((item) => item.toString())
                .join(', ')
            : existingMetadata['gradient']?.toString() ?? '');
    final statusController =
        TextEditingController(text: entry?['status']?.toString() ?? 'active');
    final sortOrderController =
        TextEditingController(text: entry?['sort_order']?.toString() ?? '0');
    final controllers = [
      sectionController,
      slugController,
      titleController,
      subtitleController,
      bodyController,
      metadataController,
      priceController,
      categoryController,
      featuresController,
      gradientController,
      statusController,
      sortOrderController,
    ];
    final isDefaultServiceEntry = entry != null &&
        entry['section']?.toString() == 'services' &&
        entry['id'] == null;
    var isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(entry != null ? 'Edit CMS Entry' : 'New CMS Entry'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: sectionController.text,
                  decoration: InputDecoration(
                      labelText: 'Section',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                  items: _contentSections
                      .map((sectionValue) => DropdownMenuItem(
                            value: sectionValue,
                            child: Text(sectionValue,
                                style: const TextStyle(fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => sectionController.text = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                if (isDefaultServiceEntry)
                  _buildDialogTextField('Slug', slugController, readOnly: true)
                else
                  _buildDialogTextField('Slug', slugController),
                _buildDialogTextField('Title', titleController),
                _buildDialogTextField('Subtitle', subtitleController),
                if (sectionController.text == 'services') ...[
                  _buildDialogTextField('Price', priceController),
                  _buildDialogTextField('Category', categoryController),
                  _buildDialogTextField(
                      'Features (comma-separated)', featuresController,
                      maxLines: 2),
                  _buildDialogTextField(
                      'Gradient colors (comma-separated)', gradientController,
                      maxLines: 2),
                  _buildDialogTextField('Body', bodyController, maxLines: 4),
                ] else ...[
                  _buildDialogTextField('Body', bodyController, maxLines: 4),
                  _buildDialogTextField('Metadata (JSON)', metadataController,
                      maxLines: 4),
                ],
                _buildDialogTextField('Status', statusController),
                _buildDialogTextField('Sort Order', sortOrderController),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        setDialogState(() => isSaving = true);
                        Map<String, dynamic> metadata;
                        if (sectionController.text == 'services') {
                          final gradientValues = gradientController.text
                              .split(',')
                              .map((value) {
                                final trimmed = value.trim();
                                if (trimmed.isEmpty) return '';
                                return trimmed.startsWith('#')
                                    ? trimmed
                                    : '#$trimmed';
                              })
                              .where((value) => value.isNotEmpty)
                              .toList();
                          metadata = {
                            'price': priceController.text.trim(),
                            'category': categoryController.text.trim(),
                            'features': featuresController.text
                                .split(',')
                                .map((value) => value.trim())
                                .where((value) => value.isNotEmpty)
                                .toList(),
                            'gradient': gradientValues,
                            'icon': existingMetadata['icon'] ?? 'star',
                          };
                        } else {
                          try {
                            final decoded = jsonDecode(metadataController.text);
                            metadata = decoded is Map
                                ? Map<String, dynamic>.from(decoded)
                                : <String, dynamic>{};
                          } catch (_) {
                            metadata = <String, dynamic>{};
                          }
                        }
                        final payload = {
                          if (entry?['id'] != null) 'id': entry!['id'],
                          'section': sectionController.text.trim(),
                          'slug': slugController.text.trim(),
                          'title': titleController.text.trim(),
                          'subtitle': subtitleController.text.trim(),
                          'body': bodyController.text.trim(),
                          'metadata': metadata,
                          'status': statusController.text.trim(),
                          'sort_order':
                              int.tryParse(sortOrderController.text) ?? 0,
                        };
                        try {
                          final savedEntry =
                              await AdminService().upsertCmsEntry(payload);
                          if (savedEntry != null) {
                            if (savedEntry['section'] == 'services') {
                              ContentService()
                                  .updateServiceOverride(savedEntry);
                            }
                            if (mounted) {
                              _syncLocalCmsEntry(savedEntry);
                            }
                          }
                          await _loadData();
                          if (mounted) Navigator.of(dialogContext).pop();
                        } catch (e) {
                          setDialogState(() => isSaving = false);
                        }
                      },
                child: Text(entry != null ? 'Save' : 'Create')),
          ],
        ),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final controller in controllers) {
        controller.dispose();
      }
    });
  }

  void _syncLocalCmsEntry(Map<String, dynamic> payload) {
    if (!mounted) return;

    setState(() {
      final payloadSlug = payload['slug']?.toString();
      final payloadSection = payload['section']?.toString();
      int index = -1;

      if (payload['id'] != null) {
        index = _cmsEntries.indexWhere((entry) => entry['id'] == payload['id']);
      }
      if (index == -1 && payloadSlug != null && payloadSlug.isNotEmpty) {
        index = _cmsEntries.indexWhere((entry) =>
            entry['slug']?.toString() == payloadSlug &&
            entry['section']?.toString() == payloadSection);
      }

      if (index != -1) {
        _cmsEntries[index] = payload;
      } else {
        _cmsEntries.add(payload);
      }
    });
  }

  Widget _buildDialogTextField(String label, TextEditingController controller,
      {int maxLines = 1, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        decoration: InputDecoration(
            labelText: label,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
      ),
    );
  }

  Future<void> _deleteCmsEntry(Map<String, dynamic> entry) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete CMS Entry'),
            content: const Text('Are you sure you want to delete this entry?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete')),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;
    await AdminService().deleteCmsEntry(entry['id']);
    if (mounted) {
      setState(() {
        _cmsEntries.removeWhere((e) => e['id'] == entry['id']);
      });
    }
    if (entry['section']?.toString() == 'services') {
      ContentService().removeServiceOverride(entry['slug']?.toString());
    }
    await _loadData();
  }

  // ─── PENDING CHATS ───
  Widget _buildPendingChatsList() {
    if (_pendingChats.isEmpty)
      return _emptyState('No pending chats', LucideIcons.messageCircle,
          subtitle: 'Requests appear here. Auto-refreshes every 10s');
    return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: _pendingChats.length,
        itemBuilder: (_, i) {
          final chat = _pendingChats[i];
          return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.bgWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 8)
                  ]),
              child: Row(children: [
                Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                        color: AppColors.errorLight,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(LucideIcons.headphones,
                        color: AppColors.error, size: 20)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(chat['profiles']?['full_name'] ?? 'Guest',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      const Text('Waiting for agent...',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                      Text(_formatTimeAgo(chat['created_at']?.toString()),
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textMuted))
                    ])),
                GestureDetector(
                    onTap: () => _joinChat(chat),
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [Color(0xFF1F3BB3), Color(0xFF3B5CF6)]),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text('Join Chat',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)))),
              ]));
        });
  }

  // ─── ACTIVE CHATS ───
  Widget _buildActiveChatsList() {
    if (_activeChats.isEmpty)
      return _emptyState('No active chats', LucideIcons.messageCircle,
          subtitle: 'Ongoing conversations will appear here',
          color: AppColors.success);
    return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: _activeChats.length,
        itemBuilder: (_, i) {
          final chat = _activeChats[i];
          return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.bgWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 8)
                  ]),
              child: Row(children: [
                Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                        color: AppColors.accentGreenLight,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(LucideIcons.messageCircle,
                        color: AppColors.success, size: 20)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(chat['profiles']?['full_name'] ?? 'Guest',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      Text('Agent: ${chat['agent_name'] ?? 'You'}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.success,
                              fontWeight: FontWeight.w500)),
                      Text(
                          'Started ${_formatTimeAgo(chat['created_at']?.toString())}',
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textMuted)),
                    ])),
                GestureDetector(
                    onTap: () => _resumeChat(chat),
                    child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Text('Resume',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)))),
              ]));
        });
  }

  // ─── BOOKINGS ───
  Widget _buildBookingsList() {
    if (_bookings.isEmpty)
      return _emptyState('No bookings yet', LucideIcons.calendarCheck);
    return ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        itemCount: _bookings.length,
        itemBuilder: (_, i) {
          final b = _bookings[i];
          return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: AppColors.bgWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 8)
                  ]),
              child: Row(children: [
                Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(LucideIcons.calendarCheck,
                        color: AppColors.primary, size: 20)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(b['service_name'] ?? 'Booking',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      Text(b['reference'] ?? '',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted))
                    ])),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppColors.accentGreenLight,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(b['status'] ?? 'confirmed',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success))),
              ]));
        });
  }

  Widget _emptyState(String title, IconData icon,
      {String? subtitle, Color color = AppColors.primary}) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: color, size: 28)),
      const SizedBox(height: 14),
      Text(title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
      if (subtitle != null) ...[
        const SizedBox(height: 4),
        Text(subtitle,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted))
      ],
    ]));
  }

  String _formatTimeAgo(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      return '${diff.inHours}h ago';
    } catch (e) {
      return '';
    }
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final bool highlight;
  final bool showPulse;
  final Color? color;
  final VoidCallback onTap;
  const _TabChip(
      {required this.label,
      required this.count,
      required this.isActive,
      required this.onTap,
      this.highlight = false,
      this.showPulse = false,
      this.color});
  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    return GestureDetector(
        onTap: onTap,
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                color: isActive
                    ? activeColor
                    : (highlight ? AppColors.errorLight : AppColors.bgPrimary),
                borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (showPulse)
                Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.error.withOpacity(0.5),
                              blurRadius: 4)
                        ])),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? Colors.white
                          : (highlight
                              ? AppColors.error
                              : AppColors.textSecondary))),
              const SizedBox(width: 5),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white.withOpacity(0.2)
                          : AppColors.tabInactive,
                      borderRadius: BorderRadius.circular(6)),
                  child: Text('$count',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color:
                              isActive ? Colors.white : AppColors.textMuted))),
            ])));
  }
}

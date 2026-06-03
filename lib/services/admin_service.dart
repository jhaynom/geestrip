import 'package:supabase_flutter/supabase_flutter.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  final _supabase = Supabase.instance.client;

  bool _isAdmin = false;
  bool _isLiveAgent = false;
  String _agentName = '';

  bool get isAdmin => _isAdmin;
  bool get isLiveAgent => _isLiveAgent;
  String get agentName => _agentName;

  Future<void> checkRole() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('profiles')
          .select('role, full_name')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null) {
        _isAdmin = response['role'] == 'admin';
        _isLiveAgent = response['role'] == 'live_agent' || _isAdmin;
        _agentName = response['full_name'] as String? ?? 'Agent';
      }
    } catch (e) {}
  }

  // Get all properties (admin)
  Future<List<Map<String, dynamic>>> getAllProperties() async {
    try {
      final response = await _supabase
          .from('properties')
          .select()
          .order('created_at', ascending: false);
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // Update property status (admin)
  Future<void> updatePropertyStatus(int propertyId, String status) async {
    try {
      await _supabase
          .from('properties')
          .update({'status': status}).eq('id', propertyId);
    } catch (e) {}
  }

  Future<bool> upsertProperty(Map<String, dynamic> property) async {
    try {
      final payload = {
        'name': property['name'] ?? '',
        'type': property['type'] ?? 'hotel',
        'location': property['location'] ?? '',
        'description': property['description'] ?? '',
        'price': property['price'] ?? 0,
        'weekend_price': property['weekend_price'] ?? 0,
        'currency': property['currency'] ?? 'USD',
        'rooms': property['rooms'] ?? 1,
        'amenities': property['amenities'] ?? [],
        'photos': property['photos'] ?? [],
        'image': property['image'] ?? '',
        'status': property['status'] ?? 'active',
      };

      if (property['id'] != null) {
        await _supabase
            .from('properties')
            .update(payload)
            .eq('id', property['id']);
      } else {
        await _supabase.from('properties').insert(payload);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProperty(int propertyId) async {
    try {
      await _supabase.from('properties').delete().eq('id', propertyId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get all users (admin)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false);
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // Get pending live chat requests
  Future<List<Map<String, dynamic>>> getPendingChats() async {
    try {
      final response = await _supabase
          .from('live_chat_requests')
          .select('*, profiles!live_chat_requests_user_id_fkey(full_name)')
          .eq('status', 'waiting')
          .order('created_at', ascending: true);
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // Get active live chat requests (for Active Chats tab)
  Future<List<Map<String, dynamic>>> getActiveChats() async {
    try {
      final response = await _supabase
          .from('live_chat_requests')
          .select('*, profiles!live_chat_requests_user_id_fkey(full_name)')
          .eq('status', 'active')
          .order('created_at', ascending: false);
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // Accept a live chat request
  Future<void> acceptChatRequest(int requestId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('live_chat_requests').update({
        'status': 'active',
        'agent_id': user.id,
        'agent_name': _agentName,
      }).eq('id', requestId);
    } catch (e) {}
  }

  // Create live chat request
  Future<void> createLiveChatRequest() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('live_chat_requests').insert({
        'user_id': user.id,
        'status': 'waiting',
      });
    } catch (e) {}
  }

  // Get all bookings (admin)
  Future<List<Map<String, dynamic>>> getAllBookings() async {
    try {
      final response = await _supabase
          .from('bookings')
          .select()
          .order('created_at', ascending: false);
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // Update user role
  Future<void> updateUserRole(String userId, String role) async {
    try {
      await _supabase.from('profiles').update({'role': role}).eq('id', userId);
    } catch (e) {}
  }

  // CMS management
  Future<List<Map<String, dynamic>>> getCmsEntries({String? section}) async {
    try {
      final query = _supabase.from('cms_entries').select();
      if (section != null && section.isNotEmpty) {
        query.eq('section', section);
      }
      final response = await query.order('sort_order', ascending: true);
      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> upsertCmsEntry(
      Map<String, dynamic> entry) async {
    try {
      final payload = {
        'section': entry['section'] ?? 'faq',
        'slug': entry['slug'] ?? '',
        'title': entry['title'] ?? '',
        'subtitle': entry['subtitle'] ?? '',
        'body': entry['body'] ?? '',
        'metadata': entry['metadata'] ?? {},
        'status': entry['status'] ?? 'active',
        'sort_order': entry['sort_order'] ?? 0,
      };
      if (entry['id'] != null) {
        final response = await _supabase
            .from('cms_entries')
            .update(payload)
            .eq('id', entry['id'])
            .select()
            .maybeSingle();
        return response as Map<String, dynamic>?;
      } else {
        final response = await _supabase
            .from('cms_entries')
            .insert(payload)
            .select()
            .maybeSingle();
        return response as Map<String, dynamic>?;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteCmsEntry(dynamic entryId) async {
    try {
      await _supabase.from('cms_entries').delete().eq('id', entryId);
    } catch (e) {}
  }
}

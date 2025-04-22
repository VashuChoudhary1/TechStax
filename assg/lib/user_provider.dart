import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider extends ChangeNotifier {
  String _userName = '';
  String get userName => _userName;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final _supabase = Supabase.instance.client;

  UserProvider() {
    _loadUserFromPrefs();
    _listenToAuthChanges();
  }

  Future<void> _loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString('userName') ?? '';
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  void _listenToAuthChanges() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      if (data.event == AuthChangeEvent.signedIn) {
        await _fetchUserProfile();
      } else if (data.event == AuthChangeEvent.signedOut) {
        _userName = '';
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final data = await _supabase
          .from('profiles')
          .select('name')
          .eq('id', userId)
          .single();

      if (data != null && data['name'] != null) {
        _userName = data['name'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', _userName);
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserName(String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('profiles').upsert({'id': userId, 'name': name});
      _userName = name;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _userName);
    } catch (e) {
      debugPrint('Error updating user name: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

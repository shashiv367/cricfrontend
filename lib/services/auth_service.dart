import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';
import 'api_service.dart';

/// Handles authentication and profile/role management.
class AuthService {
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
    required String role, // 'user' | 'player' | 'umpire'
    String? phone,
  }) async {
    try {
      developer.log('🔵 [AUTH] Starting signup for: $email, role: $role');
      
      // Call backend API for signup
      developer.log('🔵 [AUTH] Calling backend API for signup...');
      final backendResponse = await ApiService.signup(
        email: email,
        password: password,
        role: role,
        fullName: fullName,
        phone: phone,
      );
      developer.log('✅ [AUTH] Backend signup successful: $backendResponse');

      // Wait a moment for Supabase to sync
      await Future.delayed(const Duration(milliseconds: 500));
      
      // After backend creates user, sign in with Supabase to get session
      developer.log('🔵 [AUTH] Signing in with Supabase...');
      final resp = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      developer.log('✅ [AUTH] Supabase signin successful. User ID: ${resp.user?.id}');
      return resp;
    } catch (e, stackTrace) {
      developer.log('❌ [AUTH] Signup failed: $e', error: e, stackTrace: stackTrace);
      // If backend signup fails, throw the error
      rethrow;
    }
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      developer.log('🔵 [AUTH] Starting login for: $email');

      // Call backend API for login (to validate and get user info).
      // If this fails or times out, we still attempt Supabase login so the user
      // can continue using the app.
      try {
        developer.log('🔵 [AUTH] Calling backend API for login...');
        final backendResponse = await ApiService.login(
          email: email,
          password: password,
        );
        developer.log('✅ [AUTH] Backend login successful: $backendResponse');
      } catch (e, stackTrace) {
        developer.log(
          '⚠️ [AUTH] Backend login failed or timed out, continuing with Supabase login only: $e',
          error: e,
          stackTrace: stackTrace,
        );
      }

      // Then sign in with Supabase to get session
      developer.log('🔵 [AUTH] Signing in with Supabase...');
      final resp = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      developer.log('✅ [AUTH] Supabase signin successful. User ID: ${resp.user?.id}');
      return resp;
    } catch (e, stackTrace) {
      developer.log('❌ [AUTH] Login failed: $e', error: e, stackTrace: stackTrace);
      // If backend login fails, throw the error
      rethrow;
    }
  }

  /// Send password reset email (Supabase magic link).
  Future<void> resetPasswordForEmail(String email) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> sendPhoneOtp({required String phone}) async {
    await supabase.auth.signInWithOtp(phone: phone);
  }

  Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    final resp = await supabase.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
    if (resp.user != null) {
      // For OTP flow we don't yet collect role; default to 'user' profile.
      await _upsertProfile(resp.user!, role: 'user');
    }
    return resp;
  }

  Future<void> _upsertProfile(
    User user, {
    String? fullName,
    String? role,
    String? phone,
  }) async {
    await supabase.from('profiles').upsert({
      'id': user.id,
      if (fullName != null) 'full_name': fullName,
      if (user.email != null) 'username': user.email,
      if (role != null) 'role': role,
      if (phone != null) 'phone': phone,
    });
  }

  /// Returns the current user's role from the profiles table.
  Future<String?> getCurrentRole() async {
    try {
      developer.log('🔵 [AUTH] Getting current user role...');
      final user = supabase.auth.currentUser;
      if (user == null) {
        developer.log('⚠️ [AUTH] No current user found');
        return null;
      }
      developer.log('🔵 [AUTH] Current user ID: ${user.id}');

      final resp = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      developer.log('🔵 [AUTH] Profile query result: $resp');
      
      if (resp == null || resp['role'] == null) {
        developer.log('⚠️ [AUTH] No role found in profile, defaulting to "user"');
        return 'user'; // Default role if not found
      }
      
      final role = resp['role'] as String;
      developer.log('✅ [AUTH] User role: $role');
      return role;
    } catch (e, stackTrace) {
      developer.log('❌ [AUTH] Failed to get role: $e', error: e, stackTrace: stackTrace);
      return 'user'; // Default on error
    }
  }

  /// Update profile fields for the current user (used by Player dashboard).
  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? phone,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    final data = <String, dynamic>{};
    if (fullName != null) data['full_name'] = fullName;
    if (email != null) data['username'] = email;
    if (phone != null) data['phone'] = phone;

    if (data.isEmpty) return;

    await supabase.from('profiles').update(data).eq('id', user.id);
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      developer.log('🔵 [AUTH] Signing out...');
      await supabase.auth.signOut();
      developer.log('✅ [AUTH] Sign out successful');
    } catch (e, stackTrace) {
      developer.log('❌ [AUTH] Sign out failed: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}


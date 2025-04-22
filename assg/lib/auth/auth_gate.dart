// lib/auth/auth_gate.dart
import 'package:assg/services/supabase_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../dashboard/dashboard_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: SupabaseService.authStateStream,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data!.event == AuthChangeEvent.signedIn) {
          return const DashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}

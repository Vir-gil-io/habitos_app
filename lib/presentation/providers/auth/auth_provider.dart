import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habitos_app/presentation/providers/habits/habits_provider.dart';
import 'package:habitos_app/presentation/providers/reminders/reminders_provider.dart';
import 'package:habitos_app/presentation/providers/profile/profile_provider.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:habitos_app/presentation/providers/wearable/wearable_activity_provider.dart';


// ── Cliente Supabase accesible desde cualquier provider ─────────────────────
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// ── Estado del usuario autenticado ──────────────────────────────────────────
final authUserProvider = StreamProvider<User?>((ref) {
  return ref
      .watch(supabaseClientProvider)
      .auth
      .onAuthStateChange
      .map((event) => event.session?.user);
});

// ── Notifier con acciones de auth ────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;
  SupabaseClient get _client => _ref.read(supabaseClientProvider);

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      // Garantiza que no quede una sesión previa activa antes de iniciar otra
      if (_client.auth.currentSession != null) {
        await _client.auth.signOut();
      }
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      _invalidateUserData();
      state = const AsyncValue.data(null);
    } on AuthException catch (e, st) {
      state = AsyncValue.error(_translateError(e.message), st);
    } catch (e, st) {
      state = AsyncValue.error(
          'Ocurrió un error inesperado. Intenta de nuevo.', st);
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    state = const AsyncValue.loading();
    try {
      await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim()},
      );
      state = const AsyncValue.data(null);
    } on AuthException catch (e, st) {
      state = AsyncValue.error(_translateError(e.message), st);
    } catch (e, st) {
      state = AsyncValue.error(
          'Ocurrió un error inesperado. Intenta de nuevo.', st);
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    _invalidateUserData();
    state = const AsyncValue.data(null);
  }

  /// Limpia el caché de datos del usuario anterior para que el siguiente
  /// inicio de sesión cargue información fresca (evita datos "pegados").
  void _invalidateUserData() {
    _ref.invalidate(habitsProvider);
    _ref.invalidate(remindersProvider);
    _ref.invalidate(profileProvider);
    _ref.invalidate(wearableActivityProvider);
  }

  String _translateError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (lower.contains('user already registered')) {
      return 'Ya existe una cuenta con este correo electrónico.';
    }
    if (lower.contains('password should be at least')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Debes confirmar tu correo electrónico antes de iniciar sesión.';
    }
    if (lower.contains('unable to validate email address')) {
      return 'El formato del correo electrónico no es válido.';
    }
    if (lower.contains('network')) {
      return 'Error de conexión. Verifica tu internet e intenta de nuevo.';
    }
    return 'Ocurrió un error. Intenta de nuevo.';
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  return AuthNotifier(ref);
});
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habitos_app/config/config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConstants.url,
    publishableKey: SupabaseConstants.publishableKey,
  );

  debugPrint(
    '✅ Supabase inicializado: ${Supabase.instance.client.supabaseUrl}',
  );

  // Prueba real de conexión a la base de datos
  try {
    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .limit(1);
    debugPrint('✅ Conexión a Supabase OK. Respuesta: $response');
  } catch (e) {
    debugPrint('❌ Error de conexión a Supabase: $e');
  }

  runApp(const ProviderScope(child: HabitosApp()));
}

extension on SupabaseClient {
  get supabaseUrl => null;
}

class HabitosApp extends StatelessWidget {
  const HabitosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      routerConfig: appRouter,
    );
  }
}

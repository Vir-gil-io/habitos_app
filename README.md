# habitos_app
## Configuración de Supabase

### Dependencia

```yaml
# pubspec.yaml
dependencies:
  supabase_flutter: ^2.16.0
```

```bash
flutter pub get
```

### Variables de conexión

En el archivo `lib/config/constants/supabase_constants.dart`:

```dart
class SupabaseConstants {
  static const String url        = 'https://<PROJECT_ID>.supabase.co';
  static const String publishableKey   = '<PUBLISHABLE_KEY>';
}
```

| Variable   | Origen en Dashboard                          | Formato                        |
|------------|----------------------------------------------|--------------------------------|
| `url`      | Project Settings → General → Project URL     | `https://<id>.supabase.co`     |
| `publishableKey`  | Project Settings → API Keys → Publishable key | `sb_publishable_<hash>`        |

> Nunca expongas la **Secret key** (`sb_secret_...`) en el cliente móvil. Está reservada para servicios de servidor, Edge Functions o workers backend. La Publishable key es segura en el cliente únicamente cuando todas las tablas tienen **Row Level Security (RLS)** habilitado con policies explícitas por `auth.uid()`, tal como está configurado en este proyecto.

### Inicialización

```dart
// lib/main.dart
await Supabase.initialize(
  url: SupabaseConstants.url,
  publishableKey: SupabaseConstants.publishableKey,
);
```

### Seguridad implementada

| Mecanismo | Descripción |
|---|---|
| Row Level Security | Habilitado en `profiles`, `habits` y `reminders`. Cada policy valida `auth.uid() = user_id` a nivel de base de datos. |
| Trigger `handle_new_user` | Crea el perfil del usuario automáticamente al registrarse, ejecutado con `SECURITY DEFINER` para evitar exposición de permisos. |
| Constraints CHECK | Valores de `category` y `unit` validados por la BD; rechaza entradas fuera del dominio definido. |
| Double-check en cliente | Todos los queries en los datasources incluyen `.eq('user_id', _userId)` como capa adicional, independiente del RLS. |

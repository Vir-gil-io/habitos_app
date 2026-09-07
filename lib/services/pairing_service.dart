import 'package:supabase_flutter/supabase_flutter.dart';

class PairingService {
  final SupabaseClient _client;
  PairingService(this._client);

  Future<bool> claimPairing(String deviceSecret) async {
    final result = await _client.rpc('claim_pairing', params: {
      'p_device_secret': deviceSecret,
    });
    return result as bool? ?? false;
  }
}
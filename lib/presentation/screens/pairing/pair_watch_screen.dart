import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:habitos_app/config/theme/app_theme.dart';
import 'package:habitos_app/presentation/providers/providers.dart';
import 'package:habitos_app/services/pairing_service.dart';

class PairWatchScreen extends ConsumerStatefulWidget {
  const PairWatchScreen({super.key});

  @override
  ConsumerState<PairWatchScreen> createState() => _PairWatchScreenState();
}

class _PairWatchScreenState extends ConsumerState<PairWatchScreen> {
  bool _processing = false;
  String? _resultMessage;
  bool _success = false;

  Future<void> _handleCode(String code) async {
    if (_processing) return;
    setState(() => _processing = true);

    try {
      final service = PairingService(ref.read(supabaseClientProvider));
      final ok = await service.claimPairing(code);
      setState(() {
        _success = ok;
        _resultMessage = ok
            ? 'Dispositivo vinculado correctamente!'
            : 'El código ya expiró o no es válido. Genera uno nuevo en el reloj.';
      });
    } catch (e) {
      setState(() {
        _success = false;
        _resultMessage = 'Ocurrió un error al vincular. Intenta de nuevo.';
      });
    } finally {
      setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Vincular Dispositivo'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: _resultMessage != null
          ? _ResultView(
              success: _success,
              message: _resultMessage!,
              onRetry: () => setState(() => _resultMessage = null),
            )
          : Stack(
              children: [
                MobileScanner(
                  onDetect: (capture) {
                    final barcode = capture.barcodes.first;
                    final value = barcode.rawValue;
                    if (value != null) _handleCode(value);
                  },
                ),
                if (_processing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                Positioned(
                  bottom: 32,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Apunta la cámara al código QR que aparece en tu Dispositivo',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final bool success;
  final String message;
  final VoidCallback onRetry;

  const _ResultView({
    required this.success,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              color: success ? AppTheme.completed : AppTheme.pending,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            if (!success)
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
                child: const Text('Intentar de nuevo'),
              )
            else
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
                child: const Text('Listo'),
              ),
          ],
        ),
      ),
    );
  }
}
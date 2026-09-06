import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../design_system/alera_colors.dart';
import '../../../design_system/alera_typography.dart';
import '../../../design_system/widgets/alera_button.dart';
import '../../caregiver/data/auth/caregiver_session_controller.dart';
import '../data/auth/patient_auth_api.dart';
import 'patient_access.dart';

class PatientQrScannerPage extends StatefulWidget {
  final CaregiverSessionController sessionController;
  const PatientQrScannerPage({super.key, required this.sessionController});

  @override
  State<PatientQrScannerPage> createState() => _PatientQrScannerPageState();
}

class _PatientQrScannerPageState extends State<PatientQrScannerPage> {
  final MobileScannerController _scanner = MobileScannerController(
    autoStart: true,
    facing: CameraFacing.back,
    formats: const [BarcodeFormat.qrCode],
  );
  final PatientQrDetectionBoundary _detections = PatientQrDetectionBoundary();
  bool _connecting = false;
  bool _disposed = false;
  String? _error;

  @override
  void dispose() {
    _disposed = true;
    // MobileScanner detaches its preview before this State disposes the
    // externally-owned controller. This also releases the camera on Back.
    _scanner.dispose();
    super.dispose();
  }

  Future<void> _stopScanner() async {
    if (_disposed) return;
    try {
      await _scanner.stop();
    } on MobileScannerException {
      // A concurrent lifecycle transition may already have stopped it.
    }
  }

  Future<void> _startScanner() async {
    if (_disposed || _connecting || !mounted) return;
    try {
      await _scanner.start(cameraDirection: CameraFacing.back);
    } on MobileScannerException {
      if (mounted && !_disposed) {
        setState(
          () =>
              _error = 'Camera access is needed to scan your patient QR code.',
        );
      }
    }
  }

  Future<void> _detect(BarcodeCapture capture) async {
    if (_connecting || capture.barcodes.isEmpty) return;
    final result = _detections.inspect(
      capture.barcodes.map((barcode) => barcode.rawValue),
    );
    if (result == null) return;
    if (result is InvalidPatientQr) {
      if (mounted) setState(() => _error = result.message);
      return;
    }
    setState(() {
      _connecting = true;
      _error = null;
    });
    await _stopScanner();
    if (!mounted || _disposed) return;
    try {
      await widget.sessionController.accessPatient(
        accessCode: (result as ValidPatientQr).accessCode,
      );
    } on PatientAccessFailure catch (failure) {
      if (mounted) {
        setState(() {
          _connecting = false;
          _error = failure.message;
          _detections.allowRetry();
        });
        await _startScanner();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _connecting = false;
          _error =
              'We couldn’t connect to Alera. Check your internet connection and try again.';
          _detections.allowRetry();
        });
        await _startScanner();
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Scan Patient QR Code')),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Position the QR code inside the frame.',
              style: AleraTypography.sectionTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Scanning will connect this device to your care household.',
              style: AleraTypography.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      key: const Key('patient-qr-scanner'),
                      controller: _scanner,
                      useAppLifecycleState: true,
                      onDetect: _detect,
                      errorBuilder: (context, error) => const ColoredBox(
                        color: Colors.black87,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Camera access is needed to scan your patient QR code.',
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const IgnorePointer(child: _ScannerFrameOverlay()),
                  ],
                ),
              ),
            ),
            if (_connecting) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              const Text('Connecting to your household…'),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                key: const Key('scanner-error'),
                style: const TextStyle(color: AleraColors.critical),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  tooltip: 'Flashlight',
                  onPressed: _connecting ? null : _scanner.toggleTorch,
                  icon: const Icon(Icons.flashlight_on),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AleraButton(
                    label: 'Enter Patient Code',
                    variant: AleraButtonVariant.secondary,
                    onPressed: _connecting
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _ScannerFrameOverlay extends StatelessWidget {
  const _ScannerFrameOverlay();

  @override
  Widget build(BuildContext context) => Center(
    child: FractionallySizedBox(
      widthFactor: 0.72,
      child: AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          key: const Key('patient-qr-scan-frame'),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 3),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';

import '../../../../design_system/alera_colors.dart';
import '../../../../design_system/alera_theme.dart';
import '../../../../design_system/alera_typography.dart';
import '../../../../design_system/widgets/alera_button.dart';
import '../../../../design_system/widgets/alera_card.dart';
import '../../../../interfaces/elderly_interface.dart';
import '../../../patient/data/auth/patient_auth_api.dart';
import '../../../patient/presentation/patient_access.dart';
import '../../../patient/presentation/patient_qr_scanner_page.dart';
import '../../caregiver_shell.dart';
import '../../data/api/caregiver_alert_api_data_source.dart';
import '../../data/api/caregiver_patient_api_data_source.dart';
import '../../data/auth/caregiver_auth_api.dart';
import '../../data/auth/caregiver_session_controller.dart';
import '../../data/auth/caregiver_token_store.dart';
import '../../domain/repositories/caregiver_repository.dart';

class CaregiverAuthGate extends StatefulWidget {
  final CaregiverRepository repository;
  final CaregiverSessionController? sessionController;

  const CaregiverAuthGate({
    super.key,
    required this.repository,
    this.sessionController,
  });

  @override
  State<CaregiverAuthGate> createState() => _CaregiverAuthGateState();
}

class _CaregiverAuthGateState extends State<CaregiverAuthGate> {
  late final CaregiverSessionController _session;
  GlobalKey<NavigatorState> _navigationKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _session = widget.sessionController ?? CaregiverSessionController.instance;
    _session.addListener(_onSessionChanged);
    _session.restoreSession();
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    if (mounted) {
      setState(() => _navigationKey = GlobalKey<NavigatorState>());
    }
  }

  Future<void> _signOut() async {
    try {
      await _session.logout();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            action: SnackBarAction(label: 'Retry', onPressed: _signOut),
            content: const Text(
              'Unable to clear saved sign-in. Please try signing out again.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget page = switch (_session.status) {
      CaregiverSessionStatus.restoring => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      CaregiverSessionStatus.unauthenticated => Theme(
        data: AleraTheme.caregiver(Theme.of(context)),
        child: HouseholdAuthFlow(sessionController: _session),
      ),
      CaregiverSessionStatus.authenticated =>
        _session.sessionType == SessionType.elderlyPatient
            ? ElderlyInterface(onSignOut: _signOut)
            : CaregiverShell(
                repository: widget.repository,
                alertDataSource: CaregiverAlertApiDataSource(session: _session),
                loadNotificationAlert: CaregiverAlertApiDataSource(
                  session: _session,
                ).fetchAlert,
                patientDataSource: CaregiverPatientApiDataSource(
                  session: _session,
                ),
                householdCode: _session.householdCode,
                onSignOut: _signOut,
              ),
    };
    // Discard the complete navigation stack on logout/401 or role changes.
    return NavigatorPopHandler<void>(
      onPopWithResult: (_) => _navigationKey.currentState?.maybePop(),
      child: Navigator(
        key: _navigationKey,
        onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => page),
      ),
    );
  }
}

enum _AuthStep {
  welcome,
  role,
  household,
  caregiver,
  patientOptions,
  patientManual,
}

class HouseholdAuthFlow extends StatefulWidget {
  final CaregiverSessionController sessionController;
  const HouseholdAuthFlow({super.key, required this.sessionController});

  @override
  State<HouseholdAuthFlow> createState() => _HouseholdAuthFlowState();
}

class _HouseholdAuthFlowState extends State<HouseholdAuthFlow> {
  final _formKey = GlobalKey<FormState>();
  final _household = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _accessCode = TextEditingController();
  _AuthStep _step = _AuthStep.welcome;
  bool _submitting = false;
  String? _error;
  String? _householdName;

  @override
  void dispose() {
    _household.dispose();
    _email.dispose();
    _password.dispose();
    _accessCode.dispose();
    super.dispose();
  }

  void _go(_AuthStep step) {
    if (_submitting) return;
    setState(() {
      _step = step;
      if (step == _AuthStep.household) _householdName = null;
      _error = null;
      _password.clear();
      _accessCode.clear();
    });
  }

  void _back() => _go(switch (_step) {
    _AuthStep.welcome => _AuthStep.welcome,
    _AuthStep.role => _AuthStep.welcome,
    _AuthStep.household => _AuthStep.role,
    _AuthStep.caregiver => _AuthStep.household,
    _AuthStep.patientOptions => _AuthStep.role,
    _AuthStep.patientManual => _AuthStep.patientOptions,
  });

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  Future<void> _continueHousehold() async {
    if (_submitting || !(_formKey.currentState?.validate() ?? false)) return;
    _household.text = _household.text.trim().toUpperCase();
    setState(() {
      _submitting = true;
      _error = null;
      _householdName = null;
    });
    try {
      final validation = await widget.sessionController.validateHousehold(
        _household.text,
      );
      if (!mounted) return;
      setState(() {
        _householdName = validation.householdName;
        _step = _AuthStep.caregiver;
      });
    } on HouseholdValidationException catch (failure) {
      if (mounted) setState(() => _error = failure.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'We couldn’t verify the household right now. Check your connection and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _submit() async {
    if (_submitting || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      if (_step == _AuthStep.patientManual) {
        await widget.sessionController.accessPatient(
          accessCode: normalizePatientAccessCode(_accessCode.text),
        );
      } else {
        await widget.sessionController.login(
          householdCode: _household.text,
          email: _email.text.trim(),
          password: _password.text,
        );
      }
    } on CaregiverLoginFailure catch (error) {
      if (mounted) setState(() => _error = error.message);
    } on PatientAccessFailure catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Unable to sign in. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (_step) {
      _AuthStep.welcome => 'Welcome to Alera',
      _AuthStep.role => 'How will you use Alera?',
      _AuthStep.household => 'Enter household code',
      _AuthStep.caregiver => 'Caregiver sign in',
      _AuthStep.patientOptions => 'Connect to your care household',
      _AuthStep.patientManual => 'Enter your patient code',
    };
    return PopScope(
      canPop: _step == _AuthStep.welcome,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: AleraColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AleraCard(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_step != _AuthStep.welcome)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: _submitting ? null : _back,
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Back'),
                            ),
                          ),
                        Text(title, style: AleraTypography.pageTitle),
                        const SizedBox(height: 20),
                        if (_step == _AuthStep.welcome) ...[
                          Text(
                            'Connect with your household.',
                            style: AleraTypography.body,
                          ),
                          const SizedBox(height: 24),
                          AleraButton(
                            label: 'Get Started',
                            onPressed: () => _go(_AuthStep.role),
                          ),
                        ],
                        if (_step == _AuthStep.household) ...[
                          TextFormField(
                            key: const Key('household-code-field'),
                            controller: _household,
                            textCapitalization: TextCapitalization.characters,
                            autocorrect: false,
                            enableSuggestions: false,
                            decoration: const InputDecoration(
                              labelText: 'Household code',
                              hintText: 'XXXX-XXXX',
                            ),
                            validator: (value) =>
                                RegExp(
                                  r'^[A-Za-z0-9]{4}-[A-Za-z0-9]{4}$',
                                ).hasMatch(value?.trim() ?? '')
                                ? null
                                : 'Enter a household code in XXXX-XXXX format.',
                            enabled: !_submitting,
                            onFieldSubmitted: (_) => _continueHousehold(),
                          ),
                          const SizedBox(height: 20),
                          AleraButton(
                            label: _submitting ? 'Validating…' : 'Continue',
                            onPressed: _submitting ? null : _continueHousehold,
                          ),
                        ],
                        if (_step == _AuthStep.caregiver) ...[
                          Text(
                            'Signing in to ${_householdName!}',
                            key: const Key('selected-household'),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: _submitting
                                  ? null
                                  : () => _go(_AuthStep.household),
                              child: const Text('Edit household'),
                            ),
                          ),
                        ],
                        if (_step == _AuthStep.role) ...[
                          Text(
                            'Choose the option that best describes you.',
                            style: AleraTypography.body,
                          ),
                          const SizedBox(height: 20),
                          AleraButton(
                            label: 'I’m a Caregiver',
                            onPressed: () => _go(_AuthStep.household),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Monitor and support the people assigned to your care.',
                            style: AleraTypography.body,
                          ),
                          const SizedBox(height: 14),
                          AleraButton(
                            label: 'I’m a Patient',
                            onPressed: () => _go(_AuthStep.patientOptions),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Connect to your care household and view your health information.',
                            style: AleraTypography.body,
                          ),
                        ],
                        if (_step == _AuthStep.caregiver) ...[
                          TextFormField(
                            key: const Key('caregiver-email-field'),
                            controller: _email,
                            enabled: !_submitting,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            validator: _required,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            key: const Key('caregiver-password-field'),
                            controller: _password,
                            enabled: !_submitting,
                            obscureText: true,
                            autocorrect: false,
                            enableSuggestions: false,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            validator: _required,
                            onFieldSubmitted: (_) => _submit(),
                          ),
                        ],
                        if (_step == _AuthStep.patientOptions) ...[
                          Text(
                            'Scan the QR code provided by your caregiver to securely access your Alera account.',
                            style: AleraTypography.body,
                          ),
                          const SizedBox(height: 20),
                          AleraButton(
                            label: 'Scan QR Code',
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => PatientQrScannerPage(
                                  sessionController: widget.sessionController,
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text('or', textAlign: TextAlign.center),
                          ),
                          AleraButton(
                            label: 'Enter Patient Code',
                            variant: AleraButtonVariant.secondary,
                            onPressed: () => _go(_AuthStep.patientManual),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your patient code can only be used once.',
                            style: AleraTypography.body,
                            textAlign: TextAlign.center,
                          ),
                        ],
                        if (_step == _AuthStep.patientManual) ...[
                          Text(
                            'Enter the one-time code provided by your caregiver.',
                            style: AleraTypography.body,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            key: const Key('patient-access-code-field'),
                            controller: _accessCode,
                            enabled: !_submitting,
                            textCapitalization: TextCapitalization.characters,
                            autocorrect: false,
                            enableSuggestions: false,
                            decoration: const InputDecoration(
                              hintText: 'XXXX-XXXX-XXXX',
                            ),
                            inputFormatters: const [
                              PatientAccessCodeFormatter(),
                            ],
                            validator: (value) =>
                                isValidPatientAccessCode(
                                  normalizePatientAccessCode(value ?? ''),
                                )
                                ? null
                                : 'Enter a valid patient code.',
                            onFieldSubmitted: (_) => _submit(),
                          ),
                        ],
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            key: const Key('auth-error'),
                            style: const TextStyle(color: AleraColors.critical),
                          ),
                        ],
                        if (_step == _AuthStep.caregiver ||
                            _step == _AuthStep.patientManual) ...[
                          const SizedBox(height: 20),
                          AleraButton(
                            label: _submitting ? 'Signing in…' : 'Sign in',
                            onPressed: _submitting ? null : _submit,
                            height: 48,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

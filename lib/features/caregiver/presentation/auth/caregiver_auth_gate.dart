import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../design_system/alera_colors.dart';
import '../../../../design_system/alera_theme.dart';
import '../../../../design_system/alera_typography.dart';
import '../../../../design_system/widgets/alera_button.dart';
import '../../../../design_system/widgets/alera_card.dart';
import '../../caregiver_shell.dart';
import '../../data/api/caregiver_alert_api_data_source.dart';
import '../../data/auth/caregiver_auth_api.dart';
import '../../data/auth/caregiver_session_controller.dart';
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
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AleraTheme.caregiver(Theme.of(context)),
      child: switch (_session.status) {
        CaregiverSessionStatus.restoring => const _RestoringSessionPage(),
        CaregiverSessionStatus.unauthenticated => CaregiverLoginPage(
          sessionController: _session,
        ),
        CaregiverSessionStatus.authenticated => CaregiverShell(
          repository: widget.repository,
          alertDataSource: CaregiverAlertApiDataSource(session: _session),
        ),
      },
    );
  }
}

class _RestoringSessionPage extends StatelessWidget {
  const _RestoringSessionPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AleraColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AleraColors.primary),
      ),
    );
  }
}

class CaregiverLoginPage extends StatefulWidget {
  final CaregiverSessionController sessionController;

  const CaregiverLoginPage({super.key, required this.sessionController});

  @override
  State<CaregiverLoginPage> createState() => _CaregiverLoginPageState();
}

class _CaregiverLoginPageState extends State<CaregiverLoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _householdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _householdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false) || _submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await widget.sessionController.login(
        householdCode: _householdController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on CaregiverLoginFailure catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Caregiver login: unexpected session failure.');
        debugPrint('$error');
        debugPrintStack(stackTrace: stackTrace);
      }
      if (mounted) {
        setState(() => _error = 'Unable to sign in. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      Text(
                        'Caregiver sign in',
                        style: AleraTypography.pageTitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to view alerts for your household.',
                        style: AleraTypography.body,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        key: const Key('household-code-field'),
                        controller: _householdController,
                        decoration: const InputDecoration(
                          labelText: 'Household code',
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        key: const Key('caregiver-email-field'),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: _required,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        key: const Key('caregiver-password-field'),
                        controller: _passwordController,
                        obscureText: true,
                        enableSuggestions: false,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        validator: _required,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          key: const Key('caregiver-login-error'),
                          style: const TextStyle(color: AleraColors.critical),
                        ),
                      ],
                      const SizedBox(height: 20),
                      AleraButton(
                        label: _submitting ? 'Signing in…' : 'Sign in',
                        onPressed: _submitting ? null : _submit,
                        height: 48,
                      ),
                    ],
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

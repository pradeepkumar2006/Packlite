import 'package:flutter/material.dart';
import '../home/home.dart';
import '../core/theme.dart';
import '../core/widgets/packlite_logo.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confPassCtrl = TextEditingController();
  
  bool _obs = true;
  bool _obs2 = true;
  bool _terms = false;
  bool _loading = false;
  int _passStrength = 0;

  @override
  void initState() {
    super.initState();
    _passCtrl.addListener(_updateStrength);
  }

  void _updateStrength() {
    final v = _passCtrl.text;
    if (v.isEmpty) {
      setState(() => _passStrength = 0);
    } else if (v.length < 4) {
      setState(() => _passStrength = 1);
    } else if (v.length < 8) {
      setState(() => _passStrength = 2);
    } else if (v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      setState(() => _passStrength = 4);
    } else {
      setState(() => _passStrength = 3);
    }
  }

  void _signup() async {
    if (!_formKey.currentState!.validate() || !_terms) {
      if (!_terms) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please agree to terms.'), backgroundColor: PackLiteTheme.error));
      return;
    }
    PackLiteTheme.haptic();
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, secondary) => const HomeScreen(),
        transitionsBuilder: (context, anim, secondary, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
                  child: const PackLiteLogo(size: 32),
                ),
                const SizedBox(height: 12),
                const Text('PACKLITE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24)),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Create account', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32)),
                      const SizedBox(height: 8),
                      Text('Start packing smarter today', style: TextStyle(color: PackLiteTheme.mutedText, fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildField(ctrl: _nameCtrl, hint: 'Enter your full name', icon: Icons.person_outline_rounded, validator: (v) => (v == null || v.length < 2) ? 'Name is too short' : null, enabled: !_loading),
                const SizedBox(height: 16),
                _buildField(ctrl: _emailCtrl, hint: 'Enter your email', icon: Icons.email_outlined, validator: (v) => (v == null || !v.contains('@')) ? 'Invalid email format' : null, enabled: !_loading),
                const SizedBox(height: 16),
                _buildField(
                  ctrl: _passCtrl, 
                  hint: 'Create a password', 
                  icon: Icons.lock_outline_rounded,
                  obs: _obs,
                  suffix: IconButton(icon: Icon(_obs ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: PackLiteTheme.mutedText), onPressed: () => setState(() => _obs = !_obs)),
                  validator: (v) => (v == null || v.length < 6) ? 'Password is too short' : null,
                  enabled: !_loading,
                ),
                _buildStrengthIndicator(),
                const SizedBox(height: 16),
                _buildField(
                  ctrl: _confPassCtrl, 
                  hint: 'Confirm your password', 
                  icon: Icons.lock_outline_rounded,
                  obs: _obs2,
                  suffix: IconButton(icon: Icon(_obs2 ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: PackLiteTheme.mutedText), onPressed: () => setState(() => _obs2 = !_obs2)),
                  validator: (v) => (v != _passCtrl.text) ? 'Passwords do not match' : null,
                  enabled: !_loading,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _terms, 
                      onChanged: (v) {
                        PackLiteTheme.haptic();
                        setState(() => _terms = v ?? false);
                      },
                      activeColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 1.5),
                    ),
                    Expanded(
                      child: Text('I agree to the Terms & Conditions and Privacy Policy', style: TextStyle(fontSize: 12, color: PackLiteTheme.mutedText, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Tappable(
                  onTap: _signup,
                  child: Container(
                    width: double.infinity, height: 56,
                    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
                    child: Center(
                      child: _loading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : const Text('Create Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: PackLiteTheme.cardBorder)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR', style: TextStyle(color: PackLiteTheme.mutedText, fontWeight: FontWeight.w700)),
                    ),
                    Expanded(child: Divider(color: PackLiteTheme.cardBorder)),
                  ],
                ),
                const SizedBox(height: 24),
                Tappable(
                  onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (c) => const HomeScreen())),
                  child: Container(
                    width: double.infinity, height: 56,
                    decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(16)),
                    child: const Center(
                      child: Text('Continue as Guest', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ', style: TextStyle(color: PackLiteTheme.mutedText, fontWeight: FontWeight.w500)),
                    Tappable(
                      onTap: () => Navigator.pop(context),
                      child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w900, decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStrengthIndicator() {
    if (_passCtrl.text.isEmpty) return const SizedBox.shrink();
    
    final labels = ["Too Short", "Weak", "Fair", "Good", "Strong"];
    final colors = [PackLiteTheme.error, PackLiteTheme.error, PackLiteTheme.mutedText2, PackLiteTheme.mutedText, Colors.black];
    
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          children: List.generate(4, (i) => Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i == 3 ? 0 : 4),
              decoration: BoxDecoration(
                color: (i < _passStrength) ? colors[_passStrength] : PackLiteTheme.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(labels[_passStrength], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors[_passStrength])),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    bool obs = false,
    Widget? suffix,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obs,
      enabled: enabled,
      validator: validator,
      cursorColor: Colors.black,
      style: const TextStyle(fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: PackLiteTheme.mutedText),
        suffixIcon: suffix,
        hintText: hint,
        hintStyle: TextStyle(color: PackLiteTheme.mutedText, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: PackLiteTheme.cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: PackLiteTheme.cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.black, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: PackLiteTheme.error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: PackLiteTheme.error, width: 2)),
        errorStyle: const TextStyle(color: PackLiteTheme.error, fontWeight: FontWeight.w500, fontSize: 10),
      ),
    );
  }
}

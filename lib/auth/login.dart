import 'package:flutter/material.dart';
import 'signup.dart';
import '../home/home.dart';
import '../core/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsign;
import '../core/widgets/packlite_logo.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obs = true;
  bool _loading = false;
  bool _googleLoading = false;

  final gsign.GoogleSignIn _googleSignIn = gsign.GoogleSignIn();

  Future<void> _googleLogin() async {
    PackLiteTheme.haptic();
    setState(() => _googleLoading = true);
    
    try {
      final gsign.GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _googleLoading = false);
        return;
      }

      final gsign.GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, anim, secondary) => const HomeScreen(),
          transitionsBuilder: (context, anim, secondary, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    PackLiteTheme.haptic();
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _loading = false);
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, secondary) => const HomeScreen(),
        transitionsBuilder: (context, anim, secondary, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _guest() {
    PackLiteTheme.haptic();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim, secondary) => const HomeScreen(),
        transitionsBuilder: (context, anim, secondary, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const PackLiteLogo(size: 32),
                ),
                const SizedBox(height: 12),
                const Text(
                  'PACKLITE',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
                ),
                const SizedBox(height: 48),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome back',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue your journey',
                        style: TextStyle(color: PackLiteTheme.mutedText, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildField(
                  ctrl: _emailCtrl,
                  hint: 'Enter your email',
                  icon: Icons.email_outlined,
                  validator: (v) => (v == null || !v.contains('@')) ? 'Invalid email format' : null,
                  enabled: !_loading,
                ),
                const SizedBox(height: 16),
                _buildField(
                  ctrl: _passCtrl,
                  hint: 'Enter your password',
                  icon: Icons.lock_outline_rounded,
                  obs: _obs,
                  suffix: IconButton(
                    icon: Icon(_obs ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: PackLiteTheme.mutedText),
                    onPressed: () => setState(() => _obs = !_obs),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
                  enabled: !_loading,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => PackLiteTheme.haptic(),
                    child: const Text('Forgot Password?', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 24),
                Tappable(
                  onTap: _loading ? () {} : _login,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: _loading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                        : const Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Tappable(
                  onTap: _googleLoading ? () {} : _googleLogin,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: PackLiteTheme.cardBorder),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _googleLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                                  height: 24,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Continue with Google',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 16),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: PackLiteTheme.cardBorder)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR', style: TextStyle(color: PackLiteTheme.mutedText, fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                    Expanded(child: Divider(color: PackLiteTheme.cardBorder)),
                  ],
                ),
                const SizedBox(height: 24),
                Tappable(
                  onTap: _guest,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('Continue as Guest', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Don\'t have an account? ', style: TextStyle(color: PackLiteTheme.mutedText, fontWeight: FontWeight.w500)),
                    Tappable(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, anim, secondary) => const SignupScreen(),
                            transitionsBuilder: (context, anim, secondary, child) => FadeTransition(opacity: anim, child: child),
                            transitionDuration: const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.w900, decoration: TextDecoration.underline)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
        errorStyle: const TextStyle(color: PackLiteTheme.error, fontWeight: FontWeight.w500),
      ),
    );
  }
}

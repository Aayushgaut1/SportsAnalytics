import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  void _login() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final res = await ApiService.login(_usernameController.text, _passwordController.text);
      if (res['success'] == true || (_usernameController.text == 'admin' && _passwordController.text == 'admin')) {
        widget.onLoginSuccess();
      } else {
        setState(() { _error = 'Invalid credentials. Try admin/admin'; });
      }
    } catch (e) {
      if (_usernameController.text == 'admin' && _passwordController.text == 'admin') {
        widget.onLoginSuccess();
      } else {
        setState(() { _error = 'Connection Error. Please check your backend.'; });
      }
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [appState.primaryColor, Colors.black, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Opacity(
              opacity: 0.1,
              child: Image.network(
                'https://images.unsplash.com/photo-1504450758481-7338eba7524a?w=1200&q=80',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', width: 100, height: 100),
                  const SizedBox(height: 20),
                  Text('SPORTSALYTICS', style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  Text('MANAGEMENT SYSTEM', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 4)),
                  const SizedBox(height: 60),
                  _buildTextField(_usernameController, 'Username', Icons.person_outline, false),
                  const SizedBox(height: 20),
                  _buildTextField(_passwordController, 'Password', Icons.lock_outline, true),
                  if (_error != null) ...[
                    const SizedBox(height: 20),
                    Text(_error!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ],
                  const SizedBox(height: 40),
                  _buildLoginButton(),
                  const SizedBox(height: 20),
                  _buildGuestButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: widget.onLoginSuccess,
        child: Text(
          'CONTINUE AS GUEST',
          style: GoogleFonts.outfit(
            color: Colors.white24,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isPassword) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: appState.primaryColor),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: appState.primaryColor,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          shadowColor: appState.primaryColor.withOpacity(0.5),
        ),
        onPressed: _isLoading ? null : _login,
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.black)
          : Text('SIGN IN', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
    );
  }
}

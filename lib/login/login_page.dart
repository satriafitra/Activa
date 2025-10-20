import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'curved_green_shape.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  // Controller untuk input
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variabel untuk alert
  bool _showAlert = false;
  bool _isSuccess = false;
  String _alertMessage = '';

  // Warna Utama
  static const Color primaryColor = Color.fromARGB(255, 54, 71, 95);
  static const Color accentColor = Color(0xFF4CAE60);
  static const Color inputFillColor = Color(0xFFF3F6F9);

  // Style Text
  TextStyle poppinsStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    Color color = primaryColor,
  }) {
    return GoogleFonts.poppins(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // Fungsi Dummy Login
  void _login() {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username == "pauzan" && password == "123") {
      _showCustomAlert(true, "Login Berhasil! Selamat datang, $username 👋");
    } else {
      _showCustomAlert(false, "Username atau password salah ❌");
    }
  }

  // Fungsi Menampilkan Alert
  void _showCustomAlert(bool success, String message) {
    setState(() {
      _showAlert = true;
      _isSuccess = success;
      _alertMessage = message;
    });

    // Hilangkan alert setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showAlert = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Sign In',
                    textAlign: TextAlign.center,
                    style: poppinsStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This is the desc of sign in lorem ipsum',
                    textAlign: TextAlign.center,
                    style: poppinsStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 40),

                  _buildInputField(
                    context,
                    controller: _usernameController,
                    hintText: 'username',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),

                  _buildInputField(
                    context,
                    controller: _passwordController,
                    hintText: 'password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),
                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot password?',
                        style: poppinsStyle(
                          color: accentColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),

                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 22),
                    ),
                    child: Text(
                      'Login',
                      style: poppinsStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Haven't any account?",
                        style: poppinsStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Sign Up',
                          style: poppinsStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          const Align(
            alignment: Alignment.bottomCenter,
            child: CurvedGreenShape(),
          ),

          // ALERT DI BAGIAN ATAS
          if (_showAlert)
            Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF5252),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSuccess ? Icons.check_circle : Icons.error_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _alertMessage,
                        style: poppinsStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _showAlert = false),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: inputFillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: poppinsStyle(
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: poppinsStyle(
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
          prefixIcon: Icon(icon, color: primaryColor.withOpacity(0.6)),
          suffixIcon: isPassword
              ? Icon(Icons.visibility_off_outlined,
                  color: primaryColor.withOpacity(0.6))
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        ),
      ),
    );
  }
}

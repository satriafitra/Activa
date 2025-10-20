import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'curved_green_shape.dart'; 

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  // Konstanta Warna Utama
  static const Color primaryColor = Color.fromARGB(255, 54, 71, 95); 
  static const Color accentColor = Color(0xFF4CAE60); 
  static const Color inputFillColor = Color(0xFFF3F6F9); 

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
                    hintText: 'username',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),

                  _buildInputField(
                    context, 
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
                    onPressed: () {},
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
        ],
      ),
    );
  }

  Widget _buildInputField(
    BuildContext context, {
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
              ? Icon(Icons.visibility_off_outlined, color: primaryColor.withOpacity(0.6))
              : null,
          border: InputBorder.none, 
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        ),
      ),
    );
  }
}
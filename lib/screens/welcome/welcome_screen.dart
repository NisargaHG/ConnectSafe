import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              // Logo
              Container(
                height: 120,
                width: 120,

                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(30),
                ),

                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 65,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "ConnectSafe",
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0B1F3A),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Stay Connected.\nStay Safe.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 70),

              // Create Account Button
              SizedBox(
                width: double.infinity,
                height: 56,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/signup");
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  child: const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,

                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/login");
                  },

                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFFE53935),
                      width: 1.5,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  child: const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE53935),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "By continuing, you agree to our",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: const [

                  Text(
                    "Terms of Service",
                    style: TextStyle(
                      color: Color(0xFFE53935),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(width: 10),

                  Text(
                    "•",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(width: 10),

                  Text(
                    "Privacy Policy",
                    style: TextStyle(
                      color: Color(0xFFE53935),
                      fontWeight: FontWeight.w600,
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
}
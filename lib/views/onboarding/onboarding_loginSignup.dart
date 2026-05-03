import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/auth_gate.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';

enum AuthMode {
  login,
  signup,
}

class OnboardingLoginSignup extends StatelessWidget {
  const OnboardingLoginSignup({super.key});

  static const Color _titleColor = Color(0xFF25180F);
  static const Color _smalltext = Color(0xFF775242);
  static const Color _dotInactive = Color(0xFFD8C0A4);
  static const Color _dotActive = Color(0xFF6A3A1E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.sizeOf(context).height -
                    MediaQuery.paddingOf(context).vertical,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const _CollageGrid(),
                  const SizedBox(height: 14),
                  const Text(
                    'How Would You Like \nTo Continue?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: _titleColor,
                      height: 1.25,
                    ),
                  ),
                  
                  const SizedBox(height: 35),
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFF775242), Color(0xE5C09671)],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            offset: Offset(0, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                        label: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        side: const BorderSide(color: Color(0xFF775242), width: 1.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        foregroundColor: const Color(0xFF775242),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () async {
                      await Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).enterGuestMode();

                      if (!context.mounted) {
                        return;
                      }

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthGate()),
                      );
                    },
                    child: const Text(
                      'Continue as Guest',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF775242),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Dot(color: _dotInactive),
                      SizedBox(width: 8),
                      _Dot(color: _dotInactive),
                      SizedBox(width: 8),
                      _Dot(color: _dotActive),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CollageGrid extends StatelessWidget {
  const _CollageGrid();

 @override
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final w = constraints.maxWidth;

      // 🔥 important: make height proportional but stable
      final h = w * 1.15;

      // add outer padding awareness (this fixes left compression feeling)
      final safeW = w;

      double col(int c) => safeW * (c / 3);
      double row(int r) => h * (r / 7);

      return Center(
        child: SizedBox(
          width: safeW,
          height: h,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: col(0),
                top: row(1),
                width: col(1) - 8,
                height: row(3) - 8,
                child: _img('assets/pic8.png'),
              ),

              Positioned(
                left: col(1),
                top: row(0),
                width: col(1) - 8,
                height: row(3) - 8,
                child: _img('assets/pic10.png'),
              ),

              Positioned(
                left: col(2),
                top: row(1),
                width: col(1) - 8,
                height: row(2) - 8,
                child: _img('assets/pic12.png'),
              ),

              Positioned(
                left: col(1),
                top: row(3),
                width: col(1) - 8,
                height: row(3) - 8,
                child: _img('assets/pic11.png'),
              ),

              Positioned(
                left: col(0),
                top: row(4),
                width: col(1) - 8,
                height: row(3) - 8,
                child: _img('assets/pic9.png'),
              ),

              Positioned(
                left: col(2),
                top: row(5),
                width: col(1) - 8,
                height: row(2) - 8,
                child: _img('assets/pic14.png'),
              ),

              Positioned(
                left: col(2),
                top: row(3),
                width: col(1) - 8,
                height: row(2) - 8,
                child: _img('assets/pic13.png'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
}

// Widget _img(String path) {
//   return ClipRRect(
//     borderRadius: BorderRadius.circular(16),
//     child: Image.asset(
//       path,
//       fit: BoxFit.cover,
//     ),
//   );
// }
Widget _img(String path) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04), // 👈 4% opacity
          offset: const Offset(0, 1), // 👈 Y = 1
          blurRadius: 3,
          spreadRadius: 0,
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        path,
        fit: BoxFit.cover,
      ),
    ),
  );
}
class _ImageTile extends StatelessWidget {
  const _ImageTile({
    required this.asset,
    required this.width,
    required this.height,
  });

  final String asset;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
        asset,
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
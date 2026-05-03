import 'package:flutter/material.dart';

import 'onboarding_next_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

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
                  const SizedBox(height: 24),
                  const Text(
                    'Explore The World\nFind Yourself',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: _titleColor,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Discover places only locals know \n and explore beyond the usual',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _smalltext,
                      height: 1.48,
                    ),
                  ),
                  const SizedBox(height: 63),
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
                              builder: (_) => const OnboardingNextScreen(),
                            ),
                          );
                        },
                    
                        label: const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 24,
                            // fontWeight: FontWeight.w600,
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
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Dot(color: _dotActive),
                      SizedBox(width: 8),
                      _Dot(color: _dotInactive),
                      SizedBox(width: 8),
                      _Dot(color: _dotInactive),
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
                child: _img('assets/pic1.png'),
              ),

              Positioned(
                left: col(1),
                top: row(0),
                width: col(1) - 8,
                height: row(3) - 8,
                child: _img('assets/pic2.png'),
              ),

              Positioned(
                left: col(2),
                top: row(1),
                width: col(1) - 8,
                height: row(2) - 8,
                child: _img('assets/pic3.png'),
              ),

              Positioned(
                left: col(1),
                top: row(3),
                width: col(1) - 8,
                height: row(3) - 8,
                child: _img('assets/pic5.png'),
              ),

              Positioned(
                left: col(0),
                top: row(4),
                width: col(1) - 8,
                height: row(3) - 8,
                child: _img('assets/pic4.png'),
              ),

              Positioned(
                left: col(2),
                top: row(5),
                width: col(1) - 8,
                height: row(2) - 8,
                child: _img('assets/pic7.png'),
              ),

              Positioned(
                left: col(2),
                top: row(3),
                width: col(1) - 8,
                height: row(2) - 8,
                child: _img('assets/pic6.png'),
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
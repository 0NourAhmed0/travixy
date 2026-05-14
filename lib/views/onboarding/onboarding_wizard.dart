import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';
import '../auth/auth_gate.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';

class OnboardingWizard extends StatefulWidget {
  const OnboardingWizard({super.key, this.postSignup = false, this.editPreferences = false});

  final bool postSignup;
  final bool editPreferences;

  @override
  State<OnboardingWizard> createState() => _OnboardingWizardState();
}

class _OnboardingWizardState extends State<OnboardingWizard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _loadedPreferences = false;

  static const _pages = [
    _OnboardingPageData(
      title: 'Tell Us About You',
      description: 'Select your interests, budget range and travel style to get personalized recommendations.',
      buttonLabel: 'Continue',
      actionType: _WizardAction.savePrefs,
      imageAssets: ['assets/pic8.png', 'assets/pic10.png', 'assets/pic12.png', 'assets/pic9.png', 'assets/pic11.png', 'assets/pic13.png', 'assets/pic14.png'],
      activeDotIndex: 0,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.editPreferences && !_loadedPreferences) {
      _loadedPreferences = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final formState = context.findAncestorStateOfType<_PrefsFormState>();
        formState?._loadCurrentPreferences();
      });
    }
  }

  void _handlePrimaryAction() {
    final current = _pages[_currentPage];
    switch (current.actionType) {
      case _WizardAction.next:
        _goNext();
        break;
      case _WizardAction.authChoice:
        if (widget.postSignup) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthGate()),
            (route) => false,
          );
        } else {
          _showAuthSheet();
        }
        break;
      case _WizardAction.savePrefs:
        _goNext();
        break;
    }
  }

  void _showAuthSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F0E8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFB08968).withOpacity(0.35),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose how to continue',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF25180F),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB08968),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(
                        color: Color.fromRGBO(119, 82, 66, 0.32),
                        width: 1.2,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(205, 189, 175, 0.1),
                    foregroundColor: const Color(0xFF775242),
                    side: const BorderSide(
                      color: Color.fromRGBO(119, 82, 66, 0.32),
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const AuthGate()),
                  );
                },
                child: const Text('Continue as Guest'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final imageHeight = screenHeight * 0.35;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/pic15.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 20,
            child: TextButton(
              onPressed: () {
                _pageController.animateToPage(
                  _pages.length - 1,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                );
              },
              child: const Text(
                'Skip',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 253, 253, 253),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            top: imageHeight - 55,
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/background.png',
                    fit: BoxFit.cover,
                  ),
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                          child: _OnboardingPage(
                            data: _pages[index],
                            isFinalPage: index == _pages.length - 1,
                            postSignup: widget.postSignup,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


enum _WizardAction { next, authChoice, savePrefs }

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.actionType,
    required this.imageAssets,
    required this.activeDotIndex,
    this.subtitle,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final _WizardAction actionType;
  final List<String> imageAssets;
  final int activeDotIndex;
  final String? subtitle;
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data, required this.isFinalPage, required this.postSignup});

  final _OnboardingPageData data;
  final bool isFinalPage;
  final bool postSignup;

  static const Color _titleColor = Color(0xFF25180F);
  static const Color _smalltext = Color(0xFF775242);


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.sizeOf(context).height - MediaQuery.paddingOf(context).vertical,
          ),
          child: Column(
            children: [
              if (data.actionType == _WizardAction.savePrefs) ...[
                PrefsForm(postSignup: postSignup, editPreferences: !postSignup),
              ] else ...[
                _ActionButton(label: data.buttonLabel, isFinalPage: isFinalPage, onPressed: () {
                  final state = context.findAncestorStateOfType<_OnboardingWizardState>();
                  state?._handlePrimaryAction();
                }, postSignup: postSignup),
              ],
              
            ],
          ),
        ),
      ),
    );
  }

  Color _currentDotColor(int index, int active) {
    return index == active ? const Color(0xFF6A3A1E) : const Color(0xFFD8C0A4);
  }


}

class _CollageGrid extends StatelessWidget {
  const _CollageGrid({required this.imageAssets});

  final List<String> imageAssets;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = w * 1.15;

        double col(int c) => w * (c / 3);
        double row(int r) => h * (r / 7);

        return Center(
          child: SizedBox(
            width: w,
            height: h,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(left: col(0), top: row(1), width: col(1) - 8, height: row(3) - 8, child: _img(imageAssets[0])),
                Positioned(left: col(1), top: row(0), width: col(1) - 8, height: row(3) - 8, child: _img(imageAssets[1])),
                Positioned(left: col(2), top: row(1), width: col(1) - 8, height: row(2) - 8, child: _img(imageAssets[2])),
                Positioned(left: col(1), top: row(3), width: col(1) - 8, height: row(3) - 8, child: _img(imageAssets[4])),
                Positioned(left: col(0), top: row(4), width: col(1) - 8, height: row(3) - 8, child: _img(imageAssets[3])),
                Positioned(left: col(2), top: row(5), width: col(1) - 8, height: row(2) - 8, child: _img(imageAssets[6])),
                Positioned(left: col(2), top: row(3), width: col(1) - 8, height: row(2) - 8, child: _img(imageAssets[5])),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _img(String path) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          offset: const Offset(0, 1),
          blurRadius: 3,
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(path, fit: BoxFit.cover),
    ),
  );
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onPressed, required this.isFinalPage, required this.postSignup});

  final String label;
  final VoidCallback onPressed;
  final bool isFinalPage;
  final bool postSignup;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
        child: ElevatedButton(
          onPressed: onPressed,
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
          child: Text(
            postSignup && isFinalPage ? 'Continue' : label,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}








class PrefsForm extends StatefulWidget {
  const PrefsForm({required this.postSignup, this.editPreferences = false});

  final bool postSignup;
  final bool editPreferences;

  @override
  State<PrefsForm> createState() => _PrefsFormState();
}

class _PrefsFormState extends State<PrefsForm> {
  final List<String> _interestOptions = ['Beaches', 'Nature', 'Culture', 'Food', 'Nightlife', 'Adventure'];
  final List<String> _travelStyles = ['Relaxed', 'Adventurous', 'Cultural',  'Luxury'];

  final Set<String> _selectedInterests = {}; 
  String _budget = 'Medium';
  String _travelStyle = 'Relaxed';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.editPreferences) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadCurrentPreferences();
      });
    }
  }

  Future<void> _loadCurrentPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    try {
      final prefs = await AuthService().loadUserPreferences(uid: user.uid);
      if (!mounted) {
        return;
      }

      setState(() {
        _selectedInterests
          ..clear()
          ..addAll(List<String>.from(prefs['interests'] ?? const []));
        _budget = (prefs['budget'] as String?) ?? 'Medium';
        _travelStyle = (prefs['travelStyle'] as String?) ?? 'Relaxed';
      });
    } catch (_) {
      // Keep defaults if the preferences document is missing or unreadable.
    }
  }

  Future<void> _savePreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not authenticated')));
      return;
    }

    setState(() => _saving = true);
    try {
      final prefs = {
        'interests': _selectedInterests.toList(),
        'budget': _budget,
        'travelStyle': _travelStyle,
      };

      await AuthService().saveUserPreferences(uid: user.uid, preferences: prefs);

      if (widget.editPreferences) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else if (widget.postSignup) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthGate()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save preferences: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Interests', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF25180F))),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _interestOptions.map((opt) {
            final selected = _selectedInterests.contains(opt);
            return ChoiceChip(
              label: Text(opt),
              selected: selected,
              backgroundColor: const Color(0xffC3AE93),

              selectedColor: const Color.fromRGBO(37, 24, 15, 0.8),
              showCheckmark: false,
              labelStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              side: const BorderSide(color: Color.fromRGBO(37, 24, 15, 0.8), width: 1),
              onSelected: (v) => setState(() => v ? _selectedInterests.add(opt) : _selectedInterests.remove(opt)),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Budget', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF25180F))),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['Low', 'Medium', 'High'].map((b) {
            final selected = _budget == b;
            return GestureDetector(
              onTap: () => setState(() => _budget = b),
              child: Container(
                width: 78,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? const Color.fromRGBO(37, 24, 15, 0.8) : const Color(0xffC3AE93),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color.fromRGBO(37, 24, 15, 0.8),
                    width: 1,
                  ),
                ),
                child: Text(
                  b,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : const Color.fromRGBO(37, 24, 15, 0.8),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Travel Style', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF25180F))),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          children: _travelStyles.map((s) {
            final sel = _travelStyle == s;
            return ChoiceChip(
              label: Text(s),
              selected: sel,
              backgroundColor: const Color(0xffC3AE93),
              selectedColor: const Color.fromRGBO(37, 24, 15, 0.8),
              showCheckmark: false,
              labelStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              side: const BorderSide(color: Color.fromRGBO(37, 24, 15, 0.8), width: 1),
              onSelected: (_) => setState(() => _travelStyle = s),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
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
            child: ElevatedButton(
              onPressed: _saving ? null : _savePreferences,
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
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(widget.editPreferences ? 'Update Preferences' : 'Save & Continue', style: const TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ],
    );
  }
}
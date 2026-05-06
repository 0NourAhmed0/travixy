import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'auth_gate.dart';

enum AuthMode {
  login,
  signup,
}

class LoginScreen extends StatefulWidget {
  final AuthMode initialMode;

  const LoginScreen({super.key, this.initialMode = AuthMode.login});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late AuthMode _authMode;
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _authMode = widget.initialMode;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.login ? AuthMode.signup : AuthMode.login;
    });
  }

  Future<void> _submitAuthForm() async {
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    
    // Validation
    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackbar('Please fill all fields');
      return;
    }

    if (_authMode == AuthMode.signup) {
      if (firstName.isEmpty || lastName.isEmpty) {
        _showErrorSnackbar('Please complete your profile fields');
        return;
      }
    }
    
    if (_authMode == AuthMode.signup && password != _confirmPasswordController.text.trim()) {
      _showErrorSnackbar('Passwords do not match');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    String result;
    if (_authMode == AuthMode.signup) {
      result = await authProvider.signup(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
    } else {
      result = await authProvider.signin(email: email, password: password);
    }
    
    if (!mounted) return;
    
    setState(() {
      _isLoading = false;
    });
    
    if (result == 'success') {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (route) => false,
      );
      return;
    } else {
      String errorMessage;
      if (result.contains('email-already-in-use') || result.contains('EMAIL_EXISTS')) {
        errorMessage = 'Email already exists';
      } else if (result.contains('user-not-found') || result.contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Email not found';
      } else if (result.contains('wrong-password') || result.contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password';
      } else if (result.contains('weak-password') || result.contains('WEAK_PASSWORD')) {
        errorMessage = 'Password too weak (min 6 characters)';
      } else if (result.contains('firebase-not-initialized')) {
        errorMessage = 'Firebase is not configured yet';
      } else {
        errorMessage = 'Authentication failed';
      }
      _showErrorSnackbar(errorMessage);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.signInWithGoogle();

    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });

    if (result != 'success') {
      if (result.contains('google-sign-in-cancelled')) {
        _showErrorSnackbar('Google sign-in was cancelled');
      } else {
        _showErrorSnackbar('Google sign-in failed');
      }
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (route) => false,
    );
  }

  Future<void> _openForgotPassword() async {
    await Navigator.of(context).pushNamed('/forgot-password');
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _enterGuestMode() async {
    await Provider.of<AuthProvider>(context, listen: false).enterGuestMode();
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
            top: 20,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          Positioned(
            top: imageHeight * 0.36,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _authMode == AuthMode.signup
                      ? 'Create your account'
                      : 'Welcome back',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _authMode == AuthMode.signup
                      ? 'Sign up to access your account\nand exclusive features'
                      : 'Sign in to continue your journey',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
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
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 34),
                      child: Column(
                        children: [
                          _buildAuthToggle(),
                          const SizedBox(height: 8),
                          if (_authMode == AuthMode.signup) ...[
                            Row(
                              children: const [
                                Expanded(
                                  child: Text(
                                    ' First Name',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Color.fromRGBO(37, 24, 15, 0.8),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ' Last Name',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: Color.fromRGBO(37, 24, 15, 0.8),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _firstNameController,
                                    keyboardType: TextInputType.name,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _lastNameController,
                                    keyboardType: TextInputType.name,
                                  ),
                                ),
                              ],
                            ),

                          ],
                          _buildFieldLabel('Email'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 12),
                          _buildFieldLabel('Password'),
                          const SizedBox(height: 8),
                          _buildPasswordField(
                            controller: _passwordController,
                            showPassword: _showPassword,
                            onToggle: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                          if (_authMode == AuthMode.signup) ...[
                            const SizedBox(height: 12),
                            _buildFieldLabel('Confirm Password'),
                            const SizedBox(height: 8),
                            _buildPasswordField(
                              controller: _confirmPasswordController,
                              showPassword: _showConfirmPassword,
                              onToggle: () {
                                setState(() {
                                  _showConfirmPassword = !_showConfirmPassword;
                                });
                              },
                            ),
                          ],
                          if (_authMode == AuthMode.login) ...[
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _openForgotPassword,
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(color: Color(0xFF8B6F47)),
                                ),
                              ),
                            ),
                          ]
                          else
                            const SizedBox(height: 20),
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: CircularProgressIndicator(
                                color: Color(0xFF8B6F47),
                              ),
                            )
                          else ...[
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _submitAuthForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB08968),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: const BorderSide(
                                      color: Color(0xFF8B6F47),
                                      width: 1.5,
                                    ),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  _authMode == AuthMode.login
                                      ? 'Login'
                                      : 'Register',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: OutlinedButton.icon(
                                onPressed: _signInWithGoogle,
                                icon: const Icon(Icons.g_mobiledata, size: 30),
                                label: const Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF5F0E8),
                                  foregroundColor: const Color(0xFF8B6F47),
                                  side: const BorderSide(
                                    color: Color(0xFF8B6F47),
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _enterGuestMode,
                              child: const Text(
                                'Continue as Guest',
                                style: TextStyle(color: Color(0xFF8B6F47)),
                              ),
                            ),
                          ],
                        ],
                      ),
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

  Widget _buildAuthToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(205, 189, 175, 0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color.fromRGBO(119, 82, 66, 0.32),
          width: 1.2,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_authMode != AuthMode.login) {
                  _toggleAuthMode();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _authMode == AuthMode.login
                      ? const Color.fromRGBO(205, 189, 175, 1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _authMode == AuthMode.login
                    ? _buildGradientTabText('Sign In')
                    : const Text(
                        'Sign In',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(37, 24, 15, 1),
                          fontFamily: 'Poppins',
                        ),
                      ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_authMode != AuthMode.signup) {
                  _toggleAuthMode();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _authMode == AuthMode.signup
                      ? const Color.fromARGB(255, 197, 178, 163)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _authMode == AuthMode.signup
                    ? _buildGradientTabText('Sign Up')
                    : const Text(
                        'Sign Up',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(37, 24, 15, 1),
                          fontFamily: 'Poppins',
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientTabText(String label) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color.fromRGBO(119, 82, 66, 1),
            Color.fromRGBO(209, 145, 118, 1),
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color.fromRGBO(37, 24, 15, 0.8),
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool showPassword,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(205, 189, 175, 0.4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color.fromRGBO(119, 82, 66, 0.32),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: !showPassword,
              decoration: const InputDecoration(
                hintText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                showPassword ? Icons.visibility : Icons.visibility_off,
                color: const Color(0xFF8B6F47),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(205, 189, 175, 0.4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color.fromRGBO(119, 82, 66, 0.32),
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: const InputDecoration(
          hintText: '',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
        ),
      ),
    );
  }
}
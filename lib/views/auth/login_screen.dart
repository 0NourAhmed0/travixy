import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late AuthMode _authMode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authMode = widget.initialMode;
  }

  @override
  void dispose() {
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
    
    // Validation
    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackbar('Please fill all fields');
      return;
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
      result = await authProvider.signup(email: email, password: password);
    } else {
      result = await authProvider.signin(email: email, password: password);
    }
    
    if (!mounted) return;
    
    setState(() {
      _isLoading = false;
    });
    
    if (result == 'success') {
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.signInWithGoogle();

    if (!mounted) {
      return;
    }

    if (result != 'success') {
      _showErrorSnackbar('Google sign-in failed');
    }
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade800, Colors.purple.shade700],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.explore, size: 60, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text(
                      'LikeALocal',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Travel like a local',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    if (_authMode == AuthMode.signup) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                    ],
                    if (_authMode == AuthMode.login) ...[
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _openForgotPassword,
                          child: const Text('Forgot password?'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitAuthForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            _authMode == AuthMode.login ? 'Login' : 'Sign Up',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _signInWithGoogle,
                          icon: const Icon(Icons.login),
                          label: const Text('Continue with Google'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _toggleAuthMode,
                        child: Text(
                          _authMode == AuthMode.login
                              ? 'Create new account'
                              : 'Login instead',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _enterGuestMode,
                        child: const Text('Continue as Guest'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpgradePage extends StatefulWidget {
  const UpgradePage({super.key});

  @override
  State<UpgradePage> createState() => _UpgradePageState();
}

class _UpgradePageState extends State<UpgradePage> {
  static const _kIsPremium = 'is_premium';
  bool _isPremium = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPremium();
  }

  Future<void> _loadPremium() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPremium = prefs.getBool(_kIsPremium) ?? false;
      _loading = false;
    });
  }

  Future<void> _purchase() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsPremium, true);
    setState(() {
      _isPremium = true;
      _loading = false;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upgrade successful — premium unlocked')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        backgroundColor: const Color(0xFFF5F0E8),
        foregroundColor: const Color(0xFF25180F),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Premium', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('Get unlimited pins, remove ads, and priority support.'),
                  const SizedBox(height: 24),
                  Card(
                    child: ListTile(
                      title: Text(_isPremium ? 'You are a premium user' : 'Not premium yet'),
                      subtitle: _isPremium ? const Text('Thank you!') : const Text('Tap purchase to upgrade'),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isPremium ? null : _purchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF775242),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(_isPremium ? 'Premium Active' : 'Purchase Premium'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

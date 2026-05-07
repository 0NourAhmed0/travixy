import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travixy/providers/post_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/places_provider.dart';
import 'providers/recommendations_provider.dart';
import 'views/auth/auth_gate.dart';
import 'views/home/home_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/auth/forgot_password_screen.dart';
import 'views/place/place_detail_screen.dart';
import 'views/shared/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase config is not wired yet in this workspace.
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, PlacesProvider>(
          create: (_) => PlacesProvider(),
          update: (_, authProvider, placesProvider) {
            if (authProvider.isAuthenticated && !authProvider.isGuestMode) {
              placesProvider?.updateTokenAndUser(
                authProvider.token,
                authProvider.userId,
              );
            } else {
              placesProvider?.clearAuthContext();
            }
            return placesProvider ?? PlacesProvider();
          },
        ),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => RecommendationsProvider()),
      ],
      child: MaterialApp(
        title: 'LikeALocal',
        theme: ThemeData(
          fontFamily: 'Poppins',
          primarySwatch: Colors.blue,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.transparent,
        ),
builder: (context, child) {
  return Stack(
    fit: StackFit.expand,
    children: [
      Image.asset(
        'assets/background.png',
        fit: BoxFit.cover,
      ),
      if (child != null) child,
    ],
  );
},
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/signup': (context) => const SignupScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/place-detail': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as String;
            return PlaceDetailScreen(placeId: args);
          },
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
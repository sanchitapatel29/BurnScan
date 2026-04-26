import 'package:burn_scan/providers/auth_provider.dart';
import 'package:burn_scan/providers/editing_provider.dart';
import 'package:burn_scan/providers/image_workflow_provider.dart';
import 'package:burn_scan/providers/patient_provider.dart';
import 'package:burn_scan/screens/home_screen.dart';
import 'package:burn_scan/screens/login_screen.dart';
import 'package:burn_scan/screens/splash_screen.dart';
import 'package:burn_scan/services/auth_service.dart';
import 'package:burn_scan/services/database_service.dart';
import 'package:burn_scan/services/image_service.dart';
import 'package:burn_scan/services/ml_service.dart';
import 'package:burn_scan/services/report_service.dart';
import 'package:burn_scan/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BurnScanApp());
}

class BurnScanApp extends StatelessWidget {
  const BurnScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => DatabaseService.instance),
        Provider(
          create: (context) => AuthService(context.read<DatabaseService>()),
        ),
        Provider(create: (_) => ImageService()),
        Provider(create: (_) => const MLService()),
        Provider(create: (_) => ReportService()),
        ChangeNotifierProvider(
          create: (context) =>
              AuthProvider(context.read<AuthService>())..initialize(),
        ),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(
          create: (context) => ImageWorkflowProvider(
            ImagePicker(),
            context.read<ImageService>(),
            context.read<MLService>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => EditingProvider()),
      ],
      child: MaterialApp(
        title: 'BurnScan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        home: const SplashScreen(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isReady) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return authProvider.isLoggedIn
            ? const HomeScreen()
            : const LoginScreen();
      },
    );
  }
}

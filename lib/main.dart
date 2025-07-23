import 'package:chat_gpt_clone/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'consts/app_colors.dart';
import 'package:provider/provider.dart';
import 'providers/chat_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider()..loadConversations(),
      child: MaterialApp(
        title: 'ChatGPT Clone',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.scaffoldBackground,
          colorScheme: ColorScheme.dark(
            primary: AppColors.primary,
            secondary: AppColors.surface,
            surface: AppColors.surface,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.scaffoldBackground,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: AppColors.white),
            bodyMedium: TextStyle(color: AppColors.white70),
          ),
          iconTheme: const IconThemeData(color: AppColors.primary),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ),
        home: const ChatScreen(),
      ),
    );
  }
}


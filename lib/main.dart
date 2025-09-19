import 'dart:async';
import 'dart:developer' as developer;
import 'package:chiken_odyssey/features/splash_screen/view/splash_screen.dart';
import 'package:chiken_odyssey/features/menu_screen/view/menu_screen.dart';
import 'package:chiken_odyssey/theme/theme.dart';
import 'package:chiken_odyssey/game_screen/bloc/game_bloc.dart';
import 'package:chiken_odyssey/features/settings_screen/bloc/settings_bloc.dart';
import 'package:chiken_odyssey/features/settings_screen/bloc/settings_event.dart';
import 'package:chiken_odyssey/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
 
void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e) {
        developer.log('Firebase initialization failed: $e');
        // Продолжаем работу без Firebase
      }
      
      runApp(const MyApp());
    },
    (error, stackTrace) {
      developer.log('Ошибка в приложении: $error');
      developer.log('Stack trace: $stackTrace');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<GameBloc>(create: (context) => GameBloc()),
        BlocProvider<SettingsBloc>(
          create: (context) => SettingsBloc(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        home: const SplashScreen(),
        routes: {
          '/menu': (context) => const MenuScreen(),
        },
        builder: (context, widget) {
          // Дополнительная обработка ошибок на уровне всего приложения
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return Material(
              child: Container(
                color: Colors.red,
                child: Center(
                  child: Text(
                    'Произошла ошибка!\n${errorDetails.exception}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          };
          return widget ?? const SizedBox();
        },
      ),
    );
  }
}

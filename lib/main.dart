// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';

// import 'firebase_options.dart';
// import 'splash.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Firebase connection
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'SparkClean',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A35C4)),
//       ),
//       home: const SplashScreen(),
//     );
//   }
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app_data.dart';
import 'firebase_options.dart';
import 'Splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase connection
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Saved bookings aur notifications load karo (refresh par ghayab na hon)
  await BookingStore.load();
  await NotificationStore.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SparkClean',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A35C4)),
      ),
      home: const SplashScreen(),
    );
  }
}

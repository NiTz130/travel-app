import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import 'blocs/place/placeList_bloc.dart';
import 'blocs/trip/trip_bloc.dart';
import 'blocs/user/user_bloc.dart';
import 'network_controller.dart';
import 'repositories/firebase_emulator.dart';
import 'repositories/firebase_options.dart';
import 'ui/Welcomepage.dart';
import 'ui/emailVerificationPage.dart';
import 'ui/navigationPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env', isOptional: true);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureFirebaseEmulators();
  Get.put<NetworkController>(NetworkController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<placeListBloc>(create: (_) => placeListBloc()),
        BlocProvider<userBloc>(create: (_) => userBloc()),
        BlocProvider<tripBloc>(create: (_) => tripBloc()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthHandler(),
        routes: {
          '/login': (context) => const WelcomePage(),
          '/home': (context) =>
              NavigationPage(isBackButtonClick: false, autoSelectedIndex: 0),
          '/emailVerification': (context) => const emailVerificationPage(),
        },
      ),
    );
  }
}

class AuthHandler extends StatelessWidget {
  const AuthHandler({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show splash/loading screen
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          if (user.emailVerified) {
            return NavigationPage(
              isBackButtonClick: false,
              autoSelectedIndex: 0,
            );
          } else {
            return emailVerificationPage();
          }
        } else {
          return WelcomePage();
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_event.dart';
import '../blocs/user/user_state.dart';
import '../models/user.dart';
import 'Welcomepage.dart';
import 'customPageRoutes.dart';
import 'navigationPage.dart';

class LoginPage extends StatefulWidget {
  final User userData;
  const LoginPage({required this.userData, super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final passwordController = TextEditingController();
  bool showError = false;
  String errorDetails = '';

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userData = widget.userData;

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).push(customPageRoutes(child: const WelcomePage()));
        return false;
      },
      child: MultiBlocListener(
        listeners: [
          BlocListener<userBloc, userState>(
            listener: (context, state) async {
              if (state is singInState) {
                if (state.userState[0]['isSignIn'] == true) {
                  showError = false;
                  Navigator.of(context).pushReplacement(customPageRoutes(
                    child: NavigationPage(isBackButtonClick: false, autoSelectedIndex: 0),
                  ));
                } else {
                  setState(() {
                    errorDetails = state.userState[0]['AuthException'];
                    showError = true;
                  });
                }
              }
            },
          ),
        ],
        child: Scaffold(
          body: SafeArea(
            child: userData != null
                ? SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Container(
                height: 700.0,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/app bac.jpg'),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back),
                              color: Colors.white,
                              iconSize: 40,
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                    customPageRoutes(child: const WelcomePage()));
                              },
                            ),
                          ),
                        ],
                      ),
                      // Title
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 50.0, top: 100.0),
                            child: Text(
                              "Đăng nhập",
                              style: GoogleFonts.lato(
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      // Login form
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 35.0),
                            height: 300,
                            width: 300,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/Rectangle 1 loging.png'),
                              ),
                            ),
                            child: Column(
                              children: [
                                // User avatar + info
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 25, top: 10),
                                        child: SizedBox(
                                          width: 45,
                                          height: 45,
                                          child: CircleAvatar(
                                            radius: 40,
                                            backgroundImage: userData.proPicUrl.isNotEmpty
                                                ? NetworkImage(userData.proPicUrl)
                                                : const NetworkImage("https://cdn-icons-png.flaticon.com/64/3177/3177440.png"),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10, top: 25),
                                          child: SizedBox(
                                            width: 100,
                                            child: Text(
                                              userData.name,
                                              style: GoogleFonts.poppins(
                                                textStyle: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 6),
                                          child: Text(
                                            userData.email,
                                            style: GoogleFonts.poppins(
                                              textStyle: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Password field
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 25, top: 24),
                                      child: SizedBox(
                                        width: 250,
                                        height: showError ? 60 : 40,
                                        child: TextField(
                                          onTap: () {
                                            setState(() {
                                              showError = false;
                                            });
                                          },
                                          obscureText: true,
                                          controller: passwordController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            hintText: 'Mật khẩu',
                                            errorText: showError ? errorDetails : null,
                                            border: const OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Login button
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 25, top: 24),
                                      child: SizedBox(
                                        width: 250,
                                        height: 40,
                                        child: TextButton(
                                          onPressed: () {
                                            BlocProvider.of<userBloc>(context)
                                                .add(signInEvent(userData.email, passwordController.text));
                                          },
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color>(
                                                const Color.fromARGB(255, 10, 124, 132)),
                                            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                          ),
                                          child: Text(
                                            'Đăng nhập',
                                            style: GoogleFonts.roboto(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Forgot password
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 35.0, left: 25),
                                      child: Text(
                                        "Quên mật khẩu?",
                                        style: GoogleFonts.roboto(
                                          color: const Color.fromARGB(255, 27, 199, 211),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}

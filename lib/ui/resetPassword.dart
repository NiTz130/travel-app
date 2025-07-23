import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'customPageRoutes.dart';

import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_event.dart';
import '../blocs/user/user_state.dart';
import 'Welcomepage.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final emailController = TextEditingController();
  bool showError = false;
  String errorDetails = '';
  late userBloc userbloc;
  StreamSubscription? mSub;

  @override
  void dispose() {
    emailController.dispose();
    mSub?.cancel();
    super.dispose();
  }

  void listenBloc() {
    userbloc = BlocProvider.of<userBloc>(context);
    mSub = userbloc.stream.listen((state) {
      if (state is resetPasswordState) {
        if (state.resetState[0]['isSend'] == true) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const WelcomePage()),
          );
          mSub?.cancel();
        } else {
          setState(() {
            showError = true;
            errorDetails = state.resetState[0]['AuthException'] ?? "Có lỗi xảy ra, thử lại!";
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    listenBloc();
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          customPageRoutes(child: const WelcomePage()),
        );
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
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
                    // Nút quay lại
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
                                customPageRoutes(child: const WelcomePage()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    // Tiêu đề
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 50.0, top: 100.0),
                          child: Text(
                            "Khôi phục mật khẩu",
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    // Form
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
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 60.0, left: 60),
                                    child: Text(
                                      "Nhập email của bạn\ndể lấy lại mật khẩu",
                                      style: GoogleFonts.roboto(
                                        color: Colors.white,
                                      ),
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              // Ô nhập email
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
                                        controller: emailController,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white,
                                          hintText: 'Email',
                                          errorText: showError ? (errorDetails.isEmpty ? "Vui lòng nhập email hợp lệ" : errorDetails) : null,
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
                              // Nút gửi
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 25, top: 24),
                                    child: SizedBox(
                                      width: 250,
                                      height: 40,
                                      child: TextButton(
                                        onPressed: () async {
                                          if (emailController.text.isNotEmpty) {
                                            BlocProvider.of<userBloc>(context).add(
                                              resetPassword(email: emailController.text),
                                            );
                                          } else {
                                            setState(() {
                                              showError = true;
                                              errorDetails = "Email không được để trống";
                                            });
                                          }
                                        },
                                        style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 10, 124, 132)),
                                          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                        ),
                                        child: Text(
                                          'Gửi',
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
                            ],
                          ),
                        )
                      ],
                    )
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

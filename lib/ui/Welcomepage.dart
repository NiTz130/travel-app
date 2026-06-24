import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'resetPassword.dart';
import 'signup.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_event.dart';
import '../blocs/user/user_state.dart';
import 'customPageRoutes.dart';
import 'login.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final emailController = TextEditingController();
  bool isEmailEmpty = false;
  bool showError = false;
  late userBloc userbloc;
  late StreamSubscription mSub;

  @override
  void initState() {
    super.initState();
    userbloc = BlocProvider.of<userBloc>(context);
    mSub = userbloc.stream.listen((state) {
      if (state is resetPasswordState &&
          state.resetState[0]['isSend'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã gửi email đặt lại mật khẩu!")),
        );
      } else if (state is checkEmailAlreadyExistState) {
        if (state.userState[0]['isFound'] == true) {
          showError = false;
          Navigator.of(context).pushReplacement(
            customPageRoutes(
              child: LoginPage(userData: state.userState[0]['userDetails']),
            ),
          );
        } else {
          setState(() {
            showError = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    mSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool confirmExit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thoát ứng dụng'),
            content: const Text('Bạn có chắc muốn thoát không?'),
            actions: [
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('Có'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Không'),
              ),
            ],
          ),
        );
        return confirmExit;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
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
                  child: Container(
                    margin: showError
                        ? const EdgeInsets.only(top: 75.0)
                        : const EdgeInsets.only(top: 110.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hiển thị lỗi
                        Visibility(
                          visible: showError,
                          child: Row(
                            children: [
                              Container(
                                width: 250,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(17),
                                ),
                                margin: const EdgeInsets.only(
                                  left: 50.0,
                                  bottom: 12,
                                ),
                                child: Center(
                                  child: Text(
                                    "Email không hợp lệ hoặc không tồn tại!",
                                    style: GoogleFonts.lato(
                                      textStyle: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Tiêu đề
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 100.0),
                              child: Text(
                                "Chào mừng đến với",
                                style: GoogleFonts.lato(
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Tên app
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 30.0),
                              child: Container(
                                margin: const EdgeInsets.only(left: 99.0),
                                child: Text(
                                  "Sri Travel",
                                  style: GoogleFonts.pacifico(
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Form email đăng nhập nhanh
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 35.0),
                              width: 300,
                              height: 400,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                    'assets/images/Rectangle 1.png',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    // Ô email
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 12.0,
                                            top: 12.0,
                                          ),
                                          child: SizedBox(
                                            width: 250,
                                            height: isEmailEmpty ? 60 : 40,
                                            child: TextField(
                                              onTap: () {
                                                setState(() {
                                                  showError = false;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                hintText: 'Email',
                                                errorText: isEmailEmpty
                                                    ? "Không được bỏ trống"
                                                    : null,
                                                border:
                                                    const OutlineInputBorder(
                                                      borderSide:
                                                          BorderSide.none,
                                                    ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 12.0,
                                                    ),
                                              ),
                                              controller: emailController,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Nút Tiếp tục
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 12.0,
                                            top: 12.0,
                                          ),
                                          child: SizedBox(
                                            width: 250,
                                            height: 40,
                                            child: TextButton(
                                              onPressed: () async {
                                                if (emailController
                                                    .text
                                                    .isNotEmpty) {
                                                  BlocProvider.of<userBloc>(
                                                    context,
                                                  ).add(
                                                    readUserEmailEvent(
                                                      emailController.text,
                                                    ),
                                                  );
                                                } else {
                                                  setState(() {
                                                    isEmailEmpty = true;
                                                  });
                                                }
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                      Color
                                                    >(
                                                      const Color.fromARGB(
                                                        255,
                                                        10,
                                                        124,
                                                        132,
                                                      ),
                                                    ),
                                                foregroundColor:
                                                    MaterialStateProperty.all<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                              child: Text(
                                                'Tiếp tục',
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
                                    // Dòng phân cách
                                    Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                            left: 123.0,
                                            top: 15.0,
                                          ),
                                          child: Text(
                                            "Hoặc",
                                            style: GoogleFonts.roboto(
                                              textStyle: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Nút Facebook
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 12.0,
                                            top: 12.0,
                                          ),
                                          child: SizedBox(
                                            width: 250,
                                            height: 40,
                                            child: TextButton(
                                              onPressed: () {},
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                      Color
                                                    >(
                                                      const Color.fromARGB(
                                                        255,
                                                        231,
                                                        231,
                                                        231,
                                                      ),
                                                    ),
                                                foregroundColor:
                                                    MaterialStateProperty.all<
                                                      Color
                                                    >(Colors.black),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 17.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            right: 8.0,
                                                          ),
                                                      child: Image.asset(
                                                        "assets/images/facebook-logo.png",
                                                        width: 24,
                                                        height: 24,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Tiếp tục với Facebook",
                                                      style: GoogleFonts.roboto(
                                                        textStyle:
                                                            const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Nút Google
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 12.0,
                                            top: 12.0,
                                          ),
                                          child: SizedBox(
                                            width: 250,
                                            height: 40,
                                            child: TextButton(
                                              onPressed: () {
                                                if (kDebugMode) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Google Sign-In đang tắt trong chế độ dev emulator.',
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }
                                                BlocProvider.of<userBloc>(
                                                  context,
                                                ).add(signInWithGoogle());
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                      Color
                                                    >(
                                                      const Color.fromARGB(
                                                        255,
                                                        231,
                                                        231,
                                                        231,
                                                      ),
                                                    ),
                                                foregroundColor:
                                                    MaterialStateProperty.all<
                                                      Color
                                                    >(Colors.black),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 17.0,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            right: 8.0,
                                                          ),
                                                      child: Image.asset(
                                                        "assets/images/google-logo.png",
                                                        width: 24,
                                                        height: 24,
                                                      ),
                                                    ),
                                                    Text(
                                                      "Tiếp tục với Google",
                                                      style: GoogleFonts.roboto(
                                                        textStyle:
                                                            const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Đăng ký tài khoản mới
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Chưa có tài khoản?",
                                            style: GoogleFonts.roboto(
                                              color: Colors.white,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(
                                                context,
                                              ).pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SignupPage(),
                                                ),
                                              );
                                            },
                                            style: ButtonStyle(
                                              padding:
                                                  MaterialStateProperty.all<
                                                    EdgeInsets
                                                  >(EdgeInsets.zero),
                                            ),
                                            child: Text(
                                              "Đăng ký",
                                              style: GoogleFonts.roboto(
                                                color: const Color.fromARGB(
                                                  255,
                                                  27,
                                                  199,
                                                  211,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Quên mật khẩu
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 12.0,
                                          ),
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ResetPasswordPage(),
                                                ),
                                              );
                                            },
                                            style: ButtonStyle(
                                              padding:
                                                  MaterialStateProperty.all<
                                                    EdgeInsets
                                                  >(EdgeInsets.zero),
                                            ),
                                            child: Text(
                                              "Quên mật khẩu?",
                                              style: GoogleFonts.roboto(
                                                color: const Color.fromARGB(
                                                  255,
                                                  27,
                                                  199,
                                                  211,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

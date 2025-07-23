import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../blocs/user/user_event.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_state.dart';
import 'Welcomepage.dart';
import 'customPageRoutes.dart';
import 'emailVerificationPage.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isEmailEmpty = false;
  bool isNameEmpty = false;
  bool isPasswordEmpty = false;
  bool showError = false;
  String errorDetails = '';

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void goToWelcomePage(BuildContext context) {
    Navigator.of(context).pushReplacement(
      customPageRoutes(child: const WelcomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () async {
          goToWelcomePage(context);
          return false;
        },
        child: MultiBlocListener(
          listeners: [
            BlocListener<userBloc, userState>(
              listener: (context, state) async {
                if (state is singUpState) {
                  if (state.SignUpData == 'successful') {
                    showError = false;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const emailVerificationPage(),
                      ),
                    );
                  } else {
                    setState(() {
                      showError = true;
                      errorDetails = state.SignUpData;
                    });
                  }
                }
              },
            ),
          ],
          child: Scaffold(
            body: SafeArea(
              child: Container(
                height: 700,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/app bac.jpg'),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
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
                                onPressed: () => goToWelcomePage(context),
                              ),
                            ),
                          ],
                        ),
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
                                margin: const EdgeInsets.only(left: 50.0, bottom: 1),
                                child: Center(
                                  child: Text(
                                    errorDetails,
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
                        // Tiêu đề đăng ký
                        Row(
                          children: [
                            Container(
                              margin: showError
                                  ? const EdgeInsets.only(
                                  left: 50.0, top: 50.0, bottom: 20.0)
                                  : const EdgeInsets.only(
                                  left: 50.0, top: 80.0, bottom: 20.0),
                              child: Text(
                                "Đăng ký",
                                style: GoogleFonts.lato(
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Form đăng ký
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 40.0),
                              height: 390,
                              width: 290,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/Rectangle 1.png'),
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Phần hướng dẫn
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 25.0, left: 20.0),
                                        child: Text(
                                          "Tạo tài khoản mới",
                                          style: GoogleFonts.roboto(
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  // Ô email
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20.0, top: 15),
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
                                                borderSide: BorderSide.none,
                                              ),
                                              contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                  vertical: 12.0),
                                            ),
                                            controller: emailController,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Ô tên
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20.0, top: 15),
                                        child: SizedBox(
                                          width: 250,
                                          height: isNameEmpty ? 60 : 40,
                                          child: TextField(
                                            controller: nameController,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              hintText: 'Tên',
                                              errorText: isNameEmpty
                                                  ? "Không được bỏ trống"
                                                  : null,
                                              border:
                                              const OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                              ),
                                              contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                  vertical: 12.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Ô mật khẩu
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20.0, top: 15),
                                        child: SizedBox(
                                          width: 250,
                                          height: isPasswordEmpty ? 60 : 40,
                                          child: TextField(
                                            controller: passwordController,
                                            obscureText: true,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              hintText: 'Mật khẩu',
                                              errorText: isPasswordEmpty
                                                  ? "Không được bỏ trống"
                                                  : null,
                                              border:
                                              const OutlineInputBorder(
                                                borderSide: BorderSide.none,
                                              ),
                                              contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                  vertical: 12.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Điều khoản
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20.0, top: 15),
                                        child: Text(
                                          "Bằng việc nhấn Đồng ý và tiếp tục bên dưới,",
                                          style: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(left: 20.0),
                                        child: Text(
                                          "Tôi đồng ý với",
                                          style: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        " Điều khoản & Chính sách bảo mật",
                                        style: GoogleFonts.roboto(
                                          color:
                                          Color.fromARGB(255, 27, 199, 211),
                                          fontSize: 12.5,
                                        ),
                                      )
                                    ],
                                  ),
                                  // Nút đăng ký
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15.0, top: 15.0),
                                        child: SizedBox(
                                          width: 250,
                                          height: 40,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              setState(() {
                                                isEmailEmpty =
                                                    emailController.text.isEmpty;
                                                isNameEmpty =
                                                    nameController.text.isEmpty;
                                                isPasswordEmpty =
                                                    passwordController
                                                        .text.isEmpty;
                                              });

                                              if (emailController
                                                  .text.isNotEmpty &&
                                                  nameController
                                                      .text.isNotEmpty &&
                                                  passwordController
                                                      .text.isNotEmpty) {
                                                BlocProvider.of<userBloc>(
                                                    context)
                                                    .add(signUpEvent(
                                                    email:
                                                    emailController.text,
                                                    name: nameController.text,
                                                    password:
                                                    passwordController
                                                        .text,
                                                    proPicUrl: ''));
                                              }
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  const Color.fromARGB(
                                                      255, 10, 124, 132)),
                                              foregroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.white),
                                            ),
                                            child: Text(
                                              'Đăng ký',
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
                            ),
                          ],
                        )
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

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../blocs/user/user_bloc.dart';
import '../../blocs/user/user_event.dart';
import '../Welcomepage.dart';
import 'editProfile.dart';

class myAccount extends StatefulWidget {
  const myAccount({super.key});

  @override
  State<myAccount> createState() => _myAccountState();
}

class _myAccountState extends State<myAccount> {
  late auth.User user;

  void initState() {
    super.initState();
  }

  Future<void> logOut() async {
    BlocProvider.of<userBloc>(context).add(signOutEvent());
    userBlo.authState.listen((user) {
      if (user == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => WelcomePage()),
              (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 40, left: 13),
            child: Row(
              children: [
                Text(
                  "Tài khoản",
                  style: GoogleFonts.nunito(
                    textStyle: const TextStyle(
                      color: Color.fromARGB(255, 27, 27, 27),
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Thông tin tài khoản
          FutureBuilder(
            future: userBlo.getUserDetails(),
            builder: (context, AsyncSnapshot<auth.User?> snapshot) {
              if (snapshot.hasData) {
                user = snapshot.data!;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfile(user: user),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, left: 13, right: 13),
                    child: Row(
                      children: [
                        Container(
                          width: 55,
                          height: 55,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundImage: snapshot.data?.photoURL != null
                                ? NetworkImage("${snapshot.data?.photoURL}")
                                : const NetworkImage(
                                "https://cdn-icons-png.flaticon.com/64/3177/3177440.png"),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${snapshot.data?.displayName}",
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${snapshot.data?.email}",
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    color: Color.fromARGB(255, 60, 60, 60),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
          // Cài đặt / Preferences
          Padding(
            padding: const EdgeInsets.only(left: 13, top: 34),
            child: Row(
              children: [
                Text(
                  "Cài đặt",
                  style: GoogleFonts.nunito(
                    textStyle: const TextStyle(
                      color: Color.fromARGB(255, 27, 27, 27),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // (Ở đây có thể thêm cài đặt cá nhân nếu ông muốn, ví dụ: đổi mật khẩu, dark mode...)
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: SizedBox(
              width: 220,
              height: 50,
              child: TextButton(
                onPressed: () {
                  logOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(width: 2.0, color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Text(
                  'Đăng xuất',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

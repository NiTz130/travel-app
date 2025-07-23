import 'package:firebase_auth/firebase_auth.dart';
import '../user/userAuth_repo.dart';

class userProfileRepo {
  Future<String> createUser(String email, String userName, String password, String proPic) async {
    List signUpState = await userAuthRep.signUp(email, userName, password, proPic);
    print(signUpState);
    User? user = signUpState[0]['user'];

    if (user != null && user.email != null) {
      await user.updateDisplayName(userName);
      await user.updatePhotoURL(proPic);
    } else {
      print('user null');
    }

    return signUpState[0]['authException'];
  }
}

final userProfileRep = userProfileRepo();

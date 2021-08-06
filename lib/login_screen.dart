import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'dashboard_screen.dart';

const users = const {
  'admin': 'admin'
};

class LoginScreen extends StatelessWidget {
  Duration get loginTime => Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data) {
    print('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(data.name)) {
        return 'Tài khoản không tồn tại';
      }
      if (users[data.name] != data.password) {
        return 'Sai mật khẩu';
      }
      return null;
    });
  }

  Future<String?> _recoverPassword(String name) {
    print('Name: $name');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return 'Tài khoản không tồn tại';
      }
        return 'Sai mật khẩu';
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'KMA',
      onLogin: _authUser,
      onSignup: _authUser,
      userType: LoginUserType.name,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => DashboardScreen(),
        ));
      },
      userValidator: (value){},
      onRecoverPassword: _recoverPassword,
      hideForgotPasswordButton: true,
      hideSignUpButton: true,
    );
  }
}

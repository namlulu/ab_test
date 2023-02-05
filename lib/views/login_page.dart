import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import 'home_page.dart';

/// 로그인 페이지
class LoginPage extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final FirebaseRemoteConfig remoteConfig;

  const LoginPage({
    required this.analytics,
    required this.remoteConfig,
    Key? key,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("로그인"),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// 현재 유저 로그인 상태
                const Center(
                  child: Text(
                    "로그인해 주세요 🙂",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                /// 이메일
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(hintText: "이메일"),
                ),

                /// 비밀번호
                TextField(
                  controller: passwordController,
                  obscureText: false, // 비밀번호 안보이게
                  decoration: const InputDecoration(hintText: "비밀번호"),
                ),
                const SizedBox(height: 32),

                /// 로그인 버튼
                ElevatedButton(
                  child: const Text(
                    "로그인",
                    style: TextStyle(fontSize: 21),
                  ),
                  onPressed: () async {
                    await widget.analytics.logEvent(
                      name: "login",
                      parameters: {
                        "email": emailController.text,
                      },
                    );

                    await widget.remoteConfig.fetchAndActivate();
                    String direction =
                        widget.remoteConfig.getString('TEST_TEXT');

                    if (kDebugMode) {
                      print(widget.remoteConfig.getAll());
                      print(direction);
                    }

                    // 로그인
                    authService.signIn(
                      email: emailController.text,
                      password: passwordController.text,
                      onSuccess: () {
                        // 로그인 성공
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("로그인 성공"),
                          ),
                        );
                      },
                      onError: (err) {
                        // 에러 발생
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(err),
                          ),
                        );
                      },
                    );

                    // 로그인 성공시 HomePage로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomePage(
                            analytics: widget.analytics,
                            remoteConfig: widget.remoteConfig,
                            direction: direction),
                      ),
                    );
                  },
                ),

                /// 회원가입 버튼
                ElevatedButton(
                  child: const Text(
                    "회원가입",
                    style: TextStyle(fontSize: 21),
                  ),
                  onPressed: () {
                    // 회원가입
                    authService.signUp(
                      email: emailController.text,
                      password: passwordController.text,
                      onSuccess: () {
                        // 회원가입 성공
                        if (kDebugMode) {
                          print("회원가입 성공");
                        }
                      },
                      onError: (err) {
                        // 에러 발생
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(err),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

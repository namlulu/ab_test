import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // main 함수에서 async 사용하기 위함
  await Firebase.initializeApp(); // firebase 앱 시작
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    setRemoteSetting();
    super.initState();
  }

  void setRemoteSetting() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(analytics: analytics),
    );
  }
}

/// 로그인 페이지
class LoginPage extends StatefulWidget {
  final FirebaseAnalytics analytics;

  const LoginPage({required this.analytics, Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("로그인")),
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

                // 로그인 성공시 HomePage로 이동
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => HomePage(analytics: widget.analytics)),
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
                if (kDebugMode) {
                  print("sign up");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 홈페이지
class HomePage extends StatefulWidget {
  final FirebaseAnalytics analytics;

  const HomePage({
    required this.analytics,
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController jobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("버킷 리스트"),
        actions: [
          TextButton(
            child: const Text(
              "로그아웃",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              if (kDebugMode) {
                print("sign out");
              }
              // 로그인 페이지로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginPage(analytics: widget.analytics),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          /// 입력창
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                /// 텍스트 입력창
                Expanded(
                  child: TextField(
                    controller: jobController,
                    decoration: const InputDecoration(
                      hintText: "하고 싶은 일을 입력해주세요.",
                    ),
                  ),
                ),

                /// 추가 버튼
                ElevatedButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    // create bucket
                    if (jobController.text.isNotEmpty) {
                      if (kDebugMode) {
                        print("create bucket");
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          /// 버킷 리스트
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                String job = "$index";
                bool isDone = false;
                return ListTile(
                  title: Text(
                    job,
                    style: TextStyle(
                      fontSize: 24,
                      color: isDone ? Colors.grey : Colors.black,
                      decoration: isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  // 삭제 아이콘 버튼
                  trailing: IconButton(
                    icon: const Icon(CupertinoIcons.delete),
                    onPressed: () {
                      // 삭제 버튼 클릭시
                    },
                  ),
                  onTap: () {
                    // 아이템 클릭하여 isDone 업데이트
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

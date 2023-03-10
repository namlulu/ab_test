import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../model/bucket_model.dart';
import 'login_page.dart';

/// 홈페이지
class HomePage extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final FirebaseRemoteConfig remoteConfig;
  final String direction;

  const HomePage({
    required this.analytics,
    required this.remoteConfig,
    required this.direction,
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController jobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser()!;

    return Consumer<BucketModel>(
      builder: (context, bucketModel, child) {
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
                  context.read<AuthService>().signOut();

                  // 로그인 페이지로 이동
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(
                        analytics: widget.analytics,
                        remoteConfig: widget.remoteConfig,
                      ),
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
                        textAlign: widget.direction == 'LEFT'
                            ? TextAlign.left
                            : TextAlign.right,
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
                          bucketModel.create(jobController.text, user.uid);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              /// 버킷 리스트
              Expanded(
                child: FutureBuilder<QuerySnapshot>(
                  future: bucketModel.read(user.uid),
                  builder: (context, snapshot) {
                    final documents = snapshot.data?.docs ?? []; // 문서들 가져오기


                    if (documents.isEmpty) {
                      return Center(child: Text("버킷 리스트를 작성해주세요."));
                    }

                    return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final doc = documents[index];
                        String job = doc.get('job');
                        bool isDone = doc.get('isDone');

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
                              bucketModel.delete(doc.id);
                            },
                          ),
                          onTap: () {
                            // 아이템 클릭하여 isDone 업데이트
                            bucketModel.update(doc.id, !isDone);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

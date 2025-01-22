import 'package:flutter/material.dart';
import 'package:lastdance_f/model/student_model.dart';
import 'package:lastdance_f/screen/my_page_update.dart';

class MyPage extends StatefulWidget {
  final int studentId;
  const MyPage({super.key, required this.studentId});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  Map<String, dynamic> _student = {};
  final StudentModel _studentModel = StudentModel();



  @override
  void initState() {
    super.initState();
    _loadStudent(); // 데이터 로드
  }

  void _loadStudent() async {
    try {
      Map<String, dynamic> studentData =
          await _studentModel.searchDetailStudent(widget.studentId);
      setState(() {
        _student = studentData; // 데이터 저장
      });
    } catch (e) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 상태 확인
    if (_student.isEmpty) {

      return Scaffold(
        appBar: AppBar(
          title: Text("학생 정보 로딩 중..."),
          backgroundColor: Color(0xFFFFEFB0),
        ),
        backgroundColor: Color(0xFFFFEFB0),
        body: Center(
          child: CircularProgressIndicator(), // 로딩 인디케이터 표시
        ),
      );
    }

    return Scaffold(
    backgroundColor: Color(0xFFFFEFB0),
      appBar: AppBar(
        title: Row(children: [Icon(
          Icons.person,
          color: Colors.deepOrange,
          size: 30,// 아이콘 색상 설정
        ) ,Text("${_student['studentName']} 학생 인적 사항" , style: TextStyle(fontSize: 18)),],),
        backgroundColor: Color(0xffF4F4F4),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 15),
                      if( _student['studentImg'] != null )
              Image.network(
                      "http://112.221.66.174:6892${_student['studentImg']}",
                         width: 150,
                         height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                           return Container(
                        width: 100,
                         height: 100,
                           color: Colors.grey[300],
                          child: Icon(Icons.image, color: Colors.grey[700]),
                         );
                            },
                           ),
                      Text("프로필 사진" ,style: const TextStyle(fontSize: 20, fontWeight:FontWeight.bold )),
                      SizedBox(height: 18),

                      // 학생 이름
                      Row(
                        children: [
                          Container(
                            width: 87,
                            child: Text("이 름", style: TextStyle(fontSize: 15, fontWeight:FontWeight.bold),
                                textAlign: TextAlign.center),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 14.0),
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey)),
                              ),
                              child: Text("${_student['studentName']}",
                                  style: TextStyle(fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      // 생년월일
                      Row(
                        children: [
                          Container(
                            width: 87,
                         child: Text("생년월일 ", style: TextStyle(fontSize: 15, fontWeight:FontWeight.bold),
                           textAlign: TextAlign.center),
                           ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 14.0),
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey)),
                              ),
                              child: Text(
                                  "${_student['studentBirth'] ?? '미입력'}",
                                  style: TextStyle(fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      // 학교, 학년 등
                      Row(
                        children: [
                          Container(
                            width: 87,
                            child: Text("학교", style: TextStyle(fontSize: 15, fontWeight:FontWeight.bold),
                                textAlign: TextAlign.center),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 14.0),
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey)),
                              ),
                              child: Text(
                                  "${_student['schoolName']}/${_student['grade']}학년/${_student['classNo']}반 / ${_student['studentNo']}번",
                                  style: TextStyle(fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      // 성별
                      Row(
                        children: [
                          Container(
                            width: 87,
                            child: Text("성별", style: TextStyle(fontSize: 15, fontWeight:FontWeight.bold),
                                textAlign: TextAlign.center),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 14.0),
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey)),
                              ),
                              child: Text(
                                  "${_student['studentGender'] ?? '미입력'} ",
                                  style: TextStyle(fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      // 연락처
                      Row(
                        children: [
                          Container(
                            width: 87,
                            child: Text("핸드폰", style: TextStyle(fontSize: 15, fontWeight:FontWeight.bold),
                                textAlign: TextAlign.center),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 14.0),
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey)),
                              ),
                              child: Text(
                                  "${_student['studentPhone'] ?? '미입력'}",
                                  style: TextStyle(fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      // 보호자
                      Row(
                        children: [
                          Container(
                            width: 87,
                            child: Text("보호자", style: TextStyle(fontSize: 15, fontWeight:FontWeight.bold),
                                textAlign: TextAlign.center),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 14.0),
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey)),
                              ),
                              child: Text("${_student['parentsName'] ?? '미입력'}",
                                  style: TextStyle(fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),

                      Row(
                        children: [
                          Container(
                            width: 87,
                            child: Text("보호자 번호",
                                style: TextStyle(fontSize: 15, fontWeight:FontWeight.bold),
                                textAlign: TextAlign.center),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 14.0),
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey)),
                              ),
                              child: Text(
                                  "${_student['parentsPhone'] ?? '미입력'}",
                                  style: TextStyle(fontSize: 15)),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 15),
                      Row(
                        children: [
                          Container(
                            width: 87,
                            child: Text("주소", style: TextStyle(fontSize: 15, fontWeight:FontWeight.bold),
                                textAlign: TextAlign.center),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 14.0),
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey)),
                              ),
                              child: Text(
                                  "${_student['studentAddress'] ?? '미입력'}",
                                  style: TextStyle(fontSize: 15)),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 15),

                      Row(
                        children: [
                          Container(
                            width: 87,
                            child: Text("특이사항", style: TextStyle(fontSize: 15, fontWeight:FontWeight.bold),
                                textAlign: TextAlign.center),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.only(left: 14.0),
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(color: Colors.grey)),
                              ),
                              child: Text("${_student['studentEtc'] ?? '미입력' }",
                                  style: TextStyle(fontSize: 15)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: () async {
                          // 페이지 이동 후 돌아온 후 자동으로 데이터를 새로 로드
                          final updatedData = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyPageUpdate(studentData: _student),
                            ),
                          );
                          if (updatedData != null) {
                            setState(() {
                              _student = updatedData;
                            });
                            _loadStudent();
                          } else {
                            _loadStudent();
                          }
                        },
                        icon: const Icon(Icons.update, color: Colors.white, ),
                        label: const Text("수정하기"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

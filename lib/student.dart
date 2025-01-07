class Student {
  final StudentInfo studentInfo;
  final int teacherId;
  final int classId;
  final int year;

  Student(
      {required this.studentInfo,
      required this.teacherId,
      required this.classId,
      required this.year});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
        studentInfo: StudentInfo.fromJson(json['studentInfo']),
        teacherId: json['teacherId'],
        classId: json['classId'],
        year: json['year']);
  }
}

class StudentInfo {
  final int studentNo;
  final String studentName;

  StudentInfo({required this.studentNo, required this.studentName});

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
        studentNo: json['studentNo'], studentName: json['studentName']);
  }
}

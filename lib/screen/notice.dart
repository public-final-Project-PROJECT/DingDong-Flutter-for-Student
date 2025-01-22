import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lastdance_f/model/notice_model.dart';
import 'package:lastdance_f/screen/notice_detail.dart';

class Notice extends StatefulWidget {
  final int classId;
  const Notice({super.key, required this.classId});

  @override
  State<Notice> createState() => _NoticeState();
}

class _NoticeState extends State<Notice> {
  List<dynamic> _noticeList = [];
  final NoticeModel _noticeModel = NoticeModel();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadNotice();
  }

  void _loadNotice({String? category}) async {
    List<dynamic> noticeData = await _noticeModel.searchNotice(category: category, classId: widget.classId);
    setState(() {
      _noticeList = noticeData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [Icon(
          Icons.article,
          color: Colors.deepOrange,
          size: 30,// 아이콘 색상 설정
        ), const Text("공지사항") ],) ,
        backgroundColor: Color(0xFFFFEFB0),

        shape: const Border(
          bottom: BorderSide(color: Colors.grey, width: 1),
        ),
      ),
      backgroundColor: Color(0xFFFFEFB0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedCategory,
                  hint: const Text("카테고리 선택"),
                  items: const [
                    DropdownMenuItem(value: null, child: Text("전체")),
                    DropdownMenuItem(value: "가정통신문", child: Text("가정통신문")),
                    DropdownMenuItem(value: "알림장", child: Text("알림장")),
                    DropdownMenuItem(value: "학교생활", child: Text("학교생활")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                    _loadNotice(category: value);
                  },
                  dropdownColor: const Color(0xffFFFFFF),
                ),
              ],
            ),
          ),
          Expanded(
            child: _noticeList.isEmpty
                ? const Center(
              child: Text(
                "공지사항이 존재하지 않습니다.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _noticeList.length,
              itemBuilder: (context, index) {
                var notice = _noticeList[index];
                String formattedCreateAt = _formatDate(notice['createdAt']);
                String formattedUpdatedAt = _formatDate(notice['updatedAt']);

                String displayDate = "";
                if (notice['updatedAt'] != null &&
                    notice['updatedAt'].isNotEmpty &&
                    notice['createdAt'] != notice['updatedAt']) {
                  formattedUpdatedAt = _formatDate(notice['updatedAt']);
                  displayDate = "수정일: $formattedUpdatedAt";
                } else {
                  formattedCreateAt = _formatDate(notice['createdAt']);
                  displayDate = "작성일: $formattedCreateAt";
                }

                return Card(
                  margin: const EdgeInsets.all(5.0),
                  color: Color(0xFFFFEB99),
                  elevation: 4.0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(9.0),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child:
                    Container(
                    margin: const EdgeInsets.only(left: 17),
                    child:
                          Text(
                            notice['noticeTitle'],
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold,color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                    )
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Container(
                      margin: const EdgeInsets.only(left: 17),
                      child:
                      Text(
                          "${notice['noticeCategory']}",
                          style: const TextStyle(fontSize: 12, color: Colors.deepOrange),
                        ),
                    ),
                        const SizedBox(height: 8),
                        Container(
                          margin: const EdgeInsets.only(left: 17),
                          child: Text(
                            "${notice['noticeContent']}",
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),


                  Container(
                    margin: const EdgeInsets.only(left: 17),
                    child:
                        Text(displayDate, style: const TextStyle(fontSize: 11)),
                    )
                      ,  const SizedBox(height: 8),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  NoticeDetailPage(noticeId: notice['noticeId'])));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formattedDate = DateFormat('yyyy.MM.dd').format(dateTime);
    return formattedDate;
  }
}
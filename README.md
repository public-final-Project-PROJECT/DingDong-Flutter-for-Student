<br/>

# DingDong- Flutter ( 학생 모바일 )
![dingdongLOGO](https://github.com/user-attachments/assets/748232a0-c3c7-4399-acf9-4e172bc744fa)

<br/>
<summary>목차</summary>

1. [ 소개](#intro)
2. [요구사항](#reqirements)
3. [레포지토리별 기능](#function)
4. [팀원 소개](#members)
5. [개발 기간](#createDate)
6. [화면 구성](#screen)
7. [기술 스택](#stack)
8. [개발환경](#environment)
<br/>

## 👨‍🏫 1. <span id="intro"> 프로젝트 소개  </span>

✔ 이 프로젝트는 초등교사와 학생이 소통할 수 있는 학급 관리 시스템입니다. 
  교사는 웹과 모바일 앱을 활용하고 학생은 앱을 통해 학급 활용에 참여 할 수 있습니다.
  <br/>
  
✔ 교사의 웹/앱 과 학생의 앱을 분리하여 하이브리드 방식으로 소통이 가능하도록 개발하였습니다. 
<br/>
<br/>

##  📌 2. <span id="reqirements">요구사항</span>

📁 공지사항 : 가정통신문 | 알림장 | 학교생활 카테고리로 구분
<br/><tap/> ㄴ 📁 공지사항 작성 / 수정 가능

📁 출석부 : 날짜 지정 및 각 학생의 출석 상태
<br/><tap/> ㄴ 📁 출석 여부 지정 : 특이사항 작성 후 '제출/수정' 클릭
<br/><tap/> ㄴ 📁 학생 이름 클릭 시 학생 인적사항 페이지로 이동

📁 캘린더 : 달력 API 호출하여 이벤트 생성

📁 편의기능
<br/><tap/> ㄴ 📁 타이머 : 감소 시간 지정 타이머
<br/><tap/> ㄴ 📁 자리 바꾸기 : 랜덤 / 자리 지정 선택형 좌석 배치
<br/><tap/> ㄴ 📁 발표자 뽑기 : 얼굴 인식 후 인식된 얼굴 중 발표자 랜덤 선정
<br/><tap/> ㄴ 📁 학급 투표 : 익명 / 공개투표
<br/><tap/> ㄴ 📁 전자 칠판 : 실제 학급의 칠판을 모티브 하여 구현

<br/>

## 📌 3.  <span id="function">레포지토리별 기능</span>

📁 공지사항 : 
<br/><tap/> ㄴ 📁 공지사항 작성 시 파일, 이미지 첨부 (첨부 파일명 보이게)
<br/><tap/> ㄴ 📁 공지사항 작성 시 등록 후 수정 가능

📁 출석부 : 출석 등록 및 특정 날짜의 출석 기록들을 불러오며 수정 가능
<br/><tap/> ㄴ 📁 출석부 학생 이름 클릭 시 학생 인적사항 페이지로 이동

📁 캘린더 : 캘린더 API 호출하여 이벤트 생성 및 삭제 가능

📁 편의기능
<br/><tap/> ㄴ 📁 타이머 : 감소 시간 지정 후 실행시 원형 타이머 작동 (타이머 작동 시 고정 타이머 모달 생성 (다른 페이지 이동 및 복귀 시 정상 작동))
<br/><tap/> ㄴ 📁 자리 바꾸기 : 랜덤 / 자리 지정 선택형 좌석 배치| 조정된 자리 저장 및 인쇄 가능
<br/><tap/> ㄴ 📁 발표자 뽑기 : 카메라로 얼굴 인식 후 인식된 얼굴 중 발표장 랜덤 선정
<br/><tap/> ㄴ 📁 학급 투표 : 익명 / 공개투표
<br/><tap/> ㄴ 📁 전자 칠판 : 실제 학급의 칠판을 모티브 하여 구현

<br/>

## 🧑‍🤝‍🧑 4. <span id="members">각 팀원 담당 기능</span>

<br/>

| **장근우** | **이승환** | **이진우** | **최서연** | **김수아** |
| :-------: | :-------: | :-------: | :-------: | :-------: |
| 로그인 <br/>QR코드 <br/>발표자 선정 <br/>전자칠판 <br/>학급 생성 및 삭제 | 캘린더 페이지 <br/>메인 페이지 | 학생 인적사항 <br/>출석부 <br/>공지사항 <br/>알림 기능 | 좌석 랜덤 돌리기 페이지 <br/>학급 투표 페이지 | 타이머 페이지 <br/>앱 / 웹 전반적인 <br/>디자인 담당 |

<br/>

##  ⏲️ 5. <span id="createDate">개발 기간</span>

#### 개발 기간
2024년 12월 04일 ~ 2025년 01월 23일

<br/>
<br/>

## 💻  6. <span id="screen"> 화면 구성 </span>
### < 학생 앱 페이지 > 

<br/>

| 홈 페이지 | 상세 페이지 |
|---------|---------|
|![image](https://github.com/user-attachments/assets/2e20b2ef-ecbe-43f6-b075-5bd8bae4effc)|![image](https://github.com/user-attachments/assets/65886634-a4c3-42b7-bfc7-3389a227f306)



<br/>

| 학생 정보 수정 페이지|  |
|---------|---------|
|![image](https://github.com/user-attachments/assets/e0a2c86b-2439-42a1-a534-8490a81f5d72)|![image](https://github.com/user-attachments/assets/6339e2da-1973-49c1-af35-21c2983c34c6)


<br/>

| 공지사항 페이지 |  |
|---------|---------|
|![image](https://github.com/user-attachments/assets/1956e1a4-019f-47a9-8aeb-e90b821c4c17)|![image](https://github.com/user-attachments/assets/a196fb9a-1040-43cc-b827-072786862fb7)


<br/>

| 알림 페이지 | |
|---------|---------|
|![image](https://github.com/user-attachments/assets/7a7cb758-d4da-402e-b57b-d893baabecbb)|![image](https://github.com/user-attachments/assets/dbf393fb-e882-4ff1-bc70-a9bcefcf9349)


<br/>

|좌석 페이지 | 투표 페이지 |
|---------|---------|
|![image](https://github.com/user-attachments/assets/422de55a-e997-4272-a6f0-802c2a5656b4)|![image](https://github.com/user-attachments/assets/e51d7870-03de-4016-95fe-9f27844c9365)

<br/>
<br/>

## ⚙️  7. <span id ="stack"> 기술 스택 </span>

<br/>

DataBase : Mysql, JPQL

아이디어 회의 :Notion

<br/>

📝 프로젝트 아키텍쳐

![프로젝트_아키텍쳐](https://github.com/user-attachments/assets/92303c61-b663-4af7-9d85-893fd50ad785)
##

<br/>

📝 ERD 다이어그램
![image](https://github.com/user-attachments/assets/8bcc6a8a-c48c-4bb4-a95d-85d849f10551)

<br/>


## 💻 8. <span id = "environment" > 개발환경 <span/>


Version : Java 17

IDE : IntelliJ

Framework : SpringBoot 3.3.5

ORM : JPA

<br/>
<br/>
<br/>

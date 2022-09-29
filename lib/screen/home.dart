import 'package:ahri_manager/screen/buy_object.dart';
import 'package:ahri_manager/screen/calendar_scr.dart';
import 'package:ahri_manager/screen/map_hospital.dart';
import 'package:ahri_manager/screen/my.dart';
import 'package:flutter/material.dart';
import 'package:ahri_manager/plus/user_helper.dart';
import 'package:ahri_manager/data/user_data.dart';


import 'calendar_scr.dart';

//메인화면(탭 선택 화면)
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<user_information> user_infotmations=[]; //유저정보 리스트
  final UserHelper helper=UserHelper();
  @override
  void initState(){
    helper.init().then((value){
     updateScreen();
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration( //배경이미지
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('asset/imgs/background3.jpg'),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightGreen,
          title:
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                        "놀러와 우리홈",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'jua',
                          fontSize: 30.0,
                        ),
                      ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0),
                    child: ElevatedButton(
                      child: Text(
                        "내정보",
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(primary: Colors.white),
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => My()));
                      },
                    ),
                  ),
                ],
              ),
        ),

        backgroundColor: Colors.transparent, //배경색 투명으로 설정
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,

          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column( //달력
                      //mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => Buy_object()));
                          },
                          icon: Image.asset('asset/imgs/schedule.png'),
                         
                          iconSize: 70,
                          //padding,
                        ),


                        Text(
                          "기록장",
                          style: TextStyle(
                            fontFamily: 'jua',
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column( //병원 찾기
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton( //병원 이미지
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => Map_hospital()));
                          },
                          icon: Image.asset('asset/imgs/hospital.png'),
                          iconSize: 70,
                        ),

                      Text(
                            '병원 찾기',
                            style: TextStyle(
                              fontFamily: 'jua',
                              fontSize: 20.0,
                            ),
                          ),
                    ],
                  ),
                ],
              ),


              //동물 이미지 넣기 (Column)


              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      IconButton( //물품 이미지
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Buy_object()));
                          },
                        icon: Image.asset('asset/imgs/pet-food.png'),
                        iconSize: 70,
                      ),

                      Text(
                        "물품구매",
                        style: TextStyle(
                          fontFamily: 'jua',
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            ],
          ),

        ),
      ),
    );
  }
  void updateScreen(){
    user_infotmations=helper.getuserinformation();
    setState(() {});
  }
}


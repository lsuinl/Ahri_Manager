import 'dart:async';
import 'package:ahri_manager/data/user_information.dart';
import 'package:ahri_manager/data/hospital_information.dart';
import 'package:ahri_manager/plus/user_helper.dart';
import 'package:ahri_manager/screen/hospital_list.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class naver extends StatefulWidget {
  const naver({Key? key}) : super(key: key);

  @override
  State<naver> createState() => _naverState();
}

class _naverState extends State<naver> {
  List<NMarker> _markers = [];
  NaverMapController? mapController;
  List<information> hospitalinf = [];
  List<user_information> user_informations = [];
  final UserHelper helper = UserHelper();
  NLatLng mylocation = NLatLng(0, 0);
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<NaverMapController> _controller = Completer();
  late NOverlayImage markerIcon;
  String animalspecies = "";

  @override
  final TextStyle textStyle=GoogleFonts.nanumGothic(
    fontSize: 20.0,
    color: Colors.black,
    fontWeight: FontWeight.w600,
  );

  void initState() {
    hospitalinf = hospitialinf; //병원리스트
    helper.init().then((value) {
      updateScreen();
    });
    getCurrentLocation(); //내위치 가져오기
    setCustomMapPin(); //커스텀마거적용\
    mapController!.addOverlayAll(_markers.toSet());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    createmarker(); //마커만들기
    return Scaffold(
        appBar: _appbar(
            textStyle: textStyle,
            hospitalinf: hospitalinf,
            mylocation: mylocation,
            mapController: mapController,
            animalspecies: animalspecies),
        body: _navermap(
            mylocation: mylocation,
            textStyle: textStyle,
            markers: _markers,
            onMapCreated: _onMapCreated,
        ),
    );
  }

  void _onMapCreated(NaverMapController controller) { //맵 생성
    if (_controller.isCompleted) _controller = Completer();
    _controller.complete(controller);
    mapController=controller; //하,,,니놈이구나
  }

  void getCurrentLocation() async { //현재위치 가져오기
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    setState(() {
      mylocation = NLatLng(position.latitude, position.longitude);
    });
  }

  void createmarker(){
    if (user_informations.isNotEmpty) {
      animalspecies = user_informations.first.species;
    }

    for (int i = 0; i < hospitalinf.length; i++) {
      if (hospitalinf[i].animal.contains(animalspecies)) {
        _markers.add(NMarker(
          id: (hospitalinf[i].name),
          position: NLatLng(
            hospitalinf[i].xy.latitude,
            hospitalinf[i].xy.longitude,
          ),
          icon: markerIcon,
        ));
        _markers.last.openInfoWindow(
          NInfoWindow.onMarker(id: hospitalinf[i].name, text: hospitalinf[i].name));
        _markers.last.setOnTapListener(
              (NMarker? marker) { //마커선택 시 탭 활성화
          showModalBottomSheet<void>(
            context: context,
            builder: (context) {
              return Container(
                height: MediaQuery.of(context).size.height/2,
                decoration: BoxDecoration(
                  // image: DecorationImage(
                  //   image: AssetImage('asset/imgs/pattern1.png',),
                  //   fit: BoxFit.cover,
                  // ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "${hospitalinf[i].name}",
                      style: textStyle,
                    ),
                    new TextButton(
                      onPressed: () =>
                          launchUrl(Uri.parse(
                              'tel:${hospitalinf[i].phone.replaceAll(
                                  "-", "")}')),
                      child: new Text(
                        "${hospitalinf[i].phone}",
                        style: textStyle.copyWith(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    Text(
                      "${hospitalinf[i].adress}",
                      textAlign: TextAlign.center,
                      style: textStyle,
                    ),
                  ],
                ),
                //),
              );
            }, // builder
          );
        },);

      }
    }

  }
  //커스텀 마커디자인
  void setCustomMapPin() async {
    markerIcon = await NOverlayImage.fromAssetImage(
      'asset/imgs/marker.png',
    );
  }

  void updateScreen() { //초기정보업데이트
    user_informations = helper.getuserinformation();
    setState(() {});
  }
}

class _appbar extends StatelessWidget implements PreferredSizeWidget {
  final TextStyle textStyle;
  final List<information> hospitalinf;
  final NLatLng mylocation;
  final NaverMapController? mapController;
  final String animalspecies;

  const _appbar({
    required this.textStyle,
    required this.hospitalinf,
    required this.mylocation,
    required this.mapController,
    required this.animalspecies,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar( //상단:앱바
      title: Text(
        '병원찾기',
        style: textStyle.copyWith(
          color: Colors.white,
          fontSize: 30.0,
          fontWeight: FontWeight.w600,
          shadows: [
            Shadow(
              blurRadius: 5.0,
              color: Colors.black,
              offset: Offset(1.0, 1.0),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.purple[100],
      centerTitle: true,
      actions: [ //인근병원찾기버튼
        TextButton(
          onPressed: () {
            NLatLng initlocation = NLatLng(0, 0);
            for (int i = 0; i < hospitalinf.length; i++) {
              if (hospitalinf[i].animal.contains(animalspecies)) {
                if (((mylocation.latitude - initlocation.latitude).abs() +
                    (mylocation.longitude - initlocation.longitude).abs()) >
                    ((mylocation.latitude - hospitalinf[i].xy.latitude).abs() +
                        (mylocation.longitude - hospitalinf[i].xy.longitude).abs())) {
                  initlocation = hospitalinf[i].xy;
                }
              }
            }
            NCameraUpdate cameraupdate = NCameraUpdate.scrollAndZoomTo(target: initlocation,zoom: 1.0);
            if (mapController != null) {
              mapController!.updateCamera(cameraupdate);
            }
          },
          child: Text(
            "인근병원찾기",
            style: textStyle.copyWith(
              fontSize: 15.0,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  // preferredSize를 명시적으로 정의합니다.
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}


  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(kToolbarHeight) ;


class _navermap extends StatelessWidget {
  final ValueChanged<NaverMapController> onMapCreated;
  final List<NMarker> markers;
  final NLatLng mylocation;
  final TextStyle textStyle;

  const _navermap({
    required this.mylocation,
    required this.textStyle,
    required this.markers,
    required this.onMapCreated,
    Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Position>(
        stream: Geolocator.getPositionStream(), //내 현재위치 가져오기
        builder: (context, snapshot) {
          return Column(
            children: [
              Expanded(
                flex: 3,
                child: NaverMap(
                  options: NaverMapViewOptions(
                    logoClickEnable: true,
                    locationButtonEnable: true,
                    mapType: NMapType.basic,


                  ),
                  //initLocationTrackingMode: LocationTrackingMode.Follow, //초기위치는 내위치
                  //onMapCreated:  onMapCreated, //콜백 조작
                  //:markers,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              HospitalListScreen(
                                mylocation: mylocation,
                              )
                      ));
                },
                child: Text(
                  "리스트로 보기",
                  style: textStyle.copyWith(
                    color: Colors.black,
                  ),
                ),
              )
            ],
          );
        });
  }
}


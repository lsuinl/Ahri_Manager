// Add 버튼을 누르면 하단에서 흰 공간이 올라오게 하는 클래스
// 여기서는 일정 등록 내용 쓸 때 사용됩니다!

import 'package:ahri_manager/calendar/component/custom_text_field.dart';
import 'package:ahri_manager/data/database/drift_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final int? scheduleId;

  const ScheduleBottomSheet(
      {required this.selectedDate, this.scheduleId, Key? key})
      : super(key: key);

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey(); //일종의 컨트롤러로 작용

  String? title;
  String? memo;
  int? selectedColorId; //데이터베이스와 관련된 데이터는 id를 써서 primary key를 사용하여 관리

  @override
  Widget build(BuildContext context) {
    final bottonInset = MediaQuery.of(context).viewInsets.bottom;
    //키보드에 가려져서 안 보일 부분만큼 흰 창을 올려줄 것이다.

    return SingleChildScrollView(
      child: GestureDetector(
          onTap: () {
            FocusScope.of(context)
                .requestFocus(FocusNode());
          },
          child: FutureBuilder<Schedule>(
            future: widget.scheduleId == null
                ? null
                : GetIt.I<LocalDatabase>().getScheduleById(widget.scheduleId!),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('스케줄을 불러올 수 없습니다.'),
                );
              }

              //로딩중일 때
              if (snapshot.connectionState != ConnectionState.none &&
                  !snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasData && title == null) {
                title = snapshot.data!.title;
                memo = snapshot.data!.memo;
                selectedColorId = snapshot.data!.colorId;
              }

              return SafeArea(
                child: Container(
                  height: MediaQuery.of(context).size.height / 1.8 +
                      bottonInset,
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottonInset),
                    child: Padding(
                      padding: EdgeInsets.only(left: 8, right: 8, top: 16),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 16.0),
                            _Title(
                              onSavedTitle: (String? val) {
                                title = val;
                              },
                              initialValue: title ?? '',
                            ), //일정 내용 입력
                            SizedBox(height: 16.0),
                            _Memo(
                              onSavedMemo: (String? val) {
                                memo = val;
                              },
                              initialValue: memo ?? '',
                            ), //추가적 메모 입력
                            SizedBox(height: 16.0),
                            FutureBuilder<List<CategoryColor>>(
                                future: GetIt.I<LocalDatabase>().getCategoryColors(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData && //데이터가 있고
                                      selectedColorId == null && //한번도 값이 세팅된 적이 없고
                                      snapshot.data!.isNotEmpty) {
                                    //최소한 하나의 값이 들어있다면
                                    selectedColorId = snapshot.data![0].id;
                                    //selectedColorId를 snapshot.data의 첫번째 id로 설정
                                  }
                                  return _ColorPicker(
                                    colors: snapshot.hasData ? snapshot.data! : [],
                                    selectedColorId: selectedColorId,
                                    colorIdSetter: (int id){
                                      setState(() {
                                        selectedColorId = id;
                                      });
                                    },
                                  );
                                }), //카테고릐 색깔
                            SizedBox(height: 8.0),
                            _SaveButton(
                              onPressed: onSavePressed,
                            ), //저장 버튼
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          )
      ),
    );
  }

  Future<void> onSavePressed() async {
    if (formKey.currentState == null) {
      return;
    }

    //모든 텍스트 폼 필드를 검사한 뒤 모두 에러가 없으면 TRUE가 나옴
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      if (widget.scheduleId == null) {
        await GetIt.I<LocalDatabase>().createSchedule(
          SchedulesCompanion(
            date: Value(widget.selectedDate),
            title: Value(title!),
            memo: Value(memo!),
            colorId: Value(selectedColorId!),
          ),
        );
      } else {
        await GetIt.I<LocalDatabase>().updateScheduleById(
          widget.scheduleId!,
          SchedulesCompanion(
            date: Value(widget.selectedDate),
            title: Value(title!),
            memo: Value(memo!),
            colorId: Value(selectedColorId!),
          ),
        );
      }

      Navigator.of(context).pop();
    } else {
      print('에러가 있습니다.');
    }
  }
}

class _Title extends StatelessWidget {
  final FormFieldSetter<String> onSavedTitle;
  final String initialValue;

  //일정 내용
  const _Title(
      {required this.onSavedTitle, required this.initialValue, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      //내용
      label: '제목',
      isMemo: false,
      onSaved: onSavedTitle,
      initialValue: initialValue,
    );
  }
}

class _Memo extends StatelessWidget {
  final FormFieldSetter<String> onSavedMemo;
  final String initialValue;

  //일정 추가 메모
  const _Memo({required this.onSavedMemo, required this.initialValue, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      //메모
      label: '메모',
      isMemo: true,
      onSaved: onSavedMemo,
      initialValue: initialValue,
    );
  }
}

typedef ColorIdSetter = void Function(int id);

class _ColorPicker extends StatelessWidget {
  final List<CategoryColor> colors;
  final int? selectedColorId;
  final ColorIdSetter colorIdSetter;

  //카테고리 색상 선택
  const _ColorPicker(
      {required this.colors,
        required this.selectedColorId,
        required this.colorIdSetter,
        Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0, //색상 버튼 사이를 띄어줌 (가로)
      runSpacing: 10.0, //(세로)
      children: colors
          .map(
            (e) => GestureDetector(
          onTap: () {
            colorIdSetter(e.id!);
          },
          child: renderColor(e, selectedColorId == e.id),
        ),
      )
          .toList(),
    );
  }

  Widget renderColor(CategoryColor color, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(
          int.parse(
            'FF${color.hexCode}',
            radix: 16,
          ),
        ),
        border: isSelected
            ? Border.all(
          color: Colors.black,
          width: 4.0,
        )
            : null,
      ),
      width: 32,
      height: 32,
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SaveButton({required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
            ),
            child: Text('저장'),
          ),
        ),
      ],
    );
  }
}
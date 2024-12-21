import 'package:flutter/material.dart';

class Basic extends StatelessWidget {
  final Color? backgroundColor;
  final Widget child;
  final String? title;
  final Widget? bottomNavigationBar;

  const Basic({
    required this.child,
    this.backgroundColor,
    this.title,
    this.bottomNavigationBar,
    super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: backgroundColor?? Colors.white,
      appBar: renderAppBar(),
      body: SafeArea(
          top: true,
          bottom: false,
          child: child
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  AppBar? renderAppBar(){
    if(title==null){
      return null;
    }else{
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(title!,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500
          ),
        ),
        foregroundColor: Colors.black,
      );
    }
  }

}

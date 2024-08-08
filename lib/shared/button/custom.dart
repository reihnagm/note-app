import 'package:mynote/shared/button/bounce.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function() onTap;
  final String? btnTxt;
  final String? pathIcon;
  final bool customText;
  final bool withIcon;
  final Text? text;
  final double width;
  final double height;
  final double fontSize;
  final double sizeBorderRadius;
  final Color loadingColor;
  final Color btnColor;
  final Color btnTextColor;
  final Color btnBorderColor;
  final bool isBorder;
  final bool isBorderRadius;
  final bool isLoading;
  final bool isBoxShadow;

  const CustomButton({
    super.key, 
    required this.onTap, 
    this.btnTxt, 
    this.pathIcon = "",
    this.text,
    this.width = double.infinity,
    this.height = 55.0,
    this.fontSize = 14.0,
    this.sizeBorderRadius = 10.0,
    this.isLoading = false,
    this.loadingColor = Colors.white,
    this.btnColor = Colors.blue,
    this.btnTextColor = Colors.white,
    this.btnBorderColor = Colors.transparent,
    this.withIcon = false,
    this.customText = false,
    this.isBorder = false,
    this.isBorderRadius = false,
    this.isBoxShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Bouncing(
      onPress: onTap,
      onLongPress: () {},
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: btnColor,
          border: Border.all(
            color: isBorder 
            ? btnBorderColor 
            : Colors.transparent,
          ),
          borderRadius: isBorderRadius 
          ? BorderRadius.circular(sizeBorderRadius)
          : null
        ),
        child: isLoading 
      ? Center(
          child: SpinKitFadingCircle(
            color: loadingColor,
            size: 20.0
          ),
        )
      : Center(
          child: customText 
          ? text 
          : Text(btnTxt!,
            style: TextStyle(
              color: btnTextColor,
              fontWeight: FontWeight.w600,
              fontSize: fontSize
            ) 
          ),
        )
      ),
    );
  }
}

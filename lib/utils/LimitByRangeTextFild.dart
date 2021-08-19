import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
class CustomRangeTextInputFormatter extends TextInputFormatter {
  final input;
  final quantity;
  CustomRangeTextInputFormatter({this.input, this.quantity
  });

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue,TextEditingValue newValue,) {
    if(newValue.text == '')
      return TextEditingValue();
    else if(int.parse(newValue.text) < 1)
      return TextEditingValue().copyWith(text: '1');

    return int.parse(newValue.text) > quantity ? Fluttertoast.showToast(
        msg: "the available quantity is $quantity",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1)  : newValue;
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String getFormattedDateTime(num dt, String pattern) {
  return DateFormat(pattern).format(DateTime.fromMillisecondsSinceEpoch(dt.toInt()*1000));
}

void showMsg(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
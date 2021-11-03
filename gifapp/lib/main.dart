import 'package:flutter/material.dart';

import 'package:gifapp/ui/home_page.dart';

void main() {
  runApp(MaterialApp(
		home: const Home(),
		theme: ThemeData(hintColor: Colors.white),
	));
}
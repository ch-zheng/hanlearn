import 'app.dart';
import 'model.dart';
import 'package:flutter/material.dart';

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
	final model = Model();
	await model.initialize();
	runApp(App(model));
}

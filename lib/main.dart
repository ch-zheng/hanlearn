import 'model.dart';
import 'widgets/app.dart';
import 'package:flutter/material.dart';

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
	final model = Model();
	await model.initialize();
	runApp(App(model));
}

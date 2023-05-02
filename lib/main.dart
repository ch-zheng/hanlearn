import 'app.dart';
import 'model.dart';
import 'package:flutter/material.dart';

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
	final model = await Model.build();
	runApp(App(model));
}

import 'app.dart';
import 'model.dart';
import 'settings.dart';
import 'package:flutter/material.dart';

void main() async {
	WidgetsFlutterBinding.ensureInitialized();
	final model = await Model.build();
	final settings = await Settings.build();
	runApp(App(model, settings));
}

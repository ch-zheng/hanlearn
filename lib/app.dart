import 'model.dart';
import 'options.dart';
import 'settings.dart';
import 'study.dart';
import 'vocab.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
	final Model model;
	final Settings settings;
	const App(this.model, this.settings, {super.key});
	@override
	State<App> createState() => _AppState();
}

class _AppState extends State<App>
	with SingleTickerProviderStateMixin {
	final _destinations = [
		const NavigationDestination(icon: Icon(Icons.book), label: 'Study'),
		const NavigationDestination(icon: Icon(Icons.list), label: 'Vocabulary'),
		const NavigationDestination(icon: Icon(Icons.settings), label: 'Settings')
	];
	int navigationIndex = 0;
	late TabController tabController;
	@override
	void initState() {
		super.initState();
		tabController = TabController(length: 3, vsync: this);
	}
	@override
	void dispose() {
		tabController.dispose();
		super.dispose();
	}
	@override
	Widget build(BuildContext context) => MultiProvider(
		providers: [
			ChangeNotifierProvider<Model>.value(value: widget.model),
			ChangeNotifierProvider<Settings>.value(value: widget.settings)
		],
		child: MaterialApp(
			title: 'Hanlearn',
			//theme: ThemeData.dark(useMaterial3: true),
			theme: ThemeData.from(
				colorScheme: ColorScheme.fromSeed(
					seedColor: Colors.red,
					background: const Color(0xFF101010),
					surface: const Color(0xFF202020),
					surfaceTint: Colors.transparent,
					brightness: Brightness.dark
				),
				useMaterial3: true
			),
			home: Scaffold(
				appBar: AppBar(title: Container(
					margin: const EdgeInsets.symmetric(horizontal: 8),
					child: Text(_destinations[navigationIndex].label)
				)),
				bottomNavigationBar: NavigationBar(
					selectedIndex: navigationIndex,
					destinations: _destinations,
					onDestinationSelected: (index) => setState(() {
						navigationIndex = index;
						tabController.animateTo(index);
					})
				),
				body: TabBarView(
					controller: tabController,
					physics: const NeverScrollableScrollPhysics(),
					children: [
						const StudyPage(),
						const VocabPage(),
						SettingsPage()
					]
				)
			),
			debugShowCheckedModeBanner: false
		)
	);
}

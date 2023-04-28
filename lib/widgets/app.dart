import '../model.dart';
import 'study.dart';
import 'vocab.dart';
import 'package:flutter/material.dart';

class App extends StatefulWidget {
	final Model model;
	const App(this.model, {super.key});
	@override
	State<App> createState() => _AppState();
}

class _AppState extends State<App>
	with SingleTickerProviderStateMixin {
	static const destinationNames = ['Study', 'Vocabulary'];
	int navigationIndex = 0;
	late TabController tabController;
	PersistentBottomSheetController? sheetController;
	@override
	void initState() {
		super.initState();
		tabController = TabController(length: 2, vsync: this);
	}
	@override
	void dispose() {
		tabController.dispose();
		super.dispose();
	}
	@override
	Widget build(BuildContext context) => MaterialApp(
		title: 'Hanlearn',
		theme: ThemeData.dark(useMaterial3: true),
		home: Scaffold(
			appBar: AppBar(title: Container(
				margin: const EdgeInsets.symmetric(horizontal: 8),
				child: Text(destinationNames[navigationIndex])
			)),
			bottomNavigationBar: NavigationBar(
				selectedIndex: navigationIndex,
				destinations: const [
					NavigationDestination(icon: Icon(Icons.book), label: 'Study'),
					NavigationDestination(icon: Icon(Icons.list), label: 'Vocabulary')
				],
				onDestinationSelected: (index) => setState(() {
					navigationIndex = index;
					tabController.animateTo(index);
					sheetController?.close();
				})
			),
			body: TabBarView(
				controller: tabController,
				physics: const NeverScrollableScrollPhysics(),
				children: [
					StudyPage(widget.model),
					VocabPage(widget.model, setSheetController: (s) => sheetController = s)
				]
			)
		)
	);
}

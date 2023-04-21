//import 'util.dart';
import 'package:flutter/material.dart';
//import 'package:sqflite/sqflite.dart';

class App extends StatelessWidget {
	const App({super.key});
	@override
	Widget build(BuildContext context) => MaterialApp(
		title: 'Beihanzi',
		theme: ThemeData.dark(),
		home: const HomePage()
	);
}

class HomePage extends StatefulWidget {
	const HomePage({super.key});
	@override
	State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
	int _navigationIndex = 0;
	@override
	Widget build(BuildContext context) => Scaffold(
		body: IndexedStack(
			index: _navigationIndex,
			children: const [StudyPage(), VocabularyPage()]
		),
		bottomNavigationBar: BottomNavigationBar(
			items: const [
				BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Study'),
				BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Vocabulary'),
				//BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings')
			],
			onTap: (index) => setState(() => _navigationIndex = index),
			currentIndex: _navigationIndex,
		)
	);
}

class StudyPage extends StatefulWidget {
	const StudyPage({super.key});
	@override
	State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
	int _sliderValue = 2;
	@override
	Widget build(BuildContext context) => Column(children: [
		/*
		const Expanded(child:
		Center(child: Padding(
			padding: EdgeInsets.symmetric(horizontal: 32),
			child: Text(
				'中华人民共和国',
				style: TextStyle(
					color: Colors.lightBlueAccent,
					fontSize: 64,
					fontWeight: FontWeight.bold
				),
				textAlign: TextAlign.center
			)
		))),
		*/
		Expanded(child: Stack(children: [
			const Center(child: Padding(
				padding: EdgeInsets.symmetric(horizontal: 32),
				child: Text(
					'中华人民共和国',
					style: TextStyle(
						color: Colors.lightBlueAccent,
						fontSize: 64,
						fontWeight: FontWeight.bold
					),
					textAlign: TextAlign.center
			))),
			Positioned(
				bottom: 0,
				right: 0,
				child: Padding(
					padding: const EdgeInsets.only(right: 32),
					child: Row(children: const [
						Text('20'),
						Icon(Icons.local_fire_department)
					])
				)
			)
		])),
		const Text('5/10'),
		const Divider(),
		Padding(
			padding: const EdgeInsets.symmetric(horizontal: 16),
			child: Column(
				children: [
					FractionallySizedBox(
						widthFactor: 1,
						child: ElevatedButton.icon(
							onPressed: () => 0,
							icon: const Icon(Icons.thumb_up),
							label: const Text('Recalled')
						)
					),
					FractionallySizedBox(
						widthFactor: 1,
						child: ElevatedButton.icon(
							onPressed: () => 0,
							icon: const Icon(Icons.thumb_down),
							label: const Text('Forgot')
						)
					),
					Row(children: [
						const Text('Familiarity'),
						Expanded(child: Slider(
							value: _sliderValue.toDouble(),
							onChanged: (double value) => setState(() => _sliderValue = value.toInt()),
							min: 1,
							max: 4,
							divisions: 3,
							label: _sliderValue.toInt().toString()
						)),
					]),
					TextButton(onPressed: () => 0, child: const Text('Next Batch'))
				]
			)
		)
	]);
}

class VocabularyPage extends StatelessWidget {
	const VocabularyPage({super.key});
	@override
	Widget build(BuildContext context) => const Center(child: Text("TEST"));
}

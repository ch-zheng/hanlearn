import 'model.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
	final Model model;
	const App(this.model, {super.key});
	@override
	Widget build(BuildContext context) => MaterialApp(
		title: 'Beihanzi',
		theme: ThemeData.dark(),
		home: DefaultTabController(
			length: 2,
			child: Scaffold(
				bottomNavigationBar: const BottomAppBar(
					child: TabBar(tabs: [
						Tab(text: 'Study', icon: Icon(Icons.book)),
						Tab(text: 'Vocabulary', icon: Icon(Icons.list))
					])
				),
				body: TabBarView(
					physics: const NeverScrollableScrollPhysics(),
					children: [
						StudyPage(model, key: const ValueKey('study')),
						const VocabularyPage(key: ValueKey('vocab'))
					]
				)
			)
		),
	);
}

class StudyPage extends StatefulWidget {
	final Model model;
	const StudyPage(this.model, {super.key});
	@override
	State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> 
	with AutomaticKeepAliveClientMixin<StudyPage> {
	var flashcards = <Flashcard>[];
	int flashcardIndex = 0, sliderValue = 1;
	final pageController = PageController();
	@override
	Widget build(BuildContext context) {
		super.build(context);
		return Column(children: [
			Expanded(child: GestureDetector(
				child: Stack(children: [
					PageView.builder(
						controller: pageController,
						onPageChanged: (value) => setState(() => flashcardIndex = value),
						itemBuilder: (context, index) => Center(child: Padding (
							padding: const EdgeInsets.symmetric(horizontal: 32),
							child: Text(
								index < flashcards.length ? flashcards[index].item : '',
								style: const TextStyle(
									color: Colors.lightBlueAccent,
									fontSize: 64,
									fontWeight: FontWeight.bold
								),
								textAlign: TextAlign.center
							)
						)),
						itemCount: flashcards.length
					),
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
				]),
				//TODO: Tap detection
			)),
			Text('${flashcardIndex+1}/${flashcards.length}'),
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
								value: sliderValue.toDouble(),
								onChanged: (double value) => setState(() => sliderValue = value.toInt()),
								min: 1,
								max: 4,
								divisions: 3,
								label: sliderValue.toInt().toString()
							)),
						]),
						TextButton(
							onPressed: () =>
								widget.model.drawFlashcards(10).then(
									(value) => setState(() => flashcards = value)
								),
							child: const Text('Next Batch')
						)
					]
				)
			)
		]);
	}
	@override
	bool get wantKeepAlive => true;
}

class VocabularyPage extends StatelessWidget {
	const VocabularyPage({super.key});
	@override
	Widget build(BuildContext context) => const Center(child: Text("TEST"));
}

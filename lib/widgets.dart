import 'model.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class App extends StatefulWidget {
	final Model model;
	const App(this.model, {super.key});
	@override
	State<App> createState() => _AppState();
}

class _AppState extends State<App>
	with SingleTickerProviderStateMixin {
	int navigationIndex = 0;
	late TabController tabController;
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
			bottomNavigationBar: NavigationBar(
				selectedIndex: navigationIndex,
				destinations: const [
					NavigationDestination(icon: Icon(Icons.book), label: 'Study'),
					NavigationDestination(icon: Icon(Icons.list), label: 'Vocabulary')
				],
				onDestinationSelected: (index) => setState(() {
					navigationIndex = index;
					tabController.animateTo(index);
				})
			),
			body: TabBarView(
				controller: tabController,
				physics: const NeverScrollableScrollPhysics(),
				children: [
					StudyPage(widget.model),
					VocabularyPage(widget.model)
				]
			)
		)
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
	int flashcardIndex = 0;
	bool flashcardShown = false;
	final pageController = PageController();
	drawFlashcards() {
		widget.model.drawFlashcards(10).then(
			(value) => setState(() => flashcards = value)
		);
	}
	@override
	initState() {
		super.initState();
		drawFlashcards();
	}
	@override
	Widget build(BuildContext context) {
		super.build(context);
		final flashcard = flashcards.isNotEmpty ?
			flashcards[flashcardIndex]
			: Flashcard('', '', '');
		final result = Column(children: [
			Expanded(child: GestureDetector(
				onTap: () => setState(() => flashcardShown = !flashcardShown),
				child: PageView.builder(
					controller: pageController,
					onPageChanged: (value) => setState(() {
						flashcardIndex = value;
						flashcardShown = false;
					}),
					itemBuilder: (context, index) {
						Widget cardContents;
						if (index != flashcardIndex || !flashcardShown) {
							cardContents = Text(
								key: UniqueKey(),
								flashcards[index].item,
								style: TextStyle(
									color: (Theme.of(context).textTheme.titleLarge as TextStyle).color as Color,
									fontSize: 64,
									fontWeight: FontWeight.bold
								),
								textAlign: TextAlign.center
							);
						} else {
							//TODO: Proper contents
							cardContents = Text(
								flashcard.pinyin,
								key: UniqueKey(),
								style: TextStyle(
									color: (Theme.of(context).textTheme.titleLarge as TextStyle).color as Color,
									fontSize: 64,
									fontWeight: FontWeight.bold
								),
								textAlign: TextAlign.center
							);
						}
						return Center(child: Padding (
							padding: const EdgeInsets.fromLTRB(32, 64, 32, 32),
							child: Card(child: Center(child: AnimatedSwitcher(
								duration: const Duration(milliseconds: 100),
								child: cardContents
							)))
						));
					},
					itemCount: flashcards.length
				)
			)),
			Text(
				'${flashcardIndex+1} / ${flashcards.length}',
				style: Theme.of(context).textTheme.labelLarge as TextStyle
			),
			const Divider(),
			Padding(
				padding: const EdgeInsets.symmetric(horizontal: 16),
				child: Column(
					children: [
						FractionallySizedBox(
							widthFactor: 1,
							child: ElevatedButton.icon(
								onPressed: () => 0, //TODO
								icon: const Icon(Icons.thumb_up),
								label: const Text('Recalled')
							)
						),
						FractionallySizedBox(
							widthFactor: 1,
							child: ElevatedButton.icon(
								onPressed: () => 0, //TODO
								icon: const Icon(Icons.thumb_down),
								label: const Text('Forgot')
							)
						),
						Row(children: [
							Text('Familiarity', style: Theme.of(context).textTheme.labelLarge as TextStyle),
							Expanded(child: Slider(
								value: max(flashcard.level.toDouble(), 1),
								onChanged: (double value) =>
									setState(() => flashcards[flashcardIndex].level = value.toInt()),
								min: 1,
								max: 4,
								divisions: 3,
								label: flashcard.level.toString()
							)),
						]),
						TextButton(
							onPressed: () => drawFlashcards(),
							child: const Text('Next Batch')
						)
					]
				)
			)
		]);
		return result;
	}
	@override
	bool get wantKeepAlive => true;
}

class VocabularyPage extends StatefulWidget {
	final Model model;
	const VocabularyPage(this.model, {super.key});
	@override
	State<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends State<VocabularyPage> 
	with AutomaticKeepAliveClientMixin<VocabularyPage> {
	@override
	Widget build(BuildContext context) {
		super.build(context);
		return const Text('stuff'); //TODO
	}
	@override
	bool get wantKeepAlive => true;
}

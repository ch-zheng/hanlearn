import 'model.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:collection';

class StudyPage extends StatefulWidget {
	const StudyPage({super.key});
	@override
	State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> 
	with AutomaticKeepAliveClientMixin<StudyPage> {
	late UnmodifiableListView<Flashcard> _flashcards;
	int _flashcardIndex = 0;
	bool _flashcardShown = false;
	final _pageController = PageController();
	@override
	void initState() {
		super.initState();
		final model = Provider.of<Model>(context, listen: false);
		_flashcards = model.draw(FlashcardType.character, 10);
	}
	@override
	Widget build(BuildContext context) {
		super.build(context);
		final flashcard = _flashcards.isNotEmpty ?
			_flashcards[_flashcardIndex]
			: Flashcard(FlashcardType.character, 0, '', '', ''); //FIXME
		return Column(children: [
			Expanded(child: GestureDetector(
				onTap: () => setState(() => _flashcardShown = !_flashcardShown),
				child: PageView.builder(
					controller: _pageController,
					onPageChanged: (value) => setState(() {
						_flashcardIndex = value;
						_flashcardShown = false;
					}),
					itemBuilder: (context, index) {
						return Center(child: Padding (
							padding: const EdgeInsets.all(32),
							child: FlashcardWidget(
								_flashcards[index],
								shown: index == _flashcardIndex && _flashcardShown,
								key: ValueKey(index)
							)
						));
					},
					itemCount: _flashcards.length
				)
			)),
			Text(
				'${_flashcardIndex+1} / ${_flashcards.length}',
				style: Theme.of(context).textTheme.labelLarge
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
							Text('Familiarity', style: Theme.of(context).textTheme.labelLarge),
							Expanded(child: Slider(
								value: max(flashcard.level.toDouble(), 1),
								onChanged: (value) => setState(() {
									flashcard.level = value.toInt();
									final model = Provider.of<Model>(context);
									model.replace(flashcard.type, flashcard.id);
								}),
								min: 1,
								max: 4,
								divisions: 3,
								label: flashcard.level.toString()
							)),
						]),
						TextButton(
							onPressed: () {
								_pageController.animateToPage(
									0,
									duration: Duration(milliseconds: min(100 * _flashcardIndex, 500)),
									curve: Curves.decelerate
								);
								_flashcards = Provider.of<Model>(context, listen: false)
									.draw(FlashcardType.character, 10);
							},
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

class FlashcardWidget extends StatelessWidget {
	final Flashcard flashcard;
	final bool shown;
	const FlashcardWidget(this.flashcard, {this.shown = false, super.key});
	@override
	Widget build(BuildContext context) {
		Widget contents;
		if (!shown) {
			contents = Text(
				flashcard.item,
				style: Theme.of(context).textTheme.displayLarge?.apply(
					color: Theme.of(context).colorScheme.primary,
				),
				textAlign: TextAlign.center
			);
		} else {
			contents = Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Text(
						flashcard.item,
						style: Theme.of(context).textTheme.displayLarge?.apply(
							color: Theme.of(context).colorScheme.primary,
						),
						textAlign: TextAlign.center
					),
					const Divider(indent: 16, endIndent: 16),
					Text(
						flashcard.prettyPinyin,
						style: Theme.of(context).textTheme.headlineLarge,
						textAlign: TextAlign.center
					),
					const Divider(indent: 16, endIndent: 16),
					Text(
						flashcard.prettyDefinition,
						style: Theme.of(context).textTheme.headlineSmall,
						textAlign: TextAlign.center
					)
				]
			);
		}
		return Card(child: Center(child: SingleChildScrollView(child: Padding(
			padding: const EdgeInsets.all(8),
			child: PageTransitionSwitcher(
				duration: const Duration(milliseconds: 200),
				reverse: !shown,
				transitionBuilder: (child, primary, secondary) => SharedAxisTransition(
					animation: primary,
					secondaryAnimation: secondary,
					transitionType: SharedAxisTransitionType.vertical,
					fillColor: Colors.transparent,
					child: child
				),
				child: contents
			)
		))));
	}
}

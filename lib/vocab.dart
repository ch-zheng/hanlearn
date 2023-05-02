import 'model.dart';
import 'util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:collection';

class VocabPage extends StatelessWidget {
	const VocabPage({super.key});
	@override
	Widget build(BuildContext context) => DefaultTabController(length: 2, child:
		Column(children: const [
			TabBar(tabs: [
				Tab(text: 'Characters'),
				Tab(text: 'Words')
			]),
			Expanded(child: TabBarView(
				physics: NeverScrollableScrollPhysics(),
				children: [
					VocabTab(FlashcardType.character),
					VocabTab(FlashcardType.word)
				], 
			))
		])
	);
}

class VocabTab extends StatelessWidget {
	final FlashcardType _vocabType;
	const VocabTab(this._vocabType, {super.key});
	@override
	Widget build(BuildContext context) {
		return Stack(children: [
			Column(children: [
				//List controls
				Padding(
					padding: const EdgeInsets.symmetric(horizontal: 16),
					child: Row(children: [
						const Expanded(flex: 3, child: TextField(
							keyboardType: TextInputType.number,
							decoration: InputDecoration(labelText: 'Offset'),
							maxLength: 4
						)),
						Expanded(child: TextButton(
							onPressed: () => 0,
							child: const Text('Go')
						)
						)
					])
				),
				//Vocabulary list
				Expanded(child: VocabList(_vocabType)),
			]),
			//Floating action buttons
			Positioned(right: 8, bottom: 8, child: Column(children: [
				FloatingActionButton.extended(
					onPressed: () => 0,
					label: const Text('Add'),
					icon: const Icon(Icons.add)
				),
				const SizedBox(height: 8),
				FloatingActionButton.extended(
					onPressed: () => 0,
					label: const Text('Edit'),
					icon: const Icon(Icons.segment)
				)
			]))
		]);
	}
}

class VocabList extends StatelessWidget {
	final FlashcardType _vocabType;
	const VocabList(this._vocabType, {super.key});
	@override
	Widget build(BuildContext context) {
		final model = Provider.of<Model>(context);
		late final UnmodifiableListView<Flashcard> deck;
		switch (_vocabType) {
			case FlashcardType.character:
				deck = model.chars;
				break;
			case FlashcardType.word:
				deck = model.words;
				break;
		}
		return ListView.separated(
			itemBuilder: (context, index) => InkWell(
				key: ValueKey(index),
				onTap: () {
					final sheetRef = Provider.of<Reference<PersistentBottomSheetController>>(context, listen: false);
					final closed = sheetRef.value?.closed ?? Future.value(null);
					closed.then((_) => sheetRef.value = Scaffold.of(context)
						.showBottomSheet((_) => VocabSheet(deck[index])));
					sheetRef.value?.close();
				},
				child: VocabListItem(deck[index])
			),
			separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1),
			itemCount: deck.length
		);
	}
}

class VocabListItem extends StatelessWidget {
	final Flashcard _flashcard;
	const VocabListItem(this._flashcard, {super.key});
	@override
	Widget build(BuildContext context) => Padding(
		padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
		child: Row(children: [
			Container(
				margin: const EdgeInsets.only(right: 16),
				child: Text('${(_flashcard.id + 1).toString()}.')
			),
			Container(
				margin: const EdgeInsets.only(right: 16),
				child: Text(
					_flashcard.item,
					style: Theme.of(context).textTheme.labelLarge?.apply(
						color: Theme.of(context).colorScheme.primary,
						fontWeightDelta: 1
					)
				)
			),
			Container(
				margin: const EdgeInsets.only(right: 16),
				child: Text(
					_flashcard.prettyPinyin,
					style: Theme.of(context).textTheme.labelLarge
				)
			),
			Expanded(child: Text(
				_flashcard.prettyDefinition,
				style: Theme.of(context).textTheme.bodyMedium,
				overflow: TextOverflow.ellipsis
			)),
			Container(
				margin: const EdgeInsets.only(left: 16),
				child: SizedBox(
					width: 64,
					child: LinearProgressIndicator(value: _flashcard.level.toDouble() / 4.0)
				)
			),
			Container(
				margin: const EdgeInsets.only(left: 16),
				child: Text(
					_flashcard.level.toString(),
					style: Theme.of(context).textTheme.labelLarge
				)
			),
		])
	);
}

class VocabSheet extends StatelessWidget {
	final Flashcard _flashcard;
	const VocabSheet(this._flashcard, {super.key});
	@override
	Widget build(BuildContext context) => FractionallySizedBox(
		widthFactor: 1,
		child: Padding(
			padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
			child: Table(
				columnWidths: const {0: IntrinsicColumnWidth()},
				defaultVerticalAlignment: TableCellVerticalAlignment.middle,
				children: [
					//Definition
					TableRow(children: [
						Column(children: [
							Text(
								_flashcard.item,
								style: Theme.of(context).textTheme.headlineMedium?.apply(
									color: Theme.of(context).colorScheme.primary
								)
							),
							Text(
								_flashcard.prettyPinyin,
								style: Theme.of(context).textTheme.titleMedium,
							)
						]),
						Text(
							_flashcard.prettyDefinition,
							style: Theme.of(context).textTheme.bodyLarge,
						)
					]),
					//Familiarity
					TableRow(children: [
						Text('Familiarity', style: Theme.of(context).textTheme.labelLarge),
						Consumer<Model>(
							builder: (context, model, child) => Slider(
								value: _flashcard.level.toDouble(),
								onChanged: (value) {
									_flashcard.level = value.toInt();
									model.replace(_flashcard.type, _flashcard.id);
								},
								min: 0,
								max: 4,
								divisions: 4,
								label: _flashcard.level.toString()
							)
						)
					]),
					//Streak
					TableRow(children: [
						Text('Streak', style: Theme.of(context).textTheme.labelLarge),
						Row(children: [
							Text(
								_flashcard.streak.toString(),
								style: Theme.of(context).textTheme.titleMedium?.apply(
									color: Theme.of(context).colorScheme.primary
								)
							),
							const Padding(
								padding: EdgeInsets.symmetric(horizontal: 8),
								child: Icon(Icons.done_all)
							)
						])
					])
				]
			)
		)
	);
}

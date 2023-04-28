import '../model.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class VocabPage extends StatefulWidget {
	final Model model;
	/*
		To close the current bottom sheet
		when the app is navigated to a different page,
		this widget is passed a callback which sets the App sheet controller
		to the current sheet controller,
		so that the App can close the current sheet.
	*/
	final void Function(PersistentBottomSheetController?) setSheetController;
	const VocabPage(this.model, {required this.setSheetController, super.key});
	@override
	State<VocabPage> createState() => _VocabState();
}

class _VocabState extends State<VocabPage> 
	with AutomaticKeepAliveClientMixin<VocabPage> {
	var charFlashcards = <Flashcard>[];
	var wordFlashcards = <Flashcard>[];
	PersistentBottomSheetController? sheetController;
	@override
	initState() {
		super.initState();
		widget.model.getFlashcards(count: 30).then(
			(value) => setState(() => charFlashcards = value)
		);
		widget.model.getFlashcards(count: 30).then(
			(value) => setState(() => wordFlashcards = value)
		);
	}
	@override
	Widget build(BuildContext context) {
		super.build(context);
		return DefaultTabController(length: 2, child:
			Column(children: [
				const TabBar(tabs: [
					Tab(text: 'Characters'),
					Tab(text: 'Words')
				]),
				Expanded(child: TabBarView(children: [
					VocabList(charFlashcards, onTap: (index) {
						final future = sheetController?.closed ?? Future.value(null);
						future.then((value) => setState(() {
							sheetController = Scaffold.of(context).showBottomSheet(
								(context) => VocabSheet(charFlashcards[index])
							);
							widget.setSheetController(sheetController);
						}));
						sheetController?.close();
					}),
					VocabList(charFlashcards, onTap: (index) {
						final future = sheetController?.closed ?? Future.value(null);
						future.then((value) => setState(() {
							sheetController = Scaffold.of(context).showBottomSheet(
								(context) => VocabSheet(wordFlashcards[index])
							);
							widget.setSheetController(sheetController);
						}));
						sheetController?.close();
					})
				]))
			])
		);
	}
	@override
	bool get wantKeepAlive => true;
}

class VocabList extends StatelessWidget {
	final List<Flashcard> flashcards;
	final void Function(int)? onTap;
	const VocabList(this.flashcards, {this.onTap, super.key});
	@override
	Widget build(BuildContext context) => ListView.separated(
		itemBuilder: (context, index) => InkWell(
			key: ValueKey(index),
			onTap: () => onTap != null ? onTap!(index) : null,
			child: VocabListItem(flashcards[index])
		),
		separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1),
		itemCount: flashcards.length
	);
}

class VocabListItem extends StatelessWidget {
	final Flashcard flashcard;
	const VocabListItem(this.flashcard, {super.key});
	@override
	Widget build(BuildContext context) => Padding(
		padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
		child: Row(children: [
			Container(
				margin: const EdgeInsets.only(right: 16),
				child: Text('${(flashcard.id + 1).toString()}.')
			),
			Container(
				margin: const EdgeInsets.only(right: 16),
				child: Text(
					flashcard.item,
					style: Theme.of(context).textTheme.labelLarge?.apply(
						color: Theme.of(context).colorScheme.primary,
						fontWeightDelta: 1
					)
				)
			),
			Container(
				margin: const EdgeInsets.only(right: 16),
				child: Text(
					flashcard.prettyPinyin,
					style: Theme.of(context).textTheme.labelLarge
				)
			),
			Expanded(child: Text(
				flashcard.prettyDefinition,
				style: Theme.of(context).textTheme.bodyMedium,
				overflow: TextOverflow.ellipsis
			)),
			Container(
				margin: const EdgeInsets.only(left: 16),
				child: SizedBox(
					width: 64,
					child: LinearProgressIndicator(value: flashcard.level.toDouble() / 4.0)
				)
			),
			Container(
				margin: const EdgeInsets.only(left: 16),
				child: Text(
					flashcard.level.toString(),
					style: Theme.of(context).textTheme.labelLarge
				)
			),
		])
	);
}

class VocabSheet extends StatelessWidget {
	final Flashcard flashcard;
	const VocabSheet(this.flashcard, {super.key});
	@override
	Widget build(BuildContext context) => FractionallySizedBox(
		widthFactor: 1,
		child: Padding(
			padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
			child: Table(
				columnWidths: const {0: IntrinsicColumnWidth()},
				defaultVerticalAlignment: TableCellVerticalAlignment.middle,
				children: [
					TableRow(children: [
						Column(children: [
							Text(
								flashcard.item,
								style: Theme.of(context).textTheme.headlineMedium?.apply(
									color: Theme.of(context).colorScheme.primary
								)
							),
							Text(
								flashcard.prettyPinyin,
								style: Theme.of(context).textTheme.titleMedium,
							)
						]),
						Text(
							flashcard.prettyDefinition,
							style: Theme.of(context).textTheme.bodyLarge,
						)
					]),
					TableRow(children: [
						Text('Familiarity', style: Theme.of(context).textTheme.labelLarge),
						Slider(
							value: max(flashcard.level.toDouble(), 1),
							onChanged: (value) => flashcard.level = value.toInt(),
							min: 0,
							max: 4,
							divisions: 4,
							label: flashcard.level.toString()
						)
					]),
					TableRow(children: [
						Text('Streak', style: Theme.of(context).textTheme.labelLarge),
						Row(children: [
							Text(
								flashcard.streak.toString(),
								style: Theme.of(context).textTheme.titleMedium?.apply(
									color: Theme.of(context).colorScheme.primary
								)
							),
							const Icon(Icons.local_fire_department)
						])
					])
				]
			)
		)
	);
}

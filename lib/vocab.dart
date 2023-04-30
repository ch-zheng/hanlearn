import 'model.dart';
import 'util.dart';
import 'package:flutter/material.dart';

class VocabPage extends StatelessWidget {
	final Model model;
	final ValueWrapper<PersistentBottomSheetController> sheetController;
	const VocabPage(this.model, this.sheetController, {super.key});
	@override
	Widget build(BuildContext context) => DefaultTabController(length: 2, child:
		Column(children: [
			const TabBar(tabs: [
				Tab(text: 'Characters'),
				Tab(text: 'Words')
			]),
			Expanded(child: TabBarView(
				physics: const NeverScrollableScrollPhysics(),
				children: [
					VocabTab(model, sheetController),
					VocabTab(model, sheetController)
				], 
			))
		])
	);
}

class VocabTab extends StatefulWidget {
	final Model model;
	final ValueWrapper<PersistentBottomSheetController> sheetController;
	const VocabTab(this.model, this.sheetController, {super.key});
	@override
	State<VocabTab> createState() => _VocabTabState();
}

class _VocabTabState extends State<VocabTab>
	with AutomaticKeepAliveClientMixin<VocabTab> {
	var flashcards = <Flashcard>[];
	@override
	initState() {
		super.initState();
		widget.model.getFlashcards(count: 30).then(
			(value) => setState(() => flashcards = value)
		);
	}
	@override
	Widget build(BuildContext context) {
		super.build(context);
		return Stack(children: [
			Column(children: [
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
				Expanded(child: VocabList(flashcards, onTap: (index) {
					final future = widget.sheetController.value?.closed ?? Future.value(null);
					future.then((value) => setState(() {
						widget.sheetController.value = Scaffold.of(context).showBottomSheet(
							(context) => VocabSheet(widget.model, flashcards[index])
						);
					}));
					widget.sheetController.value?.close();
				})),
			]),
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
	final Model model;
	final Flashcard flashcard;
	const VocabSheet(this.model, this.flashcard, {super.key});
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
						FlashcardSlider(model, flashcard)
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

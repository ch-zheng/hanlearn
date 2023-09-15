import 'settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
	final _batchSizeEditor = TextEditingController();
	final _advanceSizeEditor = TextEditingController();
	final _thresholdEditor = TextEditingController();
	SettingsPage({super.key});
	@override
	Widget build(BuildContext context) => Consumer<Settings>(
		builder: (context, settings, child) {
			_batchSizeEditor.value = TextEditingValue(text: settings.batchSize.toString());
			_advanceSizeEditor.value = TextEditingValue(text: settings.advanceSize.toString());
			_thresholdEditor.value = TextEditingValue(text: settings.threshold.toString());
			return SingleChildScrollView(child: Padding(
				padding: const EdgeInsets.all(16),
				child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
					//Batch size
					Text('Batch size', style: Theme.of(context).textTheme.titleMedium),
					TextField(
						controller: _batchSizeEditor,
						keyboardType: TextInputType.number,
						textInputAction: TextInputAction.done,
						decoration: const InputDecoration(
							icon: Icon(Icons.horizontal_split),
							labelText: 'Batch size',
							helperText: 'Number of flashcards seen at once'
						),
						maxLength: 3,
						inputFormatters: [FilteringTextInputFormatter.digitsOnly],
						onSubmitted: (input) => settings.batchSize
							= int.tryParse(input) ?? settings.batchSize
					),
					const Divider(),
					//Maximum level
					Text('Maximum level', style: Theme.of(context).textTheme.titleMedium),
					Text(
						'Maximum level of flashcards that are selected to be shown',
						style: Theme.of(context).textTheme.bodyMedium,
					),
					Slider(
						value: settings.maxLevel.toDouble(),
						onChanged: (value) => settings.maxLevel = value.toInt(),
						min: 1,
						max: 4,
						divisions: 3,
						label: (settings.maxLevel - 1).toString()
					),
					const Divider(),
					//Flashcard types
					Text('Flashcard type', style: Theme.of(context).textTheme.titleMedium),
					Column(children: [
						RadioListTile<int>(
							value: 0,
							groupValue: settings.flashcardType,
							onChanged: (value) => settings.flashcardType = value ?? 0,
							title: const Text('Characters'),
							visualDensity: VisualDensity.compact
						),
						RadioListTile<int>(
							value: 1,
							groupValue: settings.flashcardType,
							onChanged: (value) => settings.flashcardType = value ?? 1,
							title: const Text('Words'),
							visualDensity: VisualDensity.compact
						),
						RadioListTile<int>(
							value: 2,
							groupValue: settings.flashcardType,
							onChanged: (value) => settings.flashcardType = value ?? 2,
							title: const Text('Characters & Words'),
							visualDensity: VisualDensity.compact
						),
					]),
					const Divider(),
					//Advancement size
					Text('Advancement size', style: Theme.of(context).textTheme.titleMedium),
					TextField(
						controller: _advanceSizeEditor,
						keyboardType: TextInputType.number,
						textInputAction: TextInputAction.done,
						decoration: const InputDecoration(
							icon: Icon(Icons.arrow_forward),
							labelText: 'Advancement size',
							helperText: 'Number of characters learned at once'
						),
						maxLength: 4,
						inputFormatters: [FilteringTextInputFormatter.digitsOnly],
						onSubmitted: (input) => settings.advanceSize
							= int.tryParse(input) ?? settings.advanceSize
					),
					const Divider(),
					//Automatic leveling
					Row(children: [
						Text('Automatic leveling', style: Theme.of(context).textTheme.titleMedium),
						Padding(
							padding: const EdgeInsets.symmetric(horizontal: 16),
							child:  Switch(
								value: settings.autoLevel,
								onChanged: (value) => settings.autoLevel = value
							)
						)
					]),
					Text(
						'Vocabulary level is automatically set according to the length of your streak for that item',
						style: Theme.of(context).textTheme.bodyMedium,
					),
					//Automatic leveling threshold
					TextField(
						controller: _thresholdEditor,
						keyboardType: TextInputType.number,
						textInputAction: TextInputAction.done,
						decoration: const InputDecoration(
							icon: Icon(Icons.fence),
							labelText: 'Threshold',
							helperText: 'Required streak per level'
						),
						maxLength: 2,
						inputFormatters: [FilteringTextInputFormatter.digitsOnly],
						onSubmitted: (input) => settings.threshold
							= int.tryParse(input) ?? settings.threshold,
						enabled: settings.autoLevel
					),
				])
			));
		}
	);
}

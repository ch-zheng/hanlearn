import 'package:sqflite/sqflite.dart';

class Flashcard {
	final String item, pinyin, definition;
	final int level, streak;
	const Flashcard(this.item, this.pinyin, this.definition, {this.level = 0, this.streak = 0});
}

class Model {
	final Database db;
	Model(this.db);
	Future<List<Flashcard>> drawFlashcards(int count) async {
		final rows = await db.query(
			'characters',
			groupBy: 'RANDOM()',
			limit: count
		);
		final result = <Flashcard>[];
		for (final row in rows) {
			result.add(Flashcard(
				row['character'] as String,
				row['pinyin'] as String,
				row['definition'] as String,
				level: row['level'] as int,
				streak: row['streak'] as int
			));
		}
		return result;
	}
}

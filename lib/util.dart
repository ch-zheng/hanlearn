//import 'package:sqflite/sqflite.dart';

class Flashcard {
	final String item, pinyin, definition;
	final int level, streak;
	const Flashcard(this.item, this.pinyin, this.definition, {this.level = 0, this.streak = 0});
}

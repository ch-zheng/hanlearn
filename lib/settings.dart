import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends ChangeNotifier {
	final SharedPreferences _prefs;
	Settings(this._prefs) {
		_prefs.setInt('batchSize', _prefs.getInt('batchSize') ?? 10);
		_prefs.setInt('maxLevel', _prefs.getInt('maxLevel') ?? 3);
		_prefs.setInt('flashcardType', _prefs.getInt('flashcardType') ?? 2);
		_prefs.setInt('advanceSize', _prefs.getInt('advanceSize') ?? 10);
		_prefs.setBool('autoLevel', _prefs.getBool('autoLevel') ?? false);
		_prefs.setInt('threshold', _prefs.getInt('threshold') ?? 10);
	}
	//Batch size
	int get batchSize => _prefs.getInt('batchSize') as int;
	set batchSize(int value) {
		assert(value >= 0);
		_prefs.setInt('batchSize', value);
		notifyListeners();
	}
	//Max level
	int get maxLevel => _prefs.getInt('maxLevel') as int;
	set maxLevel(int value) {
		assert(value > 0);
		assert(value <= 4);
		_prefs.setInt('maxLevel', value);
		notifyListeners();
	}
	//Flashcard type
	int get flashcardType => _prefs.getInt('flashcardType') as int;
	set flashcardType(int value) {
		assert(value >= 0 && value <= 2);
		_prefs.setInt('flashcardType', value);
		notifyListeners();
	}
	//Advancement size
	int get advanceSize => _prefs.getInt('advanceSize') as int;
	set advanceSize(int value) {
		assert(value >= 0);
		_prefs.setInt('advanceSize', value);
		notifyListeners();
	}
	//Automatic leveling
	bool get autoLevel => _prefs.getBool('autoLevel') as bool;
	set autoLevel(bool value) {
		_prefs.setBool('autoLevel', value);
		notifyListeners();
	}
	//Automatic leveling threshold
	int get threshold => _prefs.getInt('threshold') as int;
	set threshold(int value) {
		assert(value >= 0);
		_prefs.setInt('threshold', value);
		notifyListeners();
	}
	static Future<Settings> build() async => Settings(await SharedPreferences.getInstance());
}

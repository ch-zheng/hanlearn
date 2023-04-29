class ValueWrapper<T> {
	T? value;
	ValueWrapper({this.value});
}

//StatefulWidget subclass template
/*
class Bar extends StatefulWidget {
	const Bar({super.key});
	@override
	State<Bar> createState() => _BarState();
}
class _BarState extends State<Bar> {
	@override
	Widget build(BuildContext context) => null;
}
*/

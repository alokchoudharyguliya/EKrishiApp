import 'package:flutter/material.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
			title: 'Example',
			home: MyHomePage(title: 'GeeksForGeeks'),
			debugShowCheckedModeBanner: false,
		);
	}
}

class MyHomePage extends StatefulWidget {
	MyHomePage({super.key, required this.title});

	final String title;

	@override
	_MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
	List<int> data = [];
	int currentLength = 0;

	final int increment = 10;
	bool isLoading = false;

	@override
	void initState() {
		_loadMore();
		super.initState();
	}

	Future _loadMore() async {
		setState(() {
			isLoading = true;
		});

		// Add a delay
		await Future.delayed(const Duration(seconds: 2));
		for (var i = currentLength; i <= currentLength + increment; i++) {
			data.add(i);
		}
		setState(() {
			isLoading = false;
			currentLength = data.length;
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text(widget.title),
				backgroundColor: Colors.green,
				foregroundColor: Colors.white,
			),
			body: Column(
				children: [
					Expanded(
						child: LazyLoadScrollView(
							isLoading: isLoading,
							onEndOfPage: () => _loadMore(),
							child: ListView.builder(
								itemCount: data.length,
								itemBuilder: (context, position) {
									return DemoItem(position);
								},
							),
						),
					),
					if (isLoading)
						Center(
							child: Padding(
								padding: const EdgeInsets.symmetric(vertical: 8),
								child: CircularProgressIndicator(
									color: Colors.green.shade900,
								),
							),
						),
				],
			),
		);
	}
}

class DemoItem extends StatelessWidget {
	final int position;

	const DemoItem(
		this.position, {
		super.key,
	});

	@override
	Widget build(BuildContext context) {
		return Card(
			child: Padding(
				padding: const EdgeInsets.all(8.0),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: <Widget>[
						Row(
							crossAxisAlignment: CrossAxisAlignment.center,
							children: <Widget>[
								Container(
									color: Colors.deepOrange,
									height: 40.0,
									width: 40.0,
								),
								SizedBox(width: 8.0),
								Text("Item $position"),
							],
						),
						Text(
							"GeeksforGeeks.org was created with a goal "
							"in mind to provide well written, well "
							"thought and well explained solutions for selected"
							" questions. The core team of five super geeks"
							" constituting of technology lovers and computer"
							" science enthusiasts have been constantly working"
							" in this direction."
						),
					],
				),
			),
		);
	}
}
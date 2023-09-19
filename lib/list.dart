import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multiplatform_solutions/models/user_model.dart';
import 'package:popover/popover.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Adaptive app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future<List<User>> fetchFileFromAssets(String assetsPath) async {
  return rootBundle.loadString(assetsPath).then((file) =>
      (json.decode(file) as List).map((data) => User.fromJson(data)).toList());
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: fetchFileFromAssets('assets/users.json'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return LayoutBuilder(
            builder: (context, constrains) {
              if (constrains.maxWidth > 720) {
                return Scaffold(
                  appBar: AppBar(
                    title: Text(widget.title),
                  ),
                  body: Row(
                    children: [
                      const SizedBox(
                        width: 150,
                      ),
                      Expanded(
                        child: GridView.builder(
                          itemCount: snapshot.data?.length,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200,
                                  childAspectRatio: 3 / 2,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20),
                          itemBuilder: (context, counter) => Builder(
                            builder: (ctx) => ListTile(
                              title: Text(snapshot.data![counter].name),
                              subtitle: Text(snapshot.data![counter].surname),
                              onTap: () => showPopover(
                                context: ctx,
                                bodyBuilder: (context) {
                                  return Wrap(
                                    alignment: WrapAlignment.center,
                                    runAlignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      CupertinoListTile(
                                        onTap: () => Navigator.pop(context),
                                        leading: const Icon(
                                            Icons.account_circle_outlined),
                                        title: const Text('View profile'),
                                      ),
                                      CupertinoListTile(
                                        onTap: () => Navigator.pop(context),
                                        leading: const Icon(Icons.people),
                                        title: const Text('Friends'),
                                      ),
                                      CupertinoListTile(
                                        onTap: () => Navigator.pop(context),
                                        leading: const Icon(Icons.description),
                                        title: const Text('Report'),
                                      ),
                                    ],
                                  );
                                },
                                onPop: () => print('Popover was popped!'),
                                direction: PopoverDirection.bottom,
                                width: 200,
                                height: 150,
                                arrowHeight: 15,
                                arrowWidth: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Scaffold(
                  appBar: AppBar(
                    title: Text(widget.title),
                  ),
                  body: ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, counter) => ListTile(
                      title: Text(snapshot.data![counter].name),
                      subtitle: Text(snapshot.data![counter].surname),
                      onTap: () => showCupertinoModalPopup(
                        context: context,
                        builder: (context) {
                          return Wrap(
                            alignment: WrapAlignment.center,
                            runAlignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              CupertinoListTile(
                                onTap: () => Navigator.pop(context),
                                leading:
                                    const Icon(Icons.account_circle_outlined),
                                title: const Text('View profile'),
                              ),
                              CupertinoListTile(
                                onTap: () => Navigator.pop(context),
                                leading: const Icon(Icons.people),
                                title: const Text('Friends'),
                              ),
                              CupertinoListTile(
                                onTap: () => Navigator.pop(context),
                                leading: const Icon(Icons.description),
                                title: const Text('Report'),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              }
            },
          );
        } else {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }
      },
    );
  }
}

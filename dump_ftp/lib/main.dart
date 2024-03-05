import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  final node = await Process.run('node', ['--version'], runInShell: true);
  final express = await Process.run('npm', ['list', '-g'], runInShell: true);
  bool foundNode = node.stdout.toString()[0].toLowerCase() == 'v';
  bool foundExpress = express.stdout.toString().contains('express');

  if (foundNode && foundExpress) {
    log(foundNode.toString());
  }

  runApp(MyApp(
    foundNode: foundNode,
    foundExpress: foundExpress,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.foundNode, required this.foundExpress});
  final bool foundNode;
  final bool foundExpress;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dump-ftp'),
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              foundNode && foundExpress
                  ? const Text("All Required Packages Are Already")
                  : const Text(
                      'Please Install Node Js And Express Pakcage Globally'),
              const SizedBox(
                height: 10,
              ),
              if (foundNode && foundExpress)
                Expanded(
                  child: Column(
                    children: [
                      FilledButton.icon(
                        onPressed: () async {
                          final value = await Process.run(
                              'node', ['assets/index.js', 'hello'],
                              runInShell: true);
                          log(value.stdout);
                        },
                        icon: const Icon(Icons.launch),
                        label: const Text('Start Server'),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () async {},
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            padding: const EdgeInsets.all(50),
                            alignment: Alignment.center,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.upload),
                                Text('Click Here To Share File'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (!foundNode)
                FilledButton.icon(
                  onPressed: () async {
                    await _launchUrl();
                  },
                  icon: const Icon(
                    Icons.install_desktop_outlined,
                  ),
                  label: const Text('Download Node Js'),
                ),
              const SizedBox(
                height: 15,
              ),
              if (!foundExpress)
                FilledButton.icon(
                  onPressed: () async {
                    final value = await Process.run(
                        'npm', ['install', 'express', '-g'],
                        runInShell: true);
                    log(value.stdout);
                  },
                  icon: const Icon(
                    Icons.install_desktop_outlined,
                  ),
                  label: const Text('Install Express Globally'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _launchUrl() async {
  String url = 'https://nodejs.org/en';
  if (!await launchUrl(Uri.parse('https://nodejs.org/en'))) {
    throw Exception('Could not launch $url');
  }
}

import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sfmlinjector/Injector.dart';

void main() {
  runApp(const SfmlDynamicInjector());
}

Future<String> pickLocation() async {
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  if (selectedDirectory == null) {
    // User canceled the picker
    return "";
  }
  return selectedDirectory;
}

List<String> libs = [
  'Graphics',
  'Window',
  'Audio',
  'Network',
  'System',
];

class SfmlDynamicInjector extends StatelessWidget {
  const SfmlDynamicInjector({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("SFML Dynamic File Injector"),
        ),
        body: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController sfmlController = TextEditingController();
  TextEditingController fileController = TextEditingController();
  Injector manager = Injector();
  List<String> libs = ["graphics"];
  Stream<(bool, String)> stream =
      Stream.value((true, "Only Support x64 Project In This Beta Version"));
  List<String> messages = [];
  bool inject = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PathWidget(
            buttonText: 'Location',
            controller: sfmlController,
            onPressed: () async {
              String sfml = await pickLocation();
              sfmlController.value = TextEditingValue(text: sfml);
            },
          ),
          PathWidget(
            buttonText: 'Location',
            title: 'Project configration file',
            hintText: r'C:\Users\User\Desktop\project\test.vcxproj',
            controller: fileController,
            onPressed: () async {
              String project = await pickLocation();
              fileController.value = TextEditingValue(text: project);
            },
          ),
          PackagesWidget(
            setLibs: (value) {
              setState(() {
                libs = value;
                log(libs.toString());
              });
            },
          ),
          const SizedBox(
            height: 20,
          ),
          // const Spacer(),
          StreamBuilder(
              stream: stream,
              builder: (context, value) {
                if (value.hasData) {
                  // Add new message to the list
                  messages.add(value.data!.$2);

                  return Expanded(
                    child: ListView(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: messages.map((msg) {
                        return Text(
                          msg,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
                return Container();
              }),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 20,
              child: FilledButton(
                onPressed: () async {
                  stream = manager.injectDependency(
                      sfmlController.text, fileController.text, libs);
                  inject = true;
                  setState(() {});
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xff1a80e6),
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                child: const Text('Inject'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Map<String, String> dependencies = {
  'graphics': """sfml-window-s.lib
sfml-system-s.lib
opengl32.lib
freetype.lib""",
  'window': """sfml-system-s.lib
opengl32.lib
winmm.lib
gdi32.lib""",
  'audio': """sfml-system-s.lib
openal32.lib
flac.lib
vorbisenc.lib
vorbisfile.lib
vorbis.lib
ogg.lib""",
  "network": """sfml-system-s.lib
ws2_32.lib""",
  "system": "winmm.lib",
};

class PackagesWidget extends StatefulWidget {
  const PackagesWidget({
    super.key,
    required this.setLibs,
  });
  final Function(List<String> libs) setLibs;
  @override
  State<PackagesWidget> createState() => _PackagesWidgetState();
}

class _PackagesWidgetState extends State<PackagesWidget> {
  Set<String> selected = {
    'graphics',
  };
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      runAlignment: WrapAlignment.spaceAround,
      children: libs
          .map((e) => Padding(
                padding: const EdgeInsets.only(),
                child: ChoiceChip(
                  tooltip: dependencies[e.toLowerCase()],
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        color: Colors.transparent,
                      ),
                      borderRadius: BorderRadius.circular(2)),
                  backgroundColor: const Color(0xffe8eef2),
                  label: Text(e),
                  selected: selected.contains(e.toLowerCase()),
                  onSelected: (value) {
                    if (value) {
                      selected.add(e.toLowerCase());
                    } else {
                      selected.remove(e.toLowerCase());
                    }
                    widget.setLibs(selected.toList());

                    setState(() {});
                  },
                ),
              ))
          .toList(),
    );
  }
}

class PathWidget extends StatelessWidget {
  const PathWidget({
    super.key,
    this.title = 'SFML path',
    this.hintText = r'C:\Users\User\Desktop\project\SFML-2.5.1',
    required this.onPressed,
    required this.controller,
    this.buttonText = 'SFML',
  });
  final String title;
  final String hintText;
  final Function() onPressed;
  final TextEditingController controller;
  final String buttonText;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintStyle: const TextStyle(
                      fontWeight: FontWeight.w400, color: Colors.black54),
                  hintText: hintText,
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                  disabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent)),
                  // border: OutlineInputBorder(
                  //     borderSide: BorderSide(color: Colors.transparent)),
                  filled: true,
                  fillColor: const Color(0xffe8eef2),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xff1a80e6),
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              child: Text(buttonText),
            ),
          ],
        ),
        const SizedBox(
          height: 25,
        ),
      ],
    );
  }
}

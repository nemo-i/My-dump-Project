import 'dart:developer';
import 'dart:io';

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';

final ligthTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFE6E6E6),
    onPrimary: Color(0xFF91968D),
    secondary: Color(0xFFE86F67),
    onSecondary: Colors.white,
    error: Colors.redAccent,
    onError: Colors.white,
    background: Color(0xFFE6E6E6),
    onBackground: Colors.black,
    surface: Colors.white,
    onSurface: Colors.black,
  ),
);

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF3A3A3A),
    onPrimary: Color(0xFF91968D),
    secondary: Color(0xFF33BF24),
    onSecondary: Colors.white,
    error: Colors.redAccent,
    onError: Colors.white,
    background: Color(0xFFE6E6E6),
    onBackground: Colors.black,
    surface: Color(0xFF909589),
    onSurface: Colors.black,
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(330, 280),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setAsFrameless();
    await windowManager.setAlignment(Alignment.center);
  });
  runApp(EasyDynamicThemeWidget(child: const DumpShutDown()));
}

class DumpShutDown extends StatefulWidget {
  const DumpShutDown({super.key});

  @override
  State<DumpShutDown> createState() => _DumpShutDownState();
}

class _DumpShutDownState extends State<DumpShutDown> {
  FocusNode node = FocusNode();
  int h = 0;
  int m = 0;
  int s = 0;
  Selected selected = Selected.sec;
  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      onKey: (event) async {
        if (event is RawKeyDownEvent) {
          _changeThemeFromKeyboardKeys(event, context);
          startTimerFromkeyboard(
              Duration(hours: h, minutes: m, seconds: s), event);
          await abortShutdownFromkeyboard(event);
          await closeAppFromKeyborad(event);
          changeSelectedTimeCellFromKeyboradKeys(event, (value) {
            setState(() {
              selected = value;
            });
          });
          changeResetTimerCellValuesFromKeyboard((value) {
            setState(() {
              h = value;
              m = value;
              s = value;
            });
          }, event);
          changeTimerCellValuesFromKeyboard(event, (sec) {
            setState(() {
              s = sec;
            });
          }, (min) {
            setState(() {
              m = min;
            });
          }, (hour) {
            setState(() {
              h = hour;
            });
          }, h, m, s, selected);

          resetSecAndChangeMin(
              (min) {
                setState(() {
                  m = min;
                });
              },
              m,
              s,
              (sec) {
                setState(() {
                  s = sec;
                });
              });

          resetMinAndChangeHour(
              (hour) {
                setState(() {
                  h = hour;
                });
              },
              h,
              m,
              (min) {
                setState(() {
                  m = min;
                });
              });

          log(selected.name);
        }
      },
      focusNode: node,
      child: GestureDetector(
        onLongPress: () async {
          await windowManager.startDragging();
        },
        child: MaterialApp(
          theme: ligthTheme,
          darkTheme: darkTheme,
          themeMode: EasyDynamicTheme.of(context).themeMode,
          home: HomePage(
              hour: h,
              min: m,
              sec: s,
              selected: selected,
              onTap: (value) {
                setState(() {
                  selected = value;
                });
              }),
        ),
      ),
    );
  }
}

void startTimerFromkeyboard(Duration duration, RawKeyEvent event) async {
  if (event.physicalKey == PhysicalKeyboardKey.enter) {
    await Process.run('shutdown', ['/s', '/t', duration.inSeconds.toString()])
        .then((result) {
      log(result.stdout);
      log(result.stderr);
    }).catchError((error) {
      log(error);
    });
  }
}

Future<void> abortShutdownFromkeyboard(RawKeyEvent event) async {
  if (event.physicalKey == PhysicalKeyboardKey.controlLeft) {
    Process.run('shutdown', ['/a']).then((result) {
      if (result.exitCode == 0) {
        log("Shutdown aborted successfully.");
      } else {
        log("Failed to abort shutdown: ${result.stderr}");
      }
    }).catchError((error) {
      log("Error: $error");
    });
  }
}

void startTimer(
  Duration duration,
) async {
  await Process.run('shutdown', ['/s', '/t', duration.inSeconds.toString()])
      .then((result) {
    log(result.stdout);
    log(result.stderr);
  }).catchError((error) {
    log(error);
  });
}

void changeResetTimerCellValuesFromKeyboard(
    Function(int value) reset, RawKeyEvent event) {
  if (event.physicalKey == PhysicalKeyboardKey.keyR) {
    reset(0);
  }
}

void changeSelectedTimeCellFromKeyboradKeys(
    RawKeyEvent event, Function(Selected selected) changeSelectedCell) {
  switch (event.physicalKey) {
    case PhysicalKeyboardKey.keyS:
      changeSelectedCell(Selected.sec);
    case PhysicalKeyboardKey.keyM:
      changeSelectedCell(Selected.min);
    case PhysicalKeyboardKey.keyH:
      changeSelectedCell(Selected.hour);
  }
}

void changeValue(
    RawKeyEvent event, Function(int value) onChange, int currentValue) {
  if (event is RawKeyDownEvent) {
    if (event.physicalKey == PhysicalKeyboardKey.arrowUp) {
      onChange(currentValue++);
    }
    if (event.physicalKey == PhysicalKeyboardKey.arrowDown) {
      onChange(currentValue--);
    }
  }
}

enum Selected {
  hour,
  min,
  sec,
}

void resetMinAndChangeHour(Function(int hour) changeHour, int hour, int min,
    Function(int min) resetMin) {
  if (min > 59) {
    hour++;
    changeHour(hour);
    resetMin(0);
  }
  if (min < 0) {
    hour--;
    changeHour(hour);
    resetMin(59);
  }
}

void resetSecAndChangeMin(
    Function(int min) changeMin, int min, int sec, Function(int sec) resetSec) {
  if (sec > 59) {
    min++;
    changeMin(min);
    resetSec(0);
  }
  if (sec < 0) {
    min--;
    changeMin(min);
    resetSec(59);
  }
}

void resetTimeValues(Function(int hour) changeHour, Function(int min) changeMin,
    Function(int sec) changeSec, int min, int hour, int sec) {
  if (min > 60) {
    hour++;
    changeHour(hour);
    changeMin(0);
  }
  if (sec > 60) {
    min++;
    changeMin(min);
    changeSec(0);
  }
  if (min <= 0) {
    hour--;
    changeHour(hour);
    changeMin(59);
  }
  if (sec <= 0) {
    min--;
    changeMin(min);
    changeSec(59);
  }
}

String cellValue(int value) {
  if (value <= 60 && value >= 0) {
    if (value.toString().length < 2) {
      return value.toString().padLeft(2, '0');
    } else {
      return value.toString();
    }
  }
  return '00';
}

class TimeSegement extends StatelessWidget {
  const TimeSegement({
    super.key,
    required this.hour,
    required this.isLast,
    required this.min,
    required this.sec,
    required this.selected,
  });
  final int hour;
  final int min;
  final int sec;
  final Selected selected;
  final bool isLast;
  TextStyle get selectedStyle => GoogleFonts.orbitron(
        backgroundColor: const Color(0xFFE6E6E6),
        color: Colors.black,
        fontSize: 33,
      );
  TextStyle get def => GoogleFonts.orbitron(color: Colors.black, fontSize: 33);
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(style: def, children: [
        TextSpan(
          text: cellValue(hour),
          style: selected == Selected.hour ? selectedStyle : def,
        ),
        TextSpan(
          text: ":",
          style: def,
        ),
        TextSpan(
          text: cellValue(min),
          style: selected == Selected.min ? selectedStyle : def,
        ),
        TextSpan(
          text: ":",
          style: def,
        ),
        TextSpan(
          text: cellValue(sec),
          style: selected == Selected.sec ? selectedStyle : def,
        ),
      ]),
    );
  }
}

class TimerCell extends StatelessWidget {
  const TimerCell({
    super.key,
    this.isSelected = false,
    this.title = "H",
    this.onTap,
  });
  final bool isSelected;
  final String title;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        alignment: Alignment.center,
        width: 40,
        height: 30,
        decoration: BoxDecoration(
          color: isSelected
              ? EasyDynamicTheme.of(context).themeMode == ThemeMode.dark
                  ? ligthTheme.colorScheme.secondary
                  : darkTheme.colorScheme.secondary
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: isSelected ? Colors.white10 : const Color(0xFF859398),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.orbitron(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

void changeTimerCellValuesFromKeyboard(
  RawKeyEvent event,
  Function(int sec) changeSec,
  Function(int min) changeMin,
  Function(int hour) changeHours,
  int hours,
  int min,
  int sec,
  Selected selected,
) {
  if (event.physicalKey == PhysicalKeyboardKey.arrowUp) {
    if (selected == Selected.sec) {
      sec++;
      changeSec(sec);
    }
    if (selected == Selected.min) {
      min++;
      changeMin(min);
    }
    if (selected == Selected.hour) {
      if (hours < 59) {
        hours++;
        changeHours(hours);
      }
    }
  }
  if (event.physicalKey == PhysicalKeyboardKey.arrowDown) {
    if (selected == Selected.sec) {
      if (sec > 0) {
        sec--;
        changeSec(sec);
      }
    }
    if (selected == Selected.min) {
      if (min > 0) {
        min--;
        changeMin(min);
      }
    }
    if (selected == Selected.hour) {
      if (hours > 0) {
        hours--;
        changeHours(hours);
      }
    }
  }
}

Future<void> closeAppFromKeyborad(RawKeyEvent event) async {
  if (event.physicalKey == PhysicalKeyboardKey.keyC) {
    await windowManager.close();
  }
}

void _changeThemeFromKeyboardKeys(RawKeyDownEvent event, BuildContext context) {
  if (event.physicalKey == PhysicalKeyboardKey.keyD) {
    EasyDynamicTheme.of(context).changeTheme(dark: true);
  }
  if (event.physicalKey == PhysicalKeyboardKey.keyL) {
    EasyDynamicTheme.of(context).changeTheme(dark: false);
  }
}

//Orbitron
class HomePage extends StatefulWidget {
  const HomePage(
      {super.key,
      required this.hour,
      required this.min,
      required this.sec,
      required this.selected,
      required this.onTap});
  final int hour;
  final int min;
  final int sec;
  final Selected selected;
  final Function(Selected selected) onTap;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int get h => widget.hour;
  int get s => widget.sec;
  int get m => widget.min;
  Selected get selected => widget.selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SizedBox(
          width: 300,
          height: 250,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: 300,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Container(
                margin: const EdgeInsets.all(25),
                width: 200,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    width: 2.5,
                    color: const Color(0xFFC4C8CB),
                  ),
                  color: const Color(0xFF91968D),
                ),
                alignment: Alignment.center,
                child: SizedBox(
                  child: TimeSegement(
                    hour: h,
                    isLast: true,
                    min: m,
                    sec: s,
                    selected: selected,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(45.0),
                    child: Row(
                      children: [
                        TimerCell(
                          onTap: () {
                            widget.onTap(Selected.hour);
                          },
                          title: "H",
                          isSelected: selected == Selected.hour,
                        ),
                        TimerCell(
                          onTap: () {
                            widget.onTap(Selected.min);
                          },
                          title: "MIN",
                          isSelected: selected == Selected.min,
                        ),
                        TimerCell(
                          onTap: () {
                            widget.onTap(Selected.sec);
                          },
                          title: "SEC",
                          isSelected: selected == Selected.sec,
                        ),
                        const Spacer(),
                        CircleAvatar(
                          radius: 25,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          child: IconButton(
                            onPressed: () async {
                              startTimer(
                                Duration(hours: h, seconds: s, minutes: m),
                              );
                            },
                            icon: Icon(
                              CupertinoIcons.stopwatch,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

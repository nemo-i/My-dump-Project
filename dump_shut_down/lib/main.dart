import 'dart:developer';

import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    // titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
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
      onKey: (event) {
        if (event is RawKeyDownEvent) {
          _changeTheme(event, context);
          //changeTime(event, selected);
          // changeValue(event, (value) {
          //   setState(() {
          //     h = value;
          //   });
          // }, h);

          changeSelectedTimeCell(event);

          // resetTimeValues(
          //   (hour) {
          //     setState(() {
          //       h = hour;
          //     });
          //   },
          //   (min) {
          //     setState(() {
          //       m = min;
          //     });
          //   },
          //   (sec) {
          //     setState(() {
          //       s = sec;
          //     });
          //   },
          //   m,
          //   h,
          //   s,
          // );

          if (event.physicalKey == PhysicalKeyboardKey.arrowUp) {
            if (selected == Selected.sec) {
              setState(() {
                s++;
              });
            }
            if (selected == Selected.min) {
              setState(() {
                m++;
              });
            }
            if (selected == Selected.hour) {
              setState(() {
                if (h < 59) {
                  h++;
                }
              });
            }
          }
          if (event.physicalKey == PhysicalKeyboardKey.arrowDown) {
            if (selected == Selected.sec) {
              setState(() {
                if (s > 0) {
                  s--;
                }
              });
            }
            if (selected == Selected.min) {
              setState(() {
                if (m > 0) {
                  m--;
                }
              });
            }
            if (selected == Selected.hour) {
              setState(() {
                if (h > 0) {
                  h--;
                }
              });
            }
          }

          // switch (selected) {
          //   case Selected.hour:
          //     setState(() {
          //       h = increaseOrDecrease(event, h);
          //     });
          //     break;
          //   case Selected.min:
          //     setState(() {
          //       m = increaseOrDecrease(event, m);
          //     });
          //     break;
          //   case Selected.sec:
          //     setState(() {
          //       s = increaseOrDecrease(event, s);
          //     });
          //     break;
          //   default:
          //     return;
          // }
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
          //log(event.physicalKey.toString());
        }
      },
      focusNode: node,
      child: MaterialApp(
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: EasyDynamicTheme.of(context).themeMode,
        home: Scaffold(
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
                      color: const Color(0xFFE6E6E6),
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
                    child: TimeSegement(
                      hour: h,
                      isLast: true,
                      min: m,
                      sec: s,
                      selected: selected,
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
                              title: "H",
                              isSelected: selected == Selected.hour,
                            ),
                            TimerCell(
                              title: "MIN",
                              isSelected: selected == Selected.min,
                            ),
                            TimerCell(
                              title: "SEC",
                              isSelected: selected == Selected.sec,
                            ),
                            const Spacer(),
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.redAccent,
                              child: IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  CupertinoIcons.stopwatch,
                                  color: Colors.white,
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
        ),
      ),
    );
  }

  void changeSelectedTimeCell(RawKeyEvent event) {
    switch (event.physicalKey) {
      case PhysicalKeyboardKey.keyS:
        setState(() {
          selected = Selected.sec;
        });
      case PhysicalKeyboardKey.keyM:
        setState(() {
          selected = Selected.min;
        });
      case PhysicalKeyboardKey.keyH:
        setState(() {
          selected = Selected.hour;
        });
    }
  }

  void changeTimerCell(Selected selected, RawKeyEvent keyEvent) {}

  int increaseOrDecrease(RawKeyEvent keyEvent, int value) {
    return value;
  }

  void changeTime(
    RawKeyEvent keyEvent,
    Selected selected,
  ) {
    switch (selected) {
      case Selected.hour:
        changeValue(keyEvent, (value) {
          setState(
            () {
              h = value;
            },
          );
        }, h);
        break;
      case Selected.min:
        changeValue(keyEvent, (value) {
          setState(
            () {
              m = value;
            },
          );
        }, m);
        break;
      case Selected.sec:
        changeValue(keyEvent, (value) {
          setState(
            () {
              s = value;
            },
          );
        }, s);
        break;
      default:
        return;
    }
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
        backgroundColor: Color(0xFFE6E6E6),
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
  });
  final bool isSelected;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      alignment: Alignment.center,
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        color: isSelected ? Colors.green : const Color(0xFFFFFFFF),
        border: Border.all(
          color: const Color(0xFF859398),
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
    );
  }
}

void _changeTheme(RawKeyDownEvent event, BuildContext context) {
  if (event.physicalKey == PhysicalKeyboardKey.keyD) {
    EasyDynamicTheme.of(context).changeTheme(dark: true);
  }
  if (event.physicalKey == PhysicalKeyboardKey.keyL) {
    EasyDynamicTheme.of(context).changeTheme(dark: false);
  }
}


//Orbitron
import 'dart:developer';

class DependencyGenerator {
  String debugDependencies = "";
  String releaseDependencies = "";
  void generateDep(List<String> dependencies, {bool isDebug = true}) {
    // Mapping of SFML modules to their required libraries for Debug configuration
    final Map<String, List<String>> debugModuleDependencies = {
      'graphics': [
        'freetype.lib',
        'sfml-graphics-d.lib',
        'sfml-main-d.lib',
        'sfml-system-d.lib',
        'sfml-audio-d.lib',
        'sfml-window-d.lib',
        'sfml-network-d.lib',
      ],
      'window': ['opengl32.lib', 'winmm.lib', 'gdi32.lib'],
      'audio': [
        'openal32.lib',
        'flac.lib',
        'vorbisenc.lib',
        'vorbisfile.lib',
        'vorbis.lib',
        'ogg.lib'
      ],
      'network': ['sfml-network-d.lib', 'ws2_32.lib'],
      'system': ['winmm.lib']
    };

    // Mapping of SFML modules to their required libraries for Release configuration
    final Map<String, List<String>> releaseModuleDependencies = {
      'graphics': [
        'sfml-window.lib',
        'sfml-system.lib',
        'freetype.lib',
        'sfml-graphics.lib',
        'sfml-main.lib',
        'sfml-system.lib',
        'sfml-audio.lib',
        'sfml-network.lib',
      ],
      'window': [
        'sfml-window.lib',
        'sfml-system.lib',
        'opengl32.lib',
        'winmm.lib',
        'gdi32.lib'
      ],
      'audio': [
        'sfml-audio.lib',
        'sfml-system.lib',
        'openal32.lib',
        'flac.lib',
        'vorbisenc.lib',
        'vorbisfile.lib',
        'vorbis.lib',
        'ogg.lib'
      ],
      'network': ['sfml-network.lib', 'sfml-system.lib', 'ws2_32.lib'],
      'system': ['sfml-system.lib', 'winmm.lib']
    };

    // Use the correct set of dependencies based on the configuration
    final moduleDependencies =
        isDebug ? debugModuleDependencies : releaseModuleDependencies;

    for (var value in dependencies) {
      final module = value.toLowerCase();
      if (moduleDependencies.containsKey(module)) {
        if (isDebug) {
          debugDependencies += '${moduleDependencies[module]!.join(';')};';
        } else {
          releaseDependencies += '${moduleDependencies[module]!.join(';')};';
        }
      }
    }

    if (isDebug) {
      log('Debug dependencies: $debugDependencies');
    } else {
      log('Release dependencies: $releaseDependencies');
    }
  }
}

import 'dart:developer';
import 'dart:io';

import 'package:sfmlinjector/dependency_generator.dart';
import 'package:sfmlinjector/file_generator.dart';
import 'package:xml/xml.dart';

class Injector {
  DependencyGenerator dependencyGenerator = DependencyGenerator();
  FileGenerator fileGenerator = FileGenerator();

  void copyOriginalProjectConfigration(String project) {
    final Directory projectDir = Directory(project);
    List<FileSystemEntity> sfmls = projectDir
        .listSync()
        .where((file) => file.path.endsWith('.xml'))
        .toList();
    List<FileSystemEntity> files = projectDir
        .listSync()
        .where((file) => file.path.endsWith('.vcxproj'))
        .toList();
    if (sfmls.isEmpty && files.isNotEmpty) {
      File smfl = File("$project\\sfml-project.xml");
      File projectFile = File(files.first.path);
      smfl.createSync();
      projectFile.copySync(smfl.path);
    }
  }

  copyOriginalProjectConfigartionAndEdit(String project) {
    final Directory projectDir = Directory(project);
    List<FileSystemEntity> sfmls = projectDir
        .listSync()
        .where((file) => file.path.endsWith('.xml'))
        .toList();
    List<FileSystemEntity> files = projectDir
        .listSync()
        .where((file) => file.path.endsWith('.vcxproj'))
        .toList();
    if (sfmls.isNotEmpty && files.isNotEmpty) {
      File smfl = File("$project\\sfml-project.xml");
      File projectFile = File(files.first.path);
      smfl.copySync(projectFile.path);
    }
  }

  Stream<(bool, String)> injectDependency(
      String smfl, String project, List<String> choosedDependency) async* {
    dependencyGenerator.generateDep(choosedDependency);
    dependencyGenerator.generateDep(choosedDependency, isDebug: false);
    yield (true, "Start SFML Injection");
    final projectDir = Directory(project);
    List<FileSystemEntity> files = projectDir
        .listSync()
        .where((file) => file.path.endsWith('.vcxproj'))
        .toList();
    copyOriginalProjectConfigration(projectDir.path);
    yield (true, "Copied Original Project Configration For Backup");
    copyOriginalProjectConfigartionAndEdit(projectDir.path);

    fileGenerator.createMainFile(projectDir.path);
    yield (true, "Create Main.cpp File Contain SMFL Trial Code");
    log(smfl);
    log(projectDir.path);
    fileGenerator.copyBinFoldeFilesFromSFMLToProject(smfl, projectDir.path);
    yield (true, "Copied DLL File And Paste It Inside Your Project Folder");
    if (files.isEmpty) {
      yield (false, "Project Files Not Found");
    } else {
      log(files.first.path);
      final file = File(files.first.path);

      // Read the content once
      final fileContent = file.readAsStringSync();

      // Parse the content as XML
      final document = XmlDocument.parse(fileContent);

      // Define the external variables for dynamic inclusion
      final externalLibraryPath = '$smfl\\lib';
      final externalIncludePath = '$smfl\\include';
      final externalPath = smfl;
      final additionalDependenciesDebug = [
        'sfml-audio-d.lib',
        'sfml-graphics-d.lib',
        'sfml-main-d.lib',
        'sfml-network-d.lib',
        'sfml-system-d.lib',
        'sfml-window-d.lib'
      ].join(';');

      final additionalDependenciesRelease = [
        'sfml-graphics.lib',
        'sfml-system.lib',
        'sfml-window.lib',
        'freetype.lib',
        'opena132.lib',
        'sfml-main.lib',
        'ogg.lib',
        'flac.lib'
      ].join(';');

      // Find the first Project element
      final projectElement = document.getElement('Project');

      if (projectElement != null) {
        // Loop through ItemDefinitionGroups and modify based on Condition
        for (var itemDefinitionGroup
            in projectElement.findAllElements('ItemDefinitionGroup')) {
          var condition = itemDefinitionGroup.getAttribute('Condition');

          if (condition == "'\$(Configuration)|\$(Platform)'=='Debug|x64'") {
            final clCompile = itemDefinitionGroup.getElement('ClCompile');
            if (clCompile != null) {
              clCompile.children.add(XmlElement(
                  XmlName('AdditionalIncludeDirectories'), [], [
                XmlText('$externalIncludePath;%(AdditionalIncludeDirectories)')
              ]));
            }
            // Debug|x64 configuration - Add the paths
            final linkElement = itemDefinitionGroup.getElement('Link');
            if (linkElement != null) {
              linkElement.children.add(XmlElement(
                  XmlName('AdditionalLibraryDirectories'), [], [
                XmlText('$externalLibraryPath;%(AdditionalLibraryDirectories)')
              ]));
              linkElement.children.add(XmlElement(
                  XmlName('AdditionalDependencies'), [], [
                XmlText(
                    '${dependencyGenerator.debugDependencies}%(AdditionalDependencies)')
              ]));
            }
          } else if (condition ==
              "'\$(Configuration)|\$(Platform)'=='Release|x64'") {
            // Release|x64 configuration - Add the paths
            final clCompile = itemDefinitionGroup.getElement('ClCompile');
            if (clCompile != null) {
              clCompile.children.add(XmlElement(
                  XmlName('AdditionalIncludeDirectories'), [], [
                XmlText('$externalIncludePath;%(AdditionalIncludeDirectories)')
              ]));
            }
            final linkElement = itemDefinitionGroup.getElement('Link');
            if (linkElement != null) {
              linkElement.children.add(XmlElement(
                  XmlName('AdditionalLibraryDirectories'), [], [
                XmlText('$externalLibraryPath;%(AdditionalLibraryDirectories)')
              ]));
              linkElement.children.add(XmlElement(
                  XmlName('AdditionalDependencies'), [], [
                XmlText(
                    '${dependencyGenerator.releaseDependencies}%(AdditionalDependencies)')
              ]));
            }
          }
        }

        // Pretty print the modified XML
        log(document.toXmlString(pretty: true));
        // Create new PropertyGroup for Debug|x64
        final debugPropertyGroup = XmlElement(
          XmlName('PropertyGroup'),
          [
            XmlAttribute(XmlName('Condition'),
                "'\$(Configuration)|\$(Platform)'=='Debug|x64'")
          ],
          [
            XmlElement(XmlName('IncludePath'), [], [
              XmlText(
                  '$externalPath\\lib;$externalPath\\bin;$externalPath;\$(IncludePath)')
            ]),
            XmlElement(XmlName('LibraryPath'), [], [
              XmlText(
                  '$externalPath\\lib;$externalPath\\bin;$externalPath;\$(LibraryPath)')
            ]),
          ],
        );

        // Create new PropertyGroup for Release|x64
        final releasePropertyGroup = XmlElement(
          XmlName('PropertyGroup'),
          [
            XmlAttribute(XmlName('Condition'),
                "'\$(Configuration)|\$(Platform)'=='Release|x64'")
          ],
          [
            XmlElement(XmlName('IncludePath'), [], [
              XmlText(
                  '$externalPath\\lib;$externalPath\\bin;$externalPath;\$(IncludePath)')
            ]),
            XmlElement(XmlName('LibraryPath'), [], [
              XmlText(
                  '$externalPath\\lib;$externalPath\\bin;$externalPath;\$(LibraryPath)')
            ]),
          ],
        );

        // Append the new PropertyGroups to the Project
        projectElement.children.add(debugPropertyGroup);
        projectElement.children.add(releasePropertyGroup);
        // Optionally, write the modified XML back to the file
        file.writeAsStringSync(document.toXmlString(pretty: true));
        yield (true, "SMFL File Injected Successfully");
      } else {
        yield (false, "Project File Is Corrupt Try To Create New Project");
      }
    }
  }
}

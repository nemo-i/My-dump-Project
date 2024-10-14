import 'dart:developer';
import 'dart:io';

import 'package:sfmlinjector/templete_generator.dart';

class FileGenerator {
  TempleteGenerator templeteGenerator = TempleteGenerator();
  File createMainFile(String fileLocation) {
    File main = File("$fileLocation\\main.cpp");
    main.writeAsStringSync(templeteGenerator.mainFile);
    return main;
  }

  String getFileName(String filePath) {
    // Split the path by the backslash character
    List<String> parts = filePath.split(r'\');

    // Return the last part of the split path, which is the file name
    return parts.last;
  }

  void copyBinFoldeFilesFromSFMLToProject(
      String sfmlLocation, String projectLocation) async {
    final sfmlBinDir = Directory("$sfmlLocation\\bin");
    final projectBinDir =
        Directory(projectLocation); // Assuming the destination bin directory

    // Check if source and destination directories exist
    if (!sfmlBinDir.existsSync()) {
      log('Source directory does not exist: $sfmlBinDir');
      return;
    }
    if (!projectBinDir.existsSync()) {
      log('Destination directory does not exist: $projectBinDir');
      return;
    }

    // List all DLLs in the source directory
    final dlls = sfmlBinDir
        .listSync()
        .where((file) => file.path.endsWith('.dll'))
        .toList();

    // Remove existing DLLs in the destination bin directory
    final existingDlls = projectBinDir
        .listSync()
        .where((file) => file.path.endsWith('.dll'))
        .toList();

    for (var file in existingDlls) {
      try {
        log('Removing existing DLL: ${file.path}');
        file.deleteSync(); // Delete existing DLL file
      } catch (e) {
        log('Failed to delete ${file.path}: $e');
      }
    }

    // Copy new DLLs from the SFML bin directory to the project bin directory
    for (var file in dlls) {
      final desFile = File("${projectBinDir.path}\\${getFileName(file.path)}");
      log('Copying ${file.path} to ${desFile.path}');
      try {
        File dll = File(file.path);
        dll.copySync(desFile.path); // Copy the file directly
        log('File copied successfully: ${desFile.path}');
      } catch (e) {
        log('Failed to copy ${file.path} to ${desFile.path}: $e');
      }
    }
  }

  // String getFileName(String path) {
  //   return path.split('\\').last; // Get file name from full path
  // }
}

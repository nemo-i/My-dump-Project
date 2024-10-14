import 'dart:developer';
import 'dart:io';

import 'package:xml2json/xml2json.dart';

class TempleteGenerator {
  final Xml2Json transformer = Xml2Json();
  void vsProjectFileToJson(String project) {
    final projectDir = Directory(project);
    List<FileSystemEntity> files = projectDir
        .listSync()
        .where((file) => file.path.endsWith('.vcxproj'))
        .toList();
    if (files.isEmpty) {
      log('empty files from transformer');
    }
    File xmlFile = File(files.first.path);
    transformer.parse(xmlFile.readAsStringSync());
    transformer.toOpenRally();
    final json = File("$project\\editedversion.json");
    json.writeAsStringSync(transformer.toOpenRally());
    log(transformer.toOpenRally());
  }

  String propertyGroupTemplate(String lib, String bin, String sfml) {
    final propertyGroupTemplate = '''
   
  <PropertyGroup Condition="'\$(Configuration)|\$(Platform)'=='Debug|x64'">
     <IncludePath>$lib;$bin;$sfml\$(IncludePath)</IncludePath>
    <LibraryPath>$lib;$bin;$sfml\$(LibraryPath)</LibraryPath>
  </PropertyGroup>
  <PropertyGroup Condition="'\$(Configuration)|\$(Platform)'=='Release|x64'">
      <IncludePath>$lib;$bin;$sfml\$(IncludePath)</IncludePath>
    <LibraryPath>$lib;$bin;$sfml\$(LibraryPath)</LibraryPath>
  </PropertyGroup>

''';
    return propertyGroupTemplate;
  }

  String itemDefinitionGroupTemplate(String include, String lib,
      String debugDependencies, String releaseDependencies) {
    final configTemplate = """
  <ItemDefinitionGroup Condition="'\$(Configuration)|\$(Platform)'=='Debug|x64'">
    <ClCompile>
      <WarningLevel>Level3</WarningLevel>
      <SDLCheck>true</SDLCheck>
      <PreprocessorDefinitions>_DEBUG;_CONSOLE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <ConformanceMode>true</ConformanceMode>
      <AdditionalIncludeDirectories>$include;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
    </ClCompile>
    <Link>
      <SubSystem>Console</SubSystem>
      <GenerateDebugInformation>true</GenerateDebugInformation>
      <AdditionalLibraryDirectories>$lib;%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories>
      <AdditionalDependencies>$debugDependencies%(AdditionalDependencies)</AdditionalDependencies>
    </Link>
  </ItemDefinitionGroup>
  <ItemDefinitionGroup Condition="'\$(Configuration)|\$(Platform)'=='Release|x64'">
    <ClCompile>
      <WarningLevel>Level3</WarningLevel>
      <FunctionLevelLinking>true</FunctionLevelLinking>
      <IntrinsicFunctions>true</IntrinsicFunctions>
      <SDLCheck>true</SDLCheck>
      <PreprocessorDefinitions>NDEBUG;_CONSOLE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <ConformanceMode>true</ConformanceMode>
      <AdditionalIncludeDirectories>$include;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
    </ClCompile>
    <Link>
      <SubSystem>Console</SubSystem>
      <EnableCOMDATFolding>true</EnableCOMDATFolding>
      <OptimizeReferences>true</OptimizeReferences>
      <GenerateDebugInformation>true</GenerateDebugInformation>
      <AdditionalLibraryDirectories>$lib;%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories>
      <AdditionalDependencies>$releaseDependencies%(AdditionalDependencies)</AdditionalDependencies>
    </Link>
  </ItemDefinitionGroup>
""";
    return configTemplate;
  }

  String itemGroupTemplate = """<ItemGroup>
    <ClCompile Include="game.cpp" />
  </ItemGroup>
""";

  String mainFile = """#include <SFML/Graphics.hpp>

int main()
{
    sf::RenderWindow window(sf::VideoMode(200, 200), "SFML works!");
    sf::CircleShape shape(100.f);
    shape.setFillColor(sf::Color::Green);

    while (window.isOpen())
    {
        sf::Event event;
        while (window.pollEvent(event))
        {
            if (event.type == sf::Event::Closed)
                window.close();
        }

        window.clear();
        window.draw(shape);
        window.display();
    }

    return 0;
}""";
}
// <PropertyGroup Condition="'\$(Configuration)|\$(Platform)'=='Debug|Win32'">
//     <IncludePath>$lib;$bin;$sfml\$(IncludePath)</IncludePath>
//     <LibraryPath>$lib;$bin;$sfml\$(LibraryPath)</LibraryPath>
//   </PropertyGroup>
//   <PropertyGroup Condition="'\$(Configuration)|\$(Platform)'=='Release|Win32'">
//     <IncludePath>$lib;$bin;$sfml\$(IncludePath)</IncludePath>
//     <LibraryPath>$lib;$bin;$sfml;\$(LibraryPath)</LibraryPath>
//   </PropertyGroup>


// final configTemplate86 =
  //     """<ItemDefinitionGroup Condition="'\$(Configuration)|\$(Platform)'=='Debug|Win32'">
  //   <ClCompile>
  //     <WarningLevel>Level3</WarningLevel>
  //     <SDLCheck>true</SDLCheck>
  //     <PreprocessorDefinitions>WIN32;_DEBUG;_CONSOLE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
  //     <ConformanceMode>true</ConformanceMode>
  //     <AdditionalIncludeDirectories>$include;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
  //   </ClCompile>
  //   <Link>
  //     <SubSystem>Console</SubSystem>
  //     <GenerateDebugInformation>true</GenerateDebugInformation>
  //     <AdditionalLibraryDirectories>$lib;%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories>
  //     <AdditionalDependencies>$debugDependencies%(AdditionalDependencies)</AdditionalDependencies>
  //   </Link>
  // </ItemDefinitionGroup>
  // <ItemDefinitionGroup Condition="'\$(Configuration)|\$(Platform)'=='Release|Win32'">
  //   <ClCompile>
  //     <WarningLevel>Level3</WarningLevel>
  //     <FunctionLevelLinking>true</FunctionLevelLinking>
  //     <IntrinsicFunctions>true</IntrinsicFunctions>
  //     <SDLCheck>true</SDLCheck>
  //     <PreprocessorDefinitions>WIN32;NDEBUG;_CONSOLE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
  //     <ConformanceMode>true</ConformanceMode>
  //     <AdditionalIncludeDirectories>$include;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
  //   </ClCompile>
  //   <Link>
  //     <SubSystem>Console</SubSystem>
  //     <EnableCOMDATFolding>true</EnableCOMDATFolding>
  //     <OptimizeReferences>true</OptimizeReferences>
  //     <GenerateDebugInformation>true</GenerateDebugInformation>
  //     <AdditionalLibraryDirectories>$lib;%(AdditionalLibraryDirectories)</AdditionalLibraryDirectories>
  //     <AdditionalDependencies>$releaseDependencies%(AdditionalDependencies)</AdditionalDependencies>
  //   </Link>
  // </ItemDefinitionGroup>""";
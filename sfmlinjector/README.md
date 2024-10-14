# SFML Dynamic File Injector

**SFML Dynamic File Injector** is a tool designed to streamline the process of integrating SFML (Simple and Fast Multimedia Library) into Visual Studio projects, specifically targeting **x64** projects. The purpose of this program is to avoid the tedious task of manually adding SFML to every new project.

## Features

- Automatically injects SFML files into your Visual Studio project.
- Supports both Debug and Release configurations.
- Copies necessary **DLL** files and configures project settings to include SFML libraries and dependencies.
- Avoids the manual and repetitive process of setting up SFML for new projects.

## How It Works

1. Select your SFML folder and the Visual Studio project file (.vcxproj).
2. Choose the desired SFML modules (like `graphics`, `system`, etc.).
3. The tool will inject the necessary configurations into the project file.
4. Copies SFML's **DLL** files to your project directory.
5. Works exclusively with **x64** architecture.

## Technology Stack

- Written in **Flutter** for cross-platform UI.
- Uses **Dart** to handle the file injection process.
- Currently in **Beta**.

## Future Plans

- Support for more platforms and architectures.
- Automated configuration for **x86** projects.
- Further improvements to the user interface and experience.

## Contribution

This project is **open-source** and contributions are welcome. Feel free to fork the repository and submit pull requests.

## License

This project is licensed under the MIT License. See the `LICENSE` file for more details.

## Disclaimer

This tool is currently in **Beta**. Use it at your own risk, and please report any bugs or issues.

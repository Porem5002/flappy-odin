# Flappy Odin
A flappy bird clone developed using the [Odin Programming Language](https://odin-lang.org/) and [Raylib](https://www.raylib.com/).

## Install 
To install the game checkout the Releases section and select the binaries that are compatible with your platform.

If there are no current releases available for your platform, consider building the project on your machine, see how to do it [here](#build).

## Play

To play the game run the **executable** called **flappy_odin**.

Controls:
- **ESC** - Exit
- **ENTER** - Proceed/Unpause 
- **SPACE** - Jump
- **F** - Toggle Fullscreen

## Build

If you want to build the project in your own machine you will need to have the [Odin Programming Language](https://odin-lang.org/) installed in your PC and make it accessible via your **PATH** environment variable. The version that is recommended to be used to build the project is [dev-2024-09](https://github.com/odin-lang/Odin/releases/tag/dev-2024-09).

After doing this, run the following commands according to your platform and your needs.

### On Windows
Generate Release Build:
```
.\build.bat release
```
Generate Debug Build:
```
.\build.bat
```

### On Linux
Generate Release Build:
```
make release
```
Generate Debug Build:
```
make
```

## License
[MIT License](./LICENSE)
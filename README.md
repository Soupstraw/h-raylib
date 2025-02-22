# h-raylib: Haskell bindings for Raylib

This library includes Haskell bindings to the [Raylib](https://www.raylib.com/) library.

## Usage

To use this package, include it as a dependency in your cabal file.

```cabal
build-depends:
  base,
  # ...
  h-raylib
```

Your platform-specific dependencies will automatically be built by default. You
may want to disable this behavior. You can disable the `detect-platform` flag to
achieve this.

You can do this through the command line when running your project, like so

```sh
cabal run --constraint="h-raylib -detect-platform"
```

Or you can add it to your `cabal.project` file.

```
package h-raylib
  flags: -detect-platform
```

The flags `platform-windows`, `platform-mac`, `platform-linux`, and `platform-bsd` are also
supported if you want to build for a different platform.

## Platform specific requirements

This library has been tested on Windows and Ubuntu through WSL. It may not work properly on other platforms, so don't hesitate to report issues on the GitHub repository.

### Windows

h-raylib should automatically work if you do not disable the `detect-platform` flag. In that case, you may skip this step.

**If you do disable the `detect-platform` flag when building,** use the `platform-windows` flag when building.

### Ubuntu/Debian based systems

You may need to run the following to install [X11](https://en.wikipedia.org/wiki/X_Window_System) (a window manager for Linux).

```bash
sudo apt-get install libx11-dev libxrandr-dev libxi-dev libxcursor-dev libxinerama-dev
```

Now, h-raylib should automatically work if you do not disable the `detect-platform` flag. In that case, you may skip the following.

**If you do disable the `detect-platform` flag when building,** use the `platform-linux` flag when building

### Other platforms

This library has not yet been tested on platforms other than Windows and Ubuntu. Anybody willing to try is welcome.

If you get it working on other platforms, please create a pull request in the
GitHub repository and update `h-raylib.cabal` with the relevant config.

## Running in GHCi

You can use this library in GHCi just like any other library, but you will need to add `--constraint="h-raylib +ghci"` to the command. For example, in the root folder of this repository, you could use the command below to use the library through GHCi.

```
cabal repl --constraint="h-raylib +ghci"
```

You may need to use `:set -fno-ghci-sandbox` after entering the REPL to fix problems with multithreaded execution.

On Windows, you may lose joystick support when running in GHCi.

## Contributing

To contribute or learn more about the project, see [CONTRIBUTING.md](https://github.com/Anut-py/h-raylib/blob/master/CONTRIBUTING.md).

## FAQ

- When I try to run an h-raylib program I get an error saying "*The code execution cannot proceed because libwinpthread-1.dll was not found. Reinstalling the program may fix this problem.*"
  - See [#14](https://github.com/Anut-py/h-raylib/issues/14)

## License

This project is licensed under the Apache License 2.0. See more in `LICENSE`.

# CPUSim

## Description

This project started out as a school-project and to be a drop-in replacement for the aging [sms32 Microprocessor Simulator](http://www.softwareforeducation.com/sms32v50/) but with some changes in mind.

### Differences (TODO: incomplete)

- No special "games" or traffic lights as outputs available
- many language differences (list?)
- custom (V)RAM size
- Breakpoints
- 16-bit
...

## License

This program is licensed under the GPL v.3. Please read the gpl.txt text document
included with the source code if you would like to read the terms of the license.
The license can also be found online at
[http://www.gnu.org/licenses/gpl.txt](http://www.gnu.org/licenses/gpl.txt).

## Download

Binary releases together with the corresponding source code can be found in the [releases section](https://github.com/HERDER2014/CPUSim/releases) of our GitHub page.

### ArchLinux Users

There's already an (incomplete) [PKGBUILD available in the AUR](https://aur.archlinux.org/packages/herder-cpusim-git/) ([upstream URL](https://github.com/LeonardKoenig/PKGBUILDs))

## Building & Contributing

### Dependencies

- lazarus
- qt4pas (linux?)
- lazarus-qt (?- lazarus-qt (?))

### Build

execute to build in release mode (optmizations such as O3 flags):

```
lazbuild --build-mode=release --widgetset=qt --build-all --recursive cpusim.lpi
```

skip the build-mode flag in order to build in debug mode.

To open the project in the Lazarus IDE just open the cpusim.lpi as a project.

### Packaging (Linux)

The icon [src/cpusim.png](src/cpusim.png) should be located at

`/usr/share/pixmaps/cpusim.png`

and the contents of the ['Examples' directory](Examples/) in

`/usr/share/cpusim/Examples/`

TODO: Use a scalable vektor graphics instead of png and fix paths in source code

The [desktop file](cpusim.desktop) should be ready to use and goes into

`/usr/share/applications/`

### Contribute

See the [git book](git-scm.com/book/en/v2) on how to use git.
Forks and pull requests welcome.

Please try avoiding to commiting lfm files when you did not a change (lazarus writes windows arrangement into lfm's which we don't want to commit).

## Roadmap

### Must-have:
- 16bit
- CPU Simulation
- Befehle von Niklas Zettel
- GUI
- Heftige Kommentierung
- Ein-/Ausgabe
- Speichern/Öffnen

### Should have:
- Monitor
- Debugger

### Nice to have:
- Dokumentation
- String Operationen (kp mehr was das sein soll)



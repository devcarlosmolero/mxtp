![Awesome Mix Vol.1](https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExamNzM3JxcjFra2NiZGNoM2NtcW9nNG9veHd0ZW9yZDF2cHR1OTJibyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/oTcESYsgkjU1W/giphy.gif)

# MXTP - Mixtape CLI Tools

**MXTP** is a command-line tool to prepare and organize mixtapes for cassette recording with maximum quality. It helps you minimize distortion, optimize space, and balance track distribution between Side A and Side B.

## Features

* **Trim**: Remove leading and trailing silence from audio tracks.
* **Normalize**: Adjust track volumes for consistent playback.
* **Reorganize**: Distribute tracks between Side A and Side B, optimizing cassette usage and renaming files with side prefixes.

## Installation

```bash
brew tap devcarlosmolero/homebrew https://codeberg.org/devcarlosmolero/homebrew
brew install devcarlosmolero/homebrew/mxtp
```

## Usage

```bash
mxtp tutorial         # Display the full tutorial and usage instructions
mxtp duration         # Show the total playback duration of your mixtape
mxtp menu             # Open an interactive menu to choose commands to run
```

**Command order is fixed:** `TRIM → NORMALIZE → REORGANIZE`

* The order of commands is fixed: TRIM → NORMALIZE → REORGANIZE.
* For safety, original files are cloned by default rather than overwritten.

## Notes

* Works only with audio files in the selected folder (no subdirectories).
* Optimizes cassette usage and shows visual track distribution.


## License

Shield: [![MIT License][mit-shield]][mit]

This work is licensed under the [MIT License][mit].

[![MIT License][mit-image]][mit]

[mit]: https://opensource.org/licenses/MIT
[mit-image]: https://img.shields.io/badge/License-MIT-yellow.svg
[mit-shield]: https://img.shields.io/badge/License-MIT-lightgrey.svg

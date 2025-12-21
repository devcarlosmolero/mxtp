![Awesome Mix Vol.1](https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExamNzM3JxcjFra2NiZGNoM2NtcW9nNG9veHd0ZW9yZDF2cHR1OTJibyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/oTcESYsgkjU1W/giphy.gif)

# MXTP - Mixtape CLI Tools

**MXTP** is a command-line tool to prepare and organize mixtapes for cassette recording with maximum quality. It helps you minimize distortion, optimize space, and balance track distribution between Side A and Side B.

## Features

* **Trim**: Remove leading and trailing silence from audio tracks.
* **Normalize**: Adjust track volumes for consistent playback.
* **Reorganize**: Distribute tracks between Side A and Side B, optimizing cassette usage and renaming files with side prefixes.

## Installation

```bash
brew install mxtp
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

Shield: [![CC BY-NC-SA 4.0][cc-by-nc-sa-shield]][cc-by-nc-sa]

This work is licensed under a
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License][cc-by-nc-sa].

[![CC BY-NC-SA 4.0][cc-by-nc-sa-image]][cc-by-nc-sa]

[cc-by-nc-sa]: http://creativecommons.org/licenses/by-nc-sa/4.0/
[cc-by-nc-sa-image]: https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png
[cc-by-nc-sa-shield]: https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg
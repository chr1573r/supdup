# supdup
Duplicate file detection script with visualisation

Syntax: ./supdup <directory to analyze> <minimum file size in bytes for dedup check>

supdup will recursivly scan a directory and detect duplicate files.
A size filter can be specified if you want supdup to only look at files above a given file size.

While scanning the directory, the current progress will be visualized in the terminal.

* `.` indicates a file
* `>` indicates diving into a sub-directory
* `<` indicates surfacing from a sub-directory
* `!` indicates a duplicate

After the scan, a summary is printed out with filepaths to the identified duplicate files.

![Demo](https://chr1573r.github.io/repo-assets/supdup/img/demo.png)

supdup will create a work/log directory in the current folder called `supadupa`. This folder is not automatically cleaned up by supdup.

supdup has only been tested on macOS, might be broken on other OSes

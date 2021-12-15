The `mung --gc [--yes | --no] [root]` command runs a garbage collector over the master state directory `$MUNG_STATE` and removes states that no longer correspond to file names.  This happens when the file being munged is deleted but the state is not removed.

Here's what is done.  Use `find(1)` to locate all files underneath the `root` argument, which is $HOME by default.  Each file is stored with its inode number in a dictionary.  Then we examine each state and check it against the dictionary as follows, marking some states as needing recovery:

 * If the filename and inode number in the state match those in the directory, do nothing.
 * If the filename in the state is not under `root`, do nothing.
 * If the inode number in the state is not present in the dictionary, mark the state `NOFILE`.
* If the inode number in the state is present in the dictionary but the filenames don't match, mark the state `WRONGFILE`.

Then examine all the `NOFILE` states and ask the user whether to recreate the file or not.  If yes, copy state 0 to the file's original location and change the inode number in `$MUNG_STATE` by renaming the state directory to the inode number of the new file.  If no, remove the state.

Then examine all the `WRONGFILE` states and ask the user whether to recreate the file.  If yes, ask the user *where* to recreate it. The default location is the original file path, overwriting the existing file.  Then copy state 0 to the new location and change the inode number as above.  If no, remove the state.

Asking the user is done as follows.  By default, it is interactive.  If --yes is given, all questions are automatically answered yes (using the default location).  If --no is given, all questions are automatically answered no.

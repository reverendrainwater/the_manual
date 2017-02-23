# the_manual

Author: Rev. Taylor R. Rainwater

Bash script to convert all man pages on a unix machine to postscript files then compile all of them into a single pdf. Use with caution.

Implements GNU Parallel to speed things up.
Has some remnants of "ghetto" parallelism.

Goes into four directories: /bin, /sbin, /usr/bin, /usr/sbin

## DEPENDENCIES
- GNU Parallel 20170122 or greater
- enscript
- GhostScript (no version dependence I know of)
- col and man (if you don't have these then what are you doing here?)

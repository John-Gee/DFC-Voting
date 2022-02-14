This is a little bash script to help masternode owners vote.
Currently it only works with 1 masternode at a time, that can be upgraded later.

This script depends on bash, defi-cli, sed, xclip and zenity.

The title of the CFP/DFP is clickable and should launch the appropriate page on a browser.
After clicking the voting button, the dfi-cli result will be stored in the default clipboard, allowing for an easy paste on the page opened above.

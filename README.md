Xbrace — get your braces on the next line in Xcode
==================================================

I was teaching my [Modern iOS Development workshop](http://moderniosdevelopment.com) today when Jamie, one of my students, asked if there was an easy way to get Xcode to put your braces on the next line in the built‐in system code snippets. I knew there used to be an easy way but that disappeared with Xcode 4. Googling it tonight, I found [this post by Doug Stephen](http://canadian-fury.com/2012/05/16/xcode-4-dot-3-place-all-autocompleted-opening-curly-braces-on-new-lines/) and [this StackOverflow thread](http://stackoverflow.com/questions/5120343/xcode-4-with-opening-brace-on-new-line) that suggested hacking the System Code Snippets file. The problem is that you have to do it anew with every version of Xcode. Who has the time? So, instead, I decided to whip up a quick command line app to automate the process.

I’ve tested this with Xcode 4.6 and it appears to work.

Usage:
------

  1. Download xbrace and copy it to /usr/local/bin or somewhere else that’s cosy (and on your path)
  2. ```sudo xbrace```
  3. Enter your administrative password when prompted.

That’s it!

A note on backups:
------

Xbrace will back up your snippets file to your root folder (/). It will not overwrite existing backups so you cannot accidentally overwrite the backup by running it multiple times (although there is no reason to do that, of course).

Limitations
------------

Use at your own risk. I haven’t tested this thoroughly. Also, when a new version of Xcode comes out, you need to manually delete the old backup to have new snippets file backed up. I plan to implement a more elegant way of handling this.
dissemina
=========

> Experiments in writing a fast fileservers

Hello
-----

Let's see how fast a fileserver we can write, shall we?

Start off with the
[naïve](https://github.com/scvalex/dissemina2/blob/master/Naive.hs)
implementation that just reads a file and sends it.

[Continue](https://github.com/scvalex/dissemina2/blob/master/SendFile.hs)
using the dedicated system call for sending files, `sendfile(2)`.

Try to see if we can do better
[caching](https://github.com/scvalex/dissemina2/blob/master/Cached.hs)
than the filesystem.

More soon; the adventure continues!

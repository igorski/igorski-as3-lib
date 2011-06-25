these files were first shared to create an open source library of the
nl.igorski.lib.audio package, which is the the audio synthesis and caching
engine used by www.onebarloop.com

However, other classes and components used for www.onebar... ( and several other
projects ) have also been released in the public domain, hopefully someone has
use for these, in essence: they are nothing special - several have created
similar or 'better' versions of the functionalities on offer - but they get the
job done adequately.

so, what is this "BONUS" material ?:

package nl.igorski.lib.ui

these contain a plethora of everyday "components" which are all ActionScript-based.

note that this entire package has been made by someone who will do his
utmost to NOT use the Adobe Flash IDE for his applications. As such
these components rely heavily on the graphics property of the Sprite class
and use no external assets for their presentation.

These components provide basic functionality for use in user interfaces. They
were meant to be extended ( override the "draw" methods for creating your
own styles ), but are ready to go. Initially they made use of the excellent
TweenMax tween library by Greensock for animation and visual feedback, but
these references have been removed so this package works from the get-go
using solely the Flex SDK 3.5.
CocoRoids
=========

Example game for Cocos2D v3 using CCPhysics and SpriteBuilder features.

![screenshot](http://files.slembcke.net/upshot/upshot_KYL9SXlT.png)

I had a few goals in mind when I was making this:
* **Make the project more data driven:** I'm used to making a lot of games using improvised editors and hard-coded values. This works fine when you work alone. An editor make it much easer to work with a designer that doesn't also want to be a programmer.
* **Do things that are hard without an editor:** The ship explosion is a good example. The ship was made out of lots of little sprites so I could swap in a different version with physics for each piece when the ship exploded.
* **Use CCPhysics more for collision detection:** This game really only needed linear velocities and events to trigger when objects collided. The collision delegate functionality in CCPhysics made this really easy to do.


Note: You don't need [SpriteBuilder](http://www.spritebuilder.com) to compile and run the project, but a lot of the game is set up within the SpriteBuilder editor.

Getting started with the source
-
First clone the source and its submodules, then open Xcode to build target 'CocoRoids'.

```
git clone git@github.com:slembcke/CocoRoids.git
cd CocoRoids
git submodule update --init --recursive
```

Acknowledgements:
-

The graphics are from [kenney.nl](http://kenney.nl/assets). The site has a nice collection of public domain assets you can use for prototyping.

The music is "eCommerce" by BoxCat Games. Available from [freemusicarchive.org](http://freemusicarchive.org/music/BoxCat_Games/Nameless_the_Hackers_RPG_Soundtrack/BoxCat_Games_-_Nameless-_the_Hackers_RPG_Soundtrack_-_09_eCommerce) under the Creative Commons Attribution License.

The sound effects were made using [sfxrX](http://www.sethwillits.com/sfxrX/).

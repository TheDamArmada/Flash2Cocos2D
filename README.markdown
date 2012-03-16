FlashToCocos2D
===============


This tool provides a fast way of reusing animations made in Flash CS in Cocos2D projects.
A minimaly tweaked version of the amazing exporter by Grapefuktr provides a way to export all the animation information (position, rotation, scale) of a Flash made character to xml.
The FlashToCocos iOS library reads those xml files and recreates the characters in Cocos2D.

<h2>Basic workflow:</h2>

<h3>FLASH SIDE:</h3>
- create your character in Flash 
- create as many animations a needed
- every animation has to have a keyframe labeled with an unique name. IE: "*dancing*", "*running*"...
- to launch custom events during an animation, you can use keyframes labels prefixed with @. IE: "*@launchSound*"
- select 'Export for Actionscript' for your character MovieClip
- add the Grapefukrt exporting code on the first frame:

	```actionscript
	import com.grapefrukt.exporter.simple.SimpleExport;
	import com.grapefrukt.exporter.extractors.*;
	// change robot for whatever name you want to use
	var export:SimpleExport = new SimpleExport(this, "robot"); 
	// change RobotCharacterMc for whatever name you MovieClip is in the library
	export.textures.add(TextureExtractor.extract(new RobotCharacterMc)); 
	AnimationExtractor.extract(export.animations, new RobotCharacterMc);
	export.export();
	```

- publish
- on the top left corner click on "*click to output*"
- save the zip file
- unzip the zip file


<h3>XCODE:</h3>

- start a Cocos2D project
- enabled ARC following this [instructions](http://www.tinytimgames.com/2011/07/22/cocos2d-and-arc/)
- add the FlashToCocos Library
- add the [TBXML Library](http://tbxml.co.uk/)
- add the results of unzipping the file created from Flash


<h2>FTCCharacter Class</h2>
<h3>Overview</h3>
FTCharacter is the main class to be used. It extends CCLayer and it's the responsible to load the XML files and textures.
There are still a lot of methods exposed that shouldn't be. Hopefully we'll be able to clear the code a little bit in short time.
<h3>Class Methods</h3>
<code>-(FTCharacter) characterFromXMLFile:(NSString *)xmlFileName</code><br/>	
Reads and XML, loads texture and returns a FTCCharacter.<br/>
IE: <code>FTCharacter *robot = [FTCharacter characterFromXMLFile:@"robot"]</code>
<h3>Instance Methods</h3>

<code>-(void) playAnimation:(NSString *)animation loop:(BOOL)loops wait:(BOOL)waits</code>

Starts playing the specified **animation**. It will **loop** it if specified.
The wait parameter indicates if this animation should **wait** for the previous one to finish before start playing.

<code>-(void) stopAnimation</code>

Stops the current animation being played.

<code>-(void) pauseAnimation</code>

Pauses the current animation.

<code>-(void) resumeAnimation</code>

Resumes the current paused animation.

<code>-(void) playFrame:(int)_frameIndex fromAnimation:(NSString *)_animationId</code>

Sets the character to the specified **frame** for the specified **animation**.

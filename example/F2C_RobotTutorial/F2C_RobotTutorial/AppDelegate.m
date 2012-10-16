//
//  AppDelegate.m
//  F2C_RobotTutorial
//
//  Created by Jordi.Martinez on 3/15/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "HelloWorldLayer.h"

@implementation AppDelegate {
    CCDirectorIOS * _director;
    UINavigationController *_navController;
}

@synthesize window;


- (void) applicationDidFinishLaunching:(UIApplication*)application
{
    
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
	CCGLView *glView = [CCGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565    //kEAGLColorFormatRGBA8
								   depthFormat:0    //GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO sharegroup:nil multiSampling:NO numberOfSamples:0];
    
	glView.multipleTouchEnabled = YES;
    
	_director = (CCDirectorIOS *) [CCDirector sharedDirector];
	_director.wantsFullScreenLayout = YES;
    
#ifndef IN_HOUSE_RELEASE
	[_director setDisplayStats:YES];
#endif
    
	[_director setAnimationInterval:1.0 / 60];
	[_director setView:glView];
	[_director setDelegate:self];
	[_director setProjection:kCCDirectorProjection2D];
    
	if (![_director enableRetinaDisplay:YES])
	{
		CCLOG(@"Retina Display Not supported");
	}
    
	_navController = [[UINavigationController alloc] initWithRootViewController:_director];
	_navController.navigationBarHidden = YES;
    
	[window setRootViewController:_navController];
	[window makeKeyAndVisible];
    
	[[CCFileUtils sharedFileUtils] setiPadSuffix:@"-ipad"];
	[[CCFileUtils sharedFileUtils] setiPhoneRetinaDisplaySuffix:@"-hd"];
	[[CCFileUtils sharedFileUtils] setiPadRetinaDisplaySuffix:@"-ipadhd"];
    
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    
    [_director pushScene:[HelloWorldLayer scene]];

}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director view] removeFromSuperview];
	
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
}

@end

//
//  AppDelegate.h
//  F2C_RobotTutorial
//
//  Created by Jordi.Martinez on 3/15/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCProtocols.h"

@class RootViewController;
@protocol CCDirectorDelegate;

@interface AppDelegate : NSObject <UIApplicationDelegate, CCDirectorDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end

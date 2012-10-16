//
//  HelloWorldLayer.h
//  F2C_RobotTutorial
//
//  Created by Jordi.Martinez on 3/15/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "CCRobot.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
    CCRobot *theRobot;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
-(void) pause;
-(void) resume;
-(void) doPlay:(CCMenuItemLabel *)item;
@end

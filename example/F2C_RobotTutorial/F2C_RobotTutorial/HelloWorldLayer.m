//
//  HelloWorldLayer.m
//  F2C_RobotTutorial
//
//  Created by Jordi.Martinez on 3/15/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
        theRobot = [[CCRobot alloc] init];
        [theRobot setPosition:ccp(160, 310)];
        [theRobot setScale:.5f];
        [self addChild:theRobot];
        
        
        
        
        CCMenu *starMenu = [CCMenu menuWithItems: nil];        
        [starMenu setPosition:ccp(10, 200)];
        
        CCMenuItemLabel *gotoBut = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"FRAME 5 ANIM MOVING" fontName:@"Verdana" fontSize:12] target:self selector:@selector(gotoFrame)];
        [gotoBut setAnchorPoint:ccp(0, 0.5f)];
        [starMenu addChild:gotoBut];
        
        CCMenuItemLabel *pauseBut = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"PAUSE" fontName:@"Verdana" fontSize:12] target:self selector:@selector(pause)];
        [pauseBut setAnchorPoint:ccp(0, 0.5f)];
        [starMenu addChild:pauseBut];
        
        
        
        CCMenuItemLabel *resumeBut = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"RESUME" fontName:@"Verdana" fontSize:12] target:self selector:@selector(resume)];
        [resumeBut setAnchorPoint:ccp(0, 0.5f)];
        [starMenu addChild:resumeBut];
        
        
        NSArray *arr =  [[theRobot animationEventsTable] allKeys];
        [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CCMenuItemLabel *labelBut = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:obj fontName:@"Verdana" fontSize:12] target:self selector:@selector(doPlay:)];
            labelBut.tag = idx;
            [labelBut setAnchorPoint:ccp(0, 0.5f)];
            [starMenu addChild:labelBut];
        }];
        

        [starMenu alignItemsVertically];
        [self addChild:starMenu];
        
        
        
        
//        CGSize winSize = [[CCDirector sharedDirector] winSize];        
//        for (int i=0; i<20; i++) 
//        {
//            CCRobot *testRobot = [[CCRobot alloc] init];
//            int x = 50+arc4random()%(int)winSize.width-100;
//            int y = 50+arc4random()%(int)winSize.height-100;
//            testRobot.position = ccp(x, y);
//            testRobot.scale = .5;
//            [self addChild:testRobot];
//            [testRobot playAnimation:@"moving" loop:YES wait:NO];
//        }
        
        
	
    }
    
    
	return self;
}

-(void) gotoFrame
{
    [theRobot playFrame:4 fromAnimation:@"moving"];
}

-(void) pause
{
    [theRobot pauseAnimation];
}

-(void) resume
{
    [theRobot resumeAnimation];
}

-(void) doPlay:(CCMenuItemLabel *)item
{
    NSArray *arr = [[theRobot animationEventsTable] allKeys];

    NSString *animationStr = [arr objectAtIndex:item.tag];

    // to determine if the animation should loop we check if it ends in "ing"
    BOOL doesLoop = [animationStr hasSuffix:@"ing"];    
    
    [theRobot playAnimation:[arr objectAtIndex:item.tag] loop:doesLoop wait:NO];
}




@end

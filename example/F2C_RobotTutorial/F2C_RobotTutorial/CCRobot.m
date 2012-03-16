//
//  CCRobot.m
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CCRobot.h"

@implementation CCRobot

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        [self createCharacterFromXML:@"robot"];
        [self setDelegate:self];

        [self playAnimation:@"static" loop:NO wait:NO];
        [self playAnimation:@"static_move" loop:NO wait:YES];

        wheel = [self getChildByName:@"wheel"];
        [wheel setIgnoreRotation:YES];
    }
    
    return self;
}


-(void) onCharacter:(FTCCharacter *)_character event:(NSString *)_event atFrame:(int)_frameIndex
{
    NSLog(@"CHARACTER ROBOT EVENT %@ at Frame %i", _event, _frameIndex);
}

@end

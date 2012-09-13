//
//  FTCSprite.m
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FTCSprite.h"
#import "FTCCharacter.h"

@implementation FTCSprite

@synthesize name;
@synthesize ignorePosition, ignoreRotation, ignoreScale;
@synthesize animationsArr;


+ (id)spriteWithSpriteFrameName:(NSString *)spriteFrameName
{
    return [[self alloc] initWithSpriteFrameName:spriteFrameName];
}

- (id)initWithSpriteFrameName:(NSString *)spriteFrameName
{
    self = [super initWithSpriteFrameName:spriteFrameName];
    if (self) {
        NSMutableDictionary *__animations = [[NSMutableDictionary alloc] init];
        [self setAnimationsArr:__animations];
    }
    return self;
}

+ (id)spriteWithFile:(NSString *)filename
{
    return [[self alloc] initWithFile:filename];
}

- (id)initWithFile:(NSString *)filename
{
    self = [super initWithFile:filename];
    if (self) {
        NSMutableDictionary *__animations = [[NSMutableDictionary alloc] init];
        [self setAnimationsArr:__animations];
    }
    return self;
}


-(void) setCurrentAnimation:(NSString *)_framesId forCharacter:(FTCCharacter *)_character
{
    currentCharacter = _character;
    currentAnimationInfo = [self.animationsArr objectForKey:_framesId];
}

-(void) setCurrentAnimationFramesInfo:(NSArray *)_framesInfoArr forCharacter:(FTCCharacter *)_character
{
    currentCharacter = _character;
    currentAnimationInfo = _framesInfoArr;
}


-(void) applyFrameInfo:(FTCFrameInfo *)_frameInfo
{
    if (!ignorePosition) 
        [self setPosition:CGPointMake(_frameInfo.x, _frameInfo.y)];   
    
    if (!ignoreRotation) 
        [self setRotation:_frameInfo.rotation];   
    
    if (!ignoreScale) {
        if (_frameInfo.scaleX!=0)   [self setScaleX:_frameInfo.scaleX];
        if (_frameInfo.scaleY!=0)   [self setScaleY:_frameInfo.scaleY];
    }
}


-(void) playFrame:(int)_frameindex
{
    if (!currentAnimationInfo) return;
    if (_frameindex < currentAnimationInfo.count) 
        [self applyFrameInfo:[currentAnimationInfo objectAtIndex:_frameindex]];
    
}

@end

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
{
    NSArray *_currentAnimationInfo;
    FTCCharacter *_currentCharacter;
}

@synthesize name = _name;
@synthesize ignoreAlpha = _ignoreAlpha;
@synthesize ignorePosition = _ignorePosition;
@synthesize ignoreRotation = _ignoreRotation;
@synthesize ignoreScale = _ignoreScale;
@synthesize animationsArr = _animationsArr;

-(void) setCurrentAnimation:(NSString *)framesId forCharacter:(FTCCharacter *)character
{
    _currentCharacter = character;
    _currentAnimationInfo = [self.animationsArr objectForKey:framesId];
}

-(NSMutableDictionary*) animationsArr
{
    if (_animationsArr == nil)
        _animationsArr = [[NSMutableDictionary alloc] init];
    
    return _animationsArr;
}

-(void) setCurrentAnimationFramesInfo:(NSArray *)framesInfoArr forCharacter:(FTCCharacter *)character
{
    _currentCharacter = character;
    _currentAnimationInfo = framesInfoArr;
}

-(void) applyFrameInfo:(FTCFrameInfo *)frameInfo
{
    if (!_ignorePosition)
        [self setPosition:CGPointMake(frameInfo.x, frameInfo.y)];
    
    if (!_ignoreRotation)
        [self setRotation:frameInfo.rotation];
    
    if (!_ignoreScale)
    {
        if (frameInfo.scaleX!=0)
            self.scaleX = frameInfo.scaleX;
        
        if (frameInfo.scaleY!=0)
            self.scaleY = frameInfo.scaleY;
    }
    
    if (!_ignoreAlpha)
        [self setOpacity:frameInfo.alpha * 255];
}


-(void) playFrame:(int)frameindex
{
    if (!_currentAnimationInfo)
        return;
    
    if (frameindex < _currentAnimationInfo.count)
        [self applyFrameInfo:[_currentAnimationInfo objectAtIndex:frameindex]];
}

@end

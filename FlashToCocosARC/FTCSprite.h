//
//  FTCSprite.h
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "FTCFrameInfo.h"

@class  FTCCharacter;

@interface FTCSprite : CCSprite 

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL ignoreRotation;
@property (nonatomic, assign) BOOL ignorePosition;
@property (nonatomic, assign) BOOL ignoreScale;
@property (nonatomic, assign) BOOL ignoreAlpha;
@property (nonatomic, strong) NSMutableDictionary *animationsArr;

//private
-(void) setCurrentAnimation:(NSString *)framesId forCharacter:(FTCCharacter *)character;
-(void) setCurrentAnimationFramesInfo:(NSArray *)framesInfoArr forCharacter:(FTCCharacter *)character;
-(void) applyFrameInfo:(FTCFrameInfo *)frameInfo;
-(void) playFrame:(int)frameindex;
@end

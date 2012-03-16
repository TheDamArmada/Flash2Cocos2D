//
//  FTCCharacter.h
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "FTCSprite.h"
#import "FTCAnimEvent.h"

@protocol FTCCharacterDelegate;

@interface FTCCharacter : CCSprite
{
    

    NSArray                     *currentAnimEvent;
    
    int                         intFrame;
    int                         currentAnimationLength;

    NSString                    *currentAnimationId;
    NSString                    *nextAnimationId;
    
    BOOL                        _doesLoop;
    BOOL                        nextAnimationDoesLoop;
    BOOL                        _isPaused;
    
}

@property (unsafe_unretained) id<FTCCharacterDelegate> delegate;
@property (strong) NSMutableDictionary *childrenTable;
@property (strong) NSMutableDictionary *animationEventsTable;



+(FTCCharacter *) characterFromXMLFile:(NSString *)_xmlfile;
-(void) playAnimation:(NSString *)_animId loop:(BOOL)_isLoopable wait:(BOOL)_wait;
-(void) stopAnimation;
-(void) pauseAnimation;
-(void) resumeAnimation;
-(void) playFrame:(int)_frameIndex fromAnimation:(NSString *)_animationId;
-(void) playFrame;


-(id) initFromXMLFile:(NSString *)_xmlfile;
-(NSString *) getCurrentAnimation;
-(int) getDurationForAnimation:(NSString *)_animationId;
-(FTCSprite *) getChildByName:(NSString *)_childName;
-(int) getCurrentFrame;
-(void) addElement:(FTCSprite *)_element withName:(NSString *)_name atIndex:(int)_index;
-(void) reorderChildren;

// private
-(void) setFirstPose;
-(void) createCharacterFromXML:(NSString *)_xmlfile;

@end


@protocol FTCCharacterDelegate <NSObject>


@optional
-(void) onCharacterCreated:(FTCCharacter *)_character;
-(void) onCharacter:(FTCCharacter *)_character event:(NSString *)_event atFrame:(int)_frameIndex;
-(void) onCharacter:(FTCCharacter *)_character endsAnimation:(NSString *)_animationId;
-(void) onCharacter:(FTCCharacter *)_character startsAnimation:(NSString *)_animationId;
-(void) onCharacter:(FTCCharacter *)_character updateToFrame:(int)_frameIndex;
-(void) onCharacter:(FTCCharacter *)_character loopedAnimation:(NSString *)_animationId;

@end
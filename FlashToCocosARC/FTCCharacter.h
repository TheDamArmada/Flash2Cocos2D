//
//  FTCCharacter.h
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FTCSprite.h"
#import "FTCAnimEvent.h"

@protocol FTCCharacterDelegate;

@interface FTCCharacter : CCSprite

@property (nonatomic, weak) id<FTCCharacterDelegate> delegate;
@property (nonatomic, strong) NSMutableDictionary *childrenTable;
@property (nonatomic, strong) NSMutableDictionary *animationEventsTable;
@property (nonatomic, assign) float frameRate;

+(FTCCharacter *) characterFromXMLFile:(NSString *)xmlfile;

-(void) playAnimation:(NSString *)animId loop:(BOOL)isLoopable wait:(BOOL)wait;
-(void) stopAnimation;
-(void) pauseAnimation;
-(void) resumeAnimation;
-(void) playFrame:(int)frameIndex fromAnimation:(NSString *)animationId;
-(void) playFrame;

-(id) initFromXMLFile:(NSString *)xmlfile;
-(NSString *) getCurrentAnimation;
-(int) getDurationForAnimation:(NSString *)animationId;
-(FTCSprite *) getChildByName:(NSString *)childName;
-(int) getCurrentFrame;
-(void) addElement:(FTCSprite *)element withName:(NSString *)name atIndex:(int)index;
-(void) reorderChildren;

// private
-(void) setFirstPose;
-(void) createCharacterFromXML:(NSString *)xmlfile;
-(void) scheduleAnimation;

@end


@protocol FTCCharacterDelegate <NSObject>

@optional
-(void) onCharacterCreated:(FTCCharacter *)character;
-(void) onCharacter:(FTCCharacter *)character event:(NSString *)event atFrame:(int)frameIndex;
-(void) onCharacter:(FTCCharacter *)character endsAnimation:(NSString *)animationId;
-(void) onCharacter:(FTCCharacter *)character startsAnimation:(NSString *)animationId;
-(void) onCharacter:(FTCCharacter *)character updateToFrame:(int)frameIndex;
-(void) onCharacter:(FTCCharacter *)character loopedAnimation:(NSString *)animationId;

@end
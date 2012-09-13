//
//  FTCCharacter.m
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FTCCharacter.h"
#import "FTCParser.h"
#import "FTCEventInfo.h"

@implementation FTCCharacter

@synthesize childrenTable;
@synthesize animationEventsTable;
@synthesize delegate;






+(FTCCharacter *) characterFromXMLFile:(NSString *)_xmlfile
{
    FTCCharacter *_c = [[FTCCharacter alloc] init];
    [_c createCharacterFromXML:_xmlfile];
    return _c;
}


-(id) initFromXMLFile:(NSString *)_xmlfile {
    
    self = [self init];
    if (self) 
        [self createCharacterFromXML:_xmlfile];
    
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {

        self.childrenTable = [[NSMutableDictionary alloc] init];
        
        self.animationEventsTable = [[NSMutableDictionary alloc] init];
        
        currentAnimationId = @"";
        currentAnimationLength = 0;
        currentAnimationDelay = 0.0;
        
        _isRunningCustomScheduler = NO;
        [self scheduleUpdate];
    }
    
    return self;
}



-(void) update:(ccTime)_dt
{
    if (currentAnimationLength == 0 || _isPaused) return;
    
    intFrame ++;
    
    
    // end of animation
    
    if (intFrame == currentAnimationLength) {
        
        if (![nextAnimationId isEqualToString:@""]) {            
            [self playAnimation:nextAnimationId loop:nextAnimationDoesLoop wait:NO delay:nextAnimationDelay];
            return;
            
        } 
        
        if (!_doesLoop) {
            [self stopAnimation];
            return;            
        }
        
        intFrame = 0;      
        if ([delegate respondsToSelector:@selector(onCharacter:loopedAnimation:)])
            [delegate onCharacter:self loopedAnimation:currentAnimationId];
        
    }    
    
    [self playFrame];
    
}

- (void)startCustomSchedulerWithInterval:(float)_interval
{
    [self unscheduleUpdate];

    if (_isRunningCustomScheduler) {
        [self unschedule:@selector(update:)];
        _isRunningCustomScheduler = NO;
    }
    
    [self schedule:@selector(update:) interval:_interval];
    _isRunningCustomScheduler = YES;
}

- (void)stopCustomScheduler
{
    if (_isRunningCustomScheduler) {
        [self unschedule:@selector(update:)];
        _isRunningCustomScheduler = NO;
    }
    
    [self scheduleUpdate];
}

-(void) playFrame
{
    // check if theres any event for that frame
    
    if ([[currentAnimEvent objectAtIndex:intFrame] class]!=[NSNull class]) {
        if ([delegate respondsToSelector:@selector(onCharacter:event:atFrame:)])
            [delegate onCharacter:self event:[(FTCEventInfo *)[currentAnimEvent objectAtIndex:intFrame] eventType] atFrame:intFrame];
    };
    
    
    
    if ([delegate respondsToSelector:@selector(onCharacter:updateToFrame:)])
        [delegate onCharacter:self updateToFrame:intFrame];
    
    for (FTCSprite *sprite in self.childrenTable.allValues) {        
        [sprite playFrame:intFrame];
    }
       
}


-(void) pauseAnimation
{
    _isPaused = YES;
}


-(void) resumeAnimation
{
    _isPaused = NO;
}


-(int) getCurrentFrame
{
    return intFrame;
}


-(void) playFrame:(int)_frameIndex fromAnimation:(NSString *)_animationId delay:(float)_delay
{
    [self startCustomSchedulerWithInterval:_delay];
    
//    NSLog(@"PLAYING FRAME %i FROM %@", _frameIndex, _animationId);
    currentAnimationId = _animationId;
    currentAnimEvent = [[self.animationEventsTable objectForKey:_animationId] eventsInfo];
    currentAnimationLength = [[self.animationEventsTable objectForKey:_animationId] frameCount];
    currentAnimationDelay = _delay;
    intFrame = _frameIndex;
    _isPaused = YES;
    for (FTCSprite *sprite in self.childrenTable.allValues) {
        [sprite setCurrentAnimation:currentAnimationId forCharacter:self];
    }   
    [self playFrame];
    nextAnimationId = @"";
    nextAnimationDoesLoop = NO;
    nextAnimationDelay = 0.0f;
}



-(void) stopAnimation
{
    currentAnimationLength = 0;
    currentAnimationDelay = 0.0f;
    NSString *oldAnimId = currentAnimationId;
    currentAnimationId = @"";
    
    [self stopCustomScheduler];
    
    if ([delegate respondsToSelector:@selector(onCharacter:endsAnimation:)])
        [delegate onCharacter:self endsAnimation:oldAnimId];    
}





-(void) playAnimation:(NSString *)_animId loop:(BOOL)_isLoopable wait:(BOOL)_wait delay:(float)_delay
{
    if (_wait && currentAnimationLength>0) {
        nextAnimationId = _animId;
        nextAnimationDoesLoop = _isLoopable;
        nextAnimationDelay = _delay;
        return;
    }
    
    [self startCustomSchedulerWithInterval:_delay];
    
    _isPaused = NO;
    
    nextAnimationId = @"";
    nextAnimationDoesLoop = NO;
    nextAnimationDelay = 0.0f;
    
    
    intFrame = 0;
    _doesLoop = _isLoopable;
    currentAnimationId = _animId;
    
    
    for (FTCSprite *sprite in self.childrenTable.allValues) {
        [sprite setCurrentAnimation:currentAnimationId forCharacter:self];
    }       
    
    currentAnimEvent = [[self.animationEventsTable objectForKey:_animId] eventsInfo];
    currentAnimationLength = [[self.animationEventsTable objectForKey:_animId] frameCount];
    currentAnimationDelay = _delay;
    
//    NSLog(@"PLAY ANIMATION - %@ CurrentAnimLength %i", _animId, currentAnimationLength);
    
    if ([delegate respondsToSelector:@selector(onCharacter:startsAnimation:)])
        [delegate onCharacter:self startsAnimation:_animId];

}



-(FTCSprite *) getChildByName:(NSString *)_childname
{
    // build a predicate to look in the table what object has the propery _childname in .name
    return [self.childrenTable objectForKey:_childname];
}

-(NSString *) getCurrentAnimation
{
    return currentAnimationId;
}


-(int) getDurationForAnimation:(NSString *)_animationId
{
    return [[self.animationEventsTable objectForKey:_animationId] frameCount];
}

-(void) addElement:(FTCSprite *)_element withName:(NSString *)_name atIndex:(int)_index
{
    [self addChild:_element z:_index];
    
    
    [_element setName:_name];
    
    [self.childrenTable setValue:_element forKey:_name];
}




-(void) reorderChildren
{
    int totalChildren = self.childrenTable.count;
    [self.childrenTable.allValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self reorderChild:obj z:totalChildren-idx];
    }];
}






-(void) createCharacterFromXML:(NSString *)_xmlfile
{
//    NSLog(@"Creating FTCharacter");
    
    BOOL success = [[[FTCParser alloc] init] parseXML:_xmlfile toCharacter:self];
    if (!success) {
        NSLog(@"There was an error parsing %@", _xmlfile);
    }

}




-(void) setFirstPose
{
    if ([self.delegate respondsToSelector:@selector(onCharacterCreated:)])
        [self.delegate onCharacterCreated:self];
    
}



@end

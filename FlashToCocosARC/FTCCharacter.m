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
{
    void (^_onComplete) ();
    ccColor3B _childrenTableColor;
    NSArray *_currentAnimEvent;
    
    int _intFrame;
    int _currentAnimationLength;
    
    NSString *_currentAnimationId;
    NSString *_nextAnimationId;
    
    BOOL _doesLoop;
    BOOL _nextAnimationDoesLoop;
    BOOL _isPaused;
}

@synthesize delegate = _delegate;
@synthesize childrenTable = _childrenTable;
@synthesize animationEventsTable = _animationEventsTable;
@synthesize frameRate = _frameRate;

+(FTCCharacter *) characterFromXMLFile:(NSString *)xmlfile
{
    FTCCharacter *character = [[FTCCharacter alloc] init];
    [character createCharacterFromXML:xmlfile];
    return character;
}

+(FTCCharacter *) characterFromXMLFile:(NSString *)xmlfile onCharacterComplete:(void(^)())completeHandler
{
    return [[FTCCharacter alloc] initFromXMLFile:xmlfile onCharacterComplete:completeHandler];
}

-(id) initFromXMLFile:(NSString *)xmlfile {
    
    self = [self init];
    if (self)
    {
        [self createCharacterFromXML:xmlfile];
    }
    
    return self;
}

-(id) initFromXMLFile:(NSString *)xmlfile onCharacterComplete:(void (^)())completeHandler {
    
    self = [self init];
    if (self)
        [self createCharacterFromXML:xmlfile onCharacterComplete:completeHandler];
    
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
        [self initProperties];
    
    return self;
}

- (void) initProperties
{
    self.childrenTable = [[NSMutableDictionary alloc] init];
    
    self.animationEventsTable = [[NSMutableDictionary alloc] init];
    
    _currentAnimationId = @"";
}

-(void) handleScheduleUpdate:(ccTime)dt
{
    if (_currentAnimationLength == 0 || _isPaused )
        return;
    
    _intFrame ++;
    
    // end of animation
    if (_intFrame == _currentAnimationLength)
    {
        if (![_nextAnimationId isEqualToString:@""]) {
            [self playAnimation:_nextAnimationId loop:_nextAnimationDoesLoop wait:NO];
            return;
        }
        
        if (!_doesLoop) {
            [self stopAnimation];
            return;
        }
        
        _intFrame = 0;
        if ([_delegate respondsToSelector:@selector(onCharacter:loopedAnimation:)])
            [_delegate onCharacter:self loopedAnimation:_currentAnimationId];
    }
    
    [self playFrame];    
}

-(void) playFrame
{
    // check if theres any event for that frame
    if ([[_currentAnimEvent objectAtIndex:_intFrame] class]!=[NSNull class] && [_delegate respondsToSelector:@selector(onCharacter:event:atFrame:)]) 
        [_delegate onCharacter:self event:[(FTCEventInfo *)[_currentAnimEvent objectAtIndex:_intFrame] eventType] atFrame:_intFrame];
    
    
    if ([_delegate respondsToSelector:@selector(onCharacter:updateToFrame:)]) 
        [_delegate onCharacter:self updateToFrame:_intFrame];
    
    
    for (FTCSprite *sprite in self.childrenTable.allValues) 
        [sprite playFrame:_intFrame];
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
    return _intFrame;
}

-(void) playFrame:(int)frameIndex fromAnimation:(NSString *)animationId
{
    NSLog(@"PLAYING FRAME %i FROM %@", frameIndex, animationId);
    
    _currentAnimationId = animationId;
    _currentAnimEvent = [[self.animationEventsTable objectForKey:animationId] eventsInfo];
    _currentAnimationLength = [[self.animationEventsTable objectForKey:animationId] frameCount];
    _intFrame = frameIndex;
    _isPaused = YES;
    
    for (FTCSprite *sprite in self.childrenTable.allValues)
        [sprite setCurrentAnimation:_currentAnimationId forCharacter:self];
    
    [self playFrame];
}

-(void) stopAnimation
{
    _currentAnimationLength = 0;
    NSString *oldAnimId = _currentAnimationId = @"";
    
    if ([_delegate respondsToSelector:@selector(onCharacter:endsAnimation:)])
        [_delegate onCharacter:self endsAnimation:oldAnimId];
}

-(void) playAnimation:(NSString *)animId loop:(BOOL)isLoopable wait:(BOOL)wait
{
    if ([_currentAnimationId isEqualToString:animId] && _isPaused == NO)
        return;
    
    if (wait && _currentAnimationLength>0)
    {
        _nextAnimationId = animId;
        _nextAnimationDoesLoop = isLoopable;
        return;
    }
    
    _isPaused = NO;
    _nextAnimationId = @"";
    _nextAnimationDoesLoop = NO;
    _intFrame = 0;
    _doesLoop = isLoopable;
    _currentAnimationId = animId;
    
    for (FTCSprite *sprite in self.childrenTable.allValues)
        [sprite setCurrentAnimation:_currentAnimationId forCharacter:self];
    
    _currentAnimEvent = [[self.animationEventsTable objectForKey:animId] eventsInfo];
    _currentAnimationLength = [[self.animationEventsTable objectForKey:animId] frameCount];
    
    NSLog(@"PLAY ANIMATION - %@ CurrentAnimLength %i", animId, _currentAnimationLength);
    
    if ([_delegate respondsToSelector:@selector(onCharacter:startsAnimation:)])
        [_delegate onCharacter:self startsAnimation:animId];
    
}

-(FTCSprite *) getChildByName:(NSString *)childname
{
    // build a predicate to look in the table what object has the propery _childname in .name
    return [self.childrenTable objectForKey:childname];
}

-(NSString *) getCurrentAnimation
{
    return _currentAnimationId;
}

-(int) getDurationForAnimation:(NSString *)animationId
{
    return [[self.animationEventsTable objectForKey:animationId] frameCount];
}

-(void) addElement:(FTCSprite *)element withName:(NSString *)name atIndex:(int)index
{
    [self addChild:element z:index];
    
    [element setName:name];
    
    [self.childrenTable setValue:element forKey:name];
}

-(void) reorderChildren
{
    int totalChildren = self.childrenTable.count;
    
    [self.childrenTable.allValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        [self reorderChild:obj z:totalChildren-idx];
    }];
}

-(void) createCharacterFromXML:(NSString *)_xmlfile
{
    if ([[[FTCParser alloc] init] parseXML:_xmlfile toCharacter:self])
    {
        [self scheduleAnimation];
        return;
    }

    NSLog(@"%s: There was an error parsing xmlFile for character: %@", __PRETTY_FUNCTION__, _xmlfile);
}

-(void) scheduleAnimation
{
    [scheduler_ unscheduleAllSelectorsForTarget:self];
    [scheduler_ scheduleSelector:@selector(handleScheduleUpdate:) forTarget:self interval:_frameRate/1000 paused:NO];
}

-(void) createCharacterFromXML:(NSString *)xmlfile onCharacterComplete:(void(^)())completeHandler
{
    _onComplete = [completeHandler copy];
    return [self createCharacterFromXML:xmlfile];
}

-(void) setFirstPose
{
    if ([self.delegate respondsToSelector:@selector(onCharacterCreated:)])
        [self.delegate onCharacterCreated:self];
    
    if (_onComplete)
        _onComplete();
}

- (ccColor3B) color {
    return _childrenTableColor;
}

- (void) setColor:(ccColor3B)color3
{
    _childrenTableColor = color3;
    
    for (NSString *key in self.childrenTable)
    {    
        CCNode *child = [self.childrenTable objectForKey:key];
        
        if ([child isKindOfClass:[CCSprite class]])
            ((CCSprite*)child).color = color3;
    }
}

@end

//
//  FTCAnimEvent.m
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FTCAnimEvent.h"

@implementation FTCAnimEvent

@synthesize frameCount = _frameCount;
@synthesize eventsInfo = _eventsInfo;

- (NSMutableArray*) eventsInfo
{
    if (_eventsInfo == nil)
        _eventsInfo = [[NSMutableArray alloc] init];
    
    return _eventsInfo;
}

@end

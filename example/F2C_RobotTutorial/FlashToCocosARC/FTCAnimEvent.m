//
//  FTCAnimEvent.m
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FTCAnimEvent.h"

@implementation FTCAnimEvent
@synthesize eventsInfo, frameCount;




- (id)init
{
    self = [super init];
    if (self) {

        NSMutableArray *__eventsInfo = [[NSMutableArray alloc] init];
        [self setEventsInfo:__eventsInfo];  
        __eventsInfo = nil;
    }
    
    return self;
}

@end

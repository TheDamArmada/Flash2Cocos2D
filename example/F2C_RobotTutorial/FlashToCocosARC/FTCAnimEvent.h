//
//  FTCAnimEvent.h
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTCAnimEvent : NSObject

@property (unsafe_unretained) int  frameCount;
@property (strong) NSMutableArray *eventsInfo;
@end

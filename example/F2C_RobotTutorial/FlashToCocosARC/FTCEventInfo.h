//
//  FTCEventInfo.h
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTCEventInfo : NSObject

@property (unsafe_unretained) int      frameIndex;
@property (strong) NSString *eventType;
@end

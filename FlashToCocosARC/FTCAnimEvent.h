//
//  FTCAnimEvent.h
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTCAnimEvent : NSObject

@property (nonatomic, assign) int  frameCount;
@property (nonatomic, strong) NSMutableArray *eventsInfo;

@end

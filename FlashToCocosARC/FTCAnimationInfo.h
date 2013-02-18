//
//  FTCAnimationInfo.h
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTCAnimationInfo : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *partName;
@property (nonatomic, strong) NSArray *frameInfoArray;

@end

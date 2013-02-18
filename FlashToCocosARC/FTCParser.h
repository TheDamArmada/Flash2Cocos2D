//
//  FTCParser.h
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBXML.h"
#import "FTCFrameInfo.h"

@class FTCCharacter;

@interface FTCParser : NSObject

- (BOOL) characterExists:(NSString*)characterName atPath:(NSString*)path;
- (BOOL) parseXML:(NSString *)xmlfile toCharacter:(FTCCharacter *)character;
- (BOOL) parseXML:(NSString *)xmlfile withPath:(NSString*)path toCharacter:(FTCCharacter *)character;
- (BOOL) parseSheetXML:(NSString *)xmlfile toCharacter:(FTCCharacter *)character;
- (BOOL) parseSheetXML:(NSString *)xmlfile withPath:(NSString*)path toCharacter:(FTCCharacter *)character;
- (BOOL) parseAnimationXML:(NSString *)xmlfile toCharacter:(FTCCharacter *)character;
- (BOOL) parseAnimationXML:(NSString *)xmlfile withPath:(NSString*)path toCharacter:(FTCCharacter *)character;

@end

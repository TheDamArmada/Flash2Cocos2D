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
- (BOOL) parseXML:(NSString *)_xmlfile toCharacter:(FTCCharacter *)_character;
- (BOOL) parseXML:(NSString *)_xmlfile withPath:(NSString*)_path toCharacter:(FTCCharacter *)_character;
- (BOOL) parseSheetXML:(NSString *)_xmlfile toCharacter:(FTCCharacter *)_character;
- (BOOL) parseSheetXML:(NSString *)_xmlfile withPath:(NSString*)_path toCharacter:(FTCCharacter *)_character;
- (BOOL) parseAnimationXML:(NSString *)_xmlfile toCharacter:(FTCCharacter *)_character;
- (BOOL) parseAnimationXML:(NSString *)_xmlfile withPath:(NSString*)_path toCharacter:(FTCCharacter *)_character;

@end

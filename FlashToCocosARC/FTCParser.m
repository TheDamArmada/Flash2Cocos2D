//
//  FTCParser.m
//  FlashToCocos
//
//  Created by Jordi.Martinez on 9/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FTCParser.h"
#import "FTCCharacter.h"
#import "FTCSprite.h"
#import "FTCFrameInfo.h"
#import "FTCAnimEvent.h"
#import "FTCEventInfo.h"

@implementation FTCParser

static NSString* extensionSheets = @"_sheets.xml";
static NSString* extensionAnimations = @"_animations.xml";
static NSString* pathEmpty = @"";

# pragma mark - public

-(BOOL) characterExists:(NSString*)characterName atPath:(NSString*)path
{
    NSString *fileNameSheets = [characterName stringByAppendingString:extensionSheets];
    NSString *fileNameAnimations = [characterName stringByAppendingString:extensionAnimations];
    
    if ([self isValid:characterName fileName:fileNameSheets atPath:path] && [self isValid:characterName fileName:fileNameAnimations atPath:path])
        return YES;
    
    return NO;
}

-(BOOL) isValid:(NSString*)characterName fileName:(NSString*)file atPath:(NSString*)path
{
    NSString *fullPath = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:[path stringByAppendingPathComponent:file]];
    return ![fullPath isEqualToString:file];
}

-(BOOL) parseXML:(NSString *)xmlfile toCharacter:(FTCCharacter *)character
{
    return [self parseXML:xmlfile withPath:pathEmpty toCharacter:character];
}

- (BOOL) parseXML:(NSString *)xmlfile withPath:(NSString*)path toCharacter:(FTCCharacter *)character
{
    // sheets file
    BOOL sheetParse = [self parseSheetXML:xmlfile withPath:path toCharacter:character];
    
    // animations file
    BOOL animParse  = [self parseAnimationXML:xmlfile withPath:path toCharacter:character];
    
    [character setFirstPose];
    
    return (sheetParse && animParse);
}

# pragma mark - *_sheets.xml.  public.

-(BOOL) parseSheetXML:(NSString *)xmlfile toCharacter:(FTCCharacter *)character
{
    return [self parseSheetXML:pathEmpty toCharacter:character];
}

- (BOOL) parseSheetXML:(NSString *)xmlfile withPath:(NSString*)path toCharacter:(FTCCharacter *)character
{
    NSString *baseFile = [xmlfile stringByAppendingString:extensionSheets];
    
    NSError *error = nil;
    TBXML *xmlMaster = [TBXML newTBXMLWithXMLFile:[path stringByAppendingPathComponent: baseFile] error:&error];
    
    TBXMLElement *root = xmlMaster.rootXMLElement;
    if (!root)
        return NO;
    
    TBXMLElement *textureSheet = [TBXML childElementNamed:@"TextureSheet" parentElement:root];
    
    // TODO: test & fix for Sprite Sheet loading & parsing
    // check if there's a spritesheet for it
    BOOL hasSpriteSheet = [self spriteSheetExists:textureSheet];
    
    TBXMLElement *texture = [TBXML childElementNamed:@"Texture" parentElement:textureSheet];
    while (texture)
    {
        BOOL parseOk = [self parseTexture:texture hasSpriteSheet:hasSpriteSheet withPath:path toCharacter:character];
        if (!parseOk)
            return NO;
        
        texture = [TBXML nextSiblingNamed:@"Texture" searchFromElement:texture];
    }
    
    return YES;
}

# pragma mark - *_sheets.xml.  private.

- (BOOL) spriteSheetExists:(TBXMLElement*)textureSheet
{
    NSString *spriteSheetName = [NSString stringWithFormat:@"%@.plist", [TBXML valueOfAttributeNamed:@"name" forElement:textureSheet]];
    
    NSString *pathAndSpriteSheetName = [[NSBundle mainBundle] pathForResource:spriteSheetName ofType:nil];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathAndSpriteSheetName])
    {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:spriteSheetName];//TODO: add any path what was passed in
        return YES;
    }

    return NO;
}

- (BOOL) parseTexture:(TBXMLElement *)texture hasSpriteSheet:(BOOL)spriteSheetExists withPath:(NSString*)path toCharacter:(FTCCharacter *)character
{
    NSString *nName = [TBXML valueOfAttributeNamed:@"name" forElement:texture];
    
    NSRange ghostNameRange = [nName rangeOfString:@"ftcghost"];
    if (ghostNameRange.location != NSNotFound)
        return YES;
    
    float nAX           = [[TBXML valueOfAttributeNamed:@"registrationPointX" forElement:texture] floatValue];
    float nAY           = -([[TBXML valueOfAttributeNamed:@"registrationPointY" forElement:texture] floatValue]); // flash & cocos2d have inverted Y axis
    NSString *nImage    = [TBXML valueOfAttributeNamed:@"path" forElement:texture];
    int     zIndex      = [[TBXML valueOfAttributeNamed:@"zIndex" forElement:texture] intValue];
    
    FTCSprite *sprite = nil;
    NSString *relativePath = [path stringByAppendingPathComponent:nImage];
    NSString *fullImagePath = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:relativePath];
    
    if (spriteSheetExists) 
        sprite = [FTCSprite spriteWithSpriteFrameName:fullImagePath];
    else 
        sprite = [FTCSprite spriteWithFile:fullImagePath];
    
    if (!sprite)
    {
        NSLog(@"FTCParser unable to load sprite at location: %@", fullImagePath);
        return NO;
    }
    
    // SET ANCHOR P
    CGSize eSize = [sprite boundingBox].size;
    CGPoint aP = CGPointMake(nAX/eSize.width, (eSize.height - (-nAY))/eSize.height);
    [sprite setAnchorPoint:aP];
    
    [character addElement:sprite withName:nName atIndex:zIndex];
    
    return YES;
}

# pragma mark - *_animations.xml.  public.

- (BOOL)parseAnimationXML:(NSString *)xmlfile withPath:(NSString*)path toCharacter:(FTCCharacter *)character {
    
    return [self parseAnimationXML:[path stringByAppendingPathComponent: xmlfile] toCharacter:character];
}

-(BOOL) parseAnimationXML:(NSString *)xmlfile toCharacter:(FTCCharacter *)character
{
    NSString *baseFile = [xmlfile stringByAppendingString:extensionAnimations];
    
    NSError *error = nil;
    TBXML *xmlMaster = [TBXML newTBXMLWithXMLFile:baseFile error:&error];
    
    TBXMLElement *root = xmlMaster.rootXMLElement;
    if (!root)
        return NO;
    
    character.frameRate = [[TBXML valueOfAttributeNamed:@"frameRate" forElement:root] floatValue];
    
    // set the character animation (it will be filled with events)
    TBXMLElement *animation = [TBXML childElementNamed:@"Animation" parentElement:root];
    while (animation)
    {
        BOOL parseOk = [self parseAnimation:animation toCharacter:character];
        if (!parseOk)
            return NO;
        
        animation = [TBXML nextSiblingNamed:@"Animation" searchFromElement:animation];
    }
    
    return YES;
}

# pragma mark - *_animations.xml.  private.

-(BOOL) parseAnimation:(TBXMLElement*) animation toCharacter:(FTCCharacter *)character
{
    NSString *animName = [TBXML valueOfAttributeNamed:@"name" forElement:animation];
    if ([animName isEqualToString:@""])
        animName = @"_init";
    
    TBXMLElement *part = [TBXML childElementNamed:@"Part" parentElement:animation];
    while(part)
    {
        BOOL parseOk = [self parsePart:part withAnimationName:animName toCharacter:character];
        if (!parseOk)
            return NO;
        
        part = [TBXML nextSiblingNamed:@"Part" searchFromElement:part];
    }
    
    // Process Events if needed
    int animationLength = [[TBXML valueOfAttributeNamed:@"frameCount" forElement:animation] intValue];
    
    NSMutableArray  *eventsArr = [[NSMutableArray alloc] initWithCapacity:animationLength];
    for (int ea=0; ea<animationLength; ea++)
        [eventsArr addObject:[NSNull null]];
    
    TBXMLElement *eventXML = [TBXML childElementNamed:@"Marker" parentElement:animation];
    
    while (eventXML)
    {
        NSString *eventType = [TBXML valueOfAttributeNamed:@"name" forElement:eventXML];
        int     frameIndex   = [[TBXML valueOfAttributeNamed:@"frame" forElement:eventXML] intValue];
        
        FTCEventInfo *eventInfo = [[FTCEventInfo alloc] init];
        [eventInfo setFrameIndex:frameIndex];
        [eventInfo setEventType:eventType];
        
        [eventsArr insertObject:eventInfo atIndex:frameIndex];
        
        eventXML = [TBXML nextSiblingNamed:@"Marker" searchFromElement:eventXML];
    }
    
    FTCAnimEvent *eventInfo = [[FTCAnimEvent alloc] init];
    [eventInfo setFrameCount:animationLength];
    [eventInfo setEventsInfo:eventsArr];
    
    [character.animationEventsTable setValue:eventInfo forKey:animName];
    
    eventsArr = nil;
    eventInfo = nil;
    
    return YES;
}

-(BOOL) parsePart:(TBXMLElement*) part withAnimationName:(NSString*)animName toCharacter:(FTCCharacter *)character
{
    NSString *partName = [TBXML valueOfAttributeNamed:@"name" forElement:part];
    
    NSRange ghostNameRange = [partName rangeOfString:@"ftcghost"];
    if (ghostNameRange.location != NSNotFound)
        return YES;
    
    NSMutableArray *partFrames = [[NSMutableArray alloc] init];
    
    TBXMLElement *frameInfo = [TBXML childElementNamed:@"Frame" parentElement:part];
    
    while (frameInfo)
    {
        FTCFrameInfo *fi = [[FTCFrameInfo alloc] init];
        
        BOOL parseOk = [self parseFrame:frameInfo toDTO:fi];
        if (!parseOk)
            return NO;
        
        [partFrames addObject:fi];
        
        frameInfo = [TBXML nextSiblingNamed:@"Frame" searchFromElement:frameInfo];
    }
    
    FTCSprite *sprite = [character getChildByName:partName];
    [sprite.animationsArr setValue:partFrames forKey:animName];
    
    return YES;
}

-(BOOL) parseFrame:(TBXMLElement*)frameInfo toDTO:(FTCFrameInfo*)fi
{
    NSError *requiredParamMissing = nil;
    fi.index = [[TBXML valueOfAttributeNamed:@"index" forElement:frameInfo error:&requiredParamMissing] intValue];
    if (requiredParamMissing != nil)
        return NO;
    
    NSString *xPosition = [TBXML valueOfAttributeNamed:@"x" forElement:frameInfo];
    if (xPosition.length)
        fi.x = xPosition.floatValue;
    
    NSString *yPosition = [TBXML valueOfAttributeNamed:@"y" forElement:frameInfo];
    if (yPosition.length)
        fi.y = -yPosition.floatValue;
    
    NSString *scaleX = [TBXML valueOfAttributeNamed:@"scaleX" forElement:frameInfo];
    if (scaleX.length)
        fi.scaleX = scaleX.floatValue;
    
    NSString *scaleY = [TBXML valueOfAttributeNamed:@"scaleY" forElement:frameInfo];
    if (scaleY.length)
        fi.scaleY = scaleY.floatValue;
    
    NSString *rotation = [TBXML valueOfAttributeNamed:@"rotation" forElement:frameInfo];
    if (rotation.length)
        fi.rotation = rotation.floatValue;
    
    NSError *noAlpha = nil;
    NSString *alpha = [TBXML valueOfAttributeNamed:@"alpha" forElement:frameInfo error:&noAlpha];
    fi.alpha = (noAlpha == nil) ? alpha.floatValue : 1.0f;
    
    return YES;
}

@end

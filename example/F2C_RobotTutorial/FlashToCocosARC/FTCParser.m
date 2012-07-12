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


-(BOOL) parseXML:(NSString *)_xmlfile toCharacter:(FTCCharacter *)_character
{
    
    // sheets file
   
    BOOL sheetParse = [self parseSheetXML:_xmlfile toCharacter:_character];
    
//    [_character reorderChildren];
    
    // animations file
    
    BOOL animParse  = [self parseAnimationXML:_xmlfile toCharacter:_character];
    
    [_character setFirstPose];
    
    
    
    return (sheetParse && animParse);
}


-(BOOL) parseSheetXML:(NSString *)_xmlfile toCharacter:(FTCCharacter *)_character
{
    NSString *baseFile = [NSString stringWithFormat:@"%@_sheets.xml", _xmlfile];
    
    NSError *error = nil;
    TBXML *_xmlMaster = [TBXML tbxmlWithXMLFile:baseFile error:&error];
    
    
    
    // root
    
    TBXMLElement *_root = _xmlMaster.rootXMLElement;
    

    if (!_root) return NO;
    
    
    TBXMLElement *_texturesheet = [TBXML childElementNamed:@"TextureSheet" parentElement:_root];
    
    
    // check if there's a spritesheet for it
    NSString *_textureSheetName = [NSString stringWithFormat:@"%@.plist", [TBXML valueOfAttributeNamed:@"name" forElement:_texturesheet]];
    NSString *pathAndFileName = [[NSBundle mainBundle] pathForResource:_textureSheetName ofType:nil];
    BOOL      textureSheetExists = [[NSFileManager defaultManager] fileExistsAtPath:pathAndFileName];
    
    if (textureSheetExists) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:_textureSheetName];
    }
    
    TBXMLElement *_texture = [TBXML childElementNamed:@"Texture" parentElement:_texturesheet];
    
    do {
        NSString *nName     = [TBXML valueOfAttributeNamed:@"name" forElement:_texture];
        
        
        NSRange NghostNameRange;
        
        
        NghostNameRange = [nName rangeOfString:@"ftcghost"];
        
        
        if (NghostNameRange.location != NSNotFound) continue;
        
        
        
        float nAX           = [[TBXML valueOfAttributeNamed:@"registrationPointX" forElement:_texture] floatValue];
        float nAY           = [[TBXML valueOfAttributeNamed:@"registrationPointY" forElement:_texture] floatValue] * -1;
        NSString *nImage    = [TBXML valueOfAttributeNamed:@"path" forElement:_texture];
        int     zIndex      = [[TBXML valueOfAttributeNamed:@"zIndex" forElement:_texture] intValue];
        
        // no support for sprite sheets yet
        FTCSprite *_sprite = nil;
        
        if (textureSheetExists)
            _sprite = [FTCSprite spriteWithSpriteFrameName:nImage];
        else 
            _sprite = [FTCSprite spriteWithFile:nImage];
        
        // SET ANCHOR P
        CGSize eSize = [_sprite boundingBox].size;
        CGPoint aP = CGPointMake(nAX/eSize.width, (eSize.height - (-nAY))/eSize.height);        
        
        [_sprite setAnchorPoint:aP];      
        
        [_character addElement:_sprite withName:nName atIndex:zIndex];   
        
    } while ((_texture = _texture->nextSibling));
    
    return YES;

}




-(BOOL) parseAnimationXML:(NSString *)_xmlfile toCharacter:(FTCCharacter *)_character
{

    NSString *baseFile = [NSString stringWithFormat:@"%@_animations.xml", _xmlfile];
    

    
    NSError *error = nil;    
    TBXML *_xmlMaster = [TBXML tbxmlWithXMLFile:baseFile error:&error];
    
    
    TBXMLElement *_root = _xmlMaster.rootXMLElement;

    
    if (!_root) return NO;
    
    
    TBXMLElement *_animation = [TBXML childElementNamed:@"Animation" parentElement:_root];
    
    // set the character animation (it will be filled with events)
    

        
    do {        
        
        NSString *animName = [TBXML valueOfAttributeNamed:@"name" forElement:_animation];
        if ([animName isEqualToString:@""]) animName = @"_init";
        
              
        
        
        TBXMLElement *_part = [TBXML childElementNamed:@"Part" parentElement:_animation];
        
               
        do {
        
            NSString *partName = [TBXML valueOfAttributeNamed:@"name" forElement:_part];
            
            NSRange ghostNameRange;
            
            
            ghostNameRange = [partName rangeOfString:@"ftcghost"];
            
            
            if (ghostNameRange.location != NSNotFound) continue;
            
                 
            NSMutableArray *__partFrames = [[NSMutableArray alloc] init];
            
            TBXMLElement *_frameInfo = [TBXML childElementNamed:@"Frame" parentElement:_part];

            FTCSprite *__sprite = [_character getChildByName:partName];

            if (_frameInfo) {
                do {
                    
                    FTCFrameInfo *fi = [FTCFrameInfo alloc];
                    

                    fi.index = [[TBXML valueOfAttributeNamed:@"index" forElement:_frameInfo] intValue];
                    
                    fi.x = [[TBXML valueOfAttributeNamed:@"x" forElement:_frameInfo] floatValue];
                    fi.y = [[TBXML valueOfAttributeNamed:@"y" forElement:_frameInfo] floatValue] * -1;
                    
                    
                    
                    fi.scaleX = [[TBXML valueOfAttributeNamed:@"scaleX" forElement:_frameInfo] floatValue];                
                    fi.scaleY = [[TBXML valueOfAttributeNamed:@"scaleY" forElement:_frameInfo] floatValue];
                    
                    fi.rotation = [[TBXML valueOfAttributeNamed:@"rotation" forElement:_frameInfo] floatValue];
                    
                    [__partFrames addObject:fi];
                    

                    
                } while ((_frameInfo = _frameInfo->nextSibling));
            }
            
            [__sprite.animationsArr setValue:__partFrames forKey:animName];         
            
        } while ((_part = _part->nextSibling));
        
        
        // Process Events if needed
        int _animationLength = [[TBXML valueOfAttributeNamed:@"frameCount" forElement:_animation] intValue];
        
        
        
        NSMutableArray  *__eventsArr = [[NSMutableArray alloc] initWithCapacity:_animationLength];
        for (int ea=0; ea<_animationLength; ea++) { [__eventsArr addObject:[NSNull null]];};
        
            
        TBXMLElement *_eventXML = [TBXML childElementNamed:@"Marker" parentElement:_animation];
        
        
        if (_eventXML) {
            do {
                
                NSString *eventType = [TBXML valueOfAttributeNamed:@"name" forElement:_eventXML];
                int     frameIndex   = [[TBXML valueOfAttributeNamed:@"frame" forElement:_eventXML] intValue];

                FTCEventInfo *_eventInfo = [[FTCEventInfo alloc] init];
                [_eventInfo setFrameIndex:frameIndex];
                [_eventInfo setEventType:eventType];
                
                [__eventsArr insertObject:_eventInfo atIndex:frameIndex];
                
            } while ((_eventXML = [TBXML nextSiblingNamed:@"Marker" searchFromElement:_eventXML]));                                  
        }
        
        FTCAnimEvent *__eventInfo = [[FTCAnimEvent alloc] init];
        [__eventInfo setFrameCount:_animationLength];            
        [__eventInfo setEventsInfo:__eventsArr];
        
        [_character.animationEventsTable setValue:__eventInfo forKey:animName];
        

        __eventsArr = nil;
        __eventInfo = nil;


    } while ((_animation = _animation->nextSibling));

    
    
   
    return YES;
}


@end

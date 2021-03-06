//
//  NSMutableAttributedString+HTMLText.m
//  GPLib
//
//  Created by Dalton Cherry on 12/2/11.
//  Copyright (c) 2011 Basement Crew/180 Dev Designs. All rights reserved.
//
/*
 http://github.com/daltoniam/GPLib-iOS
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 */
//

#import "HTMLText.h"
#import "HTMLColors.h"
#import "HTMLElements.h"

@implementation NSMutableAttributedString (HTMLText)

static NSString* DEFAULT_FONT = @"TrebuchetMS";
void deallocationCallback( void* refCon );
CGFloat getAscentCallback( void *refCon );
CGFloat getDescentCallback( void *refCon );
CGFloat getWidthCallback( void* refCon );

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//public factory to create a string with a space
+(NSMutableAttributedString*)spaceString:(NSString*)attrName value:(id)value height:(float)h width:(float)w
{
    NSMutableAttributedString* string = [[[NSMutableAttributedString alloc] initWithString:@" "] autorelease];
    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.dealloc = deallocationCallback;
    callbacks.getAscent = getAscentCallback;
    callbacks.getDescent = getDescentCallback;
    callbacks.getWidth = getWidthCallback;
    NSString* height = [NSString stringWithFormat:@"%f",h];
    NSString* width = [NSString stringWithFormat:@"%f",w];
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, [[NSDictionary dictionaryWithObjectsAndKeys:height,@"height",width,@"width", nil] retain]);
    [string removeAttribute:(NSString*)kCTRunDelegateAttributeName range:NSMakeRange(0, string.length)]; // remove then add for apple leak.
    [string addAttribute:(NSString*)kCTRunDelegateAttributeName value:(id)delegate range:NSMakeRange(0, string.length)];
    
    [string removeAttribute:@"width" range:NSMakeRange(0, string.length)]; // remove then add for apple leak.
    [string addAttribute:@"width" value:width range:NSMakeRange(0, string.length)];
    
    [string removeAttribute:@"height" range:NSMakeRange(0, string.length)]; // remove then add for apple leak.
    [string addAttribute:@"height" value:height range:NSMakeRange(0, string.length)];
    
    if(attrName && value)
    {
        [string removeAttribute:attrName range:NSMakeRange(0, string.length)]; // remove then add for apple leak.
        [string addAttribute:attrName value:value range:NSMakeRange(0, string.length)];
    }
    
    CFRelease(delegate);
    return string;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//set font.
-(void)setFont:(UIFont*)font 
{
	[self setFontName:font.fontName size:font.pointSize];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//set font with range
-(void)setFont:(UIFont*)font range:(NSRange)range 
{
	[self setFontName:font.fontName size:font.pointSize range:range];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//set font with size.
-(void)setFontName:(NSString*)fontName size:(CGFloat)size 
{
	[self setFontName:fontName size:size range:NSMakeRange(0,[self length])];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//set font name with size and range, logic for other font setting
-(void)setFontName:(NSString*)fontName size:(CGFloat)size range:(NSRange)range 
{
	CTFontRef font = CTFontCreateWithName((CFStringRef)fontName, size, NULL);
	if (!font) return;
	[self removeAttribute:(NSString*)kCTFontAttributeName range:range]; // remove then add for apple leak.
	[self addAttribute:(NSString*)kCTFontAttributeName value:(id)font range:range];
	CFRelease(font);
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//set Text color
-(void)setTextColor:(UIColor*)color 
{
	[self setTextColor:color range:NSMakeRange(0,[self length])];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//set text color with a range
-(void)setTextColor:(UIColor*)color range:(NSRange)range 
{
	[self removeAttribute:(NSString*)kCTForegroundColorAttributeName range:range]; // remove then add for apple leak.
	[self addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)color.CGColor range:range];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//set text underlined
-(void)setTextIsUnderlined:(BOOL)underlined 
{
	[self setTextIsUnderlined:underlined range:NSMakeRange(0,[self length])];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//set text underlined with a range.
-(void)setTextIsUnderlined:(BOOL)underlined range:(NSRange)range 
{
	int32_t style = underlined ? (kCTUnderlineStyleSingle|kCTUnderlinePatternSolid) : kCTUnderlineStyleNone;
    [self removeAttribute:(NSString*)kCTUnderlineStyleAttributeName range:range]; // Work around for Apple leak
	[self addAttribute:(NSString*)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:style] range:range];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//set if text bold
-(void)setTextBold:(BOOL)isBold
{
    [self setTextBold:isBold range:NSMakeRange(0,[self length])];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//set text strikeout with a range.
-(void)setTextStrikeOut:(BOOL)strikeout range:(NSRange)range 
{
    [self removeAttribute:STRIKE_OUT range:range]; // Work around for Apple leak
	[self addAttribute:STRIKE_OUT value:[NSNumber numberWithBool:strikeout] range:range];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//set if text strikeout
-(void)setTextStrikeOut:(BOOL)isStrikeOut
{
    [self setTextStrikeOut:isStrikeOut range:NSMakeRange(0,[self length])];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//set if text hyperlink
-(void)setTextIsHyperLink:(NSString*)hyperlink range:(NSRange)range
{
    [self removeAttribute:HYPER_LINK range:range]; // Work around for Apple leak
	[self addAttribute:HYPER_LINK value:hyperlink range:range];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//set if text a hyperlink
-(void)setTextIsHyperLink:(NSString*)hyperlink
{
    [self setTextIsHyperLink:hyperlink range:NSMakeRange(0,[self length])];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//set if text is bold with a range
-(void)setTextBold:(BOOL)isBold range:(NSRange)range 
{
	NSUInteger startPoint = range.location;
	NSRange effectiveRange;
	do {
		// Get font at startPoint
		CTFontRef currentFont = (CTFontRef)[self attribute:(NSString*)kCTFontAttributeName atIndex:startPoint effectiveRange:&effectiveRange];
		// The range for which this font is effective
		NSRange fontRange = NSIntersectionRange(range, effectiveRange);
		// Create bold/unbold font variant for this font and apply
		CTFontRef newFont = CTFontCreateCopyWithSymbolicTraits(currentFont, 0.0, NULL, (isBold?kCTFontBoldTrait:0), kCTFontBoldTrait);
		if (newFont) 
        {
			[self removeAttribute:(NSString*)kCTFontAttributeName range:fontRange]; // Work around for Apple leak
			[self addAttribute:(NSString*)kCTFontAttributeName value:(id)newFont range:fontRange];
			CFRelease(newFont);
		} 
        else 
        {
            if(isBold)
            {
                NSString* fontName = [(NSString*)CTFontCopyFullName(currentFont) autorelease];
                NSLog(@"[HTML String]: can't find a bold font variant for font %@. Try another font family instead.",fontName);
            }

		}
        
		// If the fontRange was not covering the whole range, continue with next run
		startPoint = NSMaxRange(effectiveRange);
	} while(startPoint<NSMaxRange(range));
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//set if text bold
-(void)setTextItalic:(BOOL)isItalic
{
    [self setTextItalic:isItalic range:NSMakeRange(0,[self length])];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//set if text is italic with a range
-(void)setTextItalic:(BOOL)isItalic range:(NSRange)range
{
	NSUInteger startPoint = range.location;
	NSRange effectiveRange;
	do {
		// Get font at startPoint
		CTFontRef currentFont = (CTFontRef)[self attribute:(NSString*)kCTFontAttributeName atIndex:startPoint effectiveRange:&effectiveRange];
		// The range for which this font is effective
		NSRange fontRange = NSIntersectionRange(range, effectiveRange);
		// Create bold/unbold font variant for this font and apply
		CTFontRef newFont = CTFontCreateCopyWithSymbolicTraits(currentFont, 0.0, NULL, (isItalic?kCTFontItalicTrait:0), kCTFontItalicTrait);
		if (newFont) 
        {
			[self removeAttribute:(NSString*)kCTFontAttributeName range:fontRange]; // Work around for Apple leak
			[self addAttribute:(NSString*)kCTFontAttributeName value:(id)newFont range:fontRange];
			CFRelease(newFont);
		} 
        else 
        {
            if(isItalic)
            {
                NSString* fontName = [(NSString*)CTFontCopyFullName(currentFont) autorelease];
                NSLog(@"[HTML String]: can't find a Italic font variant for font %@. Try another font family instead.",fontName);
            }
		}
        
		// If the fontRange was not covering the whole range, continue with next run
		startPoint = NSMaxRange(effectiveRange);
	} while(startPoint<NSMaxRange(range));
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//set the text alignment.
-(void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode 
{
	[self setTextAlignment:alignment lineBreakMode:lineBreakMode range:NSMakeRange(0,[self length])];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//set the text alignment of the text with a range.
-(void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)linebreakmode range:(NSRange)range 
{
    
	CTParagraphStyleSetting parastyles[2] = {
		{.spec = kCTParagraphStyleSpecifierAlignment, .valueSize = sizeof(CTTextAlignment), .value = (const void*)&alignment},
		{.spec = kCTParagraphStyleSpecifierLineBreakMode, .valueSize = sizeof(CTLineBreakMode), .value = (const void*)&linebreakmode},};
    
	CTParagraphStyleRef style = CTParagraphStyleCreate(parastyles, 2);
	[self removeAttribute:(NSString*)kCTParagraphStyleAttributeName range:range];
	[self addAttribute:(NSString*)kCTParagraphStyleAttributeName value:(id)style range:range];
	CFRelease(style);
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setFontFamily:(NSString*)fontFamily size:(CGFloat)size bold:(BOOL)isBold italic:(BOOL)isItalic
{
    [self setFontFamily:fontFamily size:size bold:isBold italic:isItalic range:NSMakeRange(0,[self length])];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setFontFamily:(NSString*)fontFamily size:(CGFloat)size bold:(BOOL)isBold italic:(BOOL)isItalic range:(NSRange)range 
{
    if(!fontFamily)
        fontFamily = DEFAULT_FONT;
    CTFontSymbolicTraits symTrait = (isBold?kCTFontBoldTrait:0) | (isItalic?kCTFontItalicTrait:0);
    NSDictionary* trait = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:symTrait] forKey:(NSString*)kCTFontSymbolicTrait];
    NSDictionary* attr = [NSDictionary dictionaryWithObjectsAndKeys:
                          fontFamily,kCTFontFamilyNameAttribute,
                          trait,kCTFontTraitsAttribute,nil];
    
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((CFDictionaryRef)attr);
    if (!desc) return;
    CTFontRef aFont = CTFontCreateWithFontDescriptor(desc, size, NULL);
    CFRelease(desc);
    if (!aFont) return;
    
    [self removeAttribute:(NSString*)kCTFontAttributeName range:range]; // remove then add for apple leak.
    [self addAttribute:(NSString*)kCTFontAttributeName value:(id)aFont range:range];
    CFRelease(aFont);
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addRunDelegate:(NSRange)range attribs:(NSDictionary*)attribs
{
    CTRunDelegateCallbacks callbacks;
    callbacks.version = kCTRunDelegateVersion1;
    callbacks.dealloc = deallocationCallback;
    callbacks.getAscent = getAscentCallback;
    callbacks.getDescent = getDescentCallback;
    callbacks.getWidth = getWidthCallback;
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, [attribs retain]);
    [self removeAttribute:(NSString*)kCTRunDelegateAttributeName range:range]; // remove then add for apple leak.
    [self addAttribute:(NSString*)kCTRunDelegateAttributeName value:(id)delegate range:range];
    CFRelease(delegate);
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setImageTag:(NSString*)imageURL attribs:(NSDictionary*)attribs
{
    [self setImageTag:imageURL range:NSMakeRange(0,[self length]) attribs:attribs];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setImageTag:(NSString*)imageURL range:(NSRange)range attribs:(NSDictionary*)attribs
{
    [self addRunDelegate:range attribs:attribs];
    [self removeAttribute:IMAGE_LINK range:range];
	[self addAttribute:IMAGE_LINK value:imageURL range:range];
    for(id key in attribs)
    {
        [self removeAttribute:(NSString*)key range:range]; // remove then add for apple leak.
        [self addAttribute:(NSString*)key value:[attribs objectForKey:key] range:range];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setYoutubeTag:(NSString*)videoURL attribs:(NSDictionary*)attribs
{
    [self setYoutubeTag:videoURL range:NSMakeRange(0,[self length]) attribs:attribs];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setYoutubeTag:(NSString*)videoURL range:(NSRange)range attribs:(NSDictionary*)attribs
{
    [self addRunDelegate:range attribs:attribs];
    [self removeAttribute:VIDEO_LINK range:range];
	[self addAttribute:VIDEO_LINK value:videoURL range:range];
    for(id key in attribs)
    {
        [self removeAttribute:(NSString*)key range:range]; // remove then add for apple leak.
        [self addAttribute:(NSString*)key value:[attribs objectForKey:key] range:range];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//delegates for rundelegate
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void deallocationCallback( void* ref )
{
    [(id)ref release];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//height of object
CGFloat getAscentCallback( void *ref )
{
    float height = [(NSString*)[(NSDictionary*)ref objectForKey:@"height"] floatValue];
    if(height > 0)
        return height;
    return 250;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat getDescentCallback( void *ref)
{
    return [(NSString*)[(NSDictionary*)ref objectForKey:@"descent"] floatValue];
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//width of object
CGFloat getWidthCallback( void* ref )
{
    float width = [(NSString*)[(NSDictionary*)ref objectForKey:@"width"] floatValue];
    if(width > 0)
        return width;
    return 200;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*)convertToHTML
{
    NSMutableString* html = [[[NSMutableString alloc] init] autorelease];
    NSRange validRange = NSMakeRange(0,[self length]);
    __block BOOL closeBold = NO;
    __block BOOL closeItalic = NO;
    __block NSString* closeSpan = nil;
    __block BOOL partag = YES;
    __block BOOL listtag = NO;
    __block BOOL listelement = NO;
    __block NSString* lastListType = nil;
    __block CTTextAlignment oldAlign = kCTLeftTextAlignment;
    [self enumerateAttributesInRange:validRange options:0 usingBlock:
     ^(NSDictionary *attributes, NSRange range, BOOL *stop) 
    {
        NSString* style = [self spanStyle:attributes];
        CTFontRef font = (CTFontRef)[attributes objectForKey:(NSString*)kCTFontAttributeName];
        CTFontSymbolicTraits traits = CTFontGetSymbolicTraits(font);
        BOOL isItalic = ((traits & kCTFontItalicTrait) == kCTFontItalicTrait);
        BOOL isBold = ((traits & kCTFontBoldTrait) == kCTFontBoldTrait);
        BOOL updateAlign = NO;
        CTParagraphStyleRef parastyles = (CTParagraphStyleRef)[attributes objectForKey:(NSString*)kCTParagraphStyleAttributeName];
        CTTextAlignment Alignment;
        CTParagraphStyleGetValueForSpecifier(parastyles,kCTParagraphStyleSpecifierAlignment,sizeof(CTTextAlignment),&Alignment);
        if(oldAlign != Alignment)
        {
            oldAlign = Alignment;
            updateAlign = YES;
        }
        BOOL closeList = NO;
        NSString* imageURL = [attributes objectForKey:IMAGE_LINK];
        NSString* videoURL = [attributes objectForKey:VIDEO_LINK];
        NSString* hyperLink = [attributes objectForKey:HYPER_LINK];
        NSString* listtype = [attributes objectForKey:HTML_LIST];
        BOOL closeListTag = [[attributes objectForKey:HTML_CLOSE_LIST] boolValue];
        if(listtag && !listtype && closeListTag)
            closeList = YES;
        if(listtype && !listtag)
        {
            lastListType = [listtype copy];
            listtag = YES;
            if([listtype isEqualToString:HTML_ORDER_LIST])
                [html appendString:@"<ol>"];
            else
                [html appendString:@"<ul>"];
        }
        
        //////////////////////////////////////////////////
        //build Dom.
        if(closeSpan && ![closeSpan isEqualToString:style])
        {
            closeSpan = nil;
            [html appendString:@"</span>"];
        }
        if(closeBold && !isBold)
        {
            closeBold = NO;
            [html appendString:@"</strong>"];
        }
        if(closeItalic && !isItalic)
        {
            closeItalic = NO;
            [html appendString:@"</em>"];
        }
        if(closeList && listtag)
            listtag = NO;

        if(listtag && !listelement)
        {
            [html appendString:@"<li>"];
            listelement = YES; //list element in progress
        }
        if(partag)
        {
            partag = NO;
            if(updateAlign)
            {
                NSString* align = @"left;";
                if(Alignment == kCTCenterTextAlignment)
                    align = @"center;";
                else if(Alignment == kCTRightTextAlignment)
                    align = @"right;";
                else if(Alignment == kCTJustifiedTextAlignment)
                    align = @"justify;";
                [html appendString:[NSString stringWithFormat:@"<p style=\" text-align: %@\">",align]];
            }
            else
                [html appendString:@"<p>"];
        }
        if(isItalic && !closeItalic)
        {
            closeItalic = YES;
            [html appendString:@"<em>"];
        }
        if(isBold && !closeBold)
        {
            closeBold = YES;
            [html appendString:@"<strong>"];
        }
        if(style && !closeSpan)
        {
            closeSpan = style;
            [html appendString:[NSString stringWithFormat:@"<span style=\"%@\">",style]];
        }
        if(imageURL)
        {
            float imgheight = [(NSString*)[attributes objectForKey:@"height"] floatValue];
            float imgwidth = [(NSString*)[(NSDictionary*)attributes objectForKey:@"width"] floatValue];
            //[html appendString:[NSString stringWithFormat:@"<img src=\"%@\" \\>",imageURL ]];
            [html appendString:[NSString stringWithFormat:@"<img src=\"%@\" height=\"%f\" width=\"%f\" \\>",imageURL,imgheight,imgwidth ]];
        }
        if(videoURL)
        {
            float vidheight = 306;//[(NSString*)[attributes objectForKey:@"height"] floatValue];
            float vidwidth = 500;//[(NSString*)[(NSDictionary*)attributes objectForKey:@"width"] floatValue];
            //[html appendString:[NSString stringWithFormat:@"<img src=\"%@\" \\>",imageURL ]];
            [html appendString:[NSString stringWithFormat:@"<object width=\"%f\" height=\"%f\"><param name=\"movie\" value=\"%@\" \\> <param name=\"allowFullScreen\" value=\"true\"><param name=\"allowscriptaccess\" value=\"always\" \\><param name=\"wmode\" value=\"transparent\"><embed src=\"%@\" type=\"application/x-shockwave-flash\" allowscriptaccess=\"always\" allowfullscreen=\"true\" wmode=\"transparent\" height=\"%f\" width=\"%f\" \\></object>",vidwidth,vidheight,videoURL,videoURL,vidheight,vidwidth ]];
        }
        if(hyperLink)
            [html appendString:[NSString stringWithFormat:@"<a href=\"%@\">",hyperLink ]];
            
        NSString* string = [[self mutableString ]substringWithRange:range];
        //string = [string stringByReplacingOccurrencesOfString:@"\n"  withString:@"<p>\r\n</p>"]; 
        string = [string stringByReplacingOccurrencesOfString:@"\n"  withString:@"<br />"];
        [html appendString:string];
        if(hyperLink)
            [html appendString:@"</a>"];
        
        NSString* parString = [[self mutableString ]substringWithRange:range];
        if(!partag && [parString characterAtIndex:parString.length-1] == '\n')
        {
            [html appendString:@"</p>"];
            partag = YES;
        }
        if(listelement && [parString characterAtIndex:parString.length-1] == '\n')
        {
            [html appendString:@"</li>"];
            listelement = NO;
        }
        if(closeList)
        {
            closeList = NO;
            if([lastListType isEqualToString:HTML_ORDER_LIST])
                [html appendString:@"</ol>"];
            else
                [html appendString:@"</ul>"];
        }
     }]; 
    if(closeBold)
         [html appendString:@"</strong>"];
    if(closeItalic)
        [html appendString:@"</em>"];
    if(closeSpan)
        [html appendString:@"</span>"];
    if(listelement)
    {
        [html appendString:@"</li>"];
        if([lastListType isEqualToString:HTML_ORDER_LIST])
            [html appendString:@"</ol>"];
        else
            [html appendString:@"</ul>"];
    }
    [html appendString:@"</p>"];
    //NSLog(@"html: %@",html);
    return html;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//create span style off text and passed in attributes. This is really a helper function for the convert to html function above.
-(NSString*)spanStyle:(NSDictionary*)attributes
{
    UIColor* textcolor = [UIColor colorWithCGColor:(CGColorRef)[attributes objectForKey:(NSString*)kCTForegroundColorAttributeName]];
    BOOL isUnder = NO;
    int32_t line = [[attributes objectForKey:(NSString*)kCTUnderlineStyleAttributeName] intValue]; 
    if(line == (kCTUnderlineStyleSingle|kCTUnderlinePatternSolid))
        isUnder = YES;
    BOOL strikeOut = [[attributes objectForKey:STRIKE_OUT] boolValue];
    CTFontRef font = (CTFontRef)[attributes objectForKey:(NSString*)kCTFontAttributeName];
    CGFloat size = CTFontGetSize(font);
    
    NSString* style = [NSString HTMLStyle:textcolor fontSize:size underline:isUnder strikethrough:strikeOut];
    style = [style stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([style isEqualToString:@""])
        return nil;
    return style;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*if (NSIntersectionRange(range, validRange).length)
{
    // work with attributes
}
else
{
    NSLog(@"Invalid Range returned by attribute enumeration: %@", NSStringFromRange(range));
}*/
@end

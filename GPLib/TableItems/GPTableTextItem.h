//
//  GPTableTextItem.h
//  GPLib
//
//  Created by Dalton Cherry on 12/6/11.
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

#import <Foundation/Foundation.h>

@interface GPTableTextItem : NSObject

@property(nonatomic,copy)NSString* text;
@property(nonatomic,copy)NSString* infoText;
@property(nonatomic,retain)UIFont* font;
@property(nonatomic,retain)UIColor* color;
@property(nonatomic,retain)UIColor* backgroundColor;
@property(nonatomic,assign)UITextAlignment TextAlignment;
@property(nonatomic,copy)NSString* NavURL;
@property(nonatomic,assign)BOOL isChecked;

//notification badge
@property(nonatomic,copy)NSString* notificationText;
@property(nonatomic,retain)UIColor* notificationTextColor;
@property(nonatomic,retain)UIColor* notificationFillColor;

//for things that are not going to be displayed but are needed in the tablecell
@property(nonatomic,retain)NSDictionary* Properties;

+ (GPTableTextItem*)itemWithText:(NSString*)string;
+ (GPTableTextItem*)itemWithText:(NSString*)string url:(NSString*)url;
+(GPTableTextItem*)itemWithText:(NSString*)string url:(NSString*)url properties:(NSDictionary*)props;
+ (GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor;
+(GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor font:(UIFont*)font;
+(GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor font:(UIFont*)font url:(NSString*)url;
+(GPTableTextItem*)itemWithText:(NSString*)string font:(UIFont*)font url:(NSString*)url properties:(NSDictionary*)props;
+(GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor font:(UIFont*)font url:(NSString*)url properties:(NSDictionary*)props;
+ (GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor alignment:(UITextAlignment)align;
+ (GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor alignment:(UITextAlignment)align url:(NSString*)url;
+ (GPTableTextItem*)itemWithText:(NSString*)string font:(UIFont*)font url:(NSString*)url;
+(GPTableTextItem*)itemWithText:(NSString*)string color:(UIColor*)textcolor background:(UIColor*)color url:(NSString*)url;
+ (GPTableTextItem*)itemWithText:(NSString*)string font:(UIFont*)font color:(UIColor*)textcolor alignment:(UITextAlignment)align url:(NSString*)url;
+ (GPTableTextItem*)itemWithText:(NSString*)string font:(UIFont*)font color:(UIColor*)textcolor alignment:(UITextAlignment)align url:(NSString*)url properties:(NSDictionary*)props;
+ (GPTableTextItem*)itemWithText:(NSString*)string font:(UIFont*)font color:(UIColor*)textcolor background:(UIColor*)color alignment:(UITextAlignment)align url:(NSString*)url properties:(NSDictionary*)props;

+ (GPTableTextItem*)itemWithText:(NSString*)string infoText:(NSString*)info url:(NSString*)url;

- (NSComparisonResult)compare:(GPTableTextItem*)otherObject;

@end

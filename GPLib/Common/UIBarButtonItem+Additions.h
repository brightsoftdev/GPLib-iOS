//
//  UIBarButtonItem+Additions.h
//  GPLib
//
//  Created by Dalton Cherry on 5/31/12.
//  Copyright (c) 2012 Basement Crew/180 Dev Designs. All rights reserved.
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

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Additions)

+(id)customBarButtonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector color:(UIColor*)color;
+(id)customBackButtonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector color:(UIColor*)color;
+(id)customBarButtonWithImage:(UIImage*)image target:(id)target selector:(SEL)selector color:(UIColor*)color;

//using iOS 5 apperance APIs to set color
+(id) customBarButtonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector;
+(id) customBackButtonWithTitle:(NSString *)title target:(id)target selector:(SEL)selector;
+(id)customBarButtonWithImage:(UIImage*)image target:(id)target selector:(SEL)selector;

+(id)customBarImage:(UIImage*)image target:(id)target selector:(SEL)selector;

@end

//
//  GPTableTextFieldItem.h
//  GPLib
//
//  Created by Dalton Cherry on 4/19/12.
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

#import "GPTableTextItem.h"

@class GPTableTextFieldCell;
@class GPTableTextFieldItem;
@protocol GPTableTextFieldItemDelegate <NSObject>

@optional
//notify that text has been entered
- (void)textDidUpdate:(NSString*)text object:(GPTableTextFieldItem*)item cell:(GPTableTextFieldCell*)cell;
- (void)returnKeyWasTapped:(UITextField*)field object:(GPTableTextFieldItem*)item cell:(GPTableTextFieldCell*)cell;
@end


@interface GPTableTextFieldItem : GPTableTextItem

@property(nonatomic,assign)NSInteger height;
@property(nonatomic,copy)NSString* placeHolder;
@property(nonatomic,assign)BOOL isSecure;
@property(nonatomic,assign)UIKeyboardType keyboardType;
@property(nonatomic,assign)UITextAutocapitalizationType autoCap;
@property(nonatomic,assign)UIReturnKeyType returnKey;
@property(nonatomic,assign)id<GPTableTextFieldItemDelegate>delegate;
@property(nonatomic,assign)BOOL disabled;

+ (GPTableTextFieldItem*)itemWithText:(NSString*)string placeHolder:(NSString*)holder height:(NSInteger)height;
+ (GPTableTextFieldItem*)itemWithText:(NSString*)string placeHolder:(NSString*)holder height:(NSInteger)height Properties:(NSDictionary*)props;
@end

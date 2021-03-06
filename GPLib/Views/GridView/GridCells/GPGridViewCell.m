//
//  GPGridViewCell.m
//  GPLib
//
//  Created by Dalton Cherry on 4/6/12.
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

#import "GPGridViewCell.h"
#import "GPGridViewItem.h"

#import "GPTableMoreItem.h"

#import "UIImage+Additions.h"
#import "GPDrawExtras.h"

@implementation GPGridViewCell

@synthesize rowIndex = rowIndex, columnIndex = columnIndex;
@synthesize imageView = imageView,identifier,delegate,textLabel = textLabel;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithIdentifer:(NSString*)indent
{
    if(self = [super init])
    {
        self.identifier = indent;
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupImageView
{
    UIView* view = [[[UIView alloc] init] autorelease];
    imageView = [[UIImageView alloc] init];
    //imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    //imageView.layer.shadowOffset = CGSizeMake(1, 2);
    //imageView.layer.shadowOpacity = 0.5;
    //imageView.layer.shadowRadius = 1.0;
    //imageView.layer.shouldRasterize = YES;
    //imageView.contentMode = UIViewContentModeScaleAspectFill;
    //imageView.contentMode =  UIViewContentModeScaleToFill; 
    //imageView.clipsToBounds = YES;
    [view addSubview:imageView];
    [self addSubview:view];
    [blankView removeFromSuperview];
    if(loadingLabel)
        [imageView addSubview:loadingLabel];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupTextLabel
{
    textLabel = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    textLabel.showsTouchWhenHighlighted = YES;
    textLabel.titleLabel.textAlignment = UITextAlignmentCenter;
    [textLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    textLabel.layer.shadowOffset = CGSizeMake(1, 1);
    textLabel.layer.shadowOpacity = 0.8;
    textLabel.layer.shadowRadius = 1.0;
    [textLabel addTarget:self action:@selector(labelTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:textLabel];
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupBlankView
{
    blankView = [[UIView alloc] init];
    //blankView.backgroundColor = [UIColor whiteColor];
    //blankView.layer.shadowColor = [UIColor blackColor].CGColor;
    //blankView.layer.shadowOffset = CGSizeMake(1, 2);
    //blankView.layer.shadowOpacity = 0.5;
    //blankView.layer.shadowRadius = 1.0;
    //blankView.layer.shouldRasterize = YES;
    [self addSubview:blankView];
    
    //HUGE_VALF
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setViewShadow
{
    UIView* view = imageView;
    if(!view)
        view = blankView;
    CGSize size = CGSizeMake(1, 2);
    view.backgroundColor = [UIColor whiteColor];
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = size;
    view.layer.shadowOpacity = 0.5;
    view.layer.shadowRadius = 1.0;
    view.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, view.frame.size.width+size.width, view.frame.size.height+size.height)].CGPath;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)layoutSubviews
{
    [super layoutSubviews];
    if(textLabel && imageView)
    {
        int height = self.frame.size.height-30;
        int top = 0;
        imageView.superview.frame = CGRectMake(0, top, self.frame.size.width+1, height+1);
        imageView.frame = CGRectMake(1, 1, self.frame.size.width, height);
    //CGSize imageSize = [self imageScale:self.frame.size.height];
        //imageView.frame = CGRectMake(0, top, imageSize.width, imageSize.height);
        //NSLog(@"self.frame.size.width: %f",self.frame.size.width);
        //NSLog(@"height: %f",height);
        top += imageView.frame.size.height;
        self.textLabel.frame = CGRectMake(0, top+10, self.frame.size.width, 20);
    }
    else if(textLabel)
    {
        if(!blankView)
            [self setupBlankView];
        blankView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height-30);
        int top = blankView.frame.size.height;
        self.textLabel.frame = CGRectMake(0, top+10, self.frame.size.width, 20);
    }
    else
    {
        imageView.superview.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        imageView.frame = CGRectMake(1, 1, self.frame.size.width-1, self.frame.size.height-1);
    }
    if(!touchLayer && imageView)
    {
        touchLayer = [[CAGradientLayer layer] retain];
        [imageView.layer insertSublayer:touchLayer atIndex:0];
    }
    if(!touchLayer && blankView)
    {
        touchLayer = [[CAGradientLayer layer] retain];
        [blankView.layer insertSublayer:touchLayer atIndex:0];
    }
    if(touchLayer)
    {
        UIView* valid = imageView;
        if(!valid)
            valid = blankView;
        //touchLayer.bounds = [self convertRect:displayView.bounds fromView:self];
        int y = self.frame.origin.y + valid.frame.origin.y;
        int x = self.frame.origin.x + valid.frame.origin.x;
        CGPoint point = CGPointMake(valid.bounds.size.width/2, valid.bounds.size.height/2);
        touchLayer.bounds = CGRectMake(x,y, valid.frame.size.width, valid.frame.size.height);
        touchLayer.position =point;
        //imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    }
    if(drawShadow)
        [self setViewShadow];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(CGRect)rect
{
    [super drawRect: rect];

    if(touchLayer && isSelected)
        [touchLayer setColors:[NSArray arrayWithObjects: (id)[[UIColor colorWithWhite:0 alpha:0.2] CGColor],(id)[[UIColor colorWithWhite:0 alpha:0.2] CGColor], nil]];
    else if(touchLayer)
        [touchLayer setColors:[NSArray arrayWithObjects: (id)[[UIColor colorWithWhite:0 alpha:0.0] CGColor],(id)[[UIColor colorWithWhite:0 alpha:0.0] CGColor], nil]];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    isSelected = YES;
    [self setNeedsDisplay];
    [super touchesBegan:touches withEvent:event];
    /*CGPoint pt = [[touches anyObject] locationInView:self];
     pt = [textLabel convertPoint:pt fromView:self];
     if([textLabel pointInside:pt withEvent:event])
     return;*/
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    isSelected = NO;
    [self setNeedsDisplay];
    [super touchesMoved:touches withEvent:event];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(isSelected)
    {
        if([self.delegate respondsToSelector:@selector(gridCellWasSelected:)])
            [self.delegate gridCellWasSelected:self];
    }
    isSelected = NO;
    [self setNeedsDisplay];
    [super touchesEnded:touches withEvent:event];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    isSelected = NO;
    [self setNeedsDisplay];
    [super touchesMoved:touches withEvent:event];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)labelTapped
{
    if([self.delegate respondsToSelector:@selector(gridTextLabelWasSelected:cell:)])
        [self.delegate gridTextLabelWasSelected:textLabel cell:self];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)isLoadingState:(BOOL)state
{
    if(state)
    {
        if(!loadingLabel)
        {
            UIView* view = [self expandView];
            loadingLabel = [[GPLoadingLabel alloc] initWithStyle:GPLoadingLabelBlackStyle];
            //loadingLabel.text = @"Loading...";
            loadingLabel.frame = view.frame;
            [view addSubview:loadingLabel];
        }
        loadingLabel.hidden = NO;
    }
    else
        loadingLabel.hidden = YES;
    isSelected = state;
    [self setNeedsDisplay];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setObject:(id)object
{
    if([object isKindOfClass:[GPTableMoreItem class]])
    {
        GPTableMoreItem* item = (GPTableMoreItem*)object;
        textLabel.titleLabel.font = item.font;
        [textLabel setTitleColor:item.color forState:UIControlStateNormal];
        if(item.text)
        {
            if(!textLabel)
                [self setupTextLabel];
            [textLabel setTitle:item.text forState:UIControlStateNormal];
        }
    }
    else
    {
        GPGridViewItem* item = (GPGridViewItem*)object;
        if(item.text)
        {
            if(!textLabel)
                [self setupTextLabel];
            [textLabel setTitle:item.text forState:UIControlStateNormal];
        }
        textLabel.titleLabel.font = item.font;
        if(item.color)
            [textLabel setTitleColor:item.color forState:UIControlStateNormal];
        
        
        if(item.image && !imageView)
            [self setupImageView];
        
        imageView.image = item.image;
        if(!imageView.image)
            imageView.image = item.image;
        [self isSelected:item.isSelected];
        drawShadow = item.drawDropShadow;
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//view to use when expanding
-(UIView*)expandView
{
    if(!imageView)
        return blankView;
    return self.imageView;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)isSelected:(BOOL)selected
{
    if(selected)
    {
        imageView.layer.borderColor = [UIColor colorWithRed:250/255.0f green:203/255.0f blue:12/255.0f alpha:1].CGColor;
        imageView.layer.borderWidth = 3;
    }
    else
    {
        imageView.layer.borderColor = [UIColor clearColor].CGColor;
        imageView.layer.borderWidth = 0;
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(CGSize)imageScale:(int)height
{
    CGSize imageSize = imageView.image.size;
    CGFloat sx = imageView.frame.size.width / imageSize.width;
    CGFloat sy = height / imageSize.height;
    
    CGFloat limit = sy;
    if(sx < sy)
        limit = sx;
    return CGSizeMake(imageSize.width*limit, imageSize.height*limit);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [imageView release];
    [textLabel release];
    [touchLayer release];
    [blankView release];
    [loadingLabel release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@end

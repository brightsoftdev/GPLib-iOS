//
//  HTMLSettingsViewController.m
//  GPLib
//
//  Created by Dalton Cherry on 3/21/12.
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

#import "HTMLSettingsViewController.h"
#import "UIImage+Additions.h"

@interface HTMLSettingsViewController ()

@end

@implementation HTMLSettingsViewController

@synthesize delegate = delegate;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        sections = [[NSMutableArray alloc] initWithCapacity:2];
        self.contentSizeForViewInPopover = CGSizeMake(320, 500);

    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)initWithExtras:(NSDictionary*)query
{
    if(self = [super init])
    {
        [Settings release];
        Settings = [query retain];
        SegControl = [[[UISegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 300, 30)] autorelease];
        [SegControl insertSegmentWithTitle:@"Style" atIndex:0 animated:NO];
        [SegControl insertSegmentWithTitle:@"Link" atIndex:1 animated:NO];
        //[SegControl insertSegmentWithTitle:@"List" atIndex:2 animated:NO];
        [SegControl setSelectedSegmentIndex:0];
        SegControl.segmentedControlStyle = UISegmentedControlStyleBar;
        [SegControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
        if(!GPIsPad())
        {
            self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:SegControl] autorelease];
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"dismiss" style:UIBarButtonItemStyleBordered target:self action:@selector(dimiss)] autorelease];
        }
        else
            self.navigationItem.titleView = SegControl;
        
        [self setoptionsAtIndex:0];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)viewDidLoad
{
    [super viewDidLoad];
    if(!GPIsPad())
    {
        CGRect frame =  self.view.frame;
        frame.size.height -= 230;
        self.view.frame = frame;
        frame =  _tableView.frame;
        frame.size.height -= 190;
        _tableView.frame = frame;
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([self.delegate respondsToSelector:@selector(disableList)])
    {
        disableSettings = [[self.delegate disableList] retain];
        if([disableSettings objectForKey:HTML_SETTINGS_LINKS]  &&[[disableSettings objectForKey:HTML_SETTINGS_LINKS] boolValue])
            [SegControl removeSegmentAtIndex:1 animated:YES];
        [self setoptionsAtIndex:0];
    }
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)segmentChanged:(UISegmentedControl*)segControl
{
    [self setoptionsAtIndex:segControl.selectedSegmentIndex];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setToDefault:(NSDictionary*)query
{
    [Settings release];
    Settings = [query retain];
    [SegControl setSelectedSegmentIndex:0];
    [self setoptionsAtIndex:0];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//sub class these to customize WISWIG edit options
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setoptionsAtIndex:(int)index
{
    currentIndex = index;
    [sections removeAllObjects];
    [items removeAllObjects];
    if(index == 0)
        [self setupStyleMenu];
    else if (index == 1)
        [self setupContentMenu];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupStyleMenu
{
    //color
    int left = 0;
    if(![disableSettings objectForKey:HTML_SETTINGS_TEXT_STYLE] || [[disableSettings objectForKey:HTML_SETTINGS_TEXT_STYLE] boolValue])
    {
        NSMutableArray* firstSection = [NSMutableArray array];
        [sections addObject:@"Text Style"];
        UIView* buttonview = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)] autorelease];
        UIFont* font = [UIFont boldSystemFontOfSize:18];
        
        if(![disableSettings objectForKey:HTML_SETTINGS_BOLD] || [[disableSettings objectForKey:HTML_SETTINGS_BOLD] boolValue])
        {
            GPButton* button = [self buttonFactory:CGRectMake(left, 0, 65, 35) image:[UIImage libraryImageNamed:@"bold.png"] istoggle:YES selector:@selector(setBold:) font:font];
            if([[Settings objectForKey:@"bold"] boolValue])
                [button swapButtonState];
            [buttonview addSubview:button];
            left+= 75;
        }
        
        if(![disableSettings objectForKey:HTML_SETTINGS_ITALIC] || [[disableSettings objectForKey:HTML_SETTINGS_ITALIC] boolValue])
        {
            GPButton* button = [self buttonFactory:CGRectMake(left, 0, 65, 35) image:[UIImage libraryImageNamed:@"italic.png"] istoggle:YES selector:@selector(setItalic:) font:font];
            if([[Settings objectForKey:@"italic"] boolValue])
                [button swapButtonState];
            [buttonview addSubview:button];
            left+= 75;
        }
        
        if(![disableSettings objectForKey:HTML_SETTINGS_UNDERLINE] || [[disableSettings objectForKey:HTML_SETTINGS_UNDERLINE] boolValue])
        {
            GPButton* button = [self buttonFactory:CGRectMake(left, 0, 65, 35) image:[UIImage libraryImageNamed:@"underline.png"] istoggle:YES selector:@selector(setUnder:) font:font];
            if([[Settings objectForKey:@"underline"] boolValue])
                [button swapButtonState];
            [buttonview addSubview:button];
            left+= 75;
        }
        
        if(![disableSettings objectForKey:HTML_SETTINGS_STRIKE_THROUGH] || [[disableSettings objectForKey:HTML_SETTINGS_STRIKE_THROUGH] boolValue])
        {
            GPButton* button = [self buttonFactory:CGRectMake(left, 0, 65, 35) image:[UIImage libraryImageNamed:@"strike.png"] istoggle:YES selector:@selector(setStrike:) font:font];
            if([[Settings objectForKey:@"strike"] boolValue])
                [button swapButtonState];
            [buttonview addSubview:button];
            //left+= 75;
        }
        
        if(buttonview.subviews.count > 0)
            [firstSection addObject:buttonview];
        
        UIColor* settingcolor = [Settings objectForKey:@"color"];
        int textSize = [[Settings objectForKey:@"size"] intValue];
        NSString* fontName = [Settings objectForKey:@"font"];
        if(![disableSettings objectForKey:HTML_SETTINGS_TEXT_COLOR] || [[disableSettings objectForKey:HTML_SETTINGS_TEXT_COLOR] boolValue])
        {
            [ColorItem release];
            ColorItem = [[GPTableTextItem itemWithText:@"Color" color:settingcolor font:[UIFont boldSystemFontOfSize:17] url:@"color"] retain];
            [firstSection addObject:ColorItem];
        }
        
        if(![disableSettings objectForKey:HTML_SETTINGS_TEXT_SIZE] || [[disableSettings objectForKey:HTML_SETTINGS_TEXT_SIZE] boolValue])
        {
            [textSizeItem release];
            textSizeItem = [[GPTableTextItem itemWithText:[NSString stringWithFormat:@"%d pt",textSize] color:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:17] url:@"size"] retain];
            [firstSection addObject:textSizeItem];
        }
        
        if(![disableSettings objectForKey:HTML_SETTINGS_FONTS] || [[disableSettings objectForKey:HTML_SETTINGS_FONTS] boolValue])
        {
            [fontItem release];
            fontItem = [[GPTableTextItem itemWithText:fontName color:[UIColor blackColor] font:[UIFont fontWithName:fontName size:17] url:@"font"] retain];
            [firstSection addObject:fontItem];
        }
        
        [items addObject:firstSection];
    }
    
    if(![disableSettings objectForKey:HTML_SETTINGS_PARA_STYLE] || [[disableSettings objectForKey:HTML_SETTINGS_PARA_STYLE] boolValue])
    {
        NSMutableArray* secondSection = [NSMutableArray array];
        [sections addObject:@"Paragraph Style"];
        left = 0;
        UIView* paraview = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)] autorelease];
        UIFont* font = [UIFont boldSystemFontOfSize:18];
        int align = [[Settings objectForKey:@"alignment"] intValue];
        
    if(![disableSettings objectForKey:HTML_SETTINGS_LEFT_JUSTIFY] || [[disableSettings objectForKey:HTML_SETTINGS_LEFT_JUSTIFY] boolValue])
        {
            GPButton* button = [self buttonFactory:CGRectMake(left, 0, 65, 35) image:[UIImage libraryImageNamed:@"left_justify.png"] istoggle:YES selector:@selector(setAlignment:) font:font];
            button.tag = kCTLeftTextAlignment;
            if(align == kCTLeftTextAlignment)
            {
                [button swapButtonState];
                OldAlign = [button retain];
            }
            [paraview addSubview:button];
            left+= 75;
        }
        
        if(![disableSettings objectForKey:HTML_SETTINGS_CENTER_JUSTIFY] || [[disableSettings objectForKey:HTML_SETTINGS_CENTER_JUSTIFY] boolValue])
        {
            GPButton* button = [self buttonFactory:CGRectMake(left, 0, 65, 35) image:[UIImage libraryImageNamed:@"center_justify.png"] istoggle:YES selector:@selector(setAlignment:) font:font];
            button.tag = kCTCenterTextAlignment;
            if(align == kCTCenterTextAlignment)
            {
                [button swapButtonState];
                OldAlign = [button retain];
            }
            [paraview addSubview:button];
            left+= 75;
        }
        
        if(![disableSettings objectForKey:HTML_SETTINGS_RIGHT_JUSTIFY] || [[disableSettings objectForKey:HTML_SETTINGS_RIGHT_JUSTIFY] boolValue])
        {
            GPButton* button = [self buttonFactory:CGRectMake(left, 0, 65, 35) image:[UIImage libraryImageNamed:@"right_justify.png"] istoggle:YES selector:@selector(setAlignment:) font:font];
            button.tag = kCTRightTextAlignment;
            if(align == kCTRightTextAlignment)
            {
                [button swapButtonState];
                OldAlign = [button retain];
            }
            [paraview addSubview:button];
            left+= 75;
        }
        
        if(![disableSettings objectForKey:HTML_SETTINGS_JUSTIFY_JUSTIFY] || [[disableSettings objectForKey:HTML_SETTINGS_JUSTIFY_JUSTIFY] boolValue])
        {
            GPButton* button = [self buttonFactory:CGRectMake(left, 0, 65, 35) image:[UIImage libraryImageNamed:@"justify_justify.png"] istoggle:YES selector:@selector(setAlignment:) font:font];
            button.tag = kCTJustifiedTextAlignment;
            if(align == kCTJustifiedTextAlignment)
            {
                [button swapButtonState];
                OldAlign = [button retain];
            }
            [paraview addSubview:button];
            //left+= 75;
        }
        
        left = 0;
        BOOL Order = [[Settings objectForKey:@"orderlist"] boolValue];
        BOOL unOrder = [[Settings objectForKey:@"unorderlist"] boolValue];
        UIView* listview = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 40)] autorelease];
        
        if(![disableSettings objectForKey:HTML_SETTINGS_ORDER] || [[disableSettings objectForKey:HTML_SETTINGS_ORDER] boolValue])
        {
            GPButton* button = [self buttonFactory:CGRectMake(left, 0, 65, 35) image:[UIImage libraryImageNamed:@"orderlist.png"] istoggle:YES selector:@selector(setList:) font:font];
            button.tag = 0;
            if(Order)
            {
                [button swapButtonState];
                OldList = [button retain];
            }
            [listview addSubview:button];
            left += 225;
        }
        
        if(![disableSettings objectForKey:HTML_SETTINGS_UNORDER] || [[disableSettings objectForKey:HTML_SETTINGS_UNORDER] boolValue])
        {
            GPButton* button = [self buttonFactory:CGRectMake(left, 0, 65, 35) image:[UIImage libraryImageNamed:@"unorderlist.png"] istoggle:YES selector:@selector(setList:) font:font];
            button.tag = 1;
            if(unOrder)
            {
                [button swapButtonState];
                OldList = [button retain];
            }
            [listview addSubview:button];
        }
        
        if(listview.subviews.count > 0)
            [secondSection addObject:listview];
        if(paraview.subviews.count > 0)
            [secondSection addObject:paraview];
        
        [items addObject:secondSection];
    }
    
    
    //[items addObject:[NSArray arrayWithObjects:ColorItem,textSizeItem,fontItem,buttonview, nil]];
    
    //[items addObject:secondSection];
    //[items addObject:[NSArray arrayWithObjects:paraview,listview,nil]];
    [self.tableView reloadData];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupContentMenu
{
    NSString* link = nil;
    UIColor* color = [UIColor lightGrayColor];
    NSString* text = @"Select Text to Create a Link";
    if([self.delegate respondsToSelector:@selector(viewWasDimissed)])
    {
        if([self.delegate isHyperLinkReady])
        {
            link = HYPER_LINK;
            color = [UIColor blackColor];
            text = @"Create Link";
        }
    }
    [sections addObject:@"Create Link"];
    [items addObject:[NSArray arrayWithObject:[GPTableTextItem itemWithText:text font:[UIFont boldSystemFontOfSize:17] color:color alignment:UITextAlignmentLeft url:link]]];
    [self.tableView reloadData];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)didSelectObject:(id)object atIndexPath:(NSIndexPath *)indexPath
{
    if([object isKindOfClass:[GPTableTextItem class]])
    {
        GPTableTextItem* item = (GPTableTextItem*)object;
        if([item.NavURL isEqualToString:@"color"])
        {
            HTMLListViewController* view = [[[HTMLListViewController alloc] initWithColor:ColorItem.color] autorelease];
            view.delegate = self;
            [self.navigationController pushViewController:view animated:YES];
            return;
        }
        else if([item.NavURL isEqualToString:@"size"])
        {
            int temp = 12;
            NSRange loc = [textSizeItem.text rangeOfString:@" "];
            if(loc.location)
                temp = [[textSizeItem.text substringToIndex:loc.location] intValue];
            HTMLListViewController* view = [[[HTMLListViewController alloc] initWithSize:temp] autorelease];
            view.delegate = self;
            [self.navigationController pushViewController:view animated:YES];
            return;
        }
        else if([item.NavURL isEqualToString:@"font"])
        {
            HTMLListViewController* view = [[[HTMLListViewController alloc] initWithFont:item.font.fontName] autorelease];
            view.delegate = self;
            [self.navigationController pushViewController:view animated:YES];
            return;
        }
        else if([self.delegate respondsToSelector:@selector(didSelectItem:path:)])
            [self.delegate didSelectItem:object path:indexPath];
    }
        
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)didSelectItem:(id)object path:(NSIndexPath*)indexPath
{
    GPTableTextItem* item = (GPTableTextItem*)object;
    NSString* type = [item.Properties objectForKey:@"type"];
    if([type isEqualToString:KEYWORD_HTML_COLOR])
        ColorItem.color = item.color;
    else if([type isEqualToString:KEYWORD_HTML_SIZE])
        textSizeItem.text = [NSString stringWithFormat:@"%d pt",(int)item.font.pointSize];
    else if([type isEqualToString:KEYWORD_HTML_FONT])
    {
        fontItem.text = item.text;
        fontItem.font = item.font;
    }
    
    if([self.delegate respondsToSelector:@selector(didSelectItem:path:)])
        [self.delegate didSelectItem:object path:indexPath];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)isAllowedFont:(NSString*)fontName
{
    if([self.delegate respondsToSelector:@selector(isAllowedFont:)])
        return [self.delegate isAllowedFont:fontName];
    return YES;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dimiss
{
    if([self.delegate respondsToSelector:@selector(viewWasDimissed)])
        [self.delegate viewWasDimissed];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(GPButton*)buttonFactory:(CGRect)frame image:(UIImage*)image istoggle:(BOOL)persist selector:(SEL)sel font:(UIFont*)font
{
    GPButton* button = [[[GPButton alloc] initWithFrame:frame] autorelease];
    button.gradientStartColor = [UIColor colorFromRGB:240 green:240 blue:240 alpha:1];
    button.gradientEndColor = [UIColor colorFromRGB:212 green:212 blue:212 alpha:1];
    button.highlightColor = [UIColor colorFromRGB:163 green:215 blue:255 alpha:1];
    button.doesPersistent = persist;
    if(font)
        button.titleLabel.font = font;
    [button addTarget:self 
               action:sel
     forControlEvents:UIControlEventTouchDown];
    //[button setTitle:text forState:UIControlStateNormal];
    [button setImage:image forState:UIControlStateNormal];
    return button;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setBold:(GPButton*)sender
{
    if([self.delegate respondsToSelector:@selector(updateBold:)])
        [self.delegate updateBold:sender.isSelected];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setItalic:(GPButton*)sender
{
    if([self.delegate respondsToSelector:@selector(updateItalic:)])
        [self.delegate updateItalic:sender.isSelected];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setUnder:(GPButton*)sender
{
    if([self.delegate respondsToSelector:@selector(updateUnderLine:)])
        [self.delegate updateUnderLine:sender.isSelected];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setStrike:(GPButton*)sender
{
    if([self.delegate respondsToSelector:@selector(updateStrike:)])
        [self.delegate updateStrike:sender.isSelected];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setList:(GPButton*)sender
{
    if(!OldList)
        OldList = [sender retain];
    if(OldList.tag != sender.tag )
    {
        [OldList swapButtonState];
        [OldList release];
        OldList = [sender retain];
    }
    if([self.delegate respondsToSelector:@selector(updateList:)])
        [self.delegate updateList:sender.tag];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setAlignment:(GPButton*)sender
{
    if(OldAlign.tag == sender.tag)
    {
        [sender swapButtonState];
        return;
    }
    [OldAlign swapButtonState];
    [OldAlign release];
    OldAlign = [sender retain];
    if([self.delegate respondsToSelector:@selector(updateAlignment:)])
        [self.delegate updateAlignment:sender.tag];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//subclass this to enable set to grouped style.
-(BOOL)grouped
{
    return YES;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*-(BOOL)checkMarks
{
    return YES;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//subclass this to create an exclude a section from the checkmark selection. Return YES to exclude
-(BOOL)checkMarksExpection:(int)section
{
    if( (currentIndex == 0 || currentIndex == 1) && section == 0)
        return YES;
    return NO;
}*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    if(GPIsPad())
        [SegControl release];
    [ColorItem release];
    [textSizeItem release];
    [fontItem release];
    [OldAlign release];
    [OldList release];
    [Settings release];
    [disableSettings release];
    [super dealloc];
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@end

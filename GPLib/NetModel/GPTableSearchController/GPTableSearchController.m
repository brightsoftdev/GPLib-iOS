//
//  GPTableSearchController.m
//  GPLib
//
//  Created by Dalton Cherry on 4/24/12.
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

#import <objc/runtime.h>
#import "GPTableSearchController.h"
#import "GPTableTextItem.h"
#import "GPTableCell.h"
#import "GPTableMoreItem.h"
#import "GPTableMoreCell.h"
#import "GPTableAccessory.h"

@interface GPTableSearchController ()

-(void)setupSections;
-(void)addSectionWithObject:(id)object;

@end

@implementation GPTableSearchController
 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //@"{search}"
        //UITableViewIndexSearch
        [self setupSections];
    }
    return self;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setupSections
{
    [sections release];
    [items removeAllObjects];
    sections = [[NSMutableArray alloc] initWithCapacity:27];
    [sections addObject:UITableViewIndexSearch];
    [items addObject: [NSMutableArray array]];
    NSString* alpha = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    for(int i = 0; i < 26; i++)
    {
        [sections addObject:[NSString stringWithFormat:@"%c",[alpha characterAtIndex:i] ]];
        [items addObject: [NSMutableArray array]];
    }
    if([self numberIndex])
    {
        [sections addObject:@"#"];
        [items addObject: [NSMutableArray array]];
    }
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if(isSearching)
        return nil;
    if(hideSectionTitles)
        return nil;
    NSInteger truncate = [self truncateCount];
    if(truncate <= 0)
        truncate = items.count + 1;
    if(items.count > 0 && items.count <= truncate && ![[items objectAtIndex:0] isKindOfClass:[NSArray class]] )
        return nil;
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:27];
    
    [array addObject:UITableViewIndexSearch];
    NSString* alpha = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    for(int i = 0; i < 26; i++)
        [array addObject:[NSString stringWithFormat:@"%c",[alpha characterAtIndex:i] ]];
    
    if([self numberIndex])
        [array addObject:@"#"];
    
    return array;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    if(isSearching)
        return nil;
    if(section < sections.count)
    {
        id object = [sections objectAtIndex:section];
        if([object isKindOfClass:[NSString class]])
        {
            if([object isEqualToString:UITableViewIndexSearch])
                return nil;
            return [sections objectAtIndex:section];
        }
    }
    return nil;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(isSearching)
        return nil;
    id object = [sections objectAtIndex:section];
    if([object isKindOfClass:[NSString class]] && [object isEqualToString:UITableViewIndexSearch])
        return searchController.searchBar;
    return [super tableView:tableView viewForHeaderInSection:section];
    
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(isSearching)
        return 0;
    if(section == 0 && sections.count > 0)
        return 44;
    return [super tableView:tableView heightForHeaderInSection:section];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
    UISearchBar* search = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    search.delegate = self;
    searchController = [[UISearchDisplayController alloc] initWithSearchBar:search contentsController:self];
    searchController.delegate = self;
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;
    [search release];
    searchItems = [[NSMutableArray alloc] init];
    //[self.tableView setContentOffset:CGPointMake(0,44) animated:YES]; 
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//search delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)runSearch:(NSString*)searchString
{
    if([self isNetworkSearch])
    {
        NSString* url = [self searchURL:searchString];
        [searchModel.items removeAllObjects];
        if(searchController.searchBar.scopeButtonTitles.count > 0)
        {
            [searchModel release];
            searchModel = [[self searchModel:url] retain];
            searchModel.delegate = self;
            [searchModel loadModel:NO];
        }
        else
        {
            if(!searchModel)
                searchModel = [[self searchModel:url] retain];
            searchModel.delegate = self;
            searchModel.URL = url;
            [searchModel loadModel:NO];
        }
        ActLabel.hidden = NO;
    }
    else
        [self filterLocalItems:searchString];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//this is workaround an apple bug, basically a dirty hack that resets the frame of the scopeBar to be correct
-(BOOL)searchBarShouldEndEditing:(UISearchBar*)searchBar
{
    if(searchBar.showsScopeBar)
        [self performSelector:@selector(scopeBarFix:) withObject:searchBar afterDelay:0.01];
    return YES;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)scopeBarFix:(UISearchBar*)searchBar
{
    searchBar.showsScopeBar = YES;
    [searchBar sizeToFit];
    for(UIView* view in searchBar.subviews)
    {
        if([view isKindOfClass:[UISegmentedControl class]])
        {
            CGRect frame = view.frame;
            frame.origin.y = 44;
            view.frame = frame;
            
            frame = searchBar.frame;
            frame.size.height = 88;
            searchBar.frame = frame;
        }
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)searchBarSearchButtonClicked:(UISearchBar*)searchBar
{
    [self runSearch:searchBar.text];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if([self isAutoSearch])
        [self runSearch:searchString];
    return NO;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    isSearching = YES;
    [ActLabel removeFromSuperview];
    ActLabel.frame = controller.searchResultsTableView.frame;
    [controller.searchResultsTableView addSubview:ActLabel];
    [controller.searchResultsTableView bringSubviewToFront:ActLabel];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    isSearching = NO;
    [ActLabel removeFromSuperview];
    ActLabel.frame = self.tableView.frame;
    [self.view addSubview:ActLabel];
    ActLabel.hidden = YES;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    if(isSearching)
        return searchSections ? searchSections.count : 1;
    return [super numberOfSectionsInTableView:tableView];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if(tableView != _tableView || isSearching)
    {
        if(searchSections)
            return [[searchItems objectAtIndex:section] count];
        return searchItems.count;
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)tableView:(UITableView*)tableView objectForRowAtIndexPath:(NSIndexPath*)indexPath 
{
    if(tableView != _tableView || isSearching) 
    {
        if(searchSections)
            return [[searchItems objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        if(indexPath.row <= searchItems.count)
            return [searchItems objectAtIndex:indexPath.row];
    }
    return [super tableView:tableView objectForRowAtIndexPath:indexPath];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([object isKindOfClass:[GPTableMoreItem class]])
    {
        GPModel* tempmodel = model;
        if(isSearching)
            tempmodel = searchModel;
        if(!tempmodel.isLoading)
        {
            GPTableMoreItem* item = (GPTableMoreItem*)object;
            item.isLoading = YES;
            [(GPTableMoreCell *)cell setAnimating:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [tempmodel loadModel:YES];
        }
        return;
    }
    [_tableView deselectRowAtIndexPath:indexPath animated:YES]; 
    [self didSelectObject:object atIndexPath:indexPath];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];
    
    Class cellClass = [self tableView:tableView cellClassForObject:object];
    const char* className = class_getName(cellClass);
    NSString* identifier = [[NSString alloc] initWithBytesNoCopy:(char*)className
                                                          length:strlen(className)
                                                        encoding:NSASCIIStringEncoding freeWhenDone:NO];
    
    UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) 
    {
        cell = [[[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
        if ([cell isKindOfClass:[GPTableCell class]]) 
            [(GPTableCell*)cell setAutoSize:[self autoSizeCells]];
    }
    [identifier release];
    
    if ([cell isKindOfClass:[GPTableCell class]])
        [(GPTableCell*)cell setObject:object];
    
    GPTableAccessory* view = [self customAccessory:cell.accessoryType];
    if(view)
        cell.accessoryView = view;
    
    GPModel* tempmodel = model;
    if(isSearching)
        tempmodel = searchModel;
    if(!tempmodel.isFinished && [tempmodel autoLoad])
    {
        id object = [self tableView:tableView objectForRowAtIndexPath:indexPath];
        if ([object isKindOfClass:[GPTableMoreItem class]])
        {
            GPTableMoreItem* item = (GPTableMoreItem*)object;
            item.isLoading = YES;
            [(GPTableMoreCell *)cell setAnimating:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [tempmodel loadModel:YES];
        }
    }
    if(tempmodel == model)
    {
        if(items.count > 0 && [[items objectAtIndex:0] isKindOfClass:[NSArray class]])
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.accessoryView = nil;
        }
    }
    
    return cell;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelFinished:(ASIHTTPRequest *)request
{
    if(isSearching)
    {
        [searchItems release];
        searchItems = [searchModel.items retain];
        searchSections = [searchModel.sections retain];
        [searchController.searchResultsTableView reloadData];
        ActLabel.hidden = YES;
        return;
    }
    
    NSInteger truncate = [self truncateCount];
    if(truncate <= 0)
        truncate = model.items.count + 1;
    if([self truncateIndex] && model.items.count <= truncate)
    {
        [items removeAllObjects];
        [sections release];
        sections = nil;
        items = [model.items mutableCopy];
        [items sortUsingSelector:@selector(compare:)];
        if(items.count > 0)
            emptyView.hidden = YES;
        else
            [self showEmptyView];
    }
    else
    {
        for(NSMutableArray* array in items)
            [array removeAllObjects];
        
        for(id object in model.items)
            [self addSortItem:object];
        
        [self clearEmptySections];
        NSMutableArray* array = [items lastObject];
        NSInteger total = 0;
        for(NSArray* array in items)
            total += array.count;
        if(total > 0)
        {
            GPTableTextItem* item = [GPTableTextItem itemWithText:[self countString:total]];
            item.color = [UIColor grayColor];
            item.TextAlignment = UITextAlignmentCenter;
            [array addObject:item];
        }
        if(total > 0)
            emptyView.hidden = YES;
        else
            [self showEmptyView];
    }
    
    [self.tableView reloadData];
    ActLabel.hidden = YES;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)filterLocalItems:(NSString*)text
{
    if(searchSections)
    {
        NSLog(@"Error: you must override filterLocalItems:(NSString*)text if you have searchSections");
        return;
    }
    [searchItems removeAllObjects];
    for(NSArray* array in items)
        for(GPTableTextItem* item in array)
        {
            NSString* htmltext = [item.text stringByStrippingHTML];
            if([[htmltext lowercaseString] hasPrefix:[text lowercaseString]])
                [searchItems addObject:item];
        }
    
    [searchController.searchResultsTableView reloadData];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath
{    
    [super didSelectObject:object atIndexPath:indexPath];
    if([self dimissSearchOnSelect])
        [searchController setActive:NO];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//adds an item and puts in in the proper section. returns if an sections is added
-(void)addSortItem:(id)object
{
    if([object isKindOfClass:[GPTableTextItem class]])
    {
        GPTableTextItem* item = (GPTableTextItem*)object;
        if(item.text)
        {
            NSString* text = [item.text stringByStrippingHTML];
            int i = 0;
            for(NSString* secChar in sections)
            {
                if([[secChar lowercaseString] isEqualToString:[[NSString stringWithFormat:@"%c",[text characterAtIndex:0]] lowercaseString] ])
                {
                    NSMutableArray* array = [items objectAtIndex:i];
                    [array addObject:item];
                    if(array.count > 1)
                        [array sortUsingSelector:@selector(compare:)];
                    return;
                }
                i++;
            }
            if([self numberIndex] && isnumber([text characterAtIndex:0]) )
            {
                NSMutableArray* array = [items lastObject];
                [array addObject:item];
                if(array.count > 1)
                    [array sortUsingSelector:@selector(compare:)];
                return;
            }
            if(sections && sections.count < 26)
                [self addSectionWithObject:object];
        }
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)addSectionWithObject:(id)object
{
    //clear the count object
    NSMutableArray* array = [items lastObject];
    [array removeLastObject];
    
    //rebuild the sections.
    NSString* alpha = @"abcdefghijklmnopqrstuvwxyz";
    if([self numberIndex])
        alpha = @"abcdefghijklmnopqrstuvwxyz#";
    for(int i = 0; i < alpha.length; i++)
    {
        NSString* letter = [[NSString stringWithFormat:@"%c",[alpha characterAtIndex:i]] uppercaseString];
        BOOL found = NO;
        for(NSString* section in sections)
            if([letter isEqualToString:section])
                found = YES;
        if(!found)
        {
            [sections addObject:letter];
            [items addObject:[NSMutableArray array]];
        }
    }
    
    //add the object
    [self addSortItem:object];
    //clear the sections back out
    [self clearEmptySections];
    
    //add the count object back
    array = [items lastObject];
    NSInteger total = 0;
    for(NSArray* array in items)
        total += array.count;
    GPTableTextItem* item = [GPTableTextItem itemWithText:[self countString:total]];
    item.color = [UIColor grayColor];
    item.TextAlignment = UITextAlignmentCenter;
    [array addObject:item];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//clears empty sections from table. Be careful when calling this, as once the section is remove, it can not currently
//readd the section if another item comes in that would be in the removed section.
-(void)clearEmptySections
{
    NSMutableArray* sect = [NSMutableArray array];
    NSMutableArray* ite = [NSMutableArray array];
    for(int i = 1; i < sections.count; i++)
    {
        NSArray* check = [items objectAtIndex:i];
        if(check.count == 0)
        {
            [sect addObject:[sections objectAtIndex:i]];
            [ite addObject:[items objectAtIndex:i]];
        }
    }
    for(int i = 0; i < sect.count; i++)
    {
        [sections removeObject:[sect objectAtIndex:i]];
        [items removeObject:[ite objectAtIndex:i]];
    }
    //for some reason I have to do this, not quite sure why
    if(sect.count > 0)
        [items insertObject:[NSMutableArray array] atIndex:0];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//subclass!
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//override this to set the search url when searching the table
-(NSString*)searchURL:(NSString*)searchString
{
    return nil;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//set if you want to search just local tableview results, or a network query. Default is NO (just search local)
-(BOOL)isNetworkSearch
{
    return NO;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//searches every key event
-(BOOL)isAutoSearch
{
    return YES;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//override to change to proper search model
-(GPModel*)searchModel:(NSString*)url
{
    return [[[GPModel alloc] initWithURLString:url] autorelease];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//removes the index and search bar if there are 13 items or less.
-(BOOL)truncateIndex
{
    return YES;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//don't show sections if there are these many items. 13 is default and 0 or less will cause infinte number of items
-(NSInteger)truncateCount
{
    return 13;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//override if you want to show the search bar when the view is empty. default is NO. Only use when doing a network search
-(BOOL)showSearchWhenEmpty
{
    return NO;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//return whatever your table objects are. eg: 12 users, 34 folder, 45 contacts
-(NSString*)countString:(NSInteger)count
{
    return [NSString stringWithFormat:@"%d items",count];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//show # for numbers in list content. Only set if you plan on not having any numeric text
-(BOOL)numberIndex
{
    return YES;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//dismiss the search controller when an item is selected
-(BOOL)dimissSearchOnSelect
{
    return NO;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)showEmptyView
{
    if(!emptyView && [self showSearchWhenEmpty])
    {
        [self clearEmptySections];
        [super showEmptyView];
        CGRect frame =  emptyView.frame;
        frame.size.height -= 44;
        frame.origin.y += 44;
        emptyView.frame = frame;
        hideSectionTitles = YES;
    }
    else
        [super showEmptyView];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)isSearching
{
    return isSearching;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)dealloc
{
    [searchItems release];
    [searchModel release];
    [searchController release];
    [super dealloc];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@end

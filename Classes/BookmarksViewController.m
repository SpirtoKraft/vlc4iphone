//
//  BookmarksViewController.m
//  VideoStreaming
//
//  Created by ZodTTD & Derek Tse on 09年4月4日.
//  Copyright 2009 ZodTTD (Spookysoft LLC) & HKUST. All rights reserved.
//
#import "VideoStreamingAppDelegate.h"
#import "BookmarksViewController.h"
#import "TableEditorViewController.h"

@interface BookmarksViewController(private)

-(void)loadBookmarks;
-(void)saveBookmarks;
-(void)promptToAddBookmark;
- (UITableViewCell *)tableCellWithReuseIdentifier:(NSString *)identifier;

@end

@implementation BookmarksViewController

@synthesize bookmarksArray;
@synthesize tableView;
@synthesize editViewController;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle 
{ 
    self = [super initWithNibName:nibName bundle:nibBundle]; 
    if (self) { 
        self.title = @"Bookmarks"; 
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(promptToAddBookmark)] autorelease];
		if(self.editViewController==nil)
			self.editViewController = [[[TableEditorViewController alloc]initWithNibName:@"TableEditor" bundle:nil] autorelease];
    }
    return self; 
} 

- (void)viewDidLoad {
    [super viewDidLoad];
	[self loadBookmarks];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.tableView reloadData];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self saveBookmarks];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return bookmarksArray == nil? 1:[bookmarksArray count];
}

#define PATH_TAG 1
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [self tableCellWithReuseIdentifier:CellIdentifier];
		cell.hidesAccessoryWhenEditing = NO;
    }
    
    // Set up the cell...
	if(indexPath.row < [bookmarksArray count])
	{
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		UILabel* pathLable = (UILabel*)[cell viewWithTag:PATH_TAG];
		pathLable.text = [bookmarksArray objectAtIndex:indexPath.row];
	}
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	if(self.editing)
	{
		[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
		self.editViewController.navigationItem.title = @"Edit bookmark";
		[self.editViewController editItemAtIndex:indexPath.row OfArray:self.bookmarksArray];
		[self.navigationController pushViewController:self.editViewController animated:YES];
	}
	else {
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		NSString* path = [self.bookmarksArray objectAtIndex:indexPath.row];
		NSString* protocal = [path length] >= 6 ? [[path substringToIndex:6] lowercaseString] : path;
		
		if([protocal isEqualToString:@"native:"])
    {
      NSString* url = [[path substringFromIndex:7] lowercaseString];
      NSString* urlprotocal = [url length] >= 6 ? [[url substringToIndex:6] lowercaseString] : url;

      [appDelegate playVideoInDefaultPlayerWithPath:url usingURL:([urlprotocal isEqualToString:@"http://"] ? 1 : 0)];
		}
    else
		{
      [appDelegate playVideoInVLCPlayerWithPath:path];
    }
	}

}

// The accessory view is on the right side of each cell. We'll use a "disclosure" indicator in editing mode,
// to indicate to the user that selecting the row will navigate to a new view where details can be edited.
- (UITableViewCellAccessoryType)tableView:(UITableView *)aTableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return (self.editing) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
}

		
- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// The editing style for a row is the kind of button displayed to the left of the cell when in editing mode.
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // No editing style if not editing or the index path is nil.
    return (self.editing == NO || !indexPath)? UITableViewCellEditingStyleNone:UITableViewCellEditingStyleDelete;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.bookmarksArray removeObjectAtIndex:indexPath.row];
		[self.tableView reloadData];
		[self saveBookmarks];
	}   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

// Override to support conditional rearranging of the table view.
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Return NO if you do not want the item to be re-orderable.
//    return NO;
//}

- (UITableViewCell *)tableCellWithReuseIdentifier:(NSString *)identifier
{
	/*
	 Create an instance of UITableViewCell and add tagged subviews for the name, local time, and quarter image of the time zone.
	 */
	CGRect rect = CGRectMake(0.0, 0.0, 320.0, 44);
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:rect reuseIdentifier:identifier] autorelease];
	
	/*
	 Create labels for the text fields; set the highlight color so that when the cell is selected it changes appropriately.
	 */
	rect = CGRectMake(6, 6, 276, 32);
	UILabel *label = [[UILabel alloc] initWithFrame:rect];
	label.tag = PATH_TAG;
	label.font = [UIFont boldSystemFontOfSize:18];
	label.adjustsFontSizeToFitWidth = YES;
	[cell.contentView addSubview:label];
	label.highlightedTextColor = [UIColor whiteColor];
	[label release];	
	
	return cell;
}


#pragma mark Bookmark operations
-(void) loadBookmarks
{
	if(self.bookmarksArray != nil ) 
		[self.bookmarksArray release];
		
	NSString *path=[[appDelegate getDocumentsDirectory] stringByAppendingPathComponent:@"Bookmarks.bin"];
	NSData *plistData = [NSData dataWithContentsOfFile:path];
	NSString *error;
	NSPropertyListFormat format;
	
	id plist = [NSPropertyListSerialization propertyListFromData:plistData
											 mutabilityOption:NSPropertyListImmutable
													   format:&format
											 errorDescription:&error];
	
	if(!plist)
	{
		NSLog(error);
		[error release];
		self.bookmarksArray = [[NSMutableArray alloc] init];
	}
	else
	{
		self.bookmarksArray = [[NSMutableArray alloc] initWithArray:plist];
	}
	
	[self.tableView reloadData];
}

-(void) saveBookmarks
{
	NSString *path=[[appDelegate getDocumentsDirectory] stringByAppendingPathComponent:@"Bookmarks.bin"];
	NSString *error;
	
	NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:bookmarksArray
														   format:NSPropertyListBinaryFormat_v1_0
												 errorDescription:&error];
	
	if(plistData)
		[plistData writeToFile:path atomically:NO];
	else
	{
		NSLog(error);
		[error release];
	}
}

-(void) addBookmarkWithPath:(NSString*) path
{
	[bookmarksArray addObject:path];
	[self saveBookmarks];
	[self.tableView reloadData];
}

-(void)promptToAddBookmark
{
	self.editViewController.navigationItem.title = @"Add Bookmark";
	[self.editViewController addNewItemInArray:self.bookmarksArray];
	[self.navigationController pushViewController:self.editViewController animated:YES];
}


- (void)dealloc {
	[bookmarksArray release];
	tableView.delegate = nil;
	tableView.dataSource = nil;
	[tableView release];
	[editViewController release];
    [super dealloc];
}


@end


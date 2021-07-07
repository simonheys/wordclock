//
//  FontTabViewController.m
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "FontTabViewController.h"

@implementation FontTabViewController

@synthesize displayList;
@synthesize currentFont;
@synthesize currentIndexPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	DLog(@"*** INIT ****");
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		self.title = NSLocalizedString(@"Font", @"");
		self.tabBarItem.image = [UIImage imageNamed:@"font.png"];
		_dataLoaded = NO;
	}
	return self;
}

-(void)saveChanges
{
	DLog(@"saveChanges");
	[WordClockPreferences sharedInstance].fontName = [self.currentFont objectForKey:@"fontName"];	
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self saveChanges];	
}

-(IBAction)doneSelected 
{
	[super doneSelected];
	[self saveChanges];		
}

- (void)viewWillAppear:(BOOL)animated
{
	DLog(@"viewWillAppear");
    [super viewWillAppear:animated];
	if ( !_dataLoaded ) {
		[self setLoading:YES];
		[self loadData];
	}
}

// ____________________________________________________________________________________________________ Data loading

- (void)loadData 
{
	DLog(@"loadData");
	
	[self performSelectorInBackground:@selector(loadDataThread)
		withObject:nil
    ];	
}

-(void)loadDataThread
{
	NSAutoreleasePool *apool = [[NSAutoreleasePool alloc] init];
	[self setUpDisplayList];
	[self performSelectorOnMainThread:@selector(loadDataThreadComplete) withObject:nil waitUntilDone:NO];
	[apool release];
}

-(void)loadDataThreadComplete
{
	DLog(@"loadDataThreadComplete");
	
	_dataLoaded = YES;
	
	[self.tableView reloadData];
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.separatorColor = [UIColor colorWithWhite:0.3f alpha:0.5f];
	self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	[self setLoading:NO];
}



- (void)dealloc {
	[displayList release];
    [super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ( !_dataLoaded ) {
		return 1;
	}
	// Number of sections is the number of region dictionaries
	return [displayList count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if ( !_dataLoaded ) {
		return 0;
	}
	// Number of rows is the number of names in the file dictionary for the specified section
	NSDictionary *fontDictionary = [displayList objectAtIndex:section];
	NSArray *fontsForSection = [fontDictionary objectForKey:@"Fonts"];
	return [fontsForSection count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	// The header for the section is the region name -- get this from the dictionary at the section index
	NSDictionary *fontDictionary = [displayList objectAtIndex:section];
	return [fontDictionary valueForKey:@"SectionName"];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

	if ( indexPath == currentIndexPath ) {
		cell.accessoryView = _accessorySelected;
	} else {
		cell.accessoryView = nil;
	}	
	
	// Get the section index, and so the file dictionary for that section
	NSDictionary *fontDictionary = [displayList objectAtIndex:indexPath.section];
	NSArray *fontNames = [fontDictionary objectForKey:@"Fonts"];
	
	// Set the cell's text to the name of the language at the row
	cell.textLabel.text = [[fontNames objectAtIndex:indexPath.row] objectForKey:@"fontName"];
	cell.textLabel.font = [UIFont fontWithName:cell.textLabel.text size:[UIFont labelFontSize]];
//	cell.textColor = [UIColor whiteColor];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{ 
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:currentIndexPath];
	oldCell.accessoryView = nil;

    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
	newCell.accessoryView = _accessorySelected;
	
	NSDictionary *fontDictionary = [displayList objectAtIndex:indexPath.section];
	NSArray *fontNames = [fontDictionary objectForKey:@"Fonts"];
	
	// Set the cell's text to the name of the language at the row
	self.currentFont = [fontNames objectAtIndex:indexPath.row];

	//self.currentFile = [displayList objectAtIndex:indexPath.row];
	DLog(@"currentFont:%@",[currentFont objectForKey:@"fontName"]);
	self.currentIndexPath = indexPath;
	
//	[WordClockPreferences sharedInstance].fontName = [currentFont objectForKey:@"fontName"];	
	
}


- (void)setUpDisplayList 
{
	NSArray *familyArray = [UIFont familyNames];
	NSArray *fontArray;
	int j;

	NSMutableArray *familySections = [[NSMutableArray alloc] init];	
	NSString *familyName;
	NSDictionary *fontDictionary;
	NSMutableArray *fonts;
	
	NSDictionary *currentFontDictionary;
	
	NSSortDescriptor *sortDescriptor;
	NSArray *sortDescriptors;

	currentFontDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
		[WordClockPreferences sharedInstance].fontName, @"fontName", 
		nil
	];
	self.currentFont = currentFontDictionary;
	[currentFontDictionary release];

	for ( familyName in familyArray ) {
	
		DLog(@"familyName:%@",familyName);
		
		if ( [familyName rangeOfString:@"STHeiti"].location == NSNotFound 
			&& [familyName rangeOfString:@"Hiragino"].location == NSNotFound
			&& [familyName rangeOfString:@"Apple"].location == NSNotFound
			&& [familyName rangeOfString:@"Unicode"].location == NSNotFound
		) {

			NSMutableDictionary *sectionDictionary = sectionDictionaryWithNameInArray(familyName, familySections);
			if (sectionDictionary == nil) {
				sectionDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:familyName, @"SectionName", [NSMutableArray array], @"Fonts", nil];
				[familySections addObject:sectionDictionary];
				[sectionDictionary release];
			}
			
			fonts = [sectionDictionary objectForKey:@"Fonts"];

			fontArray = [UIFont fontNamesForFamilyName:familyName];
			
			for ( j = 0; j < [fontArray count]; j++ ) {
				fontDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
					[fontArray objectAtIndex:j], @"fontName", 
					nil
				];
				[fonts addObject:fontDictionary];
				// retained by the array
				[fontDictionary release];
				/*
				if ( [(NSString *)[fontArray objectAtIndex:j] isEqualToString:[currentFont objectForKey:@"fontName"]] ) {
					NSLog(@"FOUND THE FONT");
					NSUInteger indexes[2];
					indexes[0] = [familySections count]-1;
					indexes[1] = j;
					self.currentIndexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
				}
				*/
			}
			/*
			sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fontName" ascending:YES];
			sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
			[fonts sortUsingDescriptors:sortDescriptors];
			[sortDescriptor release];
			 */
			 
			// clang says this is not needed
			//[fontDictionary release];
		}
	}
	DLog(@"done");
	
	/*
	NSUInteger indexes[2];
	indexes[0] = 0;
	indexes[1] = 0;
	self.currentIndexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
	*/

	// Sort the regions
	sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"SectionName" ascending:YES];
	sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [familySections sortUsingDescriptors:sortDescriptors];
	[sortDescriptor release];
	
	// Find the index of current selection

	NSDictionary *section;
	int i;
	
	for ( i = 0; i < [familySections count]; i++ ) {
		section = [familySections objectAtIndex:i];
		fonts = [section objectForKey:@"Fonts"];
		
		for ( j = 0; j < [fonts count]; j++ ) {
			//NSLog(@"value:%@",[files objectAtIndex:j]);
			if ( [[fonts objectAtIndex:j] isEqual:currentFont] ) {
				NSUInteger indexes[2];
				indexes[0] = i;
				indexes[1] = j;
				self.currentIndexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
				DLog(@"FOUND IT");
				break;
			}
		}
	}

	self.displayList = familySections;
	[familySections release];
}	

@end


/*
*/

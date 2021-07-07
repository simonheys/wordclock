//
//  WordsTabViewController.m
//  WordClock-iOS
//
//  Created by Simon Heys on 07/07/2021.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "WordsTabViewController.h"


NSMutableDictionary *sectionDictionaryWithNameInArray(NSString *name, NSArray *array) {
	// Return the region dictionary with a given region name
	for (NSMutableDictionary *region in array) {
		NSString *regionName = [region objectForKey:@"SectionName"];
		if ([regionName isEqualToString:name]) {
			return region;
		}
	}
	return nil;
}

@implementation WordsTabViewController

@synthesize displayList;
@synthesize currentFile;
@synthesize currentIndexPath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	DLog(@"initWithNibName");
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = NSLocalizedString(@"Words", @"");
		self.tabBarItem.image = [UIImage imageNamed:@"format.png"];
		_state = kWordsTabViewControllerNotLoadedState;
	}
	return self;
}

- (void)setState:(WordsTabViewControllerState)newState
{
	if ( _state == newState ) {
		return;
	}
	
	switch (_state ) {
		case kWordsTabViewControllerLoadingState:
//			[self setLoading:NO];
			break;
	}
	
	_state = newState;
	
	switch (_state ) {
		case kWordsTabViewControllerLoadingState:
			[self setLoading:YES];
			break;
		case kWordsTabViewControllerLoadedState:
			[self setLoading:NO];
			break;
	}
}

/*
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	DLog(@"viewWillAppear");
	[self setLoading:YES];
}
*/
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	DLog(@"viewWillAppear");
	if ( _state == kWordsTabViewControllerNotLoadedState ) {
		[self setState:kWordsTabViewControllerLoadingState];
		[self loadData];
	}
}

// ____________________________________________________________________________________________________ Data loading

- (void)loadData 
{
	DLog(@"loadData");
	
	NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];	
	([WordClockXmlFileParser sharedInstance] ).manifestFile = [thisBundle pathForResource:@"Manifest" ofType:@"xml"];
//	[thisBundle release];


	[[WordClockXmlFileParser sharedInstance] setDelegate:self];
	
	[self performSelectorInBackground:@selector(loadDataThread)
		withObject:nil
    ];

/*
	
	// threading ain't working
	[[WordClockXmlFileParser sharedInstance] parseManifestFile];
	DLog(@"finished parseManifestFile");
	[self setupDisplayList];
	[self loadDataThreadComplete];
*/
}

-(void)loadDataThread
{
	NSAutoreleasePool *apool = [[NSAutoreleasePool alloc] init];
	DLog(@"loadDataThread");
	[[WordClockXmlFileParser sharedInstance] parseManifestFile];
	DLog(@"loadDataThread 2");
	[self setupDisplayList];
	DLog(@"loadDataThread 3");
	[self performSelectorOnMainThread:@selector(loadDataThreadComplete) withObject:nil waitUntilDone:NO];
	[apool release];
}

-(void)loadDataThreadComplete
{
	DLog(@"loadDataThreadComplete");
	
	_dataLoaded = YES;
		
	[self setState:kWordsTabViewControllerLoadedState];
//	[self setLoading:NO];

	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.separatorColor = [UIColor colorWithWhite:0.3f alpha:0.5f];
	self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	
	[self.tableView reloadData];
}

-(void)wordClockXmlFileParserDidCompleteParsingManifest:(WordClockXmlFileParser *)parser
{
	DLog(@"wordClockXmlFileParserDidCompleteParsingManifest");
}

// ____________________________________________________________________________________________________ dealloc


- (void)dealloc {
	[displayList release];
    [super dealloc];
}

//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	if ( _dataLoaded ) {
		return [displayList count];
	}
	else {
		return 1;
	}
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if ( _dataLoaded ) {
		NSDictionary *fileDictionary = [displayList objectAtIndex:section];
		NSArray *filesForSection = [fileDictionary objectForKey:@"Files"];
		return [filesForSection count];
	}
	else {
		return 0;
	}
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	if ( _dataLoaded ) {
		// The header for the section is the region name -- get this from the dictionary at the section index
		NSDictionary *fileDictionary = [displayList objectAtIndex:section];
		return [fileDictionary valueForKey:@"SectionName"];
	}
	else {
		return nil;
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	if ( !_dataLoaded ) {
		return nil;
	}
	
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

/*
	static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		cell.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
		cell.textColor = [UIColor blackColor];
	}
*/
	
	// Get the section index, and so the file dictionary for that section
	NSDictionary *fileDictionary = [displayList objectAtIndex:indexPath.section];
	NSArray *languageFiles = [fileDictionary objectForKey:@"Files"];
	
	// Set the cell's text to the name of the language at the row
	cell.textLabel.text = [[languageFiles objectAtIndex:indexPath.row] objectForKey:@"fileTitle"];
	
	// Check the selection in case the cell is being re-used
	if ( [[languageFiles objectAtIndex:indexPath.row] objectForKey:@"fileName"] == [currentFile objectForKey:@"fileName"] ) {
		cell.accessoryView = _accessorySelected;
	} else {
		cell.accessoryView = nil;
	}	

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { 

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:currentIndexPath];
	oldCell.accessoryView = nil;

    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
	newCell.accessoryView = _accessorySelected;
	
	NSDictionary *fileDictionary = [displayList objectAtIndex:indexPath.section];
	NSArray *languageFiles = [fileDictionary objectForKey:@"Files"];
	
	// Set the cell's text to the name of the language at the row
	self.currentFile = [languageFiles objectAtIndex:indexPath.row];
	
	//self.currentFile = [displayList objectAtIndex:indexPath.row];
	DLog(@"currentFile:%@",[currentFile objectForKey:@"fileName"]);
	self.currentIndexPath = indexPath;
	
	//FIXME need to save prefs when the view is hidden, in case we switch tabs
	[WordClockPreferences sharedInstance].xmlFile = [currentFile objectForKey:@"fileName"];	
}




- (void)setupDisplayList 
{
	DLog(@"setupDisplayList");

	int i;
	int j;		
	
	// language sections contains the language section dictionary items
	NSMutableArray *languageSections = [[NSMutableArray alloc] init];
	
	NSArray *xmlFiles = [[WordClockXmlFileParser sharedInstance] xmlFiles];
	
	NSDictionary *xmlFileDictionary;
	NSString *sectionName;
	NSString *fileTitle;
	NSString *fileName;
	NSMutableArray *files;
	NSString *currentXmlFile = [WordClockPreferences sharedInstance].xmlFile;
	
	for ( i = 0; i < [xmlFiles count]; i++ ) {
		xmlFileDictionary = [xmlFiles objectAtIndex:i];
		
		sectionName = [xmlFileDictionary objectForKey:@"fileLanguageTitle"];
		
		// Get the region dictionary with the region name, or create it if it doesn't exist
		NSMutableDictionary *sectionDictionary = sectionDictionaryWithNameInArray(sectionName, languageSections);
		if (sectionDictionary == nil) {
			sectionDictionary = [[NSMutableDictionary alloc] initWithObjectsAndKeys:sectionName, @"SectionName", [NSMutableArray array], @"Files", nil];
			[languageSections addObject:sectionDictionary];
			[sectionDictionary release];
		}
		
		files = [sectionDictionary objectForKey:@"Files"];
		
		fileTitle = [xmlFileDictionary objectForKey:@"fileTitle"];
		fileName = [xmlFileDictionary objectForKey:@"fileName"];
				
		NSDictionary *fileDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
			fileTitle, @"fileTitle", 
			fileName, @"fileName", 
			nil
		];
		[files addObject:fileDictionary];
		
		if ( [fileName isEqualToString:currentXmlFile] ) {
			self.currentFile = fileDictionary;
		}
		
		[fileDictionary release];
	}
	
	// Sort the sections
	NSSortDescriptor *sortDescriptor;
	NSArray *sortDescriptors;
	sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"SectionName" ascending:YES];
	sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [languageSections sortUsingDescriptors:sortDescriptors];
	[sortDescriptor release];
	
	// Find the index of current selection

	NSDictionary *section;
	
	for ( i = 0; i < [languageSections count]; i++ ) {
		section = [languageSections objectAtIndex:i];
		files = [section objectForKey:@"Files"];
		
		for ( j = 0; j < [files count]; j++ ) {
			//NSLog(@"value:%@",[files objectAtIndex:j]);
			if ( [[files objectAtIndex:j] isEqual:currentFile] ) {
				NSUInteger indexes[2];
				indexes[0] = i;
				indexes[1] = j;
				self.currentIndexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
				break;
			}
		}
	}
	
	self.displayList = languageSections;
	[languageSections release];
	DLog(@"setupDisplayList:done");
}	

@end



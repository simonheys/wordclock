//
//  WordClockOptionsWindowController.m
//  WordClock macOS
//
//  Created by Simon Heys on 26/11/2012.
//  Copyright (c) Studio Heys Limited. All rights reserved.
//

#import "WordClockOptionsWindowController.h"

#import "NSView+Additions.h"
#import "WordClockPreferences.h"
#import "WordClockRenderView.h"
#import "WordClockViewController.h"
#import "WordClockWordsManifestFileParser.h"

@interface WordClockOptionsWindowController () <WordClockWordsManifestFileParserDelegate, NSWindowDelegate>
@property(nonatomic, retain) WordClockWordsManifestFileParser *wordClockXmlFileParser;
@property(nonatomic, retain) WordClockViewController *wordClockViewController;

@property(nonatomic, retain) NSMenu *fontFamilyMenu;

@property(nonatomic, assign) IBOutlet NSButton *fontButton;
@property(nonatomic, assign) IBOutlet NSColorWell *backgroundColorWell;
@property(nonatomic, assign) IBOutlet NSColorWell *foregroundColorWell;
@property(nonatomic, assign) IBOutlet NSColorWell *highlightColorWell;
@property(nonatomic, assign) IBOutlet NSPopUpButton *xmlFilePopUpButton;
@property(nonatomic, assign) IBOutlet NSPopUpButton *transitionStylePopUpButton;
@property(nonatomic, assign) IBOutlet NSPopUpButton *transitionTimePopUpButton;
@property(nonatomic, assign) IBOutlet NSButton *linearButton;
@property(nonatomic, assign) IBOutlet NSButton *rotaryButton;
@property(nonatomic, assign) IBOutlet NSView *customView;
@property(assign) IBOutlet NSView *settingsContainer;

@property(assign) IBOutlet NSPopUpButton *fontFamilyPopUpButton;
@property(assign) IBOutlet NSPopUpButton *fontVariantPopUpButton;
@property(assign) IBOutlet NSButton *defaultsButton;
@end

@implementation WordClockOptionsWindowController

- (NSBundle *)bundle {
#ifdef SCREENSAVER
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
#else
    NSBundle *bundle = [NSBundle mainBundle];
#endif
    return bundle;
}

- (void)dealloc {
    @try {
        [[WordClockPreferences sharedInstance] removeObserver:self forKeyPath:WCStyleKey];
        [[WordClockPreferences sharedInstance] removeObserver:self forKeyPath:WCFontNameKey];
    } @catch (NSException *exception) {
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_wordClockViewController release];
    [_wordClockXmlFileParser release];
    [_fontFamilyMenu release];
    [super dealloc];
}

- (instancetype)init {
    self = [super initWithWindowNibName:@"WordClockOptionsWindowController"];
    if (self) {
    }
    return self;
}

- (void)resetUI {
    DDLogVerbose(@"resetUI");

    [self.backgroundColorWell setColor:[WordClockPreferences sharedInstance].backgroundColour];
    [self.foregroundColorWell setColor:[WordClockPreferences sharedInstance].foregroundColour];
    [self.highlightColorWell setColor:[WordClockPreferences sharedInstance].highlightColour];

    [self.settingsContainer setAlphaValue:1.0f];
    [self.settingsContainer setSubViewsEnabled:YES];

    self.wordClockViewController.tracksMouseEvents = YES;

    [self updateButtons];
    [self updateXmlFileMenu];
}

- (void)updateXmlFileMenu {
    self.wordClockXmlFileParser = [[[WordClockWordsManifestFileParser alloc] init] autorelease];
    self.wordClockXmlFileParser.delegate = self;
    [self.wordClockXmlFileParser parseManifestFile];
}

- (void)windowDidLoad {
    DDLogVerbose(@"windowDidLoad");

    [self resetUI];

    DDLogVerbose(@"self.customView:%@", self.customView);

    [[WordClockPreferences sharedInstance] addObserver:self forKeyPath:WCStyleKey options:NSKeyValueObservingOptionNew context:NULL];
    [[WordClockPreferences sharedInstance] addObserver:self forKeyPath:WCFontNameKey options:NSKeyValueObservingOptionNew context:NULL];

    DDLogVerbose(@"self.wordClockViewController:%@", self.wordClockViewController);

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeKey:) name:NSWindowDidBecomeKeyNotification object:nil];

    NSRect screenFrame = [[NSScreen mainScreen] frame];
    NSRect f = self.customView.frame;
    CGFloat newHeight = roundf(f.size.width * screenFrame.size.height / screenFrame.size.width);
    f.origin.y = f.origin.y + roundf(0.5f * (f.size.height - newHeight));
    f.size.height = newHeight;
    self.customView.frame = f;
}

- (void)willRestart:(NSNotification *)notification {
    DDLogVerbose(@"willRestart");
    [[NSApplication sharedApplication] endSheet:[self window]];
}

- (void)didBecomeKey:(NSNotification *)notification {
    DDLogVerbose(@"didBecomeKey:%@", notification);
    if ([notification.object isEqual:self.window]) {
        if (!self.wordClockViewController) {
            self.wordClockViewController = [[WordClockViewController new] autorelease];
            self.wordClockViewController.view = self.customView;
            self.wordClockViewController.tracksMouseEvents = YES;
        }
        [self.wordClockViewController startAnimation];
    } else {
        [self.wordClockViewController stopAnimation];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqual:WCStyleKey]) {
        [self updateButtons];
    } else if ([keyPath isEqual:WCFontNameKey]) {
        [self updateButtons];
    }
}

- (void)updateButtons {
    NSFont *font = [NSFont fontWithName:[WordClockPreferences sharedInstance].fontName size:12.0f];
    [self.fontButton setTitle:font.displayName];

    [self setupTransitionPopupButtons];
    [self updateStyleButtons];
    [self setupFontFamilyPopUpButton];
    [self setupFontFamilyVariantPopUpButton];
}

// ____________________________________________________________________________________________________
// style

- (void)updateStyleButtons {
    switch ([WordClockPreferences sharedInstance].style) {
        case WCStyleLinear:
            [self.linearButton setEnabled:NO];
            [self.rotaryButton setEnabled:YES];
            break;
        case WCStyleRotary:
            [self.linearButton setEnabled:YES];
            [self.rotaryButton setEnabled:NO];
            break;
    }
}

- (IBAction)linearButtonPressed:(id)sender {
    [WordClockPreferences sharedInstance].style = WCStyleLinear;
}

- (IBAction)rotaryButtonPressed:(id)sender {
    [WordClockPreferences sharedInstance].style = WCStyleRotary;
}

- (void)windowWillClose:(NSNotification *)notification {
    [[NSColorPanel sharedColorPanel] orderOut:self];
}

// ____________________________________________________________________________________________________
// colour

- (IBAction)backgroundColourChanged:(id)sender {
    DDLogVerbose(@"backgroundColourChanged");
    [WordClockPreferences sharedInstance].backgroundColour = [sender color];
}

- (IBAction)foregroundColourChanged:(id)sender {
    DDLogVerbose(@"foregroundColourChanged");
    [WordClockPreferences sharedInstance].foregroundColour = [sender color];
}

- (IBAction)highlightColourChanged:(id)sender {
    DDLogVerbose(@"highlightColourChanged");
    [WordClockPreferences sharedInstance].highlightColour = [sender color];
}

// ____________________________________________________________________________________________________
// fonts

#pragma mark - font

- (NSMenu *)fontFamilyMenu {
    if (nil == _fontFamilyMenu) {
        _fontFamilyMenu = [NSMenu new];
        NSArray *familyNames = [[NSFontManager sharedFontManager] availableFontFamilies];
        CGFloat fontSize = [NSFont systemFontSize];
        [familyNames enumerateObjectsUsingBlock:^(NSString *familyName, NSUInteger idx, BOOL *_Nonnull stop) {
            NSMutableAttributedString *attrStr = [[[NSMutableAttributedString alloc] initWithString:familyName] autorelease];
            NSFont *font = [NSFont fontWithName:familyName size:fontSize];
            [attrStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, familyName.length)];
            NSMenuItem *menuItem = [[NSMenuItem new] autorelease];
            [menuItem setAttributedTitle:attrStr];
            [_fontFamilyMenu addItem:menuItem];
        }];
    }
    return _fontFamilyMenu;
}

- (void)setupFontFamilyPopUpButton {
    CGFloat fontSize = [NSFont systemFontSize];
    [self.fontFamilyPopUpButton setMenu:self.fontFamilyMenu];

    NSFont *selectedFont = [NSFont fontWithName:[WordClockPreferences sharedInstance].fontName size:fontSize];
    [self.fontFamilyPopUpButton selectItemWithTitle:selectedFont.familyName];
}

- (void)setupFontFamilyVariantPopUpButton {
    CGFloat fontSize = [NSFont systemFontSize];
    NSFont *selectedFont = [NSFont fontWithName:[WordClockPreferences sharedInstance].fontName size:fontSize];

    NSMenu *fontFamilyVariantMenu = [NSMenu new];

    NSArray *members = [[NSFontManager sharedFontManager] availableMembersOfFontFamily:selectedFont.familyName];
    DDLogVerbose(@"members:%@", members);
    DDLogVerbose(@"fontName:%@", selectedFont.fontName);
    __block NSInteger selectedIndex = 0;
    [members enumerateObjectsUsingBlock:^(NSArray *member, NSUInteger idx, BOOL *_Nonnull stop) {
        NSString *fontName = member[0];
        NSString *variantName = member[1];
        DDLogVerbose(@"variantName:%@", variantName);
        NSMutableAttributedString *attrStr = [[[NSMutableAttributedString alloc] initWithString:variantName] autorelease];
        NSFont *font = [NSFont fontWithName:fontName size:fontSize];
        [attrStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, variantName.length)];
        NSMenuItem *menuItem = [[NSMenuItem new] autorelease];
        [menuItem setAttributedTitle:attrStr];
        [fontFamilyVariantMenu addItem:menuItem];
        if ([fontName isEqualToString:selectedFont.fontName]) {
            selectedIndex = idx;
        }
    }];

    [self.fontVariantPopUpButton setMenu:fontFamilyVariantMenu];
    [self.fontVariantPopUpButton selectItemAtIndex:selectedIndex];
}

- (IBAction)fontFamilyPopUpButtonChanged:(id)sender {
    NSString *familyName = [[sender selectedItem] title];
    CGFloat fontSize = [NSFont systemFontSize];
    NSFont *font = [NSFont fontWithName:familyName size:fontSize];
    [WordClockPreferences sharedInstance].fontName = font.fontName;
}

- (IBAction)fontVariantPopUpButtonChanged:(id)sender {
    NSInteger idx = [sender indexOfSelectedItem];
    CGFloat fontSize = [NSFont systemFontSize];
    NSFont *selectedFont = [NSFont fontWithName:[WordClockPreferences sharedInstance].fontName size:fontSize];
    NSArray *members = [[NSFontManager sharedFontManager] availableMembersOfFontFamily:selectedFont.familyName];
    NSArray *member = members[idx];
    NSString *fontName = member[0];
    [WordClockPreferences sharedInstance].fontName = fontName;
}

// ____________________________________________________________________________________________________
// transition

#pragma mark - transition

- (void)setupTransitionPopupButtons {
    NSMenu *newMenu;
    NSMenuItem *menuItem;

    newMenu = [[[NSMenu alloc] initWithTitle:@"Word Clock"] autorelease];

    menuItem = [[[NSMenuItem alloc] initWithTitle:@"Slow" action:nil keyEquivalent:@""] autorelease];
    [menuItem setTag:WCTransitionStyleSlow];
    [newMenu addItem:menuItem];

    menuItem = [[[NSMenuItem alloc] initWithTitle:@"Medium" action:nil keyEquivalent:@""] autorelease];
    [menuItem setTag:WCTransitionStyleMedium];
    [newMenu addItem:menuItem];

    menuItem = [[[NSMenuItem alloc] initWithTitle:@"Fast" action:nil keyEquivalent:@""] autorelease];
    [menuItem setTag:WCTransitionStyleFast];
    [newMenu addItem:menuItem];

    [self.transitionStylePopUpButton setMenu:newMenu];
    [self.transitionStylePopUpButton selectItem:[newMenu itemWithTag:[WordClockPreferences sharedInstance].transitionStyle]];

    newMenu = [[[NSMenu alloc] initWithTitle:@"Word Clock"] autorelease];

    menuItem = [[[NSMenuItem alloc] initWithTitle:@"never" action:nil keyEquivalent:@""] autorelease];
    [menuItem setTag:0];
    [newMenu addItem:menuItem];

    menuItem = [[[NSMenuItem alloc] initWithTitle:@"every 10 seconds" action:nil keyEquivalent:@""] autorelease];
    [menuItem setTag:10];
    [newMenu addItem:menuItem];

    menuItem = [[[NSMenuItem alloc] initWithTitle:@"every 30 seconds" action:nil keyEquivalent:@""] autorelease];
    [menuItem setTag:30];
    [newMenu addItem:menuItem];

    menuItem = [[[NSMenuItem alloc] initWithTitle:@"every minute" action:nil keyEquivalent:@""] autorelease];
    [menuItem setTag:60];
    [newMenu addItem:menuItem];

    menuItem = [[[NSMenuItem alloc] initWithTitle:@"every 2 minutes" action:nil keyEquivalent:@""] autorelease];
    [menuItem setTag:60 * 2];
    [newMenu addItem:menuItem];

    menuItem = [[[NSMenuItem alloc] initWithTitle:@"every 5 minutes" action:nil keyEquivalent:@""] autorelease];
    [menuItem setTag:60 * 5];
    [newMenu addItem:menuItem];

    [self.transitionTimePopUpButton setMenu:newMenu];
    [self.transitionTimePopUpButton selectItem:[newMenu itemWithTag:[WordClockPreferences sharedInstance].transitionTime]];
}

- (IBAction)transitionStylePopUpButtonChanged:(id)sender {
    [WordClockPreferences sharedInstance].transitionStyle = [[self.transitionStylePopUpButton selectedItem] tag];
}

- (IBAction)transitionTimePopUpButtonChanged:(id)sender {
    [WordClockPreferences sharedInstance].transitionTime = [[self.transitionTimePopUpButton selectedItem] tag];
}

- (IBAction)filePopUpButtonChanged:(id)sender {
    [WordClockPreferences sharedInstance].wordsFile = [[self.xmlFilePopUpButton selectedItem] representedObject];
}

- (void)wordClockWordsManifestFileParserDidCompleteParsingManifest:(WordClockWordsManifestFileParser *)parser {
    DDLogVerbose(@"wordClockWordsManifestFileParserDidCompleteParsingManifest");

    int i;

    NSMutableArray *xmlFiles = [[self.wordClockXmlFileParser wordsFiles] mutableCopy];
    NSMenu *newMenu = [[NSMenu alloc] initWithTitle:@"Word Clock"];

    NSDictionary *xmlFileDictionary;
    NSString *sectionName;
    NSString *fileTitle;
    NSString *fileName;
    NSString *currentXmlFile = [WordClockPreferences sharedInstance].wordsFile;

    [newMenu removeAllItems];
    [newMenu setAutoenablesItems:NO];
    // Sort the sections
    NSSortDescriptor *sortDescriptor;
    NSArray *sortDescriptors;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"fileLanguageTitle" ascending:YES];
    sortDescriptors = @[ sortDescriptor ];
    [xmlFiles sortUsingDescriptors:sortDescriptors];
    [sortDescriptor release];

    NSString *currentSectionName = @"";
    NSMenuItem *menuItem;
    NSMenuItem *selectedMenuItem = nil;

    for (NSDictionary *xmlFileDictionary in xmlFiles) {
        fileTitle = [xmlFileDictionary valueForKey:@"fileTitle"];
        fileName = [xmlFileDictionary valueForKey:@"fileName"];
        sectionName = [xmlFileDictionary valueForKey:@"fileLanguageTitle"];

        if (![sectionName isEqualToString:currentSectionName]) {
            if ([currentSectionName length] > 0) {
                [newMenu addItem:[NSMenuItem separatorItem]];
            }
            menuItem = [[NSMenuItem alloc] initWithTitle:sectionName action:nil keyEquivalent:@""];
            [menuItem setEnabled:NO];
            [newMenu addItem:menuItem];
            [menuItem release];
            currentSectionName = sectionName;
        }
        menuItem = [[NSMenuItem alloc] initWithTitle:fileTitle action:nil keyEquivalent:@""];
        [menuItem setEnabled:YES];
        [menuItem setRepresentedObject:fileName];
        [newMenu addItem:menuItem];
        if ([fileName isEqualToString:currentXmlFile]) {
            selectedMenuItem = menuItem;
        }
        [menuItem release];
    }

    [self.xmlFilePopUpButton setMenu:newMenu];
    if (nil != selectedMenuItem) {
        [self.xmlFilePopUpButton selectItem:selectedMenuItem];
    }
    [self.xmlFilePopUpButton setEnabled:YES];
    self.wordClockXmlFileParser = nil;
    [xmlFiles release];
    [newMenu release];
}

- (IBAction)okSelected:(id)sender {
    DDLogVerbose(@"okSelected");
    DDLogVerbose(@"[self window]:%@", [self window]);
    [[NSApplication sharedApplication] endSheet:[self window]];
}

- (IBAction)defaultsSelected:(id)sender {
    DDLogVerbose(@"defaultsSelected");

    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:@"Reset to Defaults"];
    [alert setInformativeText:@"Are you sure you want to reset all settings to their default values? This action cannot be undone."];
    [alert addButtonWithTitle:@"Reset"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setAlertStyle:NSAlertStyleWarning];

    [alert beginSheetModalForWindow:self.window
                  completionHandler:^(NSModalResponse returnCode) {
                      if (returnCode == NSAlertFirstButtonReturn) {
                          [[WordClockPreferences sharedInstance] reset];
                          [self resetUI];
                      }
                  }];
}

- (IBAction)textTapped:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://www.simonheys.com/wordclock/"];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

@end

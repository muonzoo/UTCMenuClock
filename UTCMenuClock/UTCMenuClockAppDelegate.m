//
//  UTCMenuClockAppDelegate.m
//  UTCMenuClock
//
//  Created by John Adams on 11/14/11.
//
// Copyright 2011 John Adams
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "UTCMenuClockAppDelegate.h"
#import "LaunchAtLoginController.h"

@implementation UTCMenuClockAppDelegate

@synthesize window;
@synthesize mainMenu;

NSStatusItem *ourStatus;
NSMenuItem *dateMenuItem;
NSMenuItem *showTimeZoneItem;

- (void) quitProgram:(id)sender {
    // Cleanup here if necessary...
    [[NSApplication sharedApplication] terminate:nil];
}

- (void) toggleLaunch:(id)sender {
    NSInteger state = [sender state];
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];

    if (state == NSOffState) {
        [sender setState:NSOnState];
        [launchController setLaunchAtLogin:YES];
    } else {
        [sender setState:NSOffState];
        [launchController setLaunchAtLogin:NO];
    }

    [launchController release];
}

- (BOOL) fetchBooleanPreference:(NSString *)preference {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL value = [standardUserDefaults boolForKey:preference];
    return value;
}

- (void) togglePreference:(id)sender {
    NSInteger state = [sender state];
    NSString *preference = [sender title];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];

    preference = [preference stringByReplacingOccurrencesOfString:@" "
                                                withString:@""];
    if (state == NSOffState) {
        [sender setState:NSOnState];
        [standardUserDefaults setBool:TRUE forKey:preference];
    } else {
        [sender setState:NSOffState];
        [standardUserDefaults setBool:FALSE forKey:preference];
    }
    [self doDateUpdate];
}

- (void) openGithubURL:(id)sender {
    [[NSWorkspace sharedWorkspace]
        openURL:[NSURL URLWithString:@"http://github.com/netik/UTCMenuClock"]];
}


- (void) doDateUpdate {
    NSDate* date = [NSDate date];
    NSDateFormatter* UTCdf = [[[NSDateFormatter alloc] init] autorelease];
    NSDateFormatter* UTCdateDF = [[[NSDateFormatter alloc] init] autorelease];
    NSDateFormatter* UTCdateShortDF = [[[NSDateFormatter alloc] init] autorelease];
    NSDateFormatter* UTCdaynum = [[[NSDateFormatter alloc] init] autorelease];
    
    NSTimeZone* UTCtz = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];

    [UTCdf setTimeZone: UTCtz];
    [UTCdateDF setTimeZone: UTCtz];
    [UTCdateShortDF setTimeZone: UTCtz];
    [UTCdaynum setTimeZone: UTCtz];

    BOOL showDate = [self fetchBooleanPreference:@"ShowDate"];
    BOOL showJulian = [self fetchBooleanPreference:@"ShowJulianDate"];
    BOOL showTimeZone = [self fetchBooleanPreference:@"ShowTimeZone"];
    BOOL showOnlyHour = [self fetchBooleanPreference:@"ShowOnlyHour"];
    
    if (showOnlyHour) {
      [UTCdf setDateFormat: @"HH"];
    } else {
      [UTCdf setDateFormat: @"HH:mm"];
    }

    [UTCdateDF setDateStyle:NSDateFormatterFullStyle];
    [UTCdateShortDF setDateStyle:NSDateFormatterShortStyle];
    [UTCdaynum setDateFormat:@"D/"];

    NSString* UTCtimepart = [UTCdf stringFromDate: date];
    NSString* UTCdatepart = [UTCdateDF stringFromDate: date];
    NSString* UTCdateShort = [UTCdateShortDF stringFromDate: date];
    NSString* UTCJulianDay;
    NSString* UTCTzString;
    
    
    if (showJulian) { 
        UTCJulianDay = [UTCdaynum stringFromDate: date];
    } else { 
        UTCJulianDay = @"";
    }
    
    if (showTimeZone) { 
        UTCTzString = @"Z";
    } else { 
        UTCTzString = @"";
    }

    if (showDate) {
        [ourStatus setTitle:[NSString stringWithFormat:@"%@ %@%@%@", UTCdateShort, UTCJulianDay, UTCtimepart, UTCTzString]];
    } else {
        [ourStatus setTitle:[NSString stringWithFormat:@"%@%@%@", UTCJulianDay, UTCtimepart, UTCTzString]];
    }

    [dateMenuItem setTitle:UTCdatepart];

}

- (IBAction)showFontMenu:(id)sender {
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    [fontManager setDelegate:self];
    
    NSFontPanel *fontPanel = [fontManager fontPanel:YES];
    [fontPanel makeKeyAndOrderFront:sender];
}
// this is the main work loop, fired on 60s intervals.
- (void) fireTimer:(NSTimer*)theTimer {
    [self doDateUpdate];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // set our default preferences if they've never been set before.
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *dateKey    = @"dateKey";
    NSDate *lastRead    = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:dateKey];
    if (lastRead == nil)     // App first run: set up user defaults.
    {
        NSDictionary *appDefaults  = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], dateKey, nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:dateKey];

        [standardUserDefaults setBool:TRUE forKey:@"ShowTimeZone"];
        [showTimeZoneItem setState:NSOnState];
    }    

}

- (void)awakeFromNib
{
    mainMenu = [[NSMenu alloc] init];

    //Create Image for menu item
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    NSStatusItem *theItem;
    theItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    [theItem retain];
    // retain a reference to the item so we don't have to find it again
    ourStatus = theItem;

    //Set Image
    //[theItem setImage:(NSImage *)menuicon];
    [theItem setTitle:@""];

    //Make it turn blue when you click on it
    [theItem setHighlightMode:YES];
    [theItem setEnabled: YES];

    // build the menu
    NSMenuItem *mainItem = [[NSMenuItem alloc] init];
    dateMenuItem = mainItem;

    NSMenuItem *cp1Item = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *cp2Item = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *cp3Item = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *quitItem = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *launchItem = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *showDateItem = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *showJulianItem = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *showHourOnlyItem = [[[NSMenuItem alloc] init] autorelease];
 //   NSMenuItem *changeFontItem = [[[NSMenuItem alloc] init] autorelease];
    
    showTimeZoneItem = [[[NSMenuItem alloc] init] autorelease];
    NSMenuItem *sep1Item = [NSMenuItem separatorItem];
    NSMenuItem *sep2Item = [NSMenuItem separatorItem];
    NSMenuItem *sep3Item = [NSMenuItem separatorItem];
    NSMenuItem *sep4Item = [NSMenuItem separatorItem];
    
    [mainItem setTitle:@""];

    [cp1Item setTitle:@"UTC Menu Clock v1.2.1"];
    [cp2Item setTitle:@"jna@retina.net"];
    [cp3Item setTitle:@"http://github.com/muonzoo/UTCMenuClock"];

    [cp3Item setEnabled:TRUE];
    [cp3Item setAction:@selector(openGithubURL:)];

    [launchItem setTitle:@"Open at Login"];
    [launchItem setEnabled:TRUE];
    [launchItem setAction:@selector(toggleLaunch:)];

    [showDateItem setTitle:@"Show Date"];
    [showDateItem setEnabled:TRUE];
    [showDateItem setAction:@selector(togglePreference:)];

    [showJulianItem setTitle:@"Show Julian Date"];
    [showJulianItem setEnabled:TRUE];
    [showJulianItem setAction:@selector(togglePreference:)];

    [showTimeZoneItem setTitle:@"Show Time Zone"];
    [showTimeZoneItem setEnabled:TRUE];
    [showTimeZoneItem setAction:@selector(togglePreference:)];

    [showHourOnlyItem setTitle:@"Show Only Hour"];
    [showHourOnlyItem setEnabled:TRUE];
    [showHourOnlyItem setAction:@selector(togglePreference:)];

 //   [changeFontItem setTitle:@"Change Font..."];
  //  [changeFontItem setAction:@selector(showFontMenu:)];
    
    [quitItem setTitle:@"Quit"];
    [quitItem setEnabled:TRUE];
    [quitItem setAction:@selector(quitProgram:)];

    [mainMenu addItem:mainItem];
    // "---"
    [mainMenu addItem:sep2Item];
    // "---"
    [mainMenu addItem:cp1Item];
    [mainMenu addItem:cp2Item];
    // "---"
    [mainMenu addItem:sep1Item];
    [mainMenu addItem:cp3Item];
    // "---"
    [mainMenu addItem:sep3Item];

    // showDateItem
    BOOL showDate = [self fetchBooleanPreference:@"ShowDate"];
    BOOL showJulian = [self fetchBooleanPreference:@"ShowJulianDate"];
    BOOL showTimeZone = [self fetchBooleanPreference:@"ShowTimeZone"];
    BOOL showHourOnly = [self fetchBooleanPreference:@"ShowHourOnly"];
    
    // TODO: DRY this up a bit. 
    if (showDate) {
        [showDateItem setState:NSOnState];
    } else {
        [showDateItem setState:NSOffState];
    }

    if (showJulian) {
        [showJulianItem setState:NSOnState];
    } else {
        [showJulianItem setState:NSOffState];
    }
    
    if (showTimeZone) {
        [showTimeZoneItem setState:NSOnState];
    } else {
        [showTimeZoneItem setState:NSOffState];
    }
    if (showHourOnly) {
      [showHourOnlyItem setState:NSOnState];
    } else {
      [showHourOnlyItem setState:NSOffState];
    }
    
    // latsly, deal with Launch at Login
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    BOOL launch = [launchController launchAtLogin];
    [launchController release];

    if (launch) {
        [launchItem setState:NSOnState];
    } else {
        [launchItem setState:NSOffState];
    }

    [mainMenu addItem:launchItem];
    [mainMenu addItem:showDateItem];
    [mainMenu addItem:showJulianItem];
    [mainMenu addItem:showTimeZoneItem];
    [mainMenu addItem:showHourOnlyItem];
  //  [mainMenu addItem:changeFontItem];
    // "---"
    [mainMenu addItem:sep4Item];
    [mainMenu addItem:quitItem];

    [theItem setMenu:(NSMenu *)mainMenu];

    // Find the start of the next minute to begin updates
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components: NSEraCalendarUnit|NSYearCalendarUnit| NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate: [NSDate date]];
    [comps setMinute: [comps minute] + 1];
    NSDate *nextMinute = [calendar dateFromComponents:comps];

    // Update the display every minute with 5 seconds of tolerance
    NSTimer *timer = [[NSTimer alloc] initWithFireDate:nextMinute interval:60.0 target:self selector:@selector(fireTimer:) userInfo:nil repeats:YES];
    timer.tolerance = 5.0;
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];

    // Update the date immediately after setup since we're waiting for the minute to do it
    [self doDateUpdate];
}

@end

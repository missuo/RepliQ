//
//  AppDelegate.m
//  RepliQ
//
//  Created by Vincent Yang on 6/16/25.
//

#import "AppDelegate.h"
#import "StatusBarIcon.h"
#import "ClipboardManager.h"

// Define the notification constant
NSString * const RepliQMonitoringStatusDidChangeNotification = @"RepliQMonitoringStatusDidChangeNotification";

@interface AppDelegate ()
@property (strong, nonatomic) NSMenu *statusMenu;
@property (strong, nonatomic) NSMenuItem *monitoringMenuItem;
@property (nonatomic) BOOL windowIsVisible;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Create status bar item
    [self setupStatusBarItem];
    
    // The main window controller is automatically created by storyboard's initialViewController
    // Initialize window state as hidden (user can click status bar to open)
    self.windowIsVisible = NO;
    
    // Start monitoring by default
    self.isMonitoringEnabled = YES;
    [[ClipboardManager sharedManager] startMonitoring];
    
    // Send initial notification about monitoring status
    [[NSNotificationCenter defaultCenter] postNotificationName:RepliQMonitoringStatusDidChangeNotification object:self];
}

- (void)setupStatusBarItem {
    // Create status item
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    if (!self.statusItem) {
        NSLog(@"Failed to create status item!");
        return;
    }
    
    // Set icon
    NSButton *statusButton = self.statusItem.button;
    if (!statusButton) {
        NSLog(@"Failed to get status button!");
        return;
    }
    
    // Try different icon options
    NSImage *icon = nil;
    if (@available(macOS 11.0, *)) {
        icon = [StatusBarIcon createIconWithSymbol:@"doc.text.replace"];
        if (!icon) {
            icon = [StatusBarIcon createCustomRepliQIcon];
        }
    } else {
        icon = [StatusBarIcon createCustomRepliQIcon];
    }
    
    // Fallback to text icon if others fail
    if (!icon) {
        icon = [StatusBarIcon createIconWithText:@"R"];
    }
    
    statusButton.image = icon;
    statusButton.toolTip = @"RepliQ - Clipboard Text Replacer";
    
    NSLog(@"Status bar item created successfully with icon: %@", icon);
    
    // Create menu
    [self setupStatusMenu];
    
    // Set action for clicking the status item directly
    statusButton.action = @selector(statusBarButtonClicked:);
    statusButton.target = self;
}

- (void)setupStatusMenu {
    self.statusMenu = [[NSMenu alloc] init];
    
    // Monitoring toggle item
    self.monitoringMenuItem = [[NSMenuItem alloc] initWithTitle:@"Stop Monitoring"
                                                        action:@selector(toggleMonitoring)
                                                 keyEquivalent:@""];
    self.monitoringMenuItem.target = self;
    [self.statusMenu addItem:self.monitoringMenuItem];
    
    // Separator
    [self.statusMenu addItem:[NSMenuItem separatorItem]];
    
    // Show Window item
    NSMenuItem *showWindowItem = [[NSMenuItem alloc] initWithTitle:@"Show Window"
                                                            action:@selector(showMainWindow)
                                                     keyEquivalent:@""];
    showWindowItem.target = self;
    [self.statusMenu addItem:showWindowItem];
    
    // Separator
    [self.statusMenu addItem:[NSMenuItem separatorItem]];
    
    // About item
    NSMenuItem *aboutItem = [[NSMenuItem alloc] initWithTitle:@"About RepliQ"
                                                       action:@selector(showAbout)
                                                keyEquivalent:@""];
    aboutItem.target = self;
    [self.statusMenu addItem:aboutItem];
    
    // Quit item
    NSMenuItem *quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit RepliQ"
                                                      action:@selector(quitApplication)
                                               keyEquivalent:@"q"];
    quitItem.target = self;
    [self.statusMenu addItem:quitItem];
}

- (void)statusBarButtonClicked:(NSButton *)sender {
    NSEvent *currentEvent = [NSApp currentEvent];
    
    if (currentEvent.type == NSEventTypeRightMouseUp || 
        (currentEvent.type == NSEventTypeLeftMouseUp && (currentEvent.modifierFlags & NSEventModifierFlagControl))) {
        // Right click or Ctrl+Click - show menu using modern approach
        // Temporarily set the menu to show it
        self.statusItem.menu = self.statusMenu;
        
        // Schedule to remove the menu after a short delay to restore click behavior
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.statusItem.menu = nil;
        });
    } else {
        // Left click - toggle window
        [self toggleMainWindow];
    }
}

- (void)toggleMainWindow {
    if (self.windowIsVisible) {
        [self hideMainWindow];
    } else {
        [self showMainWindow];
    }
}

- (void)showMainWindow {
    // Find the main window controller if we don't have a reference
    if (!self.mainWindowController) {
        for (NSWindow *window in [NSApp windows]) {
            if ([window.windowController isKindOfClass:[NSWindowController class]] && 
                [window.title isEqualToString:@"RepliQ - Clipboard Text Replacer"]) {
                self.mainWindowController = window.windowController;
                break;
            }
        }
    }
    
    if (self.mainWindowController) {
        [self.mainWindowController showWindow:nil];
        [self.mainWindowController.window makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
        self.windowIsVisible = YES;
        
        // Set up window delegate to track close events
        self.mainWindowController.window.delegate = self;
    } else {
        NSLog(@"Could not find main window controller");
    }
}

- (void)hideMainWindow {
    if (self.mainWindowController && self.mainWindowController.window) {
        [self.mainWindowController.window orderOut:nil];
        self.windowIsVisible = NO;
    }
}

- (void)toggleMonitoring {
    if (self.isMonitoringEnabled) {
        [[ClipboardManager sharedManager] stopMonitoring];
        self.isMonitoringEnabled = NO;
        self.monitoringMenuItem.title = @"Start Monitoring";
        
        // Update status bar icon to show monitoring is off
        self.statusItem.button.appearsDisabled = YES;
    } else {
        [[ClipboardManager sharedManager] startMonitoring];
        self.isMonitoringEnabled = YES;
        self.monitoringMenuItem.title = @"Stop Monitoring";
        
        // Update status bar icon to show monitoring is on
        self.statusItem.button.appearsDisabled = NO;
    }
    
    // Send notification about monitoring status change
    [[NSNotificationCenter defaultCenter] postNotificationName:RepliQMonitoringStatusDidChangeNotification object:self];
}

- (void)startMonitoring {
    if (!self.isMonitoringEnabled) {
        [[ClipboardManager sharedManager] startMonitoring];
        self.isMonitoringEnabled = YES;
        self.monitoringMenuItem.title = @"Stop Monitoring";
        self.statusItem.button.appearsDisabled = NO;
        
        // Send notification about monitoring status change
        [[NSNotificationCenter defaultCenter] postNotificationName:RepliQMonitoringStatusDidChangeNotification object:self];
    }
}

- (void)stopMonitoring {
    if (self.isMonitoringEnabled) {
        [[ClipboardManager sharedManager] stopMonitoring];
        self.isMonitoringEnabled = NO;
        self.monitoringMenuItem.title = @"Start Monitoring";
        self.statusItem.button.appearsDisabled = YES;
        
        // Send notification about monitoring status change
        [[NSNotificationCenter defaultCenter] postNotificationName:RepliQMonitoringStatusDidChangeNotification object:self];
    }
}

- (void)showAbout {
    [NSApp orderFrontStandardAboutPanel:nil];
}

- (IBAction)showSettings:(id)sender {
    [self showMainWindow];
}

- (void)quitApplication {
    [[ClipboardManager sharedManager] stopMonitoring];
    [NSApp terminate:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return NO; // Don't terminate when window is closed for menu bar app
}

#pragma mark - NSWindowDelegate

- (BOOL)windowShouldClose:(NSWindow *)sender {
    // Instead of closing, hide the window
    [self hideMainWindow];
    return NO; // Don't actually close the window
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Stop clipboard monitoring when app terminates
    [[ClipboardManager sharedManager] stopMonitoring];
}

- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {
    return YES;
}

- (IBAction)showAbout:(id)sender {
    [self showAbout];
}

@end

//
//  TabViewController.m
//  RepliQ
//
//  Created by Vincent Yang on 6/16/25.
//

#import "TabViewController.h"
#import "RulesViewController.h"
#import "HistoryViewController.h"
#import "SettingsViewController.h"

@interface TabViewController ()

@end

@implementation TabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"TabViewController viewDidLoad called");
    NSLog(@"TabView: %@", self.tabView);
    NSLog(@"TabView class: %@", NSStringFromClass([self.tabView class]));
    
    // Configure tab view style
    self.tabView.tabViewType = NSTopTabsBezelBorder;
    
    NSLog(@"TabViewController loaded with %ld tab items", (long)self.tabView.tabViewItems.count);
    
    // Clear any existing tab items from storyboard
    while (self.tabView.tabViewItems.count > 0) {
        [self.tabView removeTabViewItem:[self.tabView.tabViewItems firstObject]];
    }
    
    // Create tab view items programmatically
    [self createTabViewItems];
    
    NSLog(@"TabViewController now has %ld tab items after programmatic creation", (long)self.tabView.tabViewItems.count);
    
    // Select the first tab
    if (self.tabView.tabViewItems.count > 0) {
        [self.tabView selectFirstTabViewItem:nil];
        NSLog(@"Selected first tab");
    } else {
        NSLog(@"Still no tab items found - this is a problem!");
    }
}

- (void)createTabViewItems {
    // Create Rules tab
    RulesViewController *rulesVC = [[RulesViewController alloc] init];
    NSTabViewItem *rulesTab = [[NSTabViewItem alloc] initWithIdentifier:@"rules"];
            rulesTab.label = @"Rules";
    rulesTab.viewController = rulesVC;
    [self.tabView addTabViewItem:rulesTab];
    NSLog(@"Created Rules tab");
    
    // Create History tab
    HistoryViewController *historyVC = [[HistoryViewController alloc] init];
    NSTabViewItem *historyTab = [[NSTabViewItem alloc] initWithIdentifier:@"history"];
            historyTab.label = @"History";
    historyTab.viewController = historyVC;
    [self.tabView addTabViewItem:historyTab];
    NSLog(@"Created History tab");
    
    // Create Settings tab
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    NSTabViewItem *settingsTab = [[NSTabViewItem alloc] initWithIdentifier:@"settings"];
            settingsTab.label = @"Settings";
    settingsTab.viewController = settingsVC;
    [self.tabView addTabViewItem:settingsTab];
    NSLog(@"Created Settings tab");
}

- (void)viewDidAppear {
    [super viewDidAppear];
    NSLog(@"TabViewController appeared with %ld tabs", (long)self.tabView.tabViewItems.count);
}

@end 
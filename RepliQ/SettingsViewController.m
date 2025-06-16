//
//  SettingsViewController.m
//  RepliQ
//
//  Created by Vincent Yang on 6/16/25.
//

#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "ClipboardManager.h"
#import <ServiceManagement/ServiceManagement.h>

@interface SettingsViewController ()
@property (nonatomic, strong) NSButton *launchAtLoginCheckbox;
@property (nonatomic, strong) NSButton *monitorClipboardCheckbox;
@property (nonatomic, strong) NSTextField *statusLabel;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create UI programmatically
    [self createUI];
    
    // Load saved settings
    [self loadSettings];
    
    // Initial UI state
    [self updateUI];
}

- (void)createUI {
    // Create main scroll view
    NSScrollView *mainScrollView = [[NSScrollView alloc] init];
    mainScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    mainScrollView.hasVerticalScroller = YES;
    mainScrollView.hasHorizontalScroller = NO;
    mainScrollView.autohidesScrollers = YES;
    mainScrollView.borderType = NSNoBorder;
    
    // Create main content view
    NSView *contentView = [[NSView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.view = [[NSView alloc] init];
    [self.view addSubview:mainScrollView];
    mainScrollView.documentView = contentView;
    
    // Header section
    NSView *headerView = [[NSView alloc] init];
    headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:headerView];
    
    // Title
    NSTextField *titleLabel = [[NSTextField alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.stringValue = @"Settings & Preferences";
    titleLabel.font = [NSFont systemFontOfSize:24 weight:NSFontWeightBold];
    titleLabel.textColor = [NSColor labelColor];
    titleLabel.backgroundColor = [NSColor clearColor];
    titleLabel.bordered = NO;
    titleLabel.editable = NO;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.usesSingleLineMode = NO;
    titleLabel.maximumNumberOfLines = 0;
    [headerView addSubview:titleLabel];
    
    // Subtitle
    NSTextField *subtitleLabel = [[NSTextField alloc] init];
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    subtitleLabel.stringValue = @"Configure RepliQ to work exactly how you want it";
    subtitleLabel.font = [NSFont systemFontOfSize:13];
    subtitleLabel.textColor = [NSColor secondaryLabelColor];
    subtitleLabel.backgroundColor = [NSColor clearColor];
    subtitleLabel.bordered = NO;
    subtitleLabel.editable = NO;
    subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    subtitleLabel.usesSingleLineMode = NO;
    subtitleLabel.maximumNumberOfLines = 0;
    [headerView addSubview:subtitleLabel];
    
    // General settings section
    NSTextField *generalSectionLabel = [[NSTextField alloc] init];
    generalSectionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    generalSectionLabel.stringValue = @"General";
    generalSectionLabel.font = [NSFont systemFontOfSize:16 weight:NSFontWeightSemibold];
    generalSectionLabel.textColor = [NSColor labelColor];
    generalSectionLabel.backgroundColor = [NSColor clearColor];
    generalSectionLabel.bordered = NO;
    generalSectionLabel.editable = NO;
    [contentView addSubview:generalSectionLabel];
    
    NSView *generalSection = [[NSView alloc] init];
    generalSection.translatesAutoresizingMaskIntoConstraints = NO;
    generalSection.wantsLayer = YES;
    generalSection.layer.backgroundColor = [NSColor controlBackgroundColor].CGColor;
    generalSection.layer.cornerRadius = 8;
    generalSection.layer.borderWidth = 1;
    generalSection.layer.borderColor = [NSColor separatorColor].CGColor;
    [contentView addSubview:generalSection];
    
    // Launch at login checkbox
    self.launchAtLoginCheckbox = [[NSButton alloc] init];
    self.launchAtLoginCheckbox.translatesAutoresizingMaskIntoConstraints = NO;
    [self.launchAtLoginCheckbox setButtonType:NSButtonTypeSwitch];
    [self.launchAtLoginCheckbox setTitle:@"Launch at login"];
    self.launchAtLoginCheckbox.font = [NSFont systemFontOfSize:14 weight:NSFontWeightMedium];
    self.launchAtLoginCheckbox.target = self;
    self.launchAtLoginCheckbox.action = @selector(launchAtLoginCheckboxChanged:);
    [generalSection addSubview:self.launchAtLoginCheckbox];
    
    // Monitor clipboard checkbox
    self.monitorClipboardCheckbox = [[NSButton alloc] init];
    self.monitorClipboardCheckbox.translatesAutoresizingMaskIntoConstraints = NO;
    [self.monitorClipboardCheckbox setButtonType:NSButtonTypeSwitch];
    [self.monitorClipboardCheckbox setTitle:@"Enable monitoring"];
    self.monitorClipboardCheckbox.font = [NSFont systemFontOfSize:14 weight:NSFontWeightMedium];
    self.monitorClipboardCheckbox.target = self;
    self.monitorClipboardCheckbox.action = @selector(monitorClipboardCheckboxChanged:);
    [generalSection addSubview:self.monitorClipboardCheckbox];
    
    // Status section
    NSTextField *statusSectionLabel = [[NSTextField alloc] init];
    statusSectionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    statusSectionLabel.stringValue = @"Status";
    statusSectionLabel.font = [NSFont systemFontOfSize:16 weight:NSFontWeightSemibold];
    statusSectionLabel.textColor = [NSColor labelColor];
    statusSectionLabel.backgroundColor = [NSColor clearColor];
    statusSectionLabel.bordered = NO;
    statusSectionLabel.editable = NO;
    [contentView addSubview:statusSectionLabel];
    
    NSView *statusSection = [[NSView alloc] init];
    statusSection.translatesAutoresizingMaskIntoConstraints = NO;
    statusSection.wantsLayer = YES;
    statusSection.layer.backgroundColor = [NSColor controlBackgroundColor].CGColor;
    statusSection.layer.cornerRadius = 8;
    statusSection.layer.borderWidth = 1;
    statusSection.layer.borderColor = [NSColor separatorColor].CGColor;
    [contentView addSubview:statusSection];
    
    // Status label
    self.statusLabel = [[NSTextField alloc] init];
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusLabel.backgroundColor = [NSColor clearColor];
    self.statusLabel.bordered = NO;
    self.statusLabel.editable = NO;
    self.statusLabel.font = [NSFont systemFontOfSize:13];
    self.statusLabel.textColor = [NSColor labelColor];
    self.statusLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.statusLabel.usesSingleLineMode = NO;
    self.statusLabel.maximumNumberOfLines = 0;
    [statusSection addSubview:self.statusLabel];
    
    // About section
    NSTextField *aboutSectionLabel = [[NSTextField alloc] init];
    aboutSectionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    aboutSectionLabel.stringValue = @"About RepliQ";
    aboutSectionLabel.font = [NSFont systemFontOfSize:16 weight:NSFontWeightSemibold];
    aboutSectionLabel.textColor = [NSColor labelColor];
    aboutSectionLabel.backgroundColor = [NSColor clearColor];
    aboutSectionLabel.bordered = NO;
    aboutSectionLabel.editable = NO;
    [contentView addSubview:aboutSectionLabel];
    
    NSView *aboutSection = [[NSView alloc] init];
    aboutSection.translatesAutoresizingMaskIntoConstraints = NO;
    aboutSection.wantsLayer = YES;
    aboutSection.layer.backgroundColor = [NSColor controlBackgroundColor].CGColor;
    aboutSection.layer.cornerRadius = 8;
    aboutSection.layer.borderWidth = 1;
    aboutSection.layer.borderColor = [NSColor separatorColor].CGColor;
    [contentView addSubview:aboutSection];
    
    // App icon
    NSImageView *appIcon = [[NSImageView alloc] init];
    appIcon.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(macOS 11.0, *)) {
        appIcon.image = [NSImage imageWithSystemSymbolName:@"doc.text.replace" accessibilityDescription:@"RepliQ"];
        appIcon.contentTintColor = [NSColor systemBlueColor];
    }
    [aboutSection addSubview:appIcon];
    
    // About text
    NSTextField *aboutLabel = [[NSTextField alloc] init];
    aboutLabel.translatesAutoresizingMaskIntoConstraints = NO;
    aboutLabel.stringValue = @"RepliQ - Intelligent text replacement for macOS.\nMonitor clipboard and replace text with custom rules.";
    aboutLabel.backgroundColor = [NSColor clearColor];
    aboutLabel.bordered = NO;
    aboutLabel.editable = NO;
    aboutLabel.font = [NSFont systemFontOfSize:12];
    aboutLabel.textColor = [NSColor tertiaryLabelColor];
    aboutLabel.lineBreakMode = NSLineBreakByWordWrapping;
    aboutLabel.usesSingleLineMode = NO;
    aboutLabel.maximumNumberOfLines = 0;
    [aboutSection addSubview:aboutLabel];
    
    // Set up constraints
    [self setupConstraints:mainScrollView 
               contentView:contentView 
                headerView:headerView 
                titleLabel:titleLabel
              subtitleLabel:subtitleLabel
      generalSectionLabel:generalSectionLabel
            generalSection:generalSection
        statusSectionLabel:statusSectionLabel
             statusSection:statusSection
          aboutSectionLabel:aboutSectionLabel
              aboutSection:aboutSection
                   appIcon:appIcon
                aboutLabel:aboutLabel];
}

- (void)setupConstraints:(NSScrollView *)mainScrollView 
             contentView:(NSView *)contentView 
              headerView:(NSView *)headerView 
              titleLabel:(NSTextField *)titleLabel 
            subtitleLabel:(NSTextField *)subtitleLabel 
    generalSectionLabel:(NSTextField *)generalSectionLabel 
          generalSection:(NSView *)generalSection 
      statusSectionLabel:(NSTextField *)statusSectionLabel 
           statusSection:(NSView *)statusSection 
        aboutSectionLabel:(NSTextField *)aboutSectionLabel 
            aboutSection:(NSView *)aboutSection 
                 appIcon:(NSImageView *)appIcon 
                aboutLabel:(NSTextField *)aboutLabel {
    
    // Main scroll view constraints
    [NSLayoutConstraint activateConstraints:@[
        [mainScrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [mainScrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [mainScrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [mainScrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    
    // Content view constraints
    [NSLayoutConstraint activateConstraints:@[
        [contentView.topAnchor constraintEqualToAnchor:mainScrollView.topAnchor],
        [contentView.leadingAnchor constraintEqualToAnchor:mainScrollView.leadingAnchor],
        [contentView.trailingAnchor constraintEqualToAnchor:mainScrollView.trailingAnchor],
        [contentView.widthAnchor constraintEqualToAnchor:mainScrollView.widthAnchor],
        [contentView.widthAnchor constraintLessThanOrEqualToConstant:600]
    ]];
    
    // Header view constraints
    [NSLayoutConstraint activateConstraints:@[
        [headerView.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:20],
        [headerView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [headerView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],
        [headerView.heightAnchor constraintEqualToConstant:60]
    ]];
    
    // Title constraints
    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:headerView.topAnchor],
        [titleLabel.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor],
        [titleLabel.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor]
    ]];
    
    // Subtitle constraints
    [NSLayoutConstraint activateConstraints:@[
        [subtitleLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:4],
        [subtitleLabel.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor],
        [subtitleLabel.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor],
        [subtitleLabel.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor]
    ]];
    
    // General section label constraints
    [NSLayoutConstraint activateConstraints:@[
        [generalSectionLabel.topAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:24],
        [generalSectionLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [generalSectionLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20]
    ]];
    
    // General section constraints
    [NSLayoutConstraint activateConstraints:@[
        [generalSection.topAnchor constraintEqualToAnchor:generalSectionLabel.bottomAnchor constant:8],
        [generalSection.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [generalSection.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],
        [generalSection.heightAnchor constraintEqualToConstant:80]
    ]];
    
    // Launch at login checkbox constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.launchAtLoginCheckbox.topAnchor constraintEqualToAnchor:generalSection.topAnchor constant:16],
        [self.launchAtLoginCheckbox.leadingAnchor constraintEqualToAnchor:generalSection.leadingAnchor constant:16],
        [self.launchAtLoginCheckbox.trailingAnchor constraintEqualToAnchor:generalSection.trailingAnchor constant:-16]
    ]];
    
    // Monitor clipboard checkbox constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.monitorClipboardCheckbox.topAnchor constraintEqualToAnchor:self.launchAtLoginCheckbox.bottomAnchor constant:8],
        [self.monitorClipboardCheckbox.leadingAnchor constraintEqualToAnchor:generalSection.leadingAnchor constant:16],
        [self.monitorClipboardCheckbox.trailingAnchor constraintEqualToAnchor:generalSection.trailingAnchor constant:-16],
        [self.monitorClipboardCheckbox.bottomAnchor constraintEqualToAnchor:generalSection.bottomAnchor constant:-16]
    ]];
    
    // Status section label constraints
    [NSLayoutConstraint activateConstraints:@[
        [statusSectionLabel.topAnchor constraintEqualToAnchor:generalSection.bottomAnchor constant:24],
        [statusSectionLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [statusSectionLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20]
    ]];
    
    // Status section constraints
    [NSLayoutConstraint activateConstraints:@[
        [statusSection.topAnchor constraintEqualToAnchor:statusSectionLabel.bottomAnchor constant:8],
        [statusSection.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [statusSection.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],
        [statusSection.heightAnchor constraintGreaterThanOrEqualToConstant:60]
    ]];
    
    // Status label constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.statusLabel.topAnchor constraintEqualToAnchor:statusSection.topAnchor constant:16],
        [self.statusLabel.leadingAnchor constraintEqualToAnchor:statusSection.leadingAnchor constant:16],
        [self.statusLabel.trailingAnchor constraintEqualToAnchor:statusSection.trailingAnchor constant:-16],
        [self.statusLabel.bottomAnchor constraintEqualToAnchor:statusSection.bottomAnchor constant:-16]
    ]];
    
    // About section label constraints
    [NSLayoutConstraint activateConstraints:@[
        [aboutSectionLabel.topAnchor constraintEqualToAnchor:statusSection.bottomAnchor constant:24],
        [aboutSectionLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [aboutSectionLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20]
    ]];
    
    // About section constraints
    [NSLayoutConstraint activateConstraints:@[
        [aboutSection.topAnchor constraintEqualToAnchor:aboutSectionLabel.bottomAnchor constant:8],
        [aboutSection.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [aboutSection.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],
        [aboutSection.heightAnchor constraintGreaterThanOrEqualToConstant:60],
        [aboutSection.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-20]
    ]];
    
    // App icon constraints
    [NSLayoutConstraint activateConstraints:@[
        [appIcon.topAnchor constraintEqualToAnchor:aboutSection.topAnchor constant:16],
        [appIcon.leadingAnchor constraintEqualToAnchor:aboutSection.leadingAnchor constant:16],
        [appIcon.widthAnchor constraintEqualToConstant:24],
        [appIcon.heightAnchor constraintEqualToConstant:24]
    ]];
    
    // About label constraints
    [NSLayoutConstraint activateConstraints:@[
        [aboutLabel.topAnchor constraintEqualToAnchor:aboutSection.topAnchor constant:16],
        [aboutLabel.leadingAnchor constraintEqualToAnchor:appIcon.trailingAnchor constant:12],
        [aboutLabel.trailingAnchor constraintEqualToAnchor:aboutSection.trailingAnchor constant:-16],
        [aboutLabel.bottomAnchor constraintEqualToAnchor:aboutSection.bottomAnchor constant:-16]
    ]];
}

- (void)updateUI {
    AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
    self.monitorClipboardCheckbox.state = appDelegate.isMonitoringEnabled ? NSControlStateValueOn : NSControlStateValueOff;
    
    // Update launch at login checkbox
    BOOL launchAtLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"LaunchAtLogin"];
    self.launchAtLoginCheckbox.state = launchAtLogin ? NSControlStateValueOn : NSControlStateValueOff;
    
    // Update status label
    NSString *statusText;
    if (appDelegate.isMonitoringEnabled) {
        statusText = @"✅ Monitoring enabled\nRepliQ is watching clipboard changes.";
    } else {
        statusText = @"⚠️ Monitoring disabled\nEnable to start text replacement.";
    }
    
    if (launchAtLogin) {
        statusText = [statusText stringByAppendingString:@"\n🚀 Launch at login enabled"];
    }
    
    self.statusLabel.stringValue = statusText;
}

- (void)viewWillAppear {
    [super viewWillAppear];
    [self updateUI];
}

#pragma mark - IBActions

- (IBAction)launchAtLoginCheckboxChanged:(NSButton *)sender {
    BOOL enabled = (sender.state == NSControlStateValueOn);
    
    // Save to user defaults
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"LaunchAtLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Note: In a production app, you would use SMLoginItemSetEnabled
    // For this demo, we just save the preference
    
    [self updateUI];
}

- (IBAction)monitorClipboardCheckboxChanged:(NSButton *)sender {
    BOOL enabled = (sender.state == NSControlStateValueOn);
    
    AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
    if (enabled) {
        [appDelegate startMonitoring];
    } else {
        [appDelegate stopMonitoring];
    }
    
    [self updateUI];
}

#pragma mark - Data Management

- (void)loadSettings {
    // Settings are loaded automatically in updateUI
}

@end 
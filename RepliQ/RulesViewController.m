//
//  RulesViewController.m
//  RepliQ
//
//  Created by Vincent Yang on 6/16/25.
//

#import "RulesViewController.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface RulesViewController ()
@property (nonatomic, strong) NSMutableArray<ReplacementRule *> *replacementRules;
@property (nonatomic, strong) NSTextField *keywordTextField;
@property (nonatomic, strong) NSTextField *replacementTextField;
@property (nonatomic, strong) NSButton *addRuleButton;
@property (nonatomic, strong) NSButton *deleteRuleButton;
@property (nonatomic, strong) NSTableView *rulesTableView;
@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) NSTextField *statusIndicator;
@property (nonatomic, strong) NSTimer *statusCheckTimer;
@end

@implementation RulesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create UI programmatically
    [self createUI];
    
    // Initialize replacement rules
    self.replacementRules = [[NSMutableArray alloc] init];
    
    // Load saved rules
    [self loadReplacementRules];
    
    // Set up clipboard manager
    [ClipboardManager sharedManager].replacementRules = self.replacementRules;
    
    // Configure table view
    self.rulesTableView.dataSource = self;
    self.rulesTableView.delegate = self;
    
    // Add self as delegate to clipboard manager
    [[ClipboardManager sharedManager] addDelegate:self];
    
    // Set up text field delegates for real-time validation
    self.keywordTextField.delegate = self;
    self.replacementTextField.delegate = self;
    
    // Initial UI state
    [self updateUI];
    
    // Load some default rules if none exist
    if (self.replacementRules.count == 0) {
        [self loadDefaultRules];
    }
    
    // Listen for monitoring status changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(monitoringStatusDidChange:)
                                                 name:RepliQMonitoringStatusDidChangeNotification
                                               object:nil];
    
    // Start a timer to periodically check monitoring status until it's correctly initialized
    [self startStatusCheckTimer];
}

- (void)createUI {
    // Create main scroll view for better content management
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
    titleLabel.stringValue = @"Text Replacement Rules";
    titleLabel.font = [NSFont systemFontOfSize:24 weight:NSFontWeightBold];
    titleLabel.textColor = [NSColor labelColor];
    titleLabel.backgroundColor = [NSColor clearColor];
    titleLabel.bordered = NO;
    titleLabel.editable = NO;
    [headerView addSubview:titleLabel];
    
    // Subtitle
    NSTextField *subtitleLabel = [[NSTextField alloc] init];
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    subtitleLabel.stringValue = @"Create rules to automatically replace text in your clipboard";
    subtitleLabel.font = [NSFont systemFontOfSize:13];
    subtitleLabel.textColor = [NSColor secondaryLabelColor];
    subtitleLabel.backgroundColor = [NSColor clearColor];
    subtitleLabel.bordered = NO;
    subtitleLabel.editable = NO;
    [headerView addSubview:subtitleLabel];
    
    // Status indicator
    self.statusIndicator = [[NSTextField alloc] init];
    self.statusIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusIndicator.font = [NSFont systemFontOfSize:12 weight:NSFontWeightMedium];
    self.statusIndicator.backgroundColor = [NSColor clearColor];
    self.statusIndicator.bordered = NO;
    self.statusIndicator.editable = NO;
    [headerView addSubview:self.statusIndicator];
    
    // Input section
    NSView *inputSection = [[NSView alloc] init];
    inputSection.translatesAutoresizingMaskIntoConstraints = NO;
    inputSection.wantsLayer = YES;
    inputSection.layer.backgroundColor = [NSColor controlBackgroundColor].CGColor;
    inputSection.layer.cornerRadius = 8;
    inputSection.layer.borderWidth = 1;
    inputSection.layer.borderColor = [NSColor separatorColor].CGColor;
    [contentView addSubview:inputSection];
    
    // Find text field
    NSTextField *findLabel = [[NSTextField alloc] init];
    findLabel.translatesAutoresizingMaskIntoConstraints = NO;
    findLabel.stringValue = @"Find:";
    findLabel.font = [NSFont systemFontOfSize:13 weight:NSFontWeightMedium];
    findLabel.textColor = [NSColor labelColor];
    findLabel.backgroundColor = [NSColor clearColor];
    findLabel.bordered = NO;
    findLabel.editable = NO;
    [inputSection addSubview:findLabel];
    
    self.keywordTextField = [[NSTextField alloc] init];
    self.keywordTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.keywordTextField.font = [NSFont systemFontOfSize:13];
    self.keywordTextField.placeholderString = @"Enter text to find";
    self.keywordTextField.target = self;
    self.keywordTextField.action = @selector(textFieldChanged:);
    self.keywordTextField.delegate = self;
    [inputSection addSubview:self.keywordTextField];
    
    // Replace text field
    NSTextField *replaceLabel = [[NSTextField alloc] init];
    replaceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    replaceLabel.stringValue = @"Replace with:";
    replaceLabel.font = [NSFont systemFontOfSize:13 weight:NSFontWeightMedium];
    replaceLabel.textColor = [NSColor labelColor];
    replaceLabel.backgroundColor = [NSColor clearColor];
    replaceLabel.bordered = NO;
    replaceLabel.editable = NO;
    [inputSection addSubview:replaceLabel];
    
    self.replacementTextField = [[NSTextField alloc] init];
    self.replacementTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.replacementTextField.font = [NSFont systemFontOfSize:13];
    self.replacementTextField.placeholderString = @"Enter replacement text";
    self.replacementTextField.target = self;
    self.replacementTextField.action = @selector(textFieldChanged:);
    self.replacementTextField.delegate = self;
    [inputSection addSubview:self.replacementTextField];
    
    // Button section
    NSView *buttonSection = [[NSView alloc] init];
    buttonSection.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:buttonSection];
    
    // Add rule button
    self.addRuleButton = [[NSButton alloc] init];
    self.addRuleButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.addRuleButton setTitle:@"Add Rule"];
    [self.addRuleButton setButtonType:NSButtonTypeMomentaryPushIn];
    [self.addRuleButton setBezelStyle:NSBezelStyleRounded];
    self.addRuleButton.controlSize = NSControlSizeRegular;
    self.addRuleButton.font = [NSFont systemFontOfSize:13 weight:NSFontWeightMedium];
    self.addRuleButton.wantsLayer = YES;
    self.addRuleButton.layer.backgroundColor = [NSColor systemBlueColor].CGColor;
    self.addRuleButton.layer.cornerRadius = 6;
    self.addRuleButton.contentTintColor = [NSColor whiteColor];
    self.addRuleButton.target = self;
    self.addRuleButton.action = @selector(addRuleButtonClicked:);
    [buttonSection addSubview:self.addRuleButton];
    
    // Delete rule button
    self.deleteRuleButton = [[NSButton alloc] init];
    self.deleteRuleButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.deleteRuleButton setTitle:@"Remove Selected"];
    [self.deleteRuleButton setButtonType:NSButtonTypeMomentaryPushIn];
    [self.deleteRuleButton setBezelStyle:NSBezelStyleRounded];
    self.deleteRuleButton.controlSize = NSControlSizeRegular;
    self.deleteRuleButton.font = [NSFont systemFontOfSize:13];
    self.deleteRuleButton.contentTintColor = [NSColor systemRedColor];
    self.deleteRuleButton.enabled = NO;
    self.deleteRuleButton.target = self;
    self.deleteRuleButton.action = @selector(deleteRuleButtonClicked:);
    [buttonSection addSubview:self.deleteRuleButton];
    
    // Rules table section
    NSTextField *rulesLabel = [[NSTextField alloc] init];
    rulesLabel.translatesAutoresizingMaskIntoConstraints = NO;
    rulesLabel.stringValue = @"Active Rules";
    rulesLabel.font = [NSFont systemFontOfSize:16 weight:NSFontWeightSemibold];
    rulesLabel.textColor = [NSColor labelColor];
    rulesLabel.backgroundColor = [NSColor clearColor];
    rulesLabel.bordered = NO;
    rulesLabel.editable = NO;
    [contentView addSubview:rulesLabel];
    
    // Table view
    self.scrollView = [[NSScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.hasVerticalScroller = YES;
    self.scrollView.hasHorizontalScroller = NO;
    self.scrollView.autohidesScrollers = YES;
    self.scrollView.borderType = NSNoBorder;
    self.scrollView.wantsLayer = YES;
    self.scrollView.layer.cornerRadius = 8;
    self.scrollView.layer.borderWidth = 1;
    self.scrollView.layer.borderColor = [NSColor separatorColor].CGColor;
    
    self.rulesTableView = [[NSTableView alloc] init];
    self.rulesTableView.gridStyleMask = NSTableViewSolidHorizontalGridLineMask;
    self.rulesTableView.intercellSpacing = NSMakeSize(0, 1);
    self.rulesTableView.rowHeight = 32;
    self.rulesTableView.headerView = [[NSTableHeaderView alloc] init];
    self.rulesTableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleRegular;
    
    // Create table columns
    NSTableColumn *findColumn = [[NSTableColumn alloc] initWithIdentifier:@"KeywordColumn"];
    findColumn.headerCell.stringValue = @"Find";
    findColumn.minWidth = 120;
    findColumn.width = 200;
    findColumn.resizingMask = NSTableColumnUserResizingMask;
    [self.rulesTableView addTableColumn:findColumn];
    
    NSTableColumn *replaceColumn = [[NSTableColumn alloc] initWithIdentifier:@"ReplacementColumn"];
    replaceColumn.headerCell.stringValue = @"Replace With";
    replaceColumn.minWidth = 120;
    replaceColumn.width = 200;
    replaceColumn.resizingMask = NSTableColumnUserResizingMask;
    [self.rulesTableView addTableColumn:replaceColumn];
    
    NSTableColumn *enabledColumn = [[NSTableColumn alloc] initWithIdentifier:@"EnabledColumn"];
    enabledColumn.headerCell.stringValue = @"Enabled";
    enabledColumn.width = 80;
    enabledColumn.minWidth = 80;
    enabledColumn.maxWidth = 80;
    
    NSButtonCell *checkboxCell = [[NSButtonCell alloc] init];
    [checkboxCell setButtonType:NSButtonTypeSwitch];
    [checkboxCell setTitle:@""];
    [checkboxCell setControlSize:NSControlSizeSmall];
    enabledColumn.dataCell = checkboxCell;
    [self.rulesTableView addTableColumn:enabledColumn];
    
    self.scrollView.documentView = self.rulesTableView;
    [contentView addSubview:self.scrollView];
    
    // Set up constraints
    [self setupConstraints:mainScrollView 
               contentView:contentView 
                headerView:headerView 
                titleLabel:titleLabel
              subtitleLabel:subtitleLabel
              inputSection:inputSection
                 findLabel:findLabel
              replaceLabel:replaceLabel
             buttonSection:buttonSection
                rulesLabel:rulesLabel];
}

- (void)setupConstraints:(NSScrollView *)mainScrollView 
             contentView:(NSView *)contentView 
              headerView:(NSView *)headerView 
              titleLabel:(NSTextField *)titleLabel 
            subtitleLabel:(NSTextField *)subtitleLabel 
            inputSection:(NSView *)inputSection 
               findLabel:(NSTextField *)findLabel 
            replaceLabel:(NSTextField *)replaceLabel 
           buttonSection:(NSView *)buttonSection 
              rulesLabel:(NSTextField *)rulesLabel {
    
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
        [contentView.widthAnchor constraintEqualToAnchor:mainScrollView.widthAnchor]
    ]];
    
    // Header view constraints
    [NSLayoutConstraint activateConstraints:@[
        [headerView.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:20],
        [headerView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [headerView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],
        [headerView.heightAnchor constraintEqualToConstant:80]
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
        [subtitleLabel.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor]
    ]];
    
    // Status indicator constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.statusIndicator.topAnchor constraintEqualToAnchor:subtitleLabel.bottomAnchor constant:8],
        [self.statusIndicator.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor],
        [self.statusIndicator.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor],
        [self.statusIndicator.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor]
    ]];
    
    // Input section constraints
    [NSLayoutConstraint activateConstraints:@[
        [inputSection.topAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:20],
        [inputSection.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [inputSection.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],
        [inputSection.heightAnchor constraintEqualToConstant:120]
    ]];
    
    // Find label and text field constraints
    [NSLayoutConstraint activateConstraints:@[
        [findLabel.topAnchor constraintEqualToAnchor:inputSection.topAnchor constant:16],
        [findLabel.leadingAnchor constraintEqualToAnchor:inputSection.leadingAnchor constant:16],
        [findLabel.widthAnchor constraintEqualToConstant:100]
    ]];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.keywordTextField.centerYAnchor constraintEqualToAnchor:findLabel.centerYAnchor],
        [self.keywordTextField.leadingAnchor constraintEqualToAnchor:findLabel.trailingAnchor constant:8],
        [self.keywordTextField.trailingAnchor constraintEqualToAnchor:inputSection.trailingAnchor constant:-16],
        [self.keywordTextField.heightAnchor constraintEqualToConstant:24]
    ]];
    
    // Replace label and text field constraints
    [NSLayoutConstraint activateConstraints:@[
        [replaceLabel.topAnchor constraintEqualToAnchor:findLabel.bottomAnchor constant:20],
        [replaceLabel.leadingAnchor constraintEqualToAnchor:inputSection.leadingAnchor constant:16],
        [replaceLabel.widthAnchor constraintEqualToConstant:100]
    ]];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.replacementTextField.centerYAnchor constraintEqualToAnchor:replaceLabel.centerYAnchor],
        [self.replacementTextField.leadingAnchor constraintEqualToAnchor:replaceLabel.trailingAnchor constant:8],
        [self.replacementTextField.trailingAnchor constraintEqualToAnchor:inputSection.trailingAnchor constant:-16],
        [self.replacementTextField.heightAnchor constraintEqualToConstant:24]
    ]];
    
    // Button section constraints
    [NSLayoutConstraint activateConstraints:@[
        [buttonSection.topAnchor constraintEqualToAnchor:inputSection.bottomAnchor constant:16],
        [buttonSection.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [buttonSection.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],
        [buttonSection.heightAnchor constraintEqualToConstant:32]
    ]];
    
    // Button constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.addRuleButton.centerYAnchor constraintEqualToAnchor:buttonSection.centerYAnchor],
        [self.addRuleButton.trailingAnchor constraintEqualToAnchor:buttonSection.trailingAnchor],
        [self.addRuleButton.widthAnchor constraintEqualToConstant:100],
        [self.addRuleButton.heightAnchor constraintEqualToConstant:32]
    ]];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.deleteRuleButton.centerYAnchor constraintEqualToAnchor:buttonSection.centerYAnchor],
        [self.deleteRuleButton.trailingAnchor constraintEqualToAnchor:self.addRuleButton.leadingAnchor constant:-12],
        [self.deleteRuleButton.widthAnchor constraintEqualToConstant:120],
        [self.deleteRuleButton.heightAnchor constraintEqualToConstant:32]
    ]];
    
    // Rules label constraints
    [NSLayoutConstraint activateConstraints:@[
        [rulesLabel.topAnchor constraintEqualToAnchor:buttonSection.bottomAnchor constant:24],
        [rulesLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [rulesLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20]
    ]];
    
    // Table view constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:rulesLabel.bottomAnchor constant:12],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],
        [self.scrollView.heightAnchor constraintGreaterThanOrEqualToConstant:200],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-20]
    ]];
}

- (void)loadDefaultRules {
    ReplacementRule *rule1 = [[ReplacementRule alloc] initWithKeyword:@"David" replacement:@"Tim"];
    ReplacementRule *rule2 = [[ReplacementRule alloc] initWithKeyword:@"hello" replacement:@"hi"];
    
    [self.replacementRules addObjectsFromArray:@[rule1, rule2]];
    [self.rulesTableView reloadData];
    [self saveReplacementRules];
    [[ClipboardManager sharedManager] setReplacementRules:self.replacementRules];
}

- (void)updateUI {
    [self.rulesTableView reloadData];
    
    // Update button states
    self.deleteRuleButton.enabled = (self.rulesTableView.selectedRow >= 0);
    
    // Update add button state based on text field content
    NSString *keyword = self.keywordTextField.stringValue;
    NSString *replacement = self.replacementTextField.stringValue;
    self.addRuleButton.enabled = (keyword.length > 0 && replacement.length > 0);
    
    // Update status indicator
    [self updateStatusIndicator];
}

- (void)updateStatusIndicator {
    AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
    if (appDelegate.isMonitoringEnabled) {
        self.statusIndicator.stringValue = @"🟢 Monitoring active - Rules will apply immediately";
        self.statusIndicator.textColor = [NSColor systemGreenColor];
    } else {
        self.statusIndicator.stringValue = @"🔴 Monitoring disabled - Enable in Settings to use rules";
        self.statusIndicator.textColor = [NSColor systemRedColor];
    }
}

- (void)viewWillAppear {
    [super viewWillAppear];
    [self updateUI];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    // Force update UI when view appears to ensure correct monitoring status
    [self updateUI];
}

- (void)monitoringStatusDidChange:(NSNotification *)notification {
    // Update UI when monitoring status changes
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUI];
    });
    
    // Stop the status check timer since we got a notification
    [self stopStatusCheckTimer];
}

- (void)startStatusCheckTimer {
    // Stop any existing timer
    [self stopStatusCheckTimer];
    
    // Create a timer that checks status every 0.2 seconds
    self.statusCheckTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                             target:self
                                                           selector:@selector(checkMonitoringStatus:)
                                                           userInfo:nil
                                                            repeats:YES];
}

- (void)stopStatusCheckTimer {
    if (self.statusCheckTimer) {
        [self.statusCheckTimer invalidate];
        self.statusCheckTimer = nil;
    }
}

- (void)checkMonitoringStatus:(NSTimer *)timer {
    AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
    
    // Check if AppDelegate is properly initialized and has monitoring status
    if (appDelegate && appDelegate.statusItem) {
        [self updateUI];
        
        // If we successfully got the monitoring status, stop the timer
        if (appDelegate.isMonitoringEnabled || timer.userInfo[@"attempts"]) {
            [self stopStatusCheckTimer];
        }
        
        // Safety: stop timer after 10 seconds (50 attempts)
        static int attempts = 0;
        attempts++;
        if (attempts > 50) {
            [self stopStatusCheckTimer];
            attempts = 0;
        }
    }
}

#pragma mark - IBActions

- (IBAction)addRuleButtonClicked:(NSButton *)sender {
    NSString *keyword = self.keywordTextField.stringValue;
    NSString *replacement = self.replacementTextField.stringValue;
    
    if (keyword.length > 0 && replacement.length > 0) {
        // Check if rule already exists
        for (ReplacementRule *existingRule in self.replacementRules) {
            if ([existingRule.keyword.lowercaseString isEqualToString:keyword.lowercaseString]) {
                NSAlert *alert = [[NSAlert alloc] init];
                alert.messageText = @"Rule Already Exists";
                alert.informativeText = [NSString stringWithFormat:@"A rule for '%@' already exists. Please use a different keyword.", keyword];
                [alert addButtonWithTitle:@"OK"];
                [alert runModal];
                return;
            }
        }
        
        ReplacementRule *rule = [[ReplacementRule alloc] initWithKeyword:keyword replacement:replacement];
        [self.replacementRules addObject:rule];
        
        // Save rules
        [self saveReplacementRules];
        
        // Update clipboard manager immediately
        [ClipboardManager sharedManager].replacementRules = self.replacementRules;
        
        // Clear text fields
        self.keywordTextField.stringValue = @"";
        self.replacementTextField.stringValue = @"";
        
        [self updateUI];
        
        // Show success feedback
        [self showRuleAddedFeedback:rule];
        
        NSLog(@"Rule added: '%@' -> '%@'. Total rules: %lu", keyword, replacement, (unsigned long)self.replacementRules.count);
    }
}

- (IBAction)deleteRuleButtonClicked:(NSButton *)sender {
    NSInteger selectedRow = self.rulesTableView.selectedRow;
    if (selectedRow >= 0 && selectedRow < self.replacementRules.count) {
        ReplacementRule *ruleToDelete = self.replacementRules[selectedRow];
        
        // Show confirmation dialog
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Delete Rule";
        alert.informativeText = [NSString stringWithFormat:@"Are you sure you want to delete the rule '%@' → '%@'?", ruleToDelete.keyword, ruleToDelete.replacement];
        [alert addButtonWithTitle:@"Delete"];
        [alert addButtonWithTitle:@"Cancel"];
        alert.alertStyle = NSAlertStyleWarning;
        
        NSModalResponse response = [alert runModal];
        if (response == NSAlertFirstButtonReturn) {
            [self.replacementRules removeObjectAtIndex:selectedRow];
            
            // Save rules
            [self saveReplacementRules];
            
            // Update clipboard manager immediately
            [ClipboardManager sharedManager].replacementRules = self.replacementRules;
            
            [self updateUI];
            
            NSLog(@"Rule deleted: '%@' -> '%@'. Total rules: %lu", ruleToDelete.keyword, ruleToDelete.replacement, (unsigned long)self.replacementRules.count);
        }
    }
}

- (IBAction)textFieldChanged:(NSTextField *)sender {
    [self updateUI];
}

#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)notification {
    [self updateUI];
}

- (void)showRuleAddedFeedback:(ReplacementRule *)rule {
    // Create a container view for better visual effect
    NSView *feedbackContainer = [[NSView alloc] init];
    feedbackContainer.translatesAutoresizingMaskIntoConstraints = NO;
    feedbackContainer.wantsLayer = YES;
    feedbackContainer.layer.backgroundColor = [NSColor systemGreenColor].CGColor;
    feedbackContainer.layer.cornerRadius = 8;
    feedbackContainer.layer.shadowColor = [NSColor blackColor].CGColor;
    feedbackContainer.layer.shadowOffset = CGSizeMake(0, -2);
    feedbackContainer.layer.shadowRadius = 4;
    feedbackContainer.layer.shadowOpacity = 0.2;
    feedbackContainer.alphaValue = 0.0;
    
    // Create the text label
    NSTextField *feedbackLabel = [[NSTextField alloc] init];
    feedbackLabel.translatesAutoresizingMaskIntoConstraints = NO;
    feedbackLabel.stringValue = [NSString stringWithFormat:@"✅ Rule added: '%@' → '%@'", rule.keyword, rule.replacement];
    feedbackLabel.font = [NSFont systemFontOfSize:13 weight:NSFontWeightSemibold];
    feedbackLabel.textColor = [NSColor whiteColor];
    feedbackLabel.backgroundColor = [NSColor clearColor];
    feedbackLabel.bordered = NO;
    feedbackLabel.editable = NO;
    feedbackLabel.alignment = NSTextAlignmentCenter;
    
    [feedbackContainer addSubview:feedbackLabel];
    [self.view addSubview:feedbackContainer];
    
    // Position the feedback container
    [NSLayoutConstraint activateConstraints:@[
        [feedbackContainer.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [feedbackContainer.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:20],
        [feedbackContainer.heightAnchor constraintEqualToConstant:40],
        [feedbackContainer.widthAnchor constraintGreaterThanOrEqualToConstant:200]
    ]];
    
    // Position the label inside the container
    [NSLayoutConstraint activateConstraints:@[
        [feedbackLabel.centerXAnchor constraintEqualToAnchor:feedbackContainer.centerXAnchor],
        [feedbackLabel.centerYAnchor constraintEqualToAnchor:feedbackContainer.centerYAnchor],
        [feedbackLabel.leadingAnchor constraintEqualToAnchor:feedbackContainer.leadingAnchor constant:16],
        [feedbackLabel.trailingAnchor constraintEqualToAnchor:feedbackContainer.trailingAnchor constant:-16]
    ]];
    
    // Animate in with scale effect
    feedbackContainer.layer.transform = CATransform3DMakeScale(0.8, 0.8, 1.0);
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        context.duration = 0.4;
        context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        feedbackContainer.animator.alphaValue = 1.0;
        feedbackContainer.layer.transform = CATransform3DIdentity;
    } completionHandler:^{
        // Animate out after 2.5 seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
                context.duration = 0.4;
                context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                feedbackContainer.animator.alphaValue = 0.0;
                feedbackContainer.layer.transform = CATransform3DMakeScale(0.8, 0.8, 1.0);
            } completionHandler:^{
                [feedbackContainer removeFromSuperview];
            }];
        });
    }];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.replacementRules.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row >= 0 && row < self.replacementRules.count) {
        ReplacementRule *rule = self.replacementRules[row];
        
        if ([tableColumn.identifier isEqualToString:@"KeywordColumn"]) {
            return rule.keyword;
        } else if ([tableColumn.identifier isEqualToString:@"ReplacementColumn"]) {
            return rule.replacement;
        } else if ([tableColumn.identifier isEqualToString:@"EnabledColumn"]) {
            return @(rule.isEnabled);
        }
    }
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row >= 0 && row < self.replacementRules.count) {
        ReplacementRule *rule = self.replacementRules[row];
        
        if ([tableColumn.identifier isEqualToString:@"EnabledColumn"]) {
            rule.isEnabled = [object boolValue];
            [self saveReplacementRules];
            [ClipboardManager sharedManager].replacementRules = self.replacementRules;
        }
    }
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self updateUI];
}

#pragma mark - ClipboardManagerDelegate

- (void)clipboardManager:(ClipboardManager *)manager didReplaceText:(NSString *)originalText withText:(NSString *)replacedText usingRule:(ReplacementRule *)rule {
    NSLog(@"Text replaced: '%@' -> '%@'", originalText, replacedText);
}

#pragma mark - Data Management

- (void)loadReplacementRules {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"ReplacementRules"];
    if (data) {
        NSError *error;
        NSArray *rules = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:[NSArray class], [ReplacementRule class], nil] fromData:data error:&error];
        if (rules && !error) {
            [self.replacementRules setArray:rules];
        }
    }
}

- (void)saveReplacementRules {
    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.replacementRules requiringSecureCoding:YES error:&error];
    if (data && !error) {
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"ReplacementRules"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)dealloc {
    // Remove notification observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Stop status check timer
    [self stopStatusCheckTimer];
    
    // Remove self as delegate from clipboard manager
    [[ClipboardManager sharedManager] removeDelegate:self];
}

@end 
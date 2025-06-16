//
//  ViewController.m
//  RepliQ
//
//  Created by Vincent Yang on 6/16/25.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray<ReplacementRule *> *replacementRules;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize replacement rules
    self.replacementRules = [[NSMutableArray alloc] init];
    
    // Load saved rules
    [self loadReplacementRules];
    
    // Set up clipboard manager
    [[ClipboardManager sharedManager] addDelegate:self];
    [ClipboardManager sharedManager].replacementRules = self.replacementRules;
    
    // Configure table view
    self.rulesTableView.dataSource = self;
    self.rulesTableView.delegate = self;
    
    // Initial UI state
    [self updateUI];
    
    // Load some default rules if none exist
    if (self.replacementRules.count == 0) {
        [self loadDefaultRules];
    }
    
    // Hide the monitoring button since it's now handled by menu bar
    self.enableMonitoringButton.hidden = YES;
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
    // Update current clipboard content
    NSString *currentClipboard = [[NSPasteboard generalPasteboard] stringForType:NSPasteboardTypeString];
    if (currentClipboard && currentClipboard.length > 0) {
        NSString *preview = currentClipboard.length > 50 ? 
            [NSString stringWithFormat:@"%@...", [currentClipboard substringToIndex:50]] : 
            currentClipboard;
        self.currentClipboardLabel.stringValue = [NSString stringWithFormat:@"Current: %@", preview];
    } else {
        self.currentClipboardLabel.stringValue = @"Current: (empty)";
    }
    
    // Update button states
    self.deleteRuleButton.enabled = (self.rulesTableView.selectedRow >= 0);
    self.addRuleButton.enabled = (self.keywordTextField.stringValue.length > 0 && 
                                 self.replacementTextField.stringValue.length > 0);
    
    // Update status - show monitoring status from ClipboardManager
    AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
    if (appDelegate.isMonitoringEnabled) {
        self.statusLabel.stringValue = @"Status: Monitoring clipboard (via menu bar)";
    } else {
        self.statusLabel.stringValue = @"Status: Monitoring stopped (use menu bar to start)";
    }
}

- (void)viewWillAppear {
    [super viewWillAppear];
    [self updateUI];
}

#pragma mark - IBActions

- (IBAction)addRuleButtonClicked:(NSButton *)sender {
    NSString *keyword = self.keywordTextField.stringValue;
    NSString *replacement = self.replacementTextField.stringValue;
    
    if (keyword.length > 0 && replacement.length > 0) {
        ReplacementRule *newRule = [[ReplacementRule alloc] initWithKeyword:keyword replacement:replacement];
        [self.replacementRules addObject:newRule];
        
        [self.rulesTableView reloadData];
        [self saveReplacementRules];
        [[ClipboardManager sharedManager] setReplacementRules:self.replacementRules];
        
        // Clear input fields
        self.keywordTextField.stringValue = @"";
        self.replacementTextField.stringValue = @"";
        
        [self updateUI];
    }
}

- (IBAction)deleteRuleButtonClicked:(NSButton *)sender {
    NSInteger selectedRow = self.rulesTableView.selectedRow;
    if (selectedRow >= 0 && selectedRow < self.replacementRules.count) {
        [self.replacementRules removeObjectAtIndex:selectedRow];
        
        [self.rulesTableView reloadData];
        [self saveReplacementRules];
        [[ClipboardManager sharedManager] setReplacementRules:self.replacementRules];
        
        [self updateUI];
    }
}

- (IBAction)enableMonitoringButtonClicked:(NSButton *)sender {
    // This is now handled by the menu bar, but keep for compatibility
    AppDelegate *appDelegate = (AppDelegate *)[NSApp delegate];
    [appDelegate toggleMonitoring];
    [self updateUI];
}

- (IBAction)textFieldChanged:(NSTextField *)sender {
    [self updateUI];
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
            [[ClipboardManager sharedManager] setReplacementRules:self.replacementRules];
        }
    }
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self updateUI];
}

#pragma mark - ClipboardManagerDelegate

- (void)clipboardDidChange:(NSString *)newContent originalContent:(NSString *)originalContent {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUI];
        
        // Show a brief notification in the status label
        self.statusLabel.stringValue = [NSString stringWithFormat:@"Replaced: '%@' -> '%@'", 
                                       originalContent.length > 20 ? [NSString stringWithFormat:@"%@...", [originalContent substringToIndex:20]] : originalContent,
                                       newContent.length > 20 ? [NSString stringWithFormat:@"%@...", [newContent substringToIndex:20]] : newContent];
        
        // Reset status after 3 seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateUI];
        });
    });
}

#pragma mark - Persistence

- (void)saveReplacementRules {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.replacementRules requiringSecureCoding:YES error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"ReplacementRules"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadReplacementRules {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"ReplacementRules"];
    if (data) {
        NSError *error;
        NSArray *rules = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:[NSArray class], [ReplacementRule class], nil] 
                                                             fromData:data 
                                                                error:&error];
        if (rules && !error) {
            self.replacementRules = [rules mutableCopy];
        }
    }
    
    if (!self.replacementRules) {
        self.replacementRules = [[NSMutableArray alloc] init];
    }
}

- (void)dealloc {
    [[ClipboardManager sharedManager] removeDelegate:self];
}

@end

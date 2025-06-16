//
//  HistoryViewController.m
//  RepliQ
//
//  Created by Vincent Yang on 6/16/25.
//

#import "HistoryViewController.h"

@interface HistoryItem : NSObject <NSSecureCoding>
@property (nonatomic, strong) NSString *originalText;
@property (nonatomic, strong) NSString *replacedText;
@property (nonatomic, strong) NSDate *timestamp;
@end

@implementation HistoryItem

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithOriginalText:(NSString *)originalText replacedText:(NSString *)replacedText {
    self = [super init];
    if (self) {
        _originalText = originalText;
        _replacedText = replacedText;
        _timestamp = [NSDate date];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.originalText forKey:@"originalText"];
    [coder encodeObject:self.replacedText forKey:@"replacedText"];
    [coder encodeObject:self.timestamp forKey:@"timestamp"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _originalText = [coder decodeObjectOfClass:[NSString class] forKey:@"originalText"];
        _replacedText = [coder decodeObjectOfClass:[NSString class] forKey:@"replacedText"];
        _timestamp = [coder decodeObjectOfClass:[NSDate class] forKey:@"timestamp"];
    }
    return self;
}

@end

@interface HistoryViewController ()
@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"HistoryViewController viewDidLoad called");
    
    // Always create UI programmatically to ensure it works
    [self createUI];
    
    // Initialize history
    self.historyItems = [[NSMutableArray alloc] init];
    
    // Load saved history
    [self loadHistory];
    
    // Set up table view
    self.historyTableView.dataSource = self;
    self.historyTableView.delegate = self;
    
    // Add self as delegate to clipboard manager
    [[ClipboardManager sharedManager] addDelegate:self];
    
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
    titleLabel.stringValue = @"Replacement History";
    titleLabel.font = [NSFont systemFontOfSize:24 weight:NSFontWeightBold];
    titleLabel.textColor = [NSColor labelColor];
    titleLabel.backgroundColor = [NSColor clearColor];
    titleLabel.bordered = NO;
    titleLabel.editable = NO;
    [headerView addSubview:titleLabel];
    
    // Subtitle
    NSTextField *subtitleLabel = [[NSTextField alloc] init];
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    subtitleLabel.stringValue = @"Track all text replacements made by RepliQ";
    subtitleLabel.font = [NSFont systemFontOfSize:13];
    subtitleLabel.textColor = [NSColor secondaryLabelColor];
    subtitleLabel.backgroundColor = [NSColor clearColor];
    subtitleLabel.bordered = NO;
    subtitleLabel.editable = NO;
    [headerView addSubview:subtitleLabel];
    
    // Stats section
    NSView *statsSection = [[NSView alloc] init];
    statsSection.translatesAutoresizingMaskIntoConstraints = NO;
    statsSection.wantsLayer = YES;
    statsSection.layer.backgroundColor = [NSColor controlBackgroundColor].CGColor;
    statsSection.layer.cornerRadius = 8;
    statsSection.layer.borderWidth = 1;
    statsSection.layer.borderColor = [NSColor separatorColor].CGColor;
    [contentView addSubview:statsSection];
    
    // Stats icon and label
    NSImageView *statsIcon = [[NSImageView alloc] init];
    statsIcon.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(macOS 11.0, *)) {
        statsIcon.image = [NSImage imageWithSystemSymbolName:@"chart.bar.fill" accessibilityDescription:@"Statistics"];
        statsIcon.contentTintColor = [NSColor systemBlueColor];
    }
    [statsSection addSubview:statsIcon];
    
    self.statsLabel = [[NSTextField alloc] init];
    self.statsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.statsLabel.stringValue = [NSString stringWithFormat:@"Total Replacements: %lu", (unsigned long)self.historyItems.count];
    self.statsLabel.font = [NSFont systemFontOfSize:14 weight:NSFontWeightMedium];
    self.statsLabel.textColor = [NSColor labelColor];
    self.statsLabel.backgroundColor = [NSColor clearColor];
    self.statsLabel.bordered = NO;
    self.statsLabel.editable = NO;
    [statsSection addSubview:self.statsLabel];
    
    // Control section
    NSView *controlSection = [[NSView alloc] init];
    controlSection.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:controlSection];
    
    // Clear history button
    self.clearHistoryButton = [[NSButton alloc] init];
    self.clearHistoryButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.clearHistoryButton setTitle:@"Clear History"];
    [self.clearHistoryButton setButtonType:NSButtonTypeMomentaryPushIn];
    [self.clearHistoryButton setBezelStyle:NSBezelStyleRounded];
    self.clearHistoryButton.controlSize = NSControlSizeRegular;
    self.clearHistoryButton.font = [NSFont systemFontOfSize:13 weight:NSFontWeightMedium];
    self.clearHistoryButton.wantsLayer = YES;
    self.clearHistoryButton.layer.backgroundColor = [NSColor systemOrangeColor].CGColor;
    self.clearHistoryButton.layer.cornerRadius = 6;
    self.clearHistoryButton.contentTintColor = [NSColor whiteColor];
    self.clearHistoryButton.target = self;
    self.clearHistoryButton.action = @selector(clearHistoryButtonClicked:);
    [controlSection addSubview:self.clearHistoryButton];
    
    // History section label
    NSTextField *historyLabel = [[NSTextField alloc] init];
    historyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    historyLabel.stringValue = @"Recent Activity";
    historyLabel.font = [NSFont systemFontOfSize:16 weight:NSFontWeightSemibold];
    historyLabel.textColor = [NSColor labelColor];
    historyLabel.backgroundColor = [NSColor clearColor];
    historyLabel.bordered = NO;
    historyLabel.editable = NO;
    [contentView addSubview:historyLabel];
    
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
    
    self.historyTableView = [[NSTableView alloc] init];
    self.historyTableView.gridStyleMask = NSTableViewSolidHorizontalGridLineMask;
    self.historyTableView.intercellSpacing = NSMakeSize(0, 1);
    self.historyTableView.rowHeight = 36;
    self.historyTableView.headerView = [[NSTableHeaderView alloc] init];
    self.historyTableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleRegular;
    self.historyTableView.backgroundColor = [NSColor controlBackgroundColor];
    
    // Create table columns
    NSTableColumn *timeColumn = [[NSTableColumn alloc] initWithIdentifier:@"TimeColumn"];
    timeColumn.headerCell.stringValue = @"Time";
    timeColumn.width = 120;
    timeColumn.minWidth = 100;
    timeColumn.maxWidth = 150;
    timeColumn.resizingMask = NSTableColumnUserResizingMask;
    [self.historyTableView addTableColumn:timeColumn];
    
    NSTableColumn *originalColumn = [[NSTableColumn alloc] initWithIdentifier:@"OriginalColumn"];
    originalColumn.headerCell.stringValue = @"Original Text";
    originalColumn.width = 200;
    originalColumn.minWidth = 120;
    originalColumn.resizingMask = NSTableColumnUserResizingMask;
    [self.historyTableView addTableColumn:originalColumn];
    
    NSTableColumn *replacedColumn = [[NSTableColumn alloc] initWithIdentifier:@"ReplacedColumn"];
    replacedColumn.headerCell.stringValue = @"Replaced With";
    replacedColumn.width = 200;
    replacedColumn.minWidth = 120;
    replacedColumn.resizingMask = NSTableColumnUserResizingMask;
    [self.historyTableView addTableColumn:replacedColumn];
    
    self.scrollView.documentView = self.historyTableView;
    [contentView addSubview:self.scrollView];
    
    // Empty state view
    self.emptyStateView = [[NSView alloc] init];
    self.emptyStateView.translatesAutoresizingMaskIntoConstraints = NO;
    self.emptyStateView.wantsLayer = YES;
    self.emptyStateView.layer.backgroundColor = [NSColor controlBackgroundColor].CGColor;
    self.emptyStateView.layer.cornerRadius = 8;
    self.emptyStateView.layer.borderWidth = 1;
    self.emptyStateView.layer.borderColor = [NSColor separatorColor].CGColor;
    
    // Empty state icon
    NSImageView *emptyIcon = [[NSImageView alloc] init];
    emptyIcon.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(macOS 11.0, *)) {
        emptyIcon.image = [NSImage imageWithSystemSymbolName:@"clock.arrow.circlepath" accessibilityDescription:@"No History"];
        emptyIcon.contentTintColor = [NSColor tertiaryLabelColor];
    }
    [self.emptyStateView addSubview:emptyIcon];
    
    // Empty state text
    NSTextField *emptyLabel = [[NSTextField alloc] init];
    emptyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    emptyLabel.stringValue = @"No replacement history yet\nStart using text rules to see activity here";
    emptyLabel.font = [NSFont systemFontOfSize:14];
    emptyLabel.textColor = [NSColor tertiaryLabelColor];
    emptyLabel.backgroundColor = [NSColor clearColor];
    emptyLabel.bordered = NO;
    emptyLabel.editable = NO;
    emptyLabel.alignment = NSTextAlignmentCenter;
    [self.emptyStateView addSubview:emptyLabel];
    
    // Initially hide empty state
    self.emptyStateView.hidden = self.historyItems.count > 0;
    [contentView addSubview:self.emptyStateView];
    
    // Set up constraints
    [self setupConstraints:mainScrollView 
               contentView:contentView 
                headerView:headerView 
                titleLabel:titleLabel
              subtitleLabel:subtitleLabel
              statsSection:statsSection
                 statsIcon:statsIcon
                statsLabel:self.statsLabel
            controlSection:controlSection
              historyLabel:historyLabel
            emptyStateView:self.emptyStateView
                 emptyIcon:emptyIcon
                emptyLabel:emptyLabel];
}

- (void)setupConstraints:(NSScrollView *)mainScrollView 
             contentView:(NSView *)contentView 
              headerView:(NSView *)headerView 
              titleLabel:(NSTextField *)titleLabel 
            subtitleLabel:(NSTextField *)subtitleLabel 
            statsSection:(NSView *)statsSection 
               statsIcon:(NSImageView *)statsIcon 
              statsLabel:(NSTextField *)statsLabel 
          controlSection:(NSView *)controlSection 
            historyLabel:(NSTextField *)historyLabel 
          emptyStateView:(NSView *)emptyStateView 
               emptyIcon:(NSImageView *)emptyIcon 
              emptyLabel:(NSTextField *)emptyLabel {
    
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
    
    // Stats section constraints
    [NSLayoutConstraint activateConstraints:@[
        [statsSection.topAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:20],
        [statsSection.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [statsSection.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],
        [statsSection.heightAnchor constraintEqualToConstant:50]
    ]];
    
    // Stats icon constraints
    [NSLayoutConstraint activateConstraints:@[
        [statsIcon.centerYAnchor constraintEqualToAnchor:statsSection.centerYAnchor],
        [statsIcon.leadingAnchor constraintEqualToAnchor:statsSection.leadingAnchor constant:16],
        [statsIcon.widthAnchor constraintEqualToConstant:20],
        [statsIcon.heightAnchor constraintEqualToConstant:20]
    ]];
    
    // Stats label constraints
    [NSLayoutConstraint activateConstraints:@[
        [statsLabel.centerYAnchor constraintEqualToAnchor:statsSection.centerYAnchor],
        [statsLabel.leadingAnchor constraintEqualToAnchor:statsIcon.trailingAnchor constant:12],
        [statsLabel.trailingAnchor constraintEqualToAnchor:statsSection.trailingAnchor constant:-16]
    ]];
    
    // Control section constraints
    [NSLayoutConstraint activateConstraints:@[
        [controlSection.topAnchor constraintEqualToAnchor:statsSection.bottomAnchor constant:16],
        [controlSection.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [controlSection.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],
        [controlSection.heightAnchor constraintEqualToConstant:32]
    ]];
    
    // Clear button constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.clearHistoryButton.centerYAnchor constraintEqualToAnchor:controlSection.centerYAnchor],
        [self.clearHistoryButton.trailingAnchor constraintEqualToAnchor:controlSection.trailingAnchor],
        [self.clearHistoryButton.widthAnchor constraintEqualToConstant:120],
        [self.clearHistoryButton.heightAnchor constraintEqualToConstant:32]
    ]];
    
    // History label constraints
    [NSLayoutConstraint activateConstraints:@[
        [historyLabel.topAnchor constraintEqualToAnchor:controlSection.bottomAnchor constant:24],
        [historyLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [historyLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20]
    ]];
    
    // Table view constraints
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:historyLabel.bottomAnchor constant:12],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],
        [self.scrollView.heightAnchor constraintGreaterThanOrEqualToConstant:200],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-20]
    ]];
    
    // Empty state view constraints (same position as table view)
    [NSLayoutConstraint activateConstraints:@[
        [emptyStateView.topAnchor constraintEqualToAnchor:historyLabel.bottomAnchor constant:12],
        [emptyStateView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:20],
        [emptyStateView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-20],
        [emptyStateView.heightAnchor constraintEqualToConstant:200]
    ]];
    
    // Empty state icon constraints
    [NSLayoutConstraint activateConstraints:@[
        [emptyIcon.centerXAnchor constraintEqualToAnchor:emptyStateView.centerXAnchor],
        [emptyIcon.topAnchor constraintEqualToAnchor:emptyStateView.topAnchor constant:60],
        [emptyIcon.widthAnchor constraintEqualToConstant:40],
        [emptyIcon.heightAnchor constraintEqualToConstant:40]
    ]];
    
    // Empty state label constraints
    [NSLayoutConstraint activateConstraints:@[
        [emptyLabel.topAnchor constraintEqualToAnchor:emptyIcon.bottomAnchor constant:16],
        [emptyLabel.centerXAnchor constraintEqualToAnchor:emptyStateView.centerXAnchor],
        [emptyLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:emptyStateView.leadingAnchor constant:20],
        [emptyLabel.trailingAnchor constraintLessThanOrEqualToAnchor:emptyStateView.trailingAnchor constant:-20]
    ]];
}

- (void)updateUI {
    NSLog(@"HistoryViewController updateUI: %lu items", (unsigned long)self.historyItems.count);
    
    // Update stats label
    if (self.statsLabel) {
        self.statsLabel.stringValue = [NSString stringWithFormat:@"Total Replacements: %lu", (unsigned long)self.historyItems.count];
    }
    
    // Update table view
    [self.historyTableView reloadData];
    
    // Update button state
    self.clearHistoryButton.enabled = (self.historyItems.count > 0);
    
    // Show/hide empty state based on whether we have items
    BOOL hasItems = (self.historyItems.count > 0);
    self.emptyStateView.hidden = hasItems;
    self.scrollView.hidden = !hasItems;
    
    NSLog(@"HistoryViewController updateUI: hasItems=%@, emptyStateView.hidden=%@, scrollView.hidden=%@", 
          hasItems ? @"YES" : @"NO",
          self.emptyStateView.hidden ? @"YES" : @"NO", 
          self.scrollView.hidden ? @"YES" : @"NO");
}

- (void)viewWillAppear {
    [super viewWillAppear];
    [self updateUI];
}

#pragma mark - IBActions

- (IBAction)clearHistoryButtonClicked:(NSButton *)sender {
    [self.historyItems removeAllObjects];
    [self saveHistory];
    [self updateUI];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    NSLog(@"HistoryViewController numberOfRowsInTableView: returning %lu rows", (unsigned long)self.historyItems.count);
    return self.historyItems.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSLog(@"HistoryViewController objectValueForTableColumn: row=%ld, column=%@", (long)row, tableColumn.identifier);
    
    if (row >= 0 && row < self.historyItems.count) {
        HistoryItem *item = self.historyItems[row];
        
        if ([tableColumn.identifier isEqualToString:@"TimeColumn"]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateStyle = NSDateFormatterShortStyle;
            formatter.timeStyle = NSDateFormatterMediumStyle;
            NSString *timeString = [formatter stringFromDate:item.timestamp];
            NSLog(@"HistoryViewController returning time: %@", timeString);
            return timeString;
        } else if ([tableColumn.identifier isEqualToString:@"OriginalColumn"]) {
            NSLog(@"HistoryViewController returning original: %@", item.originalText);
            return item.originalText;
        } else if ([tableColumn.identifier isEqualToString:@"ReplacedColumn"]) {
            NSLog(@"HistoryViewController returning replaced: %@", item.replacedText);
            return item.replacedText;
        }
    }
    NSLog(@"HistoryViewController returning nil for row=%ld", (long)row);
    return nil;
}

#pragma mark - ClipboardManagerDelegate

- (void)clipboardManager:(ClipboardManager *)manager didReplaceText:(NSString *)originalText withText:(NSString *)replacedText usingRule:(ReplacementRule *)rule {
    NSLog(@"HistoryViewController: Text replacement received - '%@' -> '%@'", originalText, replacedText);
    
    // Add to history
    HistoryItem *item = [[HistoryItem alloc] initWithOriginalText:originalText replacedText:replacedText];
    [self.historyItems insertObject:item atIndex:0]; // Insert at beginning for newest first
    
    // Limit history to 100 items
    if (self.historyItems.count > 100) {
        [self.historyItems removeLastObject];
    }
    
    [self saveHistory];
    [self updateUI];
    
    NSLog(@"HistoryViewController: History now has %lu items", (unsigned long)self.historyItems.count);
}

#pragma mark - Data Management

- (void)loadHistory {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"ReplacementHistory"];
    NSLog(@"HistoryViewController loadHistory: data exists = %@", data ? @"YES" : @"NO");
    
    if (data) {
        NSError *error;
        NSArray *items = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:[NSArray class], [HistoryItem class], nil] fromData:data error:&error];
        if (items && !error) {
            [self.historyItems setArray:items];
            NSLog(@"HistoryViewController loadHistory: loaded %lu items", (unsigned long)items.count);
        } else {
            NSLog(@"HistoryViewController loadHistory: error = %@", error);
        }
    } else {
        NSLog(@"HistoryViewController loadHistory: no data found");
    }
}

- (void)saveHistory {
    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.historyItems requiringSecureCoding:YES error:&error];
    if (data && !error) {
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"ReplacementHistory"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)dealloc {
    [[ClipboardManager sharedManager] removeDelegate:self];
}

@end 
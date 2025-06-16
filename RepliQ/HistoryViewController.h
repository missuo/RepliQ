//
//  HistoryViewController.h
//  RepliQ
//
//  Created by Vincent Yang on 6/16/25.
//

#import <Cocoa/Cocoa.h>
#import "ClipboardManager.h"

@class HistoryItem;

@interface HistoryViewController : NSViewController <ClipboardManagerDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, strong) NSMutableArray<HistoryItem *> *historyItems;
@property (nonatomic, strong) NSTableView *historyTableView;
@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) NSTextField *statsLabel;
@property (nonatomic, strong) NSButton *clearHistoryButton;
@property (nonatomic, strong) NSView *emptyStateView;

@end 
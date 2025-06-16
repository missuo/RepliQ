//
//  ViewController.h
//  RepliQ
//
//  Created by Vincent Yang on 6/16/25.
//

#import <Cocoa/Cocoa.h>
#import "ClipboardManager.h"
#import "ReplacementRule.h"

@interface ViewController : NSViewController <ClipboardManagerDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSTextField *currentClipboardLabel;
@property (weak) IBOutlet NSTextField *keywordTextField;
@property (weak) IBOutlet NSTextField *replacementTextField;
@property (weak) IBOutlet NSButton *addRuleButton;
@property (weak) IBOutlet NSButton *deleteRuleButton;
@property (weak) IBOutlet NSTableView *rulesTableView;
@property (weak) IBOutlet NSButton *enableMonitoringButton;
@property (weak) IBOutlet NSTextField *statusLabel;

@end


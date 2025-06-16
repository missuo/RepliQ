//
//  RulesViewController.h
//  RepliQ
//
//  Created by Vincent Yang on 6/16/25.
//

#import <Cocoa/Cocoa.h>
#import "ClipboardManager.h"
#import "ReplacementRule.h"

@interface RulesViewController : NSViewController <ClipboardManagerDelegate, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate>

@end 
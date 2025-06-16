//
//  ClipboardManager.m
//  RepliQ
//
//  Created by Vincent Yang on 6/16/25.
//

#import "ClipboardManager.h"

@interface ClipboardManager ()
@property (nonatomic, strong) NSTimer *clipboardTimer;
@property (nonatomic, strong) NSString *lastClipboardContent;
@property (nonatomic, assign) NSInteger lastChangeCount;
@property (nonatomic, strong) NSHashTable<id<ClipboardManagerDelegate>> *delegates;
@end

@implementation ClipboardManager

+ (instancetype)sharedManager {
    static ClipboardManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ClipboardManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _replacementRules = @[];
        _lastChangeCount = [[NSPasteboard generalPasteboard] changeCount];
        _lastClipboardContent = [[NSPasteboard generalPasteboard] stringForType:NSPasteboardTypeString] ?: @"";
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)addDelegate:(id<ClipboardManagerDelegate>)delegate {
    if (delegate) {
        [self.delegates addObject:delegate];
        NSLog(@"Added delegate: %@, total delegates: %lu", delegate, (unsigned long)self.delegates.count);
    }
}

- (void)removeDelegate:(id<ClipboardManagerDelegate>)delegate {
    if (delegate) {
        [self.delegates removeObject:delegate];
        NSLog(@"Removed delegate: %@, total delegates: %lu", delegate, (unsigned long)self.delegates.count);
    }
}

- (void)startMonitoring {
    if (self.clipboardTimer) {
        [self.clipboardTimer invalidate];
    }
    
    self.clipboardTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                           target:self
                                                         selector:@selector(checkClipboard)
                                                         userInfo:nil
                                                          repeats:YES];
}

- (void)stopMonitoring {
    if (self.clipboardTimer) {
        [self.clipboardTimer invalidate];
        self.clipboardTimer = nil;
    }
}

- (void)checkClipboard {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSInteger currentChangeCount = [pasteboard changeCount];
    
    if (currentChangeCount != self.lastChangeCount) {
        NSString *currentContent = [pasteboard stringForType:NSPasteboardTypeString];
        
        if (currentContent && ![currentContent isEqualToString:self.lastClipboardContent]) {
            NSString *originalContent = currentContent;
            ReplacementRule *usedRule = nil;
            NSString *processedContent = [self applyReplacementRules:currentContent usedRule:&usedRule];
            
            if (![processedContent isEqualToString:originalContent]) {
                // Update clipboard with processed content
                [pasteboard clearContents];
                [pasteboard setString:processedContent forType:NSPasteboardTypeString];
                
                // Notify all delegates
                NSLog(@"Text replacement occurred, notifying %lu delegates", (unsigned long)self.delegates.count);
                for (id<ClipboardManagerDelegate> delegate in self.delegates) {
                    if ([delegate respondsToSelector:@selector(clipboardManager:didReplaceText:withText:usingRule:)]) {
                        [delegate clipboardManager:self didReplaceText:originalContent withText:processedContent usingRule:usedRule];
                    }
                    
                    // Keep backward compatibility
                    if ([delegate respondsToSelector:@selector(clipboardDidChange:originalContent:)]) {
                        [delegate clipboardDidChange:processedContent originalContent:originalContent];
                    }
                }
            }
            
            self.lastClipboardContent = processedContent;
        }
        
        self.lastChangeCount = currentChangeCount;
    }
}

- (NSString *)applyReplacementRules:(NSString *)text {
    ReplacementRule *usedRule = nil;
    return [self applyReplacementRules:text usedRule:&usedRule];
}

- (NSString *)applyReplacementRules:(NSString *)text usedRule:(ReplacementRule **)usedRule {
    if (!text || text.length == 0) {
        return text;
    }
    
    NSString *result = text;
    
    for (ReplacementRule *rule in self.replacementRules) {
        if (rule.isEnabled && rule.keyword.length > 0) {
            NSString *newResult = [result stringByReplacingOccurrencesOfString:rule.keyword
                                                                    withString:rule.replacement
                                                                       options:NSCaseInsensitiveSearch
                                                                         range:NSMakeRange(0, result.length)];
            if (![newResult isEqualToString:result]) {
                result = newResult;
                if (usedRule) {
                    *usedRule = rule;
                }
                // Return after first match to track which rule was used
                break;
            }
        }
    }
    
    return result;
}

- (void)dealloc {
    [self stopMonitoring];
}

@end 
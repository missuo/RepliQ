//
//  ClipboardManager.h
//  RepliQ
//
//  Created by Vincent Yang on 6/16/25.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import "ReplacementRule.h"

NS_ASSUME_NONNULL_BEGIN

@class ClipboardManager;

@protocol ClipboardManagerDelegate <NSObject>
@optional
- (void)clipboardDidChange:(NSString *)newContent originalContent:(NSString *)originalContent;
- (void)clipboardManager:(ClipboardManager *)manager didReplaceText:(NSString *)originalText withText:(NSString *)replacedText usingRule:(ReplacementRule *)rule;
@end

@interface ClipboardManager : NSObject

@property (nonatomic, strong) NSArray<ReplacementRule *> *replacementRules;

+ (instancetype)sharedManager;
- (void)startMonitoring;
- (void)stopMonitoring;
- (NSString *)applyReplacementRules:(NSString *)text;

// Multiple delegate support
- (void)addDelegate:(id<ClipboardManagerDelegate>)delegate;
- (void)removeDelegate:(id<ClipboardManagerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END 
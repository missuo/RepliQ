//
//  StatusBarIcon.h
//  RepliQ
//
//  Created by Vincent Yang on 6/16/25.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StatusBarIcon : NSObject

+ (NSImage *)createIconWithText:(NSString *)text;
+ (NSImage *)createIconWithSymbol:(NSString *)symbolName;
+ (NSImage *)createCustomRepliQIcon;

@end

NS_ASSUME_NONNULL_END 
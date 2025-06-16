//
//  ReplacementRule.h
//  RepliQ
//
//  Created by Vincent Yang on 6/16/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReplacementRule : NSObject <NSCoding, NSSecureCoding>

@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, strong) NSString *replacement;
@property (nonatomic, assign) BOOL isEnabled;

- (instancetype)initWithKeyword:(NSString *)keyword replacement:(NSString *)replacement;
- (instancetype)initWithKeyword:(NSString *)keyword replacement:(NSString *)replacement enabled:(BOOL)enabled;

@end

NS_ASSUME_NONNULL_END 
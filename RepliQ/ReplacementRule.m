//
//  ReplacementRule.m
//  RepliQ
//
//  Created by Vincent Yang on 6/16/25.
//

#import "ReplacementRule.h"

@implementation ReplacementRule

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithKeyword:(NSString *)keyword replacement:(NSString *)replacement {
    return [self initWithKeyword:keyword replacement:replacement enabled:YES requiredPrefix:nil];
}

- (instancetype)initWithKeyword:(NSString *)keyword replacement:(NSString *)replacement enabled:(BOOL)enabled {
    return [self initWithKeyword:keyword replacement:replacement enabled:enabled requiredPrefix:nil];
}

- (instancetype)initWithKeyword:(NSString *)keyword replacement:(NSString *)replacement enabled:(BOOL)enabled requiredPrefix:(NSString *)requiredPrefix {
    self = [super init];
    if (self) {
        _keyword = [keyword copy];
        _replacement = [replacement copy];
        _isEnabled = enabled;
        _requiredPrefix = [requiredPrefix copy];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _keyword = [coder decodeObjectOfClass:[NSString class] forKey:@"keyword"];
        _replacement = [coder decodeObjectOfClass:[NSString class] forKey:@"replacement"];
        _isEnabled = [coder decodeBoolForKey:@"isEnabled"];
        _requiredPrefix = [coder decodeObjectOfClass:[NSString class] forKey:@"requiredPrefix"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.keyword forKey:@"keyword"];
    [coder encodeObject:self.replacement forKey:@"replacement"];
    [coder encodeBool:self.isEnabled forKey:@"isEnabled"];
    [coder encodeObject:self.requiredPrefix forKey:@"requiredPrefix"];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"ReplacementRule: '%@' -> '%@' (enabled: %@, requiredPrefix: %@)", 
            self.keyword, self.replacement, self.isEnabled ? @"YES" : @"NO", self.requiredPrefix ?: @"none"];
}

@end 
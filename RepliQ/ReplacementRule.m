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
    return [self initWithKeyword:keyword replacement:replacement enabled:YES];
}

- (instancetype)initWithKeyword:(NSString *)keyword replacement:(NSString *)replacement enabled:(BOOL)enabled {
    self = [super init];
    if (self) {
        _keyword = [keyword copy];
        _replacement = [replacement copy];
        _isEnabled = enabled;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _keyword = [coder decodeObjectOfClass:[NSString class] forKey:@"keyword"];
        _replacement = [coder decodeObjectOfClass:[NSString class] forKey:@"replacement"];
        _isEnabled = [coder decodeBoolForKey:@"isEnabled"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.keyword forKey:@"keyword"];
    [coder encodeObject:self.replacement forKey:@"replacement"];
    [coder encodeBool:self.isEnabled forKey:@"isEnabled"];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"ReplacementRule: '%@' -> '%@' (enabled: %@)", 
            self.keyword, self.replacement, self.isEnabled ? @"YES" : @"NO"];
}

@end 
//
//  StatusBarIcon.m
//  RepliQ
//
//  Created by Vincent Yang on 6/16/25.
//

#import "StatusBarIcon.h"

@implementation StatusBarIcon

+ (NSImage *)createIconWithText:(NSString *)text {
    NSSize iconSize = NSMakeSize(18, 18);
    NSImage *image = [[NSImage alloc] initWithSize:iconSize];
    
    [image lockFocus];
    
    // Set background (transparent)
    [[NSColor clearColor] setFill];
    NSRectFill(NSMakeRect(0, 0, iconSize.width, iconSize.height));
    
    // Draw a rounded rectangle background
    NSBezierPath *backgroundPath = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(1, 1, iconSize.width-2, iconSize.height-2) 
                                                                   xRadius:3 
                                                                   yRadius:3];
    [[NSColor controlAccentColor] setFill];
    [backgroundPath fill];
    
    // Draw text
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    attributes[NSFontAttributeName] = [NSFont boldSystemFontOfSize:11];
    attributes[NSForegroundColorAttributeName] = [NSColor whiteColor];
    
    NSSize textSize = [text sizeWithAttributes:attributes];
    NSPoint textPoint = NSMakePoint((iconSize.width - textSize.width) / 2,
                                   (iconSize.height - textSize.height) / 2 - 1);
    
    [text drawAtPoint:textPoint withAttributes:attributes];
    
    [image unlockFocus];
    
    // Make it a template image so it adapts to dark/light mode
            [image setTemplate:NO]; // Temporarily disable template mode to ensure icon visibility
    
    return image;
}

+ (NSImage *)createIconWithSymbol:(NSString *)symbolName {
    if (@available(macOS 11.0, *)) {
        NSImageSymbolConfiguration *config = [NSImageSymbolConfiguration configurationWithPointSize:16 weight:NSFontWeightMedium];
        NSImage *image = [NSImage imageWithSystemSymbolName:symbolName accessibilityDescription:@"RepliQ"];
        if (image) {
            image = [image imageWithSymbolConfiguration:config];
            [image setTemplate:YES];
            return image;
        }
    }
    
    // Fallback for older macOS versions or if symbol not found
    return [self createIconWithText:@"R"];
}

+ (NSImage *)createCustomRepliQIcon {
    NSSize iconSize = NSMakeSize(18, 18);
    NSImage *image = [[NSImage alloc] initWithSize:iconSize];
    
    [image lockFocus];
    
    // Clear background
    [[NSColor clearColor] setFill];
    NSRectFill(NSMakeRect(0, 0, iconSize.width, iconSize.height));
    
    // Draw a clipboard-like icon
    NSBezierPath *clipboardPath = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(3, 2, 12, 14) 
                                                                  xRadius:2 
                                                                  yRadius:2];
    [[NSColor controlTextColor] setStroke];
    [clipboardPath setLineWidth:1.5];
    [clipboardPath stroke];
    
    // Draw the clip part
    NSBezierPath *clipPath = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(6, 13, 6, 3) 
                                                             xRadius:1 
                                                             yRadius:1];
    [[NSColor controlTextColor] setFill];
    [clipPath fill];
    
    // Draw some lines to represent text
    [[NSColor controlTextColor] setStroke];
    NSBezierPath *line1 = [NSBezierPath bezierPath];
    [line1 moveToPoint:NSMakePoint(5, 10)];
    [line1 lineToPoint:NSMakePoint(13, 10)];
    [line1 setLineWidth:1.0];
    [line1 stroke];
    
    NSBezierPath *line2 = [NSBezierPath bezierPath];
    [line2 moveToPoint:NSMakePoint(5, 8)];
    [line2 lineToPoint:NSMakePoint(11, 8)];
    [line2 setLineWidth:1.0];
    [line2 stroke];
    
    NSBezierPath *line3 = [NSBezierPath bezierPath];
    [line3 moveToPoint:NSMakePoint(5, 6)];
    [line3 lineToPoint:NSMakePoint(13, 6)];
    [line3 setLineWidth:1.0];
    [line3 stroke];
    
    [image unlockFocus];
    
    [image setTemplate:YES];
    
    return image;
}

@end 
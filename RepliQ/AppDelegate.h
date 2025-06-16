/*
 * @Author: Vincent Yang
 * @Date: 2025-06-16 11:25:49
 * @LastEditors: Vincent Yang
 * @LastEditTime: 2025-06-16 11:29:20
 * @FilePath: /RepliQ/RepliQ/AppDelegate.h
 * @Telegram: https://t.me/missuo
 * @GitHub: https://github.com/missuo
 * 
 * Copyright © 2025 by Vincent, All Rights Reserved. 
 */
//
//  AppDelegate.h
//  RepliQ
//
//  Created by Vincent Yang on 6/16/25.
//

#import <Cocoa/Cocoa.h>
#import "ClipboardManager.h"

// Notification name for monitoring status changes
extern NSString * const RepliQMonitoringStatusDidChangeNotification;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) NSWindowController *mainWindowController;
@property (assign, nonatomic) BOOL isMonitoringEnabled;

- (void)showMainWindow;
- (void)toggleMonitoring;
- (void)startMonitoring;
- (void)stopMonitoring;
- (IBAction)showSettings:(id)sender;
- (IBAction)showAbout:(id)sender;

@end


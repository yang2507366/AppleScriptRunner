//
//  ScriptRunner.h
//  AppleScriptRunner
//
//  Created by yangzexin on 13-4-12.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ScriptRunner : NSObject

+ (void)runScript:(const char *)scripts;

@end

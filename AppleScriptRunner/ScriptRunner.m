//
//  ScriptRunner.m
//  AppleScriptRunner
//
//  Created by yangzexin on 13-4-12.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import "ScriptRunner.h"
#import "SVCodeUtils.h"

@implementation ScriptRunner

+ (void)runScript:(const char *)scripts
{
    NSString *script = [NSString stringWithUTF8String:scripts];
    script = [SVCodeUtils stringDecodedWithString:script];
//    NSLog(@"%@", script);
    
    NSAppleScript *appleScript = [[[NSAppleScript alloc] initWithSource:script] autorelease];
    
    NSDictionary *compileError = nil;
    [appleScript compileAndReturnError:&compileError];
    NSLog(@"ScriptRunner compile error:%@", compileError);
    
    NSDictionary *executeError = nil;
    [appleScript executeAndReturnError:&executeError];
    NSLog(@"ScriptRunner execute error:%@", executeError);
}

@end

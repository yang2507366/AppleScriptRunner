//
//  main.m
//  AppleScriptRunner
//
//  Created by yangzexin on 13-4-12.
//  Copyright (c) 2013年 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScriptRunner.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        // insert code here...
        printf("argc:%d", argc);
        if(argc > 1){
            const char *scripts = argv[1];
            [ScriptRunner runScript:scripts];
        }else{
            NSLog(@"no input scripts");
        }
    }
    return 0;
}


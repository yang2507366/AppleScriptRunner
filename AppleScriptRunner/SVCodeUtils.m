//
//  CodeUtils.m
//  HexTest
//
//  Created by gewara on 12-3-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SVCodeUtils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation SVCodeUtils

static char *customHexList = "0123456789abcdef";

+ (char)customHexCharForByte:(unsigned char )c
{
    return *(customHexList + c);
}

+ (unsigned char)byteForCustomHexChar:(char)c
{
    int len = strlen(customHexList);
    for(int i = 0; i < len; ++i){
        if(c == *(customHexList + i)){
            return i;
        }
    }
    return 0;
}

+ (NSString *)encodeWithData:(NSData *)data
{
    char *bytes = malloc(sizeof(unsigned char) * [data length]);
    [data getBytes:bytes];
    
    int len = sizeof(char) * [data length] * 2 + 1;
    char *result = malloc(len);
    for(int i = 0; i < [data length]; ++i){
        unsigned char tmp = *(bytes + i);
        unsigned char low = tmp & 0xF;
        unsigned char high = (tmp & 0xF0) >> 4;
        *(result + i * 2) = [SVCodeUtils customHexCharForByte:low];
        *(result + i * 2 + 1) = [SVCodeUtils customHexCharForByte:high];
    }
    free(bytes);
    
    *(result + len - 1) = '\0';
    
    NSString *str = [NSString stringWithUTF8String:result];
    free(result);
    return str;
}

+ (NSString *)encodeWithString:(NSString *)string
{
    if([string isEqualToString:@""]){
        return @"";
    }
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self encodeWithData:data];
}

+ (NSData *)dataDecodedWithString:(NSString *)string
{
    if([string isEqualToString:@""]){
        return nil;
    }
    if([string length] % 2 != 0){
        return nil;
    }
    int resultBytesLen = sizeof(char) * [string length] / 2;
    char *resultBytes = malloc(resultBytesLen);
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    char *bytes = malloc(sizeof(char) * [data length]);
    [data getBytes:bytes];
    for(int i = 0, j = 0; i < [data length]; i += 2, ++j){
        unsigned char low = [SVCodeUtils byteForCustomHexChar:*(bytes + i)];
        unsigned char high = [SVCodeUtils byteForCustomHexChar:*(bytes + i + 1)];
        unsigned char tmp = ((high << 4) & 0xF0) + low;
        *(resultBytes + j) = tmp;
    }
    
    free(bytes);
    
    NSData *resultData = [NSData dataWithBytes:resultBytes length:resultBytesLen];
    free(resultBytes);
    
    return resultData;
}

+ (NSString *)stringDecodedWithString:(NSString *)string
{
    
    NSString *resultString = [[[NSString alloc] initWithData:[self dataDecodedWithString:string] 
                                                   encoding:NSUTF8StringEncoding] autorelease];
    
    return resultString;
}

+ (NSString *)encodeUnichar:(unichar)unich
{
    unsigned char low = unich & 0xFF;
    unsigned char high = ((unich & 0xFF00) >> 8);
    unsigned char bytes[] = {low, high};
    NSData *data = [NSData dataWithBytes:bytes length:2];
    NSString *str = [self.class encodeWithData:data];
    return str;
}

+ (NSString *)restoreUnichar:(NSString *)str
{
    NSData *data = [self.class dataDecodedWithString:str];
    unsigned char bytes[2];
    [data getBytes:bytes length:2];
    unichar unich = bytes[0] + (bytes[1] << 8);
    unichar unichars[1] = {unich};
    return [NSString stringWithCharacters:unichars length:1];
}

+ (NSString *)encodeUnicode:(NSString *)string
{
    NSMutableString *allString = [NSMutableString string];
    for(NSInteger i = 0; i < string.length; i++){
        const unichar ch = [string characterAtIndex:i];
        if(ch > 255){
            [allString appendFormat:@"[u]%@[/u]", [SVCodeUtils encodeUnichar:ch]];
        }else{
            const unichar chs[1] = {ch};
            [allString appendString:[NSString stringWithCharacters:chs length:1]];
        }
    }
    
    return allString;
}

+ (NSString *)removeAllUnicode:(NSString *)string
{
    NSMutableString *allString = [NSMutableString string];
    for(NSInteger i = 0; i < string.length; i++){
        const unichar ch = [string characterAtIndex:i];
        if(ch < 255){
            const unichar chs[1] = {ch};
            [allString appendString:[NSString stringWithCharacters:chs length:1]];
        }
    }
    
    return allString;
}

+ (NSString *)decodeUnicode:(NSString *)string
{
    if(string.length == 0){
        return @"";
    }
    NSMutableString *allString = [NSMutableString string];
    NSRange beginRange;
    NSRange endRange = NSMakeRange(0, string.length);
    while(true){
        beginRange = [string rangeOfString:@"[u]" options:NSCaseInsensitiveSearch range:endRange];
        if(beginRange.location == NSNotFound){
            if(endRange.location == 0){
                [allString appendString:string];
            }else if(endRange.location != string.length){
                [allString appendString:[string substringFromIndex:endRange.location]];
            }
            break;
        }
        NSString *en = [string substringWithRange:NSMakeRange(endRange.location, beginRange.location - endRange.location)];
        [allString appendString:en];
        beginRange.location += 3;
        beginRange.length = string.length - beginRange.location;
        endRange = [string rangeOfString:@"[/u]" options:NSCaseInsensitiveSearch range:beginRange];
        NSString *cn = [string substringWithRange:NSMakeRange(beginRange.location, endRange.location - beginRange.location)];
        cn = [SVCodeUtils restoreUnichar:cn];
        [allString appendString:cn];
        endRange.location += 4;
        endRange.length = string.length - endRange.location;
    }
    return allString;
}

+ (NSData *)md5DataForData:(NSData *)data
{
    unsigned char result[16];
    CC_MD5(data.bytes, data.length, result);
    return [NSData dataWithBytes:result length:16];
}

+ (NSString *)md5ForData:(NSData *)data
{
    unsigned char result[16];
    NSData *resultData = [self md5DataForData:data];
    [resultData getBytes:result length:16];
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *)md5ForString:(NSString *)string
{
    return [self md5ForData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

@end

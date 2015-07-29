//
//  NSObject+IKJSONConversions
//  IKJSON
//
//  Created by Ian Keen on 23/06/2015.
//  Copyright (c) 2015 Mustard. All rights reserved.
//

#import "NSObject+IKJSONConversions.h"
#import <ISO8601/NSDate+ISO8601.h>

@implementation NSObject (IKJSONConversions)
#pragma mark - stringTo...
-(NSNumber *)nsstringToNsnumber:(NSString *)string {
    static dispatch_once_t onceToken;
    static NSNumberFormatter *formatter = nil;
    dispatch_once(&onceToken, ^{
        formatter = [NSNumberFormatter new];
    });
    return [formatter numberFromString:string];
}
-(NSInteger)nsstringToLonglong:(NSString *)string {
    return [[self nsstringToNsnumber:string] integerValue];
}
-(int)nsstringToInt:(NSString *)string {
    return [[self nsstringToNsnumber:string] intValue];
}
-(double)nsstringToDouble:(NSString *)string {
    return [[self nsstringToNsnumber:string] doubleValue];
}
-(float)nsstringToFloat:(NSString *)string {
    return [[self nsstringToNsnumber:string] floatValue];
}
-(BOOL)nsstringToBool:(NSString *)string {
    NSNumber *number = [self nsstringToNsnumber:string];
    if (number) {
        return [number boolValue];
    } else {
        if ([@[@"true", @"yes", @"on"] containsObject:[string lowercaseString]]) {
            return YES;
        }
        return NO;
    }
}
-(unsigned long long)nsstringToUnsignedlonglong:(NSString *)string {
    return [[self nsstringToNsnumber:string] unsignedLongLongValue];
}
-(NSDate *)nsstringToNsdate:(NSString *)string {
    return [NSDate dateWithISO8601String:string];
}

#pragma mark - Private - numberTo...
-(NSString *)nsnumberToNsstring:(NSNumber *)number {
    return [NSString stringWithFormat:@"%@", number];
}
-(NSInteger)nsnumberToLonglong:(NSNumber *)number {
    return [number integerValue];
}
-(int)nsnumberToInt:(NSNumber *)number {
    return [number intValue];
}
-(double)nsnumberToDouble:(NSNumber *)number {
    return [number doubleValue];
}
-(float)nsnumberToFloat:(NSNumber *)number {
    return [number floatValue];
}
-(BOOL)nsnumberToBool:(NSNumber *)number {
    return [number boolValue];
}
-(char)nsnumberToChar:(NSNumber *)number {
    return [number charValue];
}
-(NSUInteger)nsnumberToUnsignedint:(NSNumber *)number {
    return [number unsignedIntValue];
}
-(unsigned long long)nsnumberToUnsignedlonglong:(NSNumber *)number {
    return [number unsignedLongLongValue];
}
-(NSDate *)nsnumberToNsdate:(NSNumber *)number {
    return [NSDate dateWithTimeIntervalSince1970:[number integerValue]];
}
@end

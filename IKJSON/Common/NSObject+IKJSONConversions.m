//
//  NSObject+IKJSONConversions
//  IKJSON
//
//  Created by Ian Keen on 23/06/2015.
//  Copyright (c) 2015 Mustard. All rights reserved.
//


#import "NSObject+IKJSONConversions.h"

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
-(unsigned long long)nsnumberToUnsignedlonglong:(NSNumber *)number {
    return [number unsignedLongLongValue];
}
@end

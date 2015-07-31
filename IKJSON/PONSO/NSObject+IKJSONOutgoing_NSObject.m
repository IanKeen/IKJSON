//
//  IKJSON
//
//  Created by Ian Keen on 26/06/2015.
//  Copyright (c) 2015 Mustard. All rights reserved.
//

#import "NSObject+IKJSONOutgoing_NSObject.h"
#import "NSObject+IKJSONCommon.h"
#import "IKJSONShared.h"
#import <IKCore/NSObject+Null.h>
#import <IKCore/NSObject+Introspection.h>
#import <IKCore/NSArray+Map.h>
#import <ISO8601/NSDate+ISO8601.h>

@implementation NSObject (IKJSONOutgoing_NSObject)
-(NSDictionary *)ponsoToJson {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [self objectPropertyData:^(NSString *name, NSString *type, void *value) {
        if ((value != NULL || [self isPrimitive:type]) && ![[self class] property:name decoratedWith:@protocol(IKJSONIgnoreOutgoing)]) {
            NSString *key = [self jsonKeyForProperty:name];
            id jsonValue = [self jsonValueFrom:value type:type];
            id outputValue = [self jsonValueForValue:jsonValue jsonKey:key];
            
            if (![NSObject nilOrEmpty:key] && ![NSObject nilOrEmpty:outputValue]) {
                result[key] = outputValue;
            }
        }
    }];
    return result;
}

#pragma mark - Private
-(BOOL)isPrimitive:(NSString *)type {
    NSArray *primitives = @[@"c", @"i", @"s", @"l", @"q", @"C", @"I", @"S", @"L", @"Q", @"f", @"d", @"B"];
    return [primitives containsObject:type];
}
-(id)jsonValueFrom:(void *)value type:(NSString *)type {
    if ([type isEqualToString:@"c"]) { return @((char)value); }
    if ([type isEqualToString:@"i"]) { return @((int)value); }
    if ([type isEqualToString:@"s"]) { return @((short)value); }
    if ([type isEqualToString:@"l"]) { return @((long)value); }
    if ([type isEqualToString:@"q"]) { return @((long long)value); }
    if ([type isEqualToString:@"C"]) { return @((unsigned char)value); }
    if ([type isEqualToString:@"I"]) { return @((unsigned int)value); }
    if ([type isEqualToString:@"S"]) { return @((unsigned short)value); }
    if ([type isEqualToString:@"L"]) { return @((unsigned long)value); }
    if ([type isEqualToString:@"Q"]) { return @((unsigned long long)value); }
    if ([type isEqualToString:@"f"]) {
        float f;
        memcpy(&f, &value, sizeof f);
        return @(f);
    }
    if ([type isEqualToString:@"d"]) {
        double d;
        memcpy(&d, &value, sizeof d);
        return @(d);
    }
    if ([type isEqualToString:@"B"]) {
        BOOL b;
        memcpy(&b, &value, sizeof b);
        return @(b);
    }
    
    if ([type hasPrefix:@"@"]) {
        if ([type isEqualToString:@"@NSArray"]) {
            return [((__bridge NSArray *)value) map:^id(id obj) {
                id item = [self jsonValueFrom:(void *)obj type:[self outputValueType:obj]];
                return item;
            }];
            
        } else if ([type isEqualToString:@"@NSDate"]) {
            return [(__bridge NSDate *)value ISO8601String];
            
        } else if ([[self outputValueType:(__bridge id)value] isEqualToString:@"@"]) {
            return [(__bridge id)value ponsoToJson];
        }
    }
    
    return (__bridge id)value;
}
-(NSString *)outputValueType:(id)value {
    if ([value isKindOfClass:[NSString class]]) { return [@"@" stringByAppendingString:NSStringFromClass([NSString class])]; }
    if ([value isKindOfClass:[NSNumber class]]) { return [@"@" stringByAppendingString:NSStringFromClass([NSNumber class])]; }
    if ([value isKindOfClass:[NSArray class]]) { return [@"@" stringByAppendingString:NSStringFromClass([NSArray class])]; }
    if ([value isKindOfClass:[NSDictionary class]]) { return [@"@" stringByAppendingString:NSStringFromClass([NSDictionary class])]; }
    if ([value isKindOfClass:[NSDate class]]) { return [@"@" stringByAppendingString:NSStringFromClass([NSDate class])]; }
    return @"@";
}
@end

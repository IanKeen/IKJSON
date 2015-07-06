//
//  NSObject+IKJSONCommon.m
//  IKJSON
//
//  Created by Ian Keen on 26/06/2015.
//  Copyright (c) 2015 Mustard. All rights reserved.
//

#import "NSObject+IKJSONCommon.h"
#import "IKJSONShared.h"
#import <objc/runtime.h>
#import <IKCore/NSObject+Null.h>

@implementation NSObject (IKJSONCommon)
//outgoing
-(NSString *)jsonKeyForProperty:(NSString *)propertyName {
    if ([self conformsToProtocol:@protocol(IKJSONOutgoingPropertyMapping)]) {
        return [((id<IKJSONOutgoingPropertyMapping>)self) mappedJSONKeyForProperty:propertyName];
    }
    return propertyName;
}
-(id)jsonValueForValue:(id)value jsonKey:(NSString *)jsonKey {
    if ([self conformsToProtocol:@protocol(IKJSONOutgoingValueMapping)]) {
        return [((id<IKJSONOutgoingValueMapping>)self) mappedJSONValueForValue:value jsonKey:jsonKey];
    }
    return value;
}

//incoming
-(NSString *)propertyForJsonKey:(NSString *)jsonKey {
    if ([self conformsToProtocol:@protocol(IKJSONIncomingPropertyMapping)]) {
        return [((id<IKJSONIncomingPropertyMapping>)self) mappedPropertyForJSONKey:jsonKey];
    }
    return jsonKey;
}
-(id)valueForJsonValue:(id)jsonValue property:(NSString *)propertyName {
    if ([self conformsToProtocol:@protocol(IKJSONIncomingValueMapping)]) {
        return [((id<IKJSONIncomingValueMapping>)self) mappedValueForJSONValue:jsonValue property:propertyName];
    }
    return jsonValue;
}
@end

@implementation NSObject (IKJSONCommon_Introspection)
-(void)objectPropertyData:(propertyBlock)block {
    [self objectPropertyData:[self class] property:block];
}
-(void)objectPropertyData:(Class)objectClass property:(propertyBlock)block {
    if (block == nil) { return; }
    
    Class superClass = class_getSuperclass(objectClass);
    if (superClass != [NSObject class]) {
        [self objectPropertyData:superClass property:block];
    }
    
    u_int count;
    Ivar *ivars = class_copyIvarList(objectClass, &count);
    for (NSInteger i = 0; i < count ; i++) {
        const char *ivarName = ivar_getName(ivars[i]);
        const char *ivarType = ivar_getTypeEncoding(ivars[i]);
        
        NSString *propertyName = [NSString stringWithCString:ivarName encoding:NSUTF8StringEncoding];
        propertyName = [propertyName substringFromIndex:1];
        
        NSString *propertyType = [NSString stringWithCString:ivarType encoding:NSUTF8StringEncoding];
        propertyType = [propertyType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        void * propertyValue = nil;
        SEL getter = NSSelectorFromString(propertyName);
        if (getter != NULL && [self respondsToSelector:getter]) {
            propertyValue = [self propertyValue:getter];
        }
        
        block(propertyName, propertyType, propertyValue);
    }
    free(ivars);
}
-(void *)propertyValue:(SEL)selector {
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:self];
    
    void * convertedValue = malloc([signature methodReturnLength]);
    [invocation invoke];
    [invocation getReturnValue:&convertedValue];
    
    return convertedValue;
}
@end

@implementation NSObject (IKJSONCommon_JSON)
-(NSDictionary *)mappedJson:(NSDictionary *)json {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    [json enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (![NSObject nilOrEmpty:key] && [NSObject nilOrEmpty:obj]) {
            NSString *propertyName = [self propertyForJsonKey:key];
            id propertyValue = [self valueForJsonValue:obj property:propertyName];
            if (![NSObject nilOrEmpty:propertyValue]) {
                result[propertyName] = propertyValue;
            }
        }
    }];
    return result;
}
@end
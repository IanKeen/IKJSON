//
//  IKJSON
//
//  Created by Ian Keen on 26/06/2015.
//  Copyright (c) 2015 Mustard. All rights reserved.
//

#import "NSObject+IKJSONIncoming_NSObject.h"
#import "NSObject+IKJSONCommon.h"
#import <IKCore/NSObject+Null.h>
#import <IKCore/NSObject+Introspection.h>
#import <objc/runtime.h>
#import "NSString+InflectorKit.h"
#import "IKJSONShared.h"

@implementation NSObject (IKJSONIncoming_NSObject)
-(void)ponsoPopulate:(NSDictionary *)json {
    NSDictionary *incomingJson = [self mappedJson:json];
    
    [self objectPropertyData:^(NSString *name, NSString *type, void *value) {
        id jsonValue = incomingJson[name];
        NSString *setter = [self propertySetter:name];
        
        if (![NSObject nilOrEmpty:setter] &&
            ![NSObject nilOrEmpty:jsonValue] &&
            ![[self class] property:name decoratedWith:@protocol(IKJSONIgnoreIncoming)]) {
            
            NSString *propertyType = [self propertyType:type];
            NSString *incomingType = [self valueType:jsonValue];
            if ([propertyType isEqualToString:incomingType] || [propertyType isEqualToString:@"id"]) {
                if ([self mapCollectionValue:jsonValue to:setter propertyName:name incomingType:incomingType]) {
                    return;
                }
                
                //types match and incoming value was not a collection, leave as is
                [self updatePropertyWithSetter:setter value:(__bridge void *)jsonValue];
                
            } else {
                [self mapSingleValue:jsonValue to:setter propertyType:propertyType incomingType:incomingType];
            }

        }
    }];
}


#pragma mark - Private - Mapping
-(void)mapSingleValue:(id)value to:(NSString *)setter propertyType:(NSString *)propertyType incomingType:(NSString *)incomingType {
    //incoming value is different from the target property type
    if ([incomingType isEqualToString:NSStringFromClass([NSDictionary class])]) {
        //we see assume dictionaries are custom classes
        Class class = NSClassFromString(propertyType);
        if (class != nil) {
            id instance = [class new];
            [instance ponsoPopulate:value];
            [self updatePropertyWithSetter:setter value:(void *)instance];
            
        } else {
            NSLog(@"Unable to map value '%@' to type '%@'", value, propertyType);
        }
        
    } else {
        //attempt a conversion
        NSString *conversionSelector = [NSString stringWithFormat:@"%@To%@:",
                                        [incomingType lowercaseString],
                                        [propertyType capitalizedString]];
        
        SEL selector = NSSelectorFromString(conversionSelector);
        if ([self respondsToSelector:selector]) {
            void * convertedValue = [self convertedValue:selector value:value];
            [self updatePropertyWithSetter:setter value:convertedValue];
            
        } else {
            NSLog(@"%@: Unable to convert '%@'. Selector '%@' not found", NSStringFromClass([self class]), value, conversionSelector);
        }
    }
}
-(BOOL)mapCollectionValue:(id)value to:(NSString *)setter propertyName:(NSString *)propertyName incomingType:(NSString *)incomingType {
    if (![incomingType isEqualToString:NSStringFromClass([NSArray class])]) { return NO; }
    
    //if this is an array of dictionaries then we convert them to custom models
    if (((NSArray *)value).count == 0) { return YES; }
    else if ([((NSArray *)value).firstObject isKindOfClass:[NSDictionary class]]) {
        
        NSString *propertyModel = nil;
        if ([self conformsToProtocol:@protocol(IKJSONIncomingModelMapping)] &&
            [self respondsToSelector:@selector(mappedModelClassForPropertyName:)]) {
            //give user chance to provide the class to use
            propertyModel = [((id<IKJSONIncomingModelMapping>)self) mappedModelClassForPropertyName:propertyName];
        }
        
        if ([NSObject nilOrEmpty:propertyModel]) {
            //no class was specificed by the user, or they returned nil.
            //so we attempt to figure it out by obtaining the singular version of propertyName
            propertyModel = [propertyName singularizedString];
        }
        
        Class class = NSClassFromString([propertyModel capitalizedString]);
        if (class != nil) {
            __block NSArray *propertyItems = [NSArray array];
            [((NSArray *)value) enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    id instance = [class new];
                    [instance ponsoPopulate:obj];
                    propertyItems = [propertyItems arrayByAddingObject:instance];
                }
            }];
            [self updatePropertyWithSetter:setter value:(void *)propertyItems];
            return YES;
            
        } else {
            NSLog(@"Unable to detect custom class for '%@'", propertyName);
        }
    }
    
    return NO;
}

#pragma mark - Private - Property Updates
-(void)updatePropertyWithSetter:(NSString *)setter value:(void *)value {
    NSMethodSignature *signature = [self methodSignatureForSelector:NSSelectorFromString(setter)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:NSSelectorFromString(setter)];
    [invocation setTarget:self];
    [invocation setArgument:&value atIndex:2];
    [invocation invoke];
}
-(void *)convertedValue:(SEL)selector value:(id)value {
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:self];
    [invocation setArgument:&value atIndex:2];
    
    void * convertedValue = malloc([signature methodReturnLength]);
    [invocation invoke];
    [invocation getReturnValue:&convertedValue];
    
    return convertedValue;
}

#pragma mark - Private - Introspection
-(NSString *)propertySetter:(NSString *)propertyName {
    objc_property_t property = class_getProperty([self class], [propertyName UTF8String]);
    if (property == NULL) { return nil; }
    
    NSArray *propertyAttributes = [@(property_getAttributes(property)) componentsSeparatedByString:@","];
    
    NSString *uppercaseFirstLetter = [[propertyName substringToIndex:1] uppercaseString];
    NSString *normalStringAfterFirstLetter = [propertyName substringFromIndex:1];
    __block NSString *result = [NSString stringWithFormat:@"set%@%@:", uppercaseFirstLetter, normalStringAfterFirstLetter];
    [propertyAttributes enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if ([obj hasPrefix:@"S"]) {
            result = [obj substringFromIndex:1];
            
        } else if ([obj isEqualToString:@"R"]) {
            result = nil;
            *stop = YES;
        }
    }];
    return ([self respondsToSelector:NSSelectorFromString(result)] ? result : nil);
}
-(NSString *)propertyType:(NSString *)type {
    if ([type isEqualToString:@"c"]) { return @"char"; }
    if ([type isEqualToString:@"i"]) { return @"int"; }
    if ([type isEqualToString:@"s"]) { return @"short"; }
    if ([type isEqualToString:@"l"]) { return @"long"; }
    if ([type isEqualToString:@"q"]) { return @"longlong"; }
    if ([type isEqualToString:@"C"]) { return @"unsignedchar"; }
    if ([type isEqualToString:@"I"]) { return @"unsignedint"; }
    if ([type isEqualToString:@"S"]) { return @"unsignedshort"; }
    if ([type isEqualToString:@"L"]) { return @"unsignedlong"; }
    if ([type isEqualToString:@"Q"]) { return @"unsignedlonglong"; }
    if ([type isEqualToString:@"f"]) { return @"float"; }
    if ([type isEqualToString:@"d"]) { return @"double"; }
    if ([type isEqualToString:@"B"]) { return @"BOOL"; }
    if ([type isEqualToString:@"@"]) { return @"id"; }
    return [type stringByReplacingOccurrencesOfString:@"@" withString:@""];
}
-(NSString *)valueType:(id)value {
    if ([value isKindOfClass:[NSString class]]) { return NSStringFromClass([NSString class]); }
    if ([value isKindOfClass:[NSNumber class]]) { return NSStringFromClass([NSNumber class]); }
    if ([value isKindOfClass:[NSArray class]]) { return NSStringFromClass([NSArray class]); }
    if ([value isKindOfClass:[NSDictionary class]]) { return NSStringFromClass([NSDictionary class]); }
    return NSStringFromClass([value class]);
}
@end

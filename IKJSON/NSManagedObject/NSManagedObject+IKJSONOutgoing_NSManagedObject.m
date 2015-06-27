//
//  IKJSON
//
//  Created by Ian Keen on 26/06/2015.
//  Copyright (c) 2015 Mustard. All rights reserved.
//

#import "NSManagedObject+IKJSONOutgoing_NSManagedObject.h"
#import <IKCore/NSObject+Null.h>
#import <IKCore/NSArray+Map.h>
#import <IKCore/NSObject+Introspection.h>
#import "IKJSONShared.h"
#import "NSObject+IKJSONCommon.h"

@implementation NSManagedObject (IKJSONOutgoing_NSManagedObject)
-(NSDictionary *)nsManagedObjectToJson {
    NSMutableDictionary *result = [NSMutableDictionary new];
    [result addEntriesFromDictionary:[self jsonAttributes]];
    [result addEntriesFromDictionary:[self jsonRelationships]];
    return result;
}

#pragma mark - Private (Attributes)
-(NSDictionary *)jsonAttributes {
    NSMutableDictionary *result = [NSMutableDictionary new];
    [[[self entity] attributesByName] enumerateKeysAndObjectsUsingBlock:^(NSString *modelKey, NSAttributeDescription *attribute, BOOL *stop) {
        if (![[self class] property:modelKey decoratedWith:@protocol(IKJSONIgnoreOutgoing)]) {
            NSString *key = [self jsonKeyForProperty:modelKey];
            id value = [self jsonValueForValue:[self valueForKey:modelKey] jsonKey:key];
            
            if (![NSObject nilOrEmpty:key] && ![NSObject nilOrEmpty:value]) {
                result[key] = value;
            }
        }
    }];
    return result;
}
-(NSDictionary *)jsonRelationships {
    NSMutableDictionary *result = [NSMutableDictionary new];
    [[[self entity] relationshipsByName] enumerateKeysAndObjectsUsingBlock:^(NSString *relationshipKey, NSRelationshipDescription *relationship, BOOL *stop) {
        if (relationship.toMany && ![[self class] property:relationshipKey decoratedWith:@protocol(IKJSONIgnoreOutgoing)]) {
            NSSet *set = [self mutableSetValueForKey:relationshipKey];
            NSArray *objects = [set.allObjects map:^NSDictionary *(NSManagedObject *object) { return [object nsManagedObjectToJson]; }];
            result[relationshipKey] = objects;
            
        } else if (![[self class] property:relationshipKey decoratedWith:@protocol(IKJSONIgnoreOutgoing)]) {
            NSManagedObject *object = [self valueForKey:relationshipKey];
            if (![object conformsToProtocol:@protocol(IKJSONIgnoreOutgoing)]) {
                if (![NSObject nilOrEmpty:object] && [object isKindOfClass:[NSManagedObject class]]) {
                    result[relationshipKey] = [object nsManagedObjectToJson];
                }
            }
        }
    }];
    return result;
}
@end

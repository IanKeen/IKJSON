//
//  NSManagedObject+IKJSONIncoming_NSManagedObject.m
//  IKJSON
//
//  Created by Ian Keen on 26/06/2015.
//  Copyright (c) 2015 Mustard. All rights reserved.
//

#import "NSManagedObject+IKJSONIncoming_NSManagedObject.h"
#import "NSObject+IKJSONCommon.h"
#import <IKCore/NSObject+Null.h>
#import <IKCore/NSObject+Introspection.h>
#import "IKJSONShared.h"

@implementation NSManagedObject (IKJSONIncoming_NSManagedObject)
-(void)nsManagedObjectPopulate:(NSDictionary *)json {
    NSDictionary *incomingJson = [self mappedJson:json];
    
    [self populateAttributes:incomingJson];
    [self populateRelationships:incomingJson];
}

#pragma mark - Private - Mapping
-(void)populateAttributes:(NSDictionary *)json {
    [[[self entity] attributesByName] enumerateKeysAndObjectsUsingBlock:^(NSString *modelKey, NSAttributeDescription *attribute, BOOL *stop) {
        id value = json[modelKey];
        if (![NSObject nilOrEmpty:value] && ![[self class] property:modelKey decoratedWith:@protocol(IKJSONIgnoreIncoming)]) {
            value = [self convertValue:value attribute:attribute];
            [self setValue:value forKey:modelKey];
        }
    }];
}
-(void)populateRelationships:(NSDictionary *)json {
    [[[self entity] relationshipsByName] enumerateKeysAndObjectsUsingBlock:^(NSString *relationshipKey, NSRelationshipDescription *relationship, BOOL *stop) {
        if (![[self class] property:relationshipKey decoratedWith:@protocol(IKJSONIgnoreIncoming)]) {
            if (relationship.toMany) {
                NSArray *objects = json[relationshipKey];
                if (![NSObject nilOrEmpty:objects] && [objects isKindOfClass:[NSArray class]]) {
                    NSMutableSet *set = [self mutableSetValueForKey:relationshipKey];
                    [objects enumerateObjectsUsingBlock:^(NSDictionary *object, NSUInteger idx, BOOL *stop) {
                        NSManagedObject *target = [self createRelatedObject:relationship json:object];
                        [set addObject:target];
                    }];
                }
                
            } else {
                NSDictionary *object = json[relationshipKey];
                if (![NSObject nilOrEmpty:object] && [object isKindOfClass:[NSDictionary class]]) {
                    NSManagedObject *target = [self createRelatedObject:relationship json:object];
                    [self setValue:target forKey:relationshipKey];
                }
            }
        }
    }];
}
-(NSManagedObject *)createRelatedObject:(NSRelationshipDescription *)relationship json:(NSDictionary *)json {
    NSString *targetName = relationship.destinationEntity.managedObjectClassName;
    NSEntityDescription *description = [NSEntityDescription entityForName:targetName inManagedObjectContext:self.managedObjectContext];
    NSManagedObject *target = [[NSManagedObject alloc] initWithEntity:description insertIntoManagedObjectContext:self.managedObjectContext];
    
    [target nsManagedObjectPopulate:json];
    return target;
}

#pragma mark - Private - Values
-(id)convertValue:(id)value attribute:(NSAttributeDescription *)attribute {
    NSAttributeType type = attribute.attributeType;
    
    if ((type == NSStringAttributeType) && ([value isKindOfClass:[NSNumber class]])) {
        /* NSNSumber -> NSString */
        return [value stringValue];
    }
    
    else if (([self isPrimitiveInteger:type]) && ([value isKindOfClass:[NSString class]])) {
        /* NSInteger -> NSNumber */
        return [NSNumber numberWithInteger:[value integerValue]];
    }
    
    else if (([self isPrimitiveFloatingPoint:type]) && ([value isKindOfClass:[NSString class]])) {
        /* Double/Float -> NSNumber */
        return [NSNumber numberWithInteger:[value doubleValue]];
    }
    
    //Unmodified
    return value;
}
-(BOOL)isPrimitiveInteger:(NSAttributeType)type {
    return (type == NSInteger16AttributeType) || (type == NSInteger32AttributeType) || (type == NSInteger64AttributeType) || (type == NSBooleanAttributeType);
}
-(BOOL)isPrimitiveFloatingPoint:(NSAttributeType)type {
    return (type == NSFloatAttributeType) || (type == NSDoubleAttributeType) || (type == NSDecimalAttributeType);
}
@end

//
//  NSObject+IKJSON.m
//  IKJSON
//
//  Created by Ian Keen on 26/06/2015.
//  Copyright (c) 2015 Mustard. All rights reserved.
//

#import "NSObject+IKJSON.h"

#import "NSManagedObject+IKJSONOutgoing_NSManagedObject.h"
#import "NSManagedObject+IKJSONIncoming_NSManagedObject.h"
#import "NSManagedObject+IKJSONImport.h"

#import "NSObject+IKJSONOutgoing_NSObject.h"
#import "NSObject+IKJSONIncoming_NSObject.h"

@implementation NSObject (IKJSON)
-(NSDictionary *)json {
    if ([self isKindOfClass:[NSManagedObject class]]) {
        return [((NSManagedObject *)self) nsManagedObjectToJson];
    }
    return [self ponsoToJson];
}
-(void)populate:(NSDictionary *)json {
    if ([self isKindOfClass:[NSManagedObject class]]) {
        return [((NSManagedObject *)self) nsManagedObjectPopulate:json];
    }
    return [self ponsoPopulate:json];
}
@end

@implementation NSManagedObject (IKJSONImport)
+(AsyncResult *)import:(NSArray *)objectArray
       detectDeletions:(BOOL)detectDeletions
               context:(NSManagedObjectContext *)context
                  item:(importItemBlock)itemBlock
                  save:(importSaveBlock)saveBlock {
    return [self import:objectArray
        detectDeletions:detectDeletions
                context:context
                   item:itemBlock
                   save:saveBlock];
}
@end
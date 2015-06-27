//
//  NSManagedObject+IKJSONImport.m
//  IKJSON
//
//  Created by Ian Keen on 26/06/2015.
//  Copyright (c) 2015 Mustard. All rights reserved.
//

#import "NSManagedObject+IKJSONImport.h"
#import <IKCore/NSArray+Filter.h>
#import <IKCore/NSObject+Introspection.h>
#import <IKCore/NSObject+Null.h>
#import "IKJSONShared.h"
#import "NSManagedObject+IKJSONIncoming_NSManagedObject.h"

static NSInteger batchSize = 50;

@implementation NSManagedObject (IKJSONImport_NSManagedObject)
+(AsyncResult *)nsManagedObjectImport:(NSArray *)objectArray
       detectDeletions:(BOOL)detectDeletions
               context:(NSManagedObjectContext *)context
                  item:(importItemBlock)itemBlock
                  save:(importSaveBlock)saveBlock {
    if (saveBlock == nil) { @throw [NSException exceptionWithName:NSStringFromClass([self class]) reason:@"A save block is required" userInfo:nil]; }
    
    AsyncResult *result = [AsyncResult asyncResult];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *primaryIds = [self propertiesDecoratedWith:@protocol(IKJSONPrimaryKey)];
        if (primaryIds.count != 1) {
            NSString *reason = [NSString stringWithFormat:@"%@ must have a single <IKJSONPrimaryKey> defined to use imports", NSStringFromClass(self)];
            @throw [NSException exceptionWithName:@"NSManagedObject+IKJSONImport" reason:reason userInfo:nil];
        }
        
        //Sort the incoming JSON entities by primary key
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:primaryIds.firstObject ascending:YES];
        NSArray *sortedJsonEntities = [objectArray sortedArrayUsingDescriptors:@[descriptor]];
        NSArray *jsonEntityKeys = [sortedJsonEntities valueForKey:primaryIds.firstObject];
        NSEnumerator *jsonEnumerator = [sortedJsonEntities objectEnumerator];
        
        //Sort the existing entities by primary key
        NSArray *existingEntities = [[self class] entities:primaryIds.firstObject in:jsonEntityKeys orderedBy:primaryIds.firstObject ascending:YES context:context];
        NSEnumerator *entityEnumerator = [existingEntities objectEnumerator];
        
        //Get first item of each list
        NSDictionary *json = [jsonEnumerator nextObject];
        NSManagedObject *entity = [entityEnumerator nextObject];
        
        //Keep a list of entities that are created/updated
        NSMutableArray *processedEntities = [NSMutableArray array];
        NSInteger count = 0;
        while (json) {
            count++;
            
            //If the incoming json item and the existing entity at this position have the same primary key we update
            BOOL isUpdate = ([json[primaryIds.firstObject] isEqual:[entity valueForKey:primaryIds.firstObject]]);
            
            if (isUpdate) {
                [entity nsManagedObjectPopulate:json];
                if (itemBlock) { itemBlock(entity, json); }
                
                //add the processed entity to a list
                [processedEntities addObject:entity];
                
                json = [jsonEnumerator nextObject];
                entity = [entityEnumerator nextObject];
                
            } else {
                //if the primary keys dont match we create
                NSManagedObject *newEntity = [self createNewEntity:context];
                [newEntity nsManagedObjectPopulate:json];
                
                if (itemBlock) { itemBlock(entity, json); }
                
                json = [jsonEnumerator nextObject];
            }
            
            if ((count % batchSize) == 0) {
                saveBlock(^{ /*not used here*/ });
            }
        }
        
        if (detectDeletions) {
            //Compare the processed entity list to the initial list of items when we started
            //delete any entities from the initial list not in the processed list
            
            NSArray *handledPrimaryIds = [processedEntities valueForKey:primaryIds.firstObject];
            [[existingEntities filter:^BOOL(NSManagedObject *item) {
                return ![handledPrimaryIds containsObject:[item valueForKey:primaryIds.firstObject]];
                
            }] enumerateObjectsUsingBlock:^(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
                [obj deleteEntity:context];
            }];
        }
        
        saveBlock(^{
            [result fulfill:[Result success:@YES]];
        });
    });
    
    return result;
}

#pragma mark - Private - CoreData Operations
+(NSArray *)entities:(NSString *)key in:(NSArray *)possibilities orderedBy:(NSString *)orderKey ascending:(BOOL)ascending context:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K IN %@)", key, possibilities];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([self class])];
    request.fetchBatchSize = 20;
    request.predicate = predicate;
    
    if (![NSObject nilOrEmpty:orderKey]) {
        NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:orderKey ascending:ascending];
        request.sortDescriptors = @[sorter];
    }
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error) { NSLog(@"COREDATA ERROR: %@", error); }
    return results;
}
+(instancetype)createNewEntity:(NSManagedObjectContext *)context {
    __block NSManagedObject *newObject = nil;
    [context performBlockAndWait:^{
        NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass([self class]) inManagedObjectContext:context];
        newObject = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    }];
    return newObject;
}
-(void)deleteEntity:(NSManagedObjectContext *)context {
    NSManagedObject *object = self;
    if (self.managedObjectContext != context) {
        object = [context objectWithID:self.objectID];
    }
    [context deleteObject:object];
}
@end

//
//  NSObject+IKJSON.h
//  IKJSON
//
//  Created by Ian Keen on 26/06/2015.
//  Copyright (c) 2015 Mustard. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <IKResults/AsyncResult.h>
#import "IKJSONShared.h"

@interface NSObject (IKJSON)
-(NSDictionary *)json;
-(void)populate:(NSDictionary *)json;
@end

@interface NSManagedObject (IKJSONImport)
+(AsyncResult *)import:(NSArray *)objectArray
       detectDeletions:(BOOL)detectDeletions
               context:(NSManagedObjectContext *)context
                  item:(importItemBlock)itemBlock
                  save:(importSaveBlock)saveBlock;
@end
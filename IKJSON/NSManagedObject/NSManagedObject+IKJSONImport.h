//
//  NSManagedObject+IKJSONImport.h
//  IKJSON
//
//  Created by Ian Keen on 26/06/2015.
//  Copyright (c) 2015 Mustard. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <IKResults/AsyncResult.h>
#import "IKJSONShared.h"

@interface NSManagedObject (IKJSONImport_NSManagedObject)
+(AsyncResult *)nsManagedObjectImport:(NSArray *)objectArray
       detectDeletions:(BOOL)detectDeletions
               context:(NSManagedObjectContext *)context
                  item:(importItemBlock)itemBlock
                  save:(importSaveBlock)saveBlock;
@end

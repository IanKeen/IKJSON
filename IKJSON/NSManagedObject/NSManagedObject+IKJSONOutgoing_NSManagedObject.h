//
//  IKJSON
//
//  Created by Ian Keen on 26/06/2015.
//  Copyright (c) 2015 Mustard. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (IKJSONOutgoing_NSManagedObject)
-(NSDictionary *)nsManagedObjectToJson;
@end

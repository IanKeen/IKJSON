//
//  IKJSONProtocols.h
//  IKJSON
//
//  Created by Ian Keen on 26/06/2015.
//  Copyright (c) 2015 Mustard. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^importItemBlock)(id entity, NSDictionary *json);
typedef void(^importSaveBlock)(dispatch_block_t complete);

/**
 *  Incoming protocols
 *  These protocols allow for altering the incoming JSON *before* attempting to map to an object
 */

@protocol IKJSONIncomingPropertyMapping <NSObject>
-(NSString *)mappedPropertyForJSONKey:(NSString *)jsonKey;
@end

@protocol IKJSONIncomingValueMapping <NSObject>
-(id)mappedValueForJSONValue:(id)jsonValue property:(NSString *)propertyName;
@end

@protocol IKJSONIncomingModelMapping <NSObject>
-(NSString *)mappedModelClassForPropertyName:(NSString *)propertyName;
@end



/**
 *  Outgoing protocols
 *  These protocols allow for altering the keys/values while generating the outgoing JSON
 */

@protocol IKJSONOutgoingPropertyMapping <NSObject>
-(NSString *)mappedJSONKeyForProperty:(NSString *)propertyName;
@end

@protocol IKJSONOutgoingValueMapping <NSObject>
-(id)mappedJSONValueForValue:(id)value jsonKey:(NSString *)jsonKey;
@end



/**
 *  Decorator protocols
 *  These protocol allow you to modify the default behaviour when handing object/json mapping
 */

/**
 *  Applying this protocol to a property will cause it to be ignored when mapping incoming JSON
 */
@protocol IKJSONIgnoreIncoming <NSObject> @end

/**
 *  Applying this protocol to a property will cause it to be ignored when mapping to outgoing JSON
 *  This is especially useful for stopping circular references (i.e. a parent relationship)
 */
@protocol IKJSONIgnoreOutgoing <NSObject> @end

/**
 *  Applying this protocol to a property representing an objects unique identifier 
 *  allows for efficient bulk importing of a JSON collection
 */
@protocol IKJSONPrimaryKey <NSObject> @end
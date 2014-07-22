//
//  GiftResponseBuilder.h
//  PAE_iOS_SDK
//
//  Created by Shephertz Technologies Pvt Ltd on 12/06/14.
//  Copyright (c) 2014 ShephertzTechnology PVT LTD. All rights reserved.
//

#import <Shephertz_App42_iOS_API/Shephertz_App42_iOS_API.h>

/**
 *
 * GiftResponseBuilder class converts the JSON response retrieved from the
 * server to the value object i.e Gift
 *
 */
@interface GiftResponseBuilder : App42ResponseBuilder

/**
 * Converts the response in JSON format to the value object i.e Gift
 *
 * @param json
 *            - response in JSON format
 *
 * @return Gift object filled with json data
 *
 */
-(Gift*)buildResponse:(NSString*)Json;
/**
 * Converts the response in JSON format to the list of value objects i.e
 * Gift
 *
 * @param json
 *            - response in JSON format
 *
 * @return List of Gift object filled with json data
 *
 */
-(NSArray *)buildArrayResponse:(NSString*)Json;
@end

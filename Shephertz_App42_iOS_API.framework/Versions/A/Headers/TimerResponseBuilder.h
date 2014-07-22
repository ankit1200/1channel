//
//  TimerResponseBuilder.h
//  PAE_iOS_SDK
//
//  Created by Rajeev on 14/06/14.
//  Copyright (c) 2014 ShephertzTechnology PVT LTD. All rights reserved.
//

#import <Shephertz_App42_iOS_API/Shephertz_App42_iOS_API.h>

/**
 *
 * TimerResponseBuilder class converts the JSON response retrieved from the
 * server to the value object i.e Timer
 *
 */
@interface TimerResponseBuilder : App42ResponseBuilder

/**
 * Converts the response in JSON format to the value object i.e Timer
 *
 * @param json
 *            - response in JSON format
 *
 * @return Timer object filled with json data
 *
 */
-(Timer*)buildResponse:(NSString*)response;

@end

//
//  GiftService.h
//  PAE_iOS_SDK
//
//  Created by Shephertz Technologies Pvt Ltd on 12/06/14.
//  Copyright (c) 2014 ShephertzTechnology PVT LTD. All rights reserved.
//

#import <Shephertz_App42_iOS_API/Shephertz_App42_iOS_API.h>
@class Gift;

@interface GiftService : App42Service

- (id) init __attribute__((unavailable));
/**
 * This is a constructor that takes
 *
 * @param apiKey
 * @param secretKey
 * @param baseURL
 *
 */
-(id)initWithAPIKey:(NSString *)apiKey  secretKey:(NSString *)secretKey;

/**
 * Create a gift.
 *
 * @param giftName
 *            - Name of gift to be created.
 * @param giftIconPath
 *            - File path of the gift icon
 * @param displayName
 *            - An alternate name of the gift that can be used to display
 * @param tag
 *            - tag for the Gift
 * @param description
 *            - Description of the Gift to be created
 * @return Gift Object
 * @throws App42Exception
 */
-(Gift*)createGiftWithName:(NSString*)giftName giftIconPath:(NSString*)giftIconPath displayName:(NSString*)displayName giftTag:(NSString*)tag description:(NSString*)description;

/**
 * Get all gifts available.
 *
 * @return NSArray of gift Object
 * @throws App42Exception
 */
-(NSArray*)getAllGifts;

/**
 * Get gift with its name.
 *
 * @param giftName
 *            - Name of gift to be fetched.
 * @return Gift Object
 * @throws App42Exception
 */
-(Gift*)getGiftByName:(NSString*)giftName;

/**
 * Get all gifts having same tag.
 *
 * @param tag
 *            - tag for the Gift
 * @return NSArray of gift Objects
 * @throws App42Exception
 */
-(NSArray*)getGiftsByTag:(NSString*)tag;

/**
 * Delete a gift with name.
 *
 * @param giftName
 *            - Name of gift to be created.
 * @return App42Response
 * @throws App42Exception
 */
-(App42Response*)deleteGiftByName:(NSString*)giftName;

/**
 * Send a gift with name to other users.
 *
 * @param giftName
 *            - Name of gift to be created.
 * @param sender
 *            - Name of the user who is sending the gift.
 * @param recipients
 *            - Array of the user who will receive the gift.
 * @param message
 *            - message that you want to send with gift.
 * @return Gift Object
 * @throws App42Exception
 */
-(Gift*)sendGiftWithName:(NSString*)giftName from:(NSString*)sender to:(NSArray*)recipients withMessage:(NSString*)message;

/**
 * Request a gift with name from other users.
 *
 * @param giftName
 *            - Name of gift to be created.
 * @param sender
 *            - Name of the user who is requesting for the gift.
 * @param recipients
 *            - Array of the user who will receive the request.
 * @param message
 *            - message that you want to send with request.
 * @return Gift Object
 * @throws App42Exception
 */
-(Gift*)requestGiftWithName:(NSString*)giftName from:(NSString*)sender to:(NSArray*)recipients withMessage:(NSString*)message;

/**
 * Get a gift request from a user.
 *
 * @param giftName
 *            - Name of gift to be created.
 * @param userName
 *            - Name of the user who is requesting for the gift.
 * @return Gift Object
 * @throws App42Exception
 */
-(Gift*)getGiftRequestWithName:(NSString*)giftName fromUser:(NSString*)userName;


-(Gift*)distributeGiftsWithName:(NSString*)giftName to:(NSArray*)recipients count:(int)count;

-(App42Response*)getGiftCountWithName:(NSString*)giftName forUser:(NSString*)userName;

-(Gift*)acceptGiftRequestWithId:(NSString*)requestId by:(NSString*)recipient;

-(Gift*)rejectGiftRequestWithId:(NSString*)requestId by:(NSString*)recipient;

-(App42Response*)removeGiftWithRequestId:(NSString*)requestId by:(NSString*)recipient;

@end

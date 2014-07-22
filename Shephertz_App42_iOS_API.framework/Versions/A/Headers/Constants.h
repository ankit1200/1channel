//
//  Constants.h
//  App42_iOS_SERVICE_API
//
//  Created by Shephertz Technology on 07/02/12.
//  Copyright (c) 2012 ShephertzTechnology PVT LTD. All rights reserved.
//


#define SDK_VERSION     @"2.7"


#define version     @"1.0"

#define API_Key     @"apiKey"

#define VERSION     @"version"
#define ADMIN_KEY   @"adminKey"
#define SESSION_ID  @"sessionId"

#define TIME_STAMP  @"timeStamp"
#define JSON_QUERY  @"jsonQuery"

#define contentType @"application/json"

#define acceptType  @"application/json"


#define IS_IN_PRODUCTION        1  // Change this to 1 before releasing the build

#if IS_IN_PRODUCTION

    #define SERVER_URL @"https://api.shephertz.com/cloud/"
#else
   #define SERVER_URL @"http://192.168.1.34:8082/App42_API_SERVER/cloud/"
#endif

//#define SERVER_URL @"http://10.0.0.35:8082/App42_API_SERVER/api/"

/***
 *  USER PAERMISSIONS
 **/
#define APP42_READ @"R"
#define APP42_WRITE @"W"

/***
 *  BASIC SERVICE PARAMS
 **/
#define API_KEYS            @"apiKey"
#define VERSION             @"version"
#define TIME_SATMP          @"timeStamp"
#define LOG_TAG             @"App42"
#define SESSION_ID          @"sessionId"
#define ADMIN_KEY           @"adminKey"
#define PAGE_OFFSET         @"offset"
#define PAGE_MAX_RECORDS    @"max"
#define DATA_ACL_HEADER     @"dataACL"
#define SELECT_KEY_FLAG     @"1"
#define SELECT_KEYS_HEADER  @"selectKeys"
#define FB_ACCESS_TOKEN     @"fbAccessToken"
#define GEO_TAG             @"geoTag"

/***
 *  LOCAL STORAGE KEYS
 **/
#define APP42_INSTALLATION_ID     @"installationId"
#define APP42_SESSION_ID          @"sessionId"
#define APP42_LOGGEDIN_USER       @"loggedInUser"

/***
 *  Enums
 **/


  
//
//  DataManager.swift
//  1channel
//
//  Downloads the data for each series
//
//  Created by Ankit Agarwal on 7/20/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import Foundation

class DataManager : NSObject
{
    let apiKey = "19ef26e5f5afd36d55cdf1efead1bb474e1e8e8715e5e14a5fb8eac45557dd51"
    let secretKey = "dab190eefbdc70ef7eb677cc5ca4c7c398243b3ae0fa43067a40c38839ddbf52"
    
    
    //    #pragma mark - download series info
    
    func downloadSeriesData(seriesName: String, primewireId: String) {
        var objectIdDict = NSDictionary()

//        objectIdDict = NSKeyedUnarchiver.unarchiveObjectWithFile(getFilePath()) as NSDictionary
        
        var error: NSError?
        
        // download name and seasons
        let seriesNameAndSeasonsUrl = "https://www.kimonolabs.com/api/70ef8q9g?apikey=kPOHhmqHVO3WCVK0J09sj1pvhc9a1baQ&kimpath1=\(primewireId)"
        let seriesNameAndSeasonsData = NSData(contentsOfURL: NSURL(string: seriesNameAndSeasonsUrl))

        let json = NSString(data: seriesNameAndSeasonsData, encoding: NSASCIIStringEncoding)
        var objectId: String? = objectIdDict.objectForKey("series_\(seriesName)_seasons") as String?
        
        // if key already exists then just update
        if objectId {
            updateJson(collectionName: seriesName, objectId: objectId!, json: json)
        } else {
            objectIdDict.setValue(saveJson(collectionName: seriesName, json: json), forKey: "series_\(seriesName)_seasons")
        }
        
        // download episodes for season
        
        
        // download links for episode
        
        
        (NSKeyedArchiver.archivedDataWithRootObject(objectIdDict) as NSData).writeToFile(getFilePath(), atomically: true)
    }
    
    
    //    #pragma mark - json data methods
    
    // saves new json entry to app42 returns the objectId of the json
    func saveJson(dbName: String = "1channel", collectionName: String, json:String) -> String {
        
        let storageService = setupServiceApi()
        let storage = storageService.insertJSONDocument(dbName, collectionName: collectionName, json: json)
        return (storage.jsonDocArray.objectAtIndex(0) as JSONDocument).docId
    }
    
    
    // updates the value of a current entry
    func updateJson(dbName: String = "1channel", collectionName: String, objectId:String, json:String) -> String {
        
        let storageService = setupServiceApi()
        let storage = storageService.updateDocumentByDocId(dbName, collectionName: collectionName, docId: objectId, newJsonDoc: json)
        return (storage.jsonDocArray.objectAtIndex(0) as JSONDocument).docId
    }
    
    // retrieves json from app42 returns the json object
    func retrieveJson(dbName: String = "1channel", collectionName: String, objectId:String) -> String {
        
        let storageService = setupServiceApi()
        let storage = storageService.findDocumentById(dbName, collectionName: collectionName, docId: objectId)
        
        return (storage.jsonDocArray.objectAtIndex(0) as JSONDocument).jsonDoc
    }
    
    
    //    #pragma mark - helper methods
    func setupServiceApi() -> StorageService {
        let serviceAPI = ServiceAPI();
        serviceAPI.apiKey = apiKey;
        serviceAPI.secretKey = secretKey;
        return serviceAPI.buildStorageService() as StorageService
    }
    
    // filePath for plist
    func getFilePath() -> String {
        let path =  NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        return path.stringByAppendingPathComponent("objectId.plist")
    }
}
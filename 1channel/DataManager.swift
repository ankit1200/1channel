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
//    var addNewSeries = true;
    
    //MARK: download series info
    
    func downloadSeriesData(seriesName: String, seriesId: String, seasonsFromParseQuery: Array<String>) {
        // download number of seasons
        println("Starting Download")
        
        let seasons = self.downloadSeriesNameAndSeasons(seriesId)
        println("Seasons Downloaded")
        
        // download episodes for each season and links for each episode and save it to parse
        let primewireId = seriesId.stringByReplacingOccurrencesOfString("watch", withString: "tv", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var seriesClassName = seriesName.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        self.downloadEpisodesForSeason(seriesName, seriesId: primewireId, seasons: seasons)
        println("Download Complete")
    }
    
    
    //MARK: helper methods
    
    func downloadSeriesNameAndSeasons(seriesId: String) -> Array<String> {
        
        // get data from kimono
        var error: NSError?
        let seriesNameAndSeasonsUrl = "https://www.kimonolabs.com/api/70ef8q9g?apikey=kPOHhmqHVO3WCVK0J09sj1pvhc9a1baQ&kimpath1=\(seriesId)"
        var seriesNameAndSeasonsData:NSData? = NSData(contentsOfURL: NSURL(string: seriesNameAndSeasonsUrl))
        
        while seriesNameAndSeasonsData == nil {
            println("seasons fetch failed, trying again....")
            seriesNameAndSeasonsData = NSData(contentsOfURL: NSURL(string: seriesNameAndSeasonsUrl))
        }
        
        // parse json outputted from Kimono
        let jsonDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(seriesNameAndSeasonsData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        let results = jsonDict["results"] as NSDictionary

        // create swift array from NSArray
        var seasons:Array<String> = []
        for season in (results["seasons"] as NSArray) {
            seasons.append(season["season"] as String)
        }
        
        return seasons;
    }
    
    func downloadEpisodesForSeason(seriesName: String, seriesId:String, seasons: Array<String>) {
        println("Downloaded episodes for season")
        // Start downloading from the lastest season
        for season in seasons.reverse() {
            var seasonNum = season.lowercaseString
            seasonNum = seasonNum.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            // get data from kimono
            var error: NSError?
            let episodesForSeasonUrl = "https://www.kimonolabs.com/api/2lcduwri?apikey=kPOHhmqHVO3WCVK0J09sj1pvhc9a1baQ&kimpath1=\(seriesId)&kimpath2=\(seasonNum)"
            var episodesForSeasonData:NSData? = NSData(contentsOfURL: NSURL(string: episodesForSeasonUrl))
            
            while episodesForSeasonData == nil {
                println("episodes fetch failed, trying again....")
                episodesForSeasonData = NSData(contentsOfURL: NSURL(string: episodesForSeasonUrl))
            }
            
            // parse json outputted from Kimono
            let jsonDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(episodesForSeasonData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
            let results = jsonDict["results"] as NSDictionary
            
            // create swift array from NSArray
            var episodes:Array<(String, String)> = []
            for episode in (results["episodes"] as NSArray) {
                episodes.append((episode["episodeNumber"] as String), (episode["episodeName"] as String))
            }
            
            // get links for each episode in current season
            // start downloading from the latest episode
            for episode in episodes.reverse() {
                var episodeNum = (episode.0).lowercaseString
                episodeNum = episodeNum.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil)
                
                self.downloadLinksForEpisode(seriesName, seriesId:seriesId, season:seasonNum, episodeNum:episodeNum)
            }
        }
    }
    
    func downloadLinksForEpisode(seriesName:String, seriesId:String, season:String, episodeNum:String) {
        // get data from kimono
        var error: NSError?
        let linksForEpisodeUrl = "https://www.kimonolabs.com/api/4nb0gypm?apikey=kPOHhmqHVO3WCVK0J09sj1pvhc9a1baQ&kimpath1=\(seriesId)&kimpath2=\(season)-\(episodeNum)"
        var linksForEpisodeData:NSData? = NSData(contentsOfURL: NSURL(string: linksForEpisodeUrl))
        
        while linksForEpisodeData == nil {
            println("links fetch failed, trying again....")
            linksForEpisodeData = NSData(contentsOfURL: NSURL(string: linksForEpisodeUrl))
        }
        
        // parse json outputted from Kimono
        let jsonDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(linksForEpisodeData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        let results = jsonDict["results"] as NSDictionary
        let links = results["episode_links"] as NSArray
        let episodeInfo = (results["episode_info"] as NSArray)[0] as NSDictionary

        // save data to parse
        self.saveObjectToParse(seriesName, seriesId: seriesId, episodeInfo: episodeInfo, links: links);
    }
    
    func saveObjectToParse(seriesName:String, seriesId: String, episodeInfo: NSDictionary, links: NSArray) {

        let query = PFQuery(className: seriesName)
        query.whereKey("episodeNumber", equalTo: episodeInfo["episode"])
        query.whereKey("episodeTitle", equalTo: episodeInfo["title"])

        query.getFirstObjectInBackgroundWithBlock {
            (foundObject: PFObject!, error: NSError!) -> Void in

            if foundObject == nil {
                // The find failed create new object and add
                let seriesObject = PFObject(className:seriesName)
                self.configureParseObject(seriesObject, seriesName: seriesName, seriesId: seriesId, episodeInfo: episodeInfo, links: links)
                println("new object\n\(episodeInfo)")
            } else {
                // The find succeeded update found object
                self.configureParseObject(foundObject, seriesName: seriesName, seriesId: seriesId, episodeInfo: episodeInfo, links: links)
                println("update object\n\(episodeInfo)")
            }
        }
    }
    
    
    func configureParseObject(object:PFObject, seriesName: String, seriesId: String, episodeInfo: NSDictionary, links:NSArray) {
        object["seriesName"] = seriesName
        object["seriesId"] = seriesId
        object["season"] = episodeInfo["season"]
        object["episodeNumber"] = episodeInfo["episode"]
        object["episodeTitle"] = episodeInfo["title"]
        object["links"] = links
        object.saveInBackground()
    }
}
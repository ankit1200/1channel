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

    //    #pragma mark - download series info
    
    func downloadSeriesData(seriesName: String, primewireId: String) {
        
        var seriesClass:PFObject = PFObject(className: seriesName)
        
        // download name and seasons
        let seasons = self.downloadSeriesNameAndSeasons(primewireId)
        
        // download episodes for season
        
        
        // download links for episode
        let linksForEpisodeUrl = "https://www.kimonolabs.com/api/4nb0gypm?apikey=kPOHhmqHVO3WCVK0J09sj1pvhc9a1baQ&kimpath1=\(primewireId)&kimpath2=\(season)-\(episode)"
        let linksForEpisodeData = NSData(contentsOfURL: NSURL(string: linksForEpisodeUrl))
    }
    
//    #pragma mark - helper methods
    func downloadSeriesNameAndSeasons(seriesId: String) -> NSArray {
        
        // get data from kimono
        var error: NSError?
        let seriesNameAndSeasonsUrl = "https://www.kimonolabs.com/api/70ef8q9g?apikey=kPOHhmqHVO3WCVK0J09sj1pvhc9a1baQ&kimpath1=\(seriesId)"
        let seriesNameAndSeasonsData = NSData(contentsOfURL: NSURL(string: seriesNameAndSeasonsUrl))
        
        var jsonDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(seriesNameAndSeasonsData, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        let results = jsonDict["results"] as NSDictionary
        let seasons = results["seasons"] as NSArray
        
        // save data to parse
        return seasons;
    }
    
    func downloadEpisodesForSeason(seriesId:String, seasons: NSArray) {
        
        for season in seasons {
            
            // get data from kimono
            var error: NSError?
            let episodesForSeasonUrl = "https://www.kimonolabs.com/api/2lcduwri?apikey=kPOHhmqHVO3WCVK0J09sj1pvhc9a1baQ&kimpath1=\(seriesId)&kimpath2=\(season)"
            let episodesForSeasonData = NSData(contentsOfURL: NSURL(string: episodesForSeasonUrl))
            
            var jsonDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(seriesNameAndSeasonsData, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
            let results = jsonDict["results"] as NSDictionary
            let seasons = results["seasons"] as NSArray
            
            // save data to parse
        }
    }
}
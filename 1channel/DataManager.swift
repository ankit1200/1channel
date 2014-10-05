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
    //MARK: download info
    
    func downloadSeriesData(seriesName: String, seriesId: String, seasonsFromParseQuery: Array<String>) {
        println("Starting Series Download")
        
        // download number of seasons
        let seasons = self.downloadSeriesNameAndSeasons(seriesId)
        println("Seasons Downloaded")
        
        // download episodes for each season and links for each episode and save it to parse
        let primewireId = seriesId.stringByReplacingOccurrencesOfString("watch", withString: "tv", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var seriesClassName = seriesName.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        self.downloadEpisodesForSeason(seriesName, seriesId: primewireId, seasons: seasons)
        println("Series Download Complete")
    }
    
    func downloadMovieData() {
        
        println("Starting Movie Download")
        
        self.downloadMovieList()
        
        println("Movie Download Complete")
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
        
        // add image to the series
        let query = PFQuery(className: "Series")
        query.limit = 1000
        query.whereKey("seriesID", equalTo: seriesId.stringByReplacingOccurrencesOfString("tv", withString: "watch", options: NSStringCompareOptions.LiteralSearch, range: nil))
        query.getFirstObjectInBackgroundWithBlock {
            (object: PFObject!, error: NSError!) -> Void in
            if object != nil {
                object["image"] = episodeInfo["image"];
                println("image downloaded")
            }
            object.saveInBackground()
        }
        
        // save data to parse
        if !checkFakeLinks(links) {
            self.saveObjectToParse(seriesName, id: seriesId, info: episodeInfo, links: links, image:"", isMovie: false);
        }
    }
    
    func saveObjectToParse(name:String, id: String, info: NSDictionary, links: NSArray, image: String,  isMovie: Bool) {

        var query: PFQuery
        if isMovie {
            query = PFQuery(className: "Movies")
            query.limit = 1000
            var queryName = info["name"] as String
            queryName = queryName.stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
            queryName = queryName.stringByReplacingOccurrencesOfString(":", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            query.whereKey("name", equalTo: "movie_\(queryName)")
            
        } else {
            query = PFQuery(className: name)
            query.limit = 1000
            query.whereKey("episodeNumber", equalTo: info["episode"])
            query.whereKey("episodeTitle", equalTo: info["title"])
        }

        query.getFirstObjectInBackgroundWithBlock {
            (foundObject: PFObject!, error: NSError!) -> Void in
            if foundObject == nil {
                // The find failed create new object and add
                var object: PFObject!
                if isMovie {
                    object = PFObject(className: "Movies")
                } else {
                    object = PFObject(className:name)
                }
                self.configureParseObject(object, name: name, id: id, info: info, links: links, image: image, isMovie: isMovie)
                println("new object\n\(info)")
            } else {
                // The find succeeded update found object
                self.configureParseObject(foundObject, name: name, id: id, info: info, links: links, image: image, isMovie: isMovie)
                println("update object\n\(info)")
            }
        }
    }
    
    // add object to parse
    func configureParseObject(object:PFObject, name: String, id: String, info: NSDictionary, links:NSArray, image:String, isMovie: Bool) {

        if !isMovie {
            object["seriesName"] = name
            object["seriesId"] = id
            object["season"] = info["season"]
            object["episodeNumber"] = info["episode"]
            object["episodeTitle"] = info["title"]
            object["links"] = links
            object["description"] = info["description"]
        } else {
            object["name"] = name
            object["movieId"] = id
            object["links"] = links
            object["image"] = image
        }
        object.saveInBackground()
    }
    
    // check to see if season is fake
    func checkFakeLinks(links: NSArray) -> Bool{
        
        for link in links {
            let link = link as Dictionary<String, String>
            
            if link["source"] != "Watch HD" {
                return false;
            }
        }
        return true;
    }
    
    func downloadMovieList() {
        for i in 1...5 {
            // get data from kimono
            var error: NSError?
            let movieListUrl = "https://www.kimonolabs.com/api/drsxjk1y?apikey=kPOHhmqHVO3WCVK0J09sj1pvhc9a1baQ&page=\(i)"
            var movieListData:NSData? = NSData(contentsOfURL: NSURL(string: movieListUrl))
            
            while movieListData == nil {
                println("links fetch failed, trying again....")
                movieListData = NSData(contentsOfURL: NSURL(string: movieListUrl))
            }
            
            // parse json outputted from Kimono
            let jsonDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(movieListData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
            let results = jsonDict["results"] as NSDictionary
            let list = results["movieList"] as NSArray
            
            for movie in list {
                let movieDict = (movie as NSDictionary)["movie"] as NSDictionary
                var name = (movieDict["alt"] as String).stringByReplacingOccurrencesOfString("Watch ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                name = name.stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
                name = name.stringByReplacingOccurrencesOfString(":", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                name = "movie_\(name)"
                let id = (movieDict["href"] as String).stringByReplacingOccurrencesOfString("http://www.primewire.ag/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                downloadMovieLinks(name, movieId: id, image: movieDict["src"] as String)
            }
        }
    }
    
    func downloadMovieLinks(movieName: String, movieId: String, image: String) {
        // get data from kimono
        var error: NSError?
        let linksForMovieUrl = "https://www.kimonolabs.com/api/bf6pc8gm?apikey=kPOHhmqHVO3WCVK0J09sj1pvhc9a1baQ&kimpath1=\(movieId)"
        var linksForMovieData:NSData? = NSData(contentsOfURL: NSURL(string: linksForMovieUrl))
        
        while linksForMovieData == nil {
            println("links fetch failed, trying again....")
            linksForMovieData = NSData(contentsOfURL: NSURL(string: linksForMovieUrl))
        }
        
        // parse json outputted from Kimono
        let jsonDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(linksForMovieData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        let results = jsonDict["results"] as NSDictionary
        if results["links"] != nil {
            let links = results["links"] as NSArray
            let movieInfo = (results["movieInfo"] as NSArray)[0] as NSDictionary
        
            self.saveObjectToParse(movieName, id: movieId, info: movieInfo, links: links, image: image, isMovie:true)
        }
    }
}
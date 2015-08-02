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

extension NSDate
{
    convenience
    init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "LLLL dd, yyyy"
        let d = dateStringFormatter.dateFromString(dateString)
        self.init(timeInterval:0, sinceDate:d!)
    }
}

class DataManager : NSObject
{
    var imageDownloaded = false; // boolean to check if image has been downloaded
    var seriesList = Array<Episode>()
    var movieList = Array<Movie>()
    
    
    //MARK: Singleton Function
    
    class var sharedInstance: DataManager {
        struct Static {
            static var instance: DataManager?
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            Static.instance = DataManager()
        }
        return Static.instance!
    }
    
    
    //MARK: Download Series Data
    
    func downloadSeriesData(seriesName: String, seriesId: String, seasonsFromParseQuery: Array<String>?) {
        println("Starting Series Download")
        
        // download number of seasons
        var seasons:Array<String>

        if seasonsFromParseQuery != nil {
            seasons = seasonsFromParseQuery!
        } else {
            seasons = self.downloadSeriesNameAndSeasons(seriesId)
        }
        
        println("Seasons Downloaded")
        // download episodes for each season and links for each episode and save it to parse
        let primewireId = seriesId.stringByReplacingOccurrencesOfString("watch", withString: "tv", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var seriesClassName = seriesName.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        self.downloadEpisodesForSeason(seriesName, seriesId: primewireId, seasons: seasons)
        println("Series Download Complete")
    }
    
    func downloadSeriesNameAndSeasons(seriesId: String) -> Array<String> {
        
        // get data from kimono
        var error: NSError?
        let seriesNameAndSeasonsUrl = "http://www.kimonolabs.com/api/ondemand/70ef8q9g?apikey=kPOHhmqHVO3WCVK0J09sj1pvhc9a1baQ&kimpath1=\(seriesId)"
        var seriesNameAndSeasonsData:NSData? = NSData(contentsOfURL: NSURL(string: seriesNameAndSeasonsUrl)!)
        
        while seriesNameAndSeasonsData == nil {
            println("seasons fetch failed, trying again....")
            seriesNameAndSeasonsData = NSData(contentsOfURL: NSURL(string: seriesNameAndSeasonsUrl)!)
        }
        
        // parse json outputted from Kimono
        let jsonDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(seriesNameAndSeasonsData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
        let results = jsonDict["results"] as! NSDictionary

        // create swift array from NSArray
        var seasons:Array<String> = []
        for season in (results["seasons"] as! NSArray) {
            seasons.append((season["season"] as! NSDictionary)["text"] as! String) // Seasons is a dictionary containing text and a href, we have to get the text
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
            let episodesForSeasonUrl = "http://www.kimonolabs.com/api/ondemand/2lcduwri?apikey=kPOHhmqHVO3WCVK0J09sj1pvhc9a1baQ&kimpath1=\(seriesId)&kimpath2=\(seasonNum)"
            var episodesForSeasonData:NSData? = NSData(contentsOfURL: NSURL(string: episodesForSeasonUrl)!)
            
            while episodesForSeasonData == nil {
                println("episodes fetch failed, trying again....")
                episodesForSeasonData = NSData(contentsOfURL: NSURL(string: episodesForSeasonUrl)!)
            }
            
            // parse json outputted from Kimono
            let jsonDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(episodesForSeasonData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
            let results = jsonDict["results"] as! NSDictionary

            // create swift array from NSArray
            var episodes:Array<(String, String)> = []
            for episode in (results["episodes"] as! NSArray) {
                // episode number is a dictionary that contains a href and a text, we need the text
                episodes.append((episode["episodeNumber"] as! NSDictionary)["text"] as! String, (episode["episodeName"] as! NSDictionary)["text"] as! String)
            }

            // get links for each episode in current season
            // start downloading from the latest episode
            for episode in episodes.reverse() {
                var episodeNum = (episode.0).lowercaseString
                episodeNum = episodeNum.stringByReplacingOccurrencesOfString("e", withString: "episode-", options: NSStringCompareOptions.LiteralSearch, range: nil)
                
                self.downloadLinksForEpisode(seriesName, seriesId:seriesId, season:seasonNum, episodeNum:episodeNum)
            }
        }
    }
    
    func downloadLinksForEpisode(seriesName:String, seriesId:String, season:String, episodeNum:String) {
        // get data from kimono
        var error: NSError?

        let linksForEpisodeUrl = "http://www.kimonolabs.com/api/ondemand/4nb0gypm?apikey=kPOHhmqHVO3WCVK0J09sj1pvhc9a1baQ&kimpath1=\(seriesId)&kimpath2=\(season)-\(episodeNum)"
        var linksForEpisodeData:NSData? = NSData(contentsOfURL: NSURL(string: linksForEpisodeUrl)!)
        
        while linksForEpisodeData == nil {
            println("links fetch failed, trying again....")
            linksForEpisodeData = NSData(contentsOfURL: NSURL(string: linksForEpisodeUrl)!)
        }
        
        // parse json outputted from Kimono
        let jsonDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(linksForEpisodeData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
        let results = jsonDict["results"] as! NSDictionary

        var links = results["episode_links"] as! NSArray
        let episodeInfo = (results["episode_info"] as! NSArray)[0] as! NSDictionary
        
        // add image to the series
        if !imageDownloaded {
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
            imageDownloaded = true
        }
        
        links = removeFakeSoruces(links)
        // save data to parse
        if links.count > 0 {
            self.saveObjectToParse(seriesName, id: seriesId, info: episodeInfo, links: links, image:"", year:"", isMovie: false);
        }
    }
    
    //MARK: Download Movies Data
    
    func downloadMovieData(completionHandler: ()->()) {
        
        println("Starting Movie Download")
        
        self.downloadMovieLinks({completionHandler()})
        
        println("Movie Download Complete")
    }
    
    func downloadMovieLinks(completionHandler: ()->()) {
        // get data from kimono
        var error: NSError?
        let linksForMovieUrl = "http://www.kimonolabs.com/api/bf6pc8gm?apikey=kPOHhmqHVO3WCVK0J09sj1pvhc9a1baQ&kimbypage=1"
        var linksForMovieData:NSData? = NSData(contentsOfURL: NSURL(string: linksForMovieUrl)!)
        
        while linksForMovieData == nil {
            println("links fetch failed, trying again....")
            linksForMovieData = NSData(contentsOfURL: NSURL(string: linksForMovieUrl)!)
        }
        
        // parse json outputted from Kimono
        let jsonDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(linksForMovieData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as! NSDictionary
        let results = jsonDict["results"] as! NSArray

        for result in results {
            if let page = result as? NSDictionary {
                let movieInfo = (page["movieInfo"] as! NSArray)[0] as! NSDictionary
                let movieName = (movieInfo["name"] as! String)
                var movieID = (page["url"] as! String).stringByReplacingOccurrencesOfString("http://www.primewire.ag/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                movieID = movieID.stringByReplacingOccurrencesOfString("-online-free", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                let links = removeFakeSoruces(page["links"] as! NSArray)
                let image = movieInfo["image"] as! String
                var year = movieInfo["releaseDate"] as! String
                self.saveObjectToParse(movieName, id: movieID, info: movieInfo, links: links, image: image, year:year, isMovie:true)
            }
        }
        completionHandler()
    }
    
    //MARK: Helper Methods
    
    func saveObjectToParse(name:String, id: String, info: NSDictionary, links: NSArray, image: String, year:String, isMovie: Bool) {

        var query: PFQuery
        if isMovie {
            query = PFQuery(className: "Movies")
            query.whereKey("movieId", equalTo: id)
            query.limit = 1000
            
            var object = query.getFirstObject()
            if object == nil {
                var newObject = PFObject(className: "Movies")
                self.configureParseObject(newObject, name: name, id: id, info: info, links: links, image: image, year:year, isMovie: true)
                println("new object\n\(info)")
            } else {
                // The find succeeded update found object
                self.configureParseObject(object, name: name, id: id, info: info, links: links, image: image, year:year, isMovie: true)
                println("update object\n\(info)")
            }
        } else {
            query = PFQuery(className: name)
            query.whereKey("episodeNumber", equalTo: info["episode"])
            query.whereKey("season", equalTo: info["season"])
            query.limit = 1000
        
            query.getFirstObjectInBackgroundWithBlock {
                (foundObject: PFObject!, error: NSError!) -> Void in
                if foundObject == nil {
                    // The find failed create new object and add
                    var object = PFObject(className:name)
                    self.configureParseObject(object, name: name, id: id, info: info, links: links, image: image, year:year, isMovie: false)
                    println("new object\n\(info)")
                } else {
                    // The find succeeded update found object
                    self.configureParseObject(foundObject, name: name, id: id, info: info, links: links, image: image, year:year, isMovie: false)
                    println("update object\n\(info)")
                }
            }
        }
    }
    
    // add object to parse
    func configureParseObject(object:PFObject, name: String, id: String, info: NSDictionary, links:NSArray, image:String, year:String, isMovie: Bool) {

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
            object["dateReleased"] = NSDate(dateString: year)
        }
        object.saveInBackground()
    }
    
    // check to see if season is fake
    // return true if not a fake episode, else return false
    func checkFakeLinks(links: NSArray) -> Bool {
        for link in links {

            if let link = link as? Dictionary<String, String> {
                if link["source"] != "Watch HD" ||
                    link["source"] != "Sponsor Host" ||
                    link["source"] != "Promo Host" {
                    return true
                }
            }
        }
        return false
    }
    
    // remove all fake sources
    func removeFakeSoruces(links: NSArray) -> NSArray {
        var newLinks = NSMutableArray()
        for link in links {
            if let link = link as? Dictionary<String, String> {
                if link["source"] != "Watch HD" &&
                    link["source"] != "Sponsor Host" &&
                    link["source"] != "Promo Host" &&
                    link["source"] != "" {
                        newLinks.addObject(link)
                }
            }
        }
        return newLinks
    }
    
    //MARK: Parse Query Methods
    func getSupportedSeries(completionHandler: ()->()) {
        seriesList = []
        let query = PFQuery(className: "Series")
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for object in objects {
                    let series = Episode()
                    var seriesName = (object as! PFObject)["name"] as! String
                    series.parseQueryName = seriesName
                    seriesName.stringByReplacingOccurrencesOfString("series_", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    seriesName = seriesName.stringByReplacingOccurrencesOfString("_", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    series.seriesName = seriesName
                    series.seriesId = (object as! PFObject)["seriesID"] as! String
                    var urlString = (object as! PFObject)["image"] as? String
                    if urlString != nil {
                        var data = NSData(contentsOfURL: NSURL(string: urlString!)!)
                        if data != nil {
                            series.image = UIImage(data: data!)
                        } else {
                            series.image = UIImage(named: "noposter.jpg")
                        }
                    }
                    self.seriesList.append(series)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler()
                }
            } else {
                println(error)
            }
        }
    }
    
    func getMovies(completionHandler: ()->()) {
        movieList = []
        let query = PFQuery(className: "Movies")
        query.limit = 1000
        query.orderByDescending("dateReleased")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for object in objects {
                    let movie = Movie()
                    var movieName = (object as! PFObject)["name"] as! String
                    movieName = movieName.stringByReplacingOccurrencesOfString("movie_", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    movieName = movieName.stringByReplacingOccurrencesOfString("_", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    movie.name = movieName
                    movie.id = (object as! PFObject)["movieId"] as! String
                    movie.links = (object as! PFObject)["links"] as! NSArray
                    movie.imageUrl = (object as! PFObject)["image"] as! String
                    self.movieList.append(movie)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler()
                }
            } else {
                println(error)
            }
        }
    }
}
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
        
    func downloadLinksForEpisode(seriesI:Int, name:String) {
        print("Starting Series Download")
        
        // get data from kimono
        var error: NSError?
<<<<<<< HEAD
        let seriesNameAndSeasonsUrl = "https://www.kimonolabs.com/api/70ef8q9g?apikey=kPOHhmqHVO3WCVK0J09sj1pvhc9a1baQ&kimpath1=\(seriesId)"
        var seriesNameAndSeasonsData:NSData? = NSData(contentsOfURL: NSURL(string: seriesNameAndSeasonsUrl))
        
        while seriesNameAndSeasonsData == nil {
            println("seasons fetch failed, trying again....")
            seriesNameAndSeasonsData = NSData(contentsOfURL: NSURL(string: seriesNameAndSeasonsUrl))
        }
        
        let jsonDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(seriesNameAndSeasonsData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        let results = jsonDict["results"] as NSDictionary
        let seasons = results["seasons"] as NSArray
        
        return seasons;
    }
    
    func downloadEpisodesForSeason(seriesName: String, seriesId:String, seasons: NSArray) {
        println("Downloaded episodes for season")
        for season in seasons {
            
            let tempSeasonDict = season as NSDictionary
            var seasonNum = tempSeasonDict["season"] as String
            seasonNum = seasonNum.lowercaseString
            seasonNum = seasonNum.stringByReplacingOccurrencesOfString(" ", withString: "-", options: NSStringCompareOptions.LiteralSearch, range: nil)
=======
        var offset = 0                                      // Offset for kimono, because each query only shows 2500 rows at once
        var results = NSArray()                             // Results variable is defined outside, because its used in the while loop to see when the data has been parsed through
        var seriesImages = Dictionary<String, String>()     // Array of images of series to be downloaded
        repeat {
            var linksForEpisodeUrl = ""
            if seriesI == 0 {
                linksForEpisodeUrl = "https://www.kimonolabs.com/api/4nb0gypm?apikey=kPOHhmqHVO3WCVK0J09sj1pvhc9a1baQ&kimbypage=1&kimoffset=\(offset)"
            } else if seriesI == 1 {
                linksForEpisodeUrl = "https://www.kimonolabs.com/api/7cezuv7y?apikey=kPOHhmqHVO3WCVK0J09sj1pvhc9a1baQ&kimbypage=1&kimoffset=\(offset)"
            } else if seriesI == 2 {
                linksForEpisodeUrl = "https://www.kimonolabs.com/api/edoju7e4?apikey=kPOHhmqHVO3WCVK0J09sj1pvhc9a1baQ&kimbypage=1&kimoffset=\(offset)"
            }
>>>>>>> origin/master
            
            var linksForEpisodeData:NSData? = NSData(contentsOfURL: NSURL(string: linksForEpisodeUrl)!)
            
            while linksForEpisodeData == nil {
                print("links fetch failed, trying again....")
                linksForEpisodeData = NSData(contentsOfURL: NSURL(string: linksForEpisodeUrl)!)
            }
            
<<<<<<< HEAD
            let jsonDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(episodesForSeasonData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
            let results = jsonDict["results"] as NSDictionary
            let episodes = results["episodes"] as NSArray
=======
            // parse json outputted from Kimono
            let jsonDict: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(linksForEpisodeData!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
            results = jsonDict["results"] as! NSArray
>>>>>>> origin/master
            
            for page in results {
                
                let episodeInfo = (page["episode_info"] as! NSArray)[0] as! NSDictionary
                
                // check to see if the page is the last one in the current set of data
                if (page["page"] as! String) == ((results[results.count - 1])["page"] as! String) {
                    offset += (episodeInfo["index"] as! Int) - 1
                    // if the last section of results only has one page
                    if results.count == 1 {
                        offset += 1000
                    }
                    continue
                }

                var links = page["episode_links"] as? NSArray
                var episodeURLArray = (page["url"] as! String).characters.split {$0 == "/"}.map { String($0) }
                let seriesID = episodeURLArray[2]
                var seriesName = (episodeInfo["seriesName"] as! String)
                // find the right series in the api call
                if seriesName != name {
                    continue
                }
                seriesName = seriesName.stringByReplacingOccurrencesOfString(" ", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
                seriesImages[seriesID] = episodeInfo["image"] as? String
                
                if links != nil {
                    links = removeFakeSoruces(links!, isMovie: false)
                    
                    // save data to parse
                    if links!.count > 0 {
                        self.saveObjectToParse(seriesName, id: seriesID, info: episodeInfo, links: links!, image:"", year:"", isMovie: false);
                    }
                }
            }
        } while results.count > 0
        
        // add image to the series
        for (seriesID, image) in seriesImages {
            let query = PFQuery(className: "Series")
            query.limit = 100
            query.whereKey("seriesID", equalTo: seriesID)
            query.getFirstObjectInBackgroundWithBlock {
                (object: PFObject?, error: NSError?) -> Void in
                if error == nil {
                    object!["image"] = image
                    print("image downloaded")
                } else {
                    print(error)
                }
                object!.saveInBackground()
            }
        }
        
        print("Finished Series Download")
    }
    
    //MARK: Download Movies Data
    
    func downloadMovieLinks(completionHandler: ()->()) {
        print("Starting Movie Download")
        
        // get data from kimono
        let linksForMovieUrl = "http://www.kimonolabs.com/api/bf6pc8gm?apikey=kPOHhmqHVO3WCVK0J09sj1pvhc9a1baQ&kimbypage=1"
        var linksForMovieData:NSData? = NSData(contentsOfURL: NSURL(string: linksForMovieUrl)!)
        
        while linksForMovieData == nil {
            print("links fetch failed, trying again....")
            linksForMovieData = NSData(contentsOfURL: NSURL(string: linksForMovieUrl)!)
        }
        
<<<<<<< HEAD
        let jsonDict: NSDictionary = NSJSONSerialization.JSONObjectWithData(linksForEpisodeData!, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        let results = jsonDict["results"] as NSDictionary
        let links = results["episode_links"] as NSArray
        let episodeInfo = (results["episode_info"] as NSArray)[0] as NSDictionary
=======
        // parse json outputted from Kimono
        let jsonDict: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(linksForMovieData!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
        let results = jsonDict["results"] as! NSArray
>>>>>>> origin/master

        for result in results {
            if let page = result as? NSDictionary {
                let movieInfo = (page["movieInfo"] as! NSArray)[0] as! NSDictionary
                let movieName = (movieInfo["name"] as! String)
                var movieID = (page["url"] as! String).stringByReplacingOccurrencesOfString("http://www.primewire.ag/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                movieID = movieID.stringByReplacingOccurrencesOfString("-online-free", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                let image = movieInfo["image"] as! String
                let year = movieInfo["releaseDate"] as! String
                // make sure movie has links
                if page["links"] != nil {
                    let links = removeFakeSoruces(page["links"] as! NSArray, isMovie: true)
                    self.saveObjectToParse(movieName, id: movieID, info: movieInfo, links: links, image: image, year:year, isMovie:true)
                }
            }
        }
        completionHandler()
        
        print("Movie Download Complete")
    }
    
    //MARK: Helper Methods
    
    func saveObjectToParse(name:String, id: String, info: NSDictionary, links: NSArray, image: String, year:String, isMovie: Bool) {

<<<<<<< HEAD
            if (foundObject != nil) {
                // The find failed create new object and add
                let seriesObject = PFObject(className:seriesName)
                self.configureParseObject(seriesObject, seriesName: seriesName, seriesId: seriesId, episodeInfo: episodeInfo, links: links)
                println("new object\n\(episodeInfo)")
            } else if !self.addNewSeries {
=======
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
>>>>>>> origin/master
                // The find succeeded update found object
                self.configureParseObject(object, name: name, id: id, info: info, links: links, image: image, year:year, isMovie: true)
                print("update object\n\(info)")
            } else {
                let newObject = PFObject(className: "Movies")
                self.configureParseObject(newObject, name: name, id: id, info: info, links: links, image: image, year:year, isMovie: true)
                print("new object\n\(info)")
            }
        } else {
            query = PFQuery(className: name)
            query.whereKey("episodeNumber", equalTo: info["episode"]!)
            query.whereKey("season", equalTo: info["season"]!)
            query.limit = 1000
        
            query.getFirstObjectInBackgroundWithBlock {
                (foundObject: PFObject?, error: NSError?) -> Void in
                if foundObject == nil {
                    // The find failed create new object and add
                    let object = PFObject(className:name)
                    self.configureParseObject(object, name: name, id: id, info: info, links: links, image: image, year:year, isMovie: false)
                    print("new object\n\(info)")
                } else {
                    // The find succeeded update found object
                    self.configureParseObject(foundObject!, name: name, id: id, info: info, links: links, image: image, year:year, isMovie: false)
                    print("update object\n\(info)")
                }
            }
        }
    }
    
    // add object to parse
    func configureParseObject(object:PFObject, name: String, id: String, info: NSDictionary, links:NSArray, image:String, year:String, isMovie: Bool) {

        if isMovie {
            object["name"] = name
            object["movieId"] = id
            object["links"] = links
            object["image"] = image
            object["dateReleased"] = NSDate(dateString: year)
        } else {
            object["seriesName"] = name
            object["seriesId"] = id
            object["season"] = info["season"]
            object["episodeNumber"] = info["episode"]
            object["episodeTitle"] = info["title"]
            object["links"] = links
            object["description"] = info["description"]
        }
        object.saveInBackground()
    }
    
    
    // remove all fake sources
    func removeFakeSoruces(links: NSArray, isMovie:Bool) -> NSArray {
        let newLinks = NSMutableArray()
        for link in links {
            if let linkSource = link["source"] as? String {
            
                if linkSource != "Watch HD" &&
                    linkSource != "Sponsor Host" &&
                    linkSource != "Promo Host" &&
                    linkSource != "" {
                        if isMovie {
                            newLinks.addObject(["source": link["source"] as! String, "links" : link["links"] as! String])
                        } else {
                            if !(link["link"] is NSArray) {
                                newLinks.addObject(["source": link["source"] as! String, "link" : link["link"] as! String])
                            }
                        }
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
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for object in objects! {
                    let series = Episode()
                    var seriesName = object["name"] as! String
                    series.parseQueryName = seriesName
                    seriesName = seriesName.stringByReplacingOccurrencesOfString("series_", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    seriesName = seriesName.stringByReplacingOccurrencesOfString("_", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    series.seriesName = seriesName
                    series.seriesId = object["seriesID"] as! String
                    let urlString = object["image"] as? String
                    if urlString != nil {
                        let data = NSData(contentsOfURL: NSURL(string: urlString!)!)
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
                print(error)
            }
        }
    }
    
    func getMovies(completionHandler: ()->()) {
        movieList = []
        let query = PFQuery(className: "Movies")
        query.limit = 1000
        query.orderByDescending("dateReleased")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for object in objects! {
                    let movie = Movie()
                    var movieName = object["name"] as! String
                    movieName = movieName.stringByReplacingOccurrencesOfString("movie_", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    movieName = movieName.stringByReplacingOccurrencesOfString("_", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    movie.name = movieName
                    movie.id = object["movieId"] as! String
                    movie.links = object["links"] as! NSArray
                    movie.imageUrl = object["image"] as! String
                    self.movieList.append(movie)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler()
                }
            } else {
                print(error)
            }
        }
    }
}
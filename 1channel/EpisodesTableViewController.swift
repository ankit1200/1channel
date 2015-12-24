//
//  EpisodesTableViewController.swift
//  heroes
//
//  Created by Ankit Agarwal on 7/3/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class EpisodesTableViewController : UITableViewController {
    
    var episodes:[(episodeNumber: Int, episodeName: String)] = []
    var episode = Episode()
    var downloadStarted = false
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        self.getEpisodesForSeason()
    }
    
    
    //MARK: Query From Parse
    
    func getEpisodesForSeason() {
        episodes = []
        let query = PFQuery(className: episode.parseQueryName)
        query.limit = 1000
        query.selectKeys(["episodeNumber", "episodeTitle"])
        query.whereKey("season", equalTo: episode.season)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if (error == nil) {
                self.getEpisodesFromQuery(objects!)
            }
        }
    }
    
    
    //MARK: Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        
        if episodes.count != 0 {
            cell.textLabel?.text = episodes[indexPath.row].episodeName
            cell.detailTextLabel?.text = "Episode \(episodes[indexPath.row].episodeNumber)"
        }
        return cell
    }
    
    
    //MARK: Refresh button
    
//    @IBAction func getNewEpisodes(sender: AnyObject) {
//        
//        if !downloadStarted {
//            let season = [self.episode.season]
//            downloadData(season)
//            downloadStarted = true
//        } else {
//            getEpisodesForSeason()
//        }
//    }
    
    //MARK: Helper Methods
    
    func getEpisodesFromQuery(objects: [AnyObject]!) {

        for object in objects {
            var numberString = (object as! PFObject)["episodeNumber"] as! String
            let name = (object as! PFObject)["episodeTitle"] as! String
            numberString = numberString.stringByReplacingOccurrencesOfString("Episode ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let number = Int(numberString)
            self.episodes.append(episodeNumber: number!, episodeName: name)
        }
        self.episodes.sortInPlace({$0.0 < $1.0})
        self.tableView.reloadData()
    }
    
    func downloadData(seasonsFromParseQuery: Array<String>) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // background thread
//            let manager = DataManager()
//            manager.downloadSeriesData(self.episode.parseQueryName, seriesId: self.episode.seriesId, seasonsFromParseQuery: seasonsFromParseQuery)
        })
    }
    
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSources" {
            let ltvc = segue.destinationViewController as! LinksTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            
            episode.episodeNumber = "Episode \(episodes[indexPath!.row].episodeNumber)"
            episode.episodeName = episodes[indexPath!.row].episodeName
            
            // variables to pass down
            ltvc.episode = episode
            ltvc.title = "\(episode.episodeNumber) - \(episode.episodeName)"
            ltvc.isMovie = false
        }
    }
}
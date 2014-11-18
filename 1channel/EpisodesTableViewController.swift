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
        
        let query = PFQuery(className: episode.seriesName)
        query.limit = 1000
        query.selectKeys(["episodeNumber", "episodeTitle"])
        query.whereKey("season", equalTo: episode.season)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                self.getEpisodesFromQuery(objects)
            }
        }
    }
    
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSources" {
            let ltvc = segue.destinationViewController as LinksTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            
            episode.episodeNumber = "Episode \(episodes[indexPath!.row].episodeNumber)"
            episode.episodeName = episodes[indexPath!.row].episodeName
            
            // variables to pass down
            ltvc.episode = episode
            ltvc.title = "\(episode.episodeNumber) - \(episode.episodeName)"
            ltvc.isMovie = false
        }
    }
    
    
    //MARK: Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        if episodes.count != 0 {
            cell.textLabel.text = episodes[indexPath.row].episodeName
            cell.detailTextLabel!.text = "Episode \(episodes[indexPath.row].episodeNumber)"
        }
        return cell
    }
    
    
    //MARK: Refresh button
    
    @IBAction func getNewEpisodes(sender: AnyObject) {
        
        if !downloadStarted {
            let season = [self.episode.season]
            downloadData(season)
            downloadStarted = true
        } else {
            self.tableView.reloadData()
        }
    }
    
    //MARK: Helper Methods
    
    func getEpisodesFromQuery(objects: [AnyObject]!) {

        for object in objects {
            var numberString = (object as PFObject)["episodeNumber"] as String
            let name = (object as PFObject)["episodeTitle"] as String
            numberString = numberString.stringByReplacingOccurrencesOfString("Episode ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let number = numberString.toInt()
            self.episodes.append(episodeNumber: number!, episodeName: name)
        }
        self.episodes.sort({$0.0 < $1.0})
        self.tableView.reloadData()
    }
    
    func downloadData(seasonsFromParseQuery: Array<String>) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // background thread
            let manager = DataManager()
            manager.downloadSeriesData(self.episode.seriesName, seriesId: self.episode.seriesId, seasonsFromParseQuery: seasonsFromParseQuery)
        })
    }
}
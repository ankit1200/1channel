//
//  EpisodesTableViewController.swift
//  heroes
//
//  Created by Ankit Agarwal on 7/3/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class EpisodesTableViewController : UITableViewController {
    
    var episodes = Dictionary<String, String>()
    var season = String()
    var seriesId = String()
    var seriesName = String()
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        println("test \(episodes.count)")
//        self.getEpisodesForSeason()
    }
    
    
    //    #pragma mark - json parser
    
    func getEpisodesForSeason() {
        
        let query = PFQuery(className: seriesName)
        query.selectKeys(["episodeNumber", "episodeTitle"])
        query.whereKey("season", equalTo: season)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if !error {
                self.getEpisodesFromQuery(objects)
            }
        }
    }
    
    //     #pragma mark - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSources" {
            let ltvc = segue.destinationViewController as LinksTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            
            // variables to pass down
            ltvc.season = self.season
            ltvc.seriesId = self.seriesId
            ltvc.seriesName = self.seriesName
//            ltvc.episodeNumber = episodes[indexPath.row]
//            ltvc.title = "\(episodeNum) - \(episodeName)"
        }
    }
    
    
    //    #pragma mark - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println()
        return episodes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        if episodes.count != 0 {
            cell.textLabel.text = ""
            cell.detailTextLabel.text = ""
        }
        return cell
    }
    
    
    //    #pragma mark - Helper Methods
    
    func getEpisodesFromQuery(objects: [AnyObject]!) {
        
        for object in objects {
            let episodeNumber = (object as PFObject)["episodeNumber"] as String
            let episodeTitle = (object as PFObject)["episodeTitle"] as String
            self.episodes[episodeNumber] = episodeTitle
        }
        println(episodes)
//        self.tableView.reloadData()
    }
}
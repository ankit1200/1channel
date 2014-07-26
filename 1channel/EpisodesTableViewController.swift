//
//  EpisodesTableViewController.swift
//  heroes
//
//  Created by Ankit Agarwal on 7/3/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class EpisodesTableViewController : UITableViewController {
    
    var episodes:[(episodeNumber: String, episodeName: String)] = []
    var season = String()
    var seriesId = String()
    var seriesName = String()
    
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        self.getEpisodesForSeason()
    }
    
    
    //MARK: Query From Parse
    
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
            
            let episodeNumber = episodes[indexPath.row].episodeNumber
            let episodeName = episodes[indexPath.row].episodeName
            
            // variables to pass down
            ltvc.season = self.season
            ltvc.seriesId = self.seriesId
            ltvc.seriesName = self.seriesName
            ltvc.episodeNumber = episodes[indexPath.row].episodeNumber
            ltvc.title = "\(episodeNumber) - \(episodeName)"
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
            cell.detailTextLabel.text = episodes[indexPath.row].episodeNumber
        }
        return cell
    }
    
    
    //MARK: Helper Methods
    
    func getEpisodesFromQuery(objects: [AnyObject]!) {

        for object in objects {
            let number = (object as PFObject)["episodeNumber"] as String
            let name = (object as PFObject)["episodeTitle"] as String
            self.episodes += (number, name)
        }
        self.tableView.reloadData()
    }
}
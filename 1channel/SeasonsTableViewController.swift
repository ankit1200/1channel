//
//  SeasonTableViewController.swift
//  heroes
//
//  Created by Ankit Agarwal on 7/2/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class SeasonsTableViewController: UITableViewController {

    var seasons:Array<Int> = []
    var episode = Episode()
    var downloadStarted = false
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        self.getSeasonsForSeries()
        self.title = episode.seriesName
        self.tableView.backgroundView = UIImageView(image: episode.image)
        self.tableView.backgroundView?.alpha = 0.4
    }
    
    
    //MARK: Query From Parse
    
    func getSeasonsForSeries() {
        seasons = []
        let query = PFQuery(className: episode.parseQueryName)
        query.limit = 1000
        query.selectKeys(["season"])
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self.getSeasonsFromQuery(objects!)
            } else {
                print(error)
            }
        }
    }
    

    //MARK: Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.seasons.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        if seasons.count != 0 {
            cell.textLabel?.text = "Season \(seasons[indexPath.row])"
            cell.textLabel?.sizeToFit()
        }
        return cell
    }
    
    
    //MARK: Helper Methods
    
    func getSeasonsFromQuery(objects: [AnyObject]!) {
        
        for object in objects {
            let seasonString = (object as! PFObject)["season"] as! String
            let seasonNumber = seasonString.stringByReplacingOccurrencesOfString("Season ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            self.seasons.append(Int(seasonNumber)!)
        }
        self.seasons = NSSet(array: self.seasons).allObjects as! Array<Int>
        self.seasons.sortInPlace({$0 < $1})
        self.tableView.reloadData()
    }
    
    @IBAction func downloadNewEpisodes(sender: AnyObject) {
        // If download not started get new data
        // Else reload tableview with new data
        if !downloadStarted {
            downloadData()
            downloadStarted = true
        } else {
            getSeasonsForSeries()
        }
    }
    
    
    // Decide which API to call, based on TV show
    func downloadData() {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // background thread
            let manager = DataManager()
            if self.episode.seriesName == "The Big Bang Theory" || self.episode.seriesName == "Arrow" ||
                self.episode.seriesName == "Better Call Saul" || self.episode.seriesName == "Fresh Off the Boat" ||
                self.episode.seriesName == "Game of Thrones" || self.episode.seriesName == "The Walking Dead"
            {
                manager.downloadLinksForEpisode(0, name: self.episode.seriesName)
            } else if self.episode.seriesName == "Modern Family" || self.episode.seriesName == "Suits" ||
                self.episode.seriesName == "Silicon Valley" || self.episode.seriesName == "Brooklyn Nine Nine"
            {
                manager.downloadLinksForEpisode(1, name: self.episode.seriesName)
            } else if self.episode.seriesName == "Supernatural" || self.episode.seriesName == "New Girl" ||
                self.episode.seriesName == "Parks and Recreation" {
                manager.downloadLinksForEpisode(2, name: self.episode.seriesName)
            } else if self.episode.seriesName == "Homeland" || self.episode.seriesName == "The Flash" {
                    manager.downloadLinksForEpisode(3, name: self.episode.seriesName)
            }
        })
    }
    
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEpisodes" {
            let etvc = segue.destinationViewController as! EpisodesTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            episode.season = "Season \(seasons[indexPath!.row])"
            
            // variables being passed
            etvc.episode = episode
            etvc.title = episode.season
        }
    }
}


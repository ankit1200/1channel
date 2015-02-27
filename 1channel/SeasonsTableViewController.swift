//
//  SeasonTableViewController.swift
//  heroes
//
//  Created by Ankit Agarwal on 7/2/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class SeasonsTableViewController: UITableViewController {

    var seasons:Array<String> = []
    var episode = Episode()
    var downloadStarted = false
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        self.getSeasonsForSeries()
        self.title = episode.seriesName
    }
    
    
    //MARK: Query From Parse
    
    func getSeasonsForSeries() {
        seasons = []
        let query = PFQuery(className: episode.parseQueryName)
        query.limit = 1000
        query.selectKeys(["season"])
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                self.getSeasonsFromQuery(objects)
            } else {
                println(error)
            }
        }
    }
    

    //MARK: Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.seasons.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        if seasons.count != 0 {
            cell.textLabel?.text = seasons[indexPath.row]
        }
        return cell
    }
    
    
    //MARK: Helper Methods
    
    func getSeasonsFromQuery(objects: [AnyObject]!) {
        
        for object in objects {
            let season = (object as PFObject)["season"] as String
            self.seasons.append(season)
        }
        self.seasons = NSSet(array: self.seasons).allObjects as Array<String>
        self.seasons.sort({$0 < $1})
        self.tableView.reloadData()
    }
    
    @IBAction func downloadNewEpisodes(sender: AnyObject) {
        if !downloadStarted {
            downloadData(self.seasons)
            downloadStarted = true
        } else {
            getSeasonsForSeries()
        }
    }
    
    func downloadData(seasonsFromParseQuery: Array<String>) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // background thread
            let manager = DataManager()
            manager.downloadSeriesData(self.episode.parseQueryName, seriesId: self.episode.seriesId, seasonsFromParseQuery: seasonsFromParseQuery)
        })
    }
    
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showEpisodes" {
            let etvc = segue.destinationViewController as EpisodesTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            episode.season = seasons[indexPath!.row]
            
            // variables being passed
            etvc.episode = episode
            etvc.title = episode.season
        }
    }
}


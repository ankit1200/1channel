//
//  LinksTableViewController.swift
//  heroes
//
//  Created by Ankit Agarwal on 7/3/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class LinksTableViewController : UITableViewController {
    
    var links:[(link: String, source: String)] = []
    var season = String()
    var seriesId = String()
    var seriesName = String()
    var episodeNumber = String()
    
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        self.getLinksForEpisode()
    }
    
    
    //#MARK: Query From Parse
    
    func getLinksForEpisode() {
        
        let query = PFQuery(className: seriesName)
        query.selectKeys(["links"])
        query.whereKey("season", equalTo: season)
        query.whereKey("episodeNumber", equalTo: episodeNumber)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if !error {
                self.getLinksFromQuery(objects)
            }
        }
    }
    
    
    //MARK: prepare for segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let dvc = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            
            // set variables
            dvc.link = links[indexPath.row].link
        }
    }
    
    
    //MARK: Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return links.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        if links.count != 0 {
            cell.textLabel.text = links[indexPath.row].source
        }
        return cell
    }
    
    
    //MARK: Helper Methods
    
    func getLinksFromQuery(objects: [AnyObject]!) {
        
        let linksFromQuery = (objects[0] as PFObject)["links"] as NSArray
        
        for link in linksFromQuery {
            let link = link as Dictionary<String, String>
            self.links += (link["link"]!, link["source"]!)
        }
        
        self.tableView.reloadData()
    }
}

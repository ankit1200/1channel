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
    var episode = Episode()
    
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        self.getLinksForEpisode()
    }
    
    
    //#MARK: Query From Parse
    
    func getLinksForEpisode() {
        
        let query = PFQuery(className: episode.seriesName)
        query.selectKeys(["links"])
        query.whereKey("season", equalTo: episode.season)
        query.whereKey("episodeNumber", equalTo: episode.episodeNumber)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                self.getLinksFromQuery(objects)
            }
        }
    }
    
    
    //MARK: prepare for segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLink" {
            
            let dvc = segue.destinationViewController as DetailViewController
            let indexPath = self.tableView.indexPathForSelectedRow()
            
            // set variables
            dvc.linkAndSource = links[indexPath!.row]

            // analytics
            let dimensions = [
                "seriesName": episode.seriesName,
                "season": episode.season,
                "episodeNum": episode.episodeNumber,
                "source": links[indexPath!.row].source
            ]
            // Send the dimensions to Parse along with the 'search' event
            PFAnalytics.trackEvent("watchEpisode", dimensions:dimensions)
        }
    }
    
    
    //MARK: Table View
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return links.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        if links.count != 0 {
            cell.textLabel!.text = links[indexPath.row].source
        }
        return cell
    }
    
    //MARK: Helper Methods
    
    func getLinksFromQuery(objects: [AnyObject]!) {
        
        let linksFromQuery = (objects[0] as PFObject)["links"] as NSArray
        for link in linksFromQuery {
            let link = link as Dictionary<String, String>
            let source = link["source"]!
            if source != "Watch HD" &&
                source != "promptfile.com" {
                self.links.append(link: link["link"]!, source: source)
            }
        }
        
        self.tableView.reloadData()
    }
}

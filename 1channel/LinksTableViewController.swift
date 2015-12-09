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
    var movie = Movie()
    var isMovie = false
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        if isMovie {
            self.getLinksForMovie(movie.links)
        } else {
            self.getLinksForEpisode()
        }
    }
    
    
    //#MARK: Query From Parse
    
    func getLinksForEpisode() {
        
        let query = PFQuery(className: episode.parseQueryName)
        query.limit = 1000
        query.selectKeys(["links"])
        query.whereKey("season", equalTo: episode.season)
        query.whereKey("episodeNumber", equalTo: episode.episodeNumber)
        
        query.findObjectsInBackgroundWithBlock {
<<<<<<< HEAD
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error != nil) {
=======
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
>>>>>>> origin/master
                self.getLinksFromQuery(objects)
            }
        }
    }
    
    
    //MARK: prepare for segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLink" {
            
            let dvc = segue.destinationViewController as! DetailViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            
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
    
    
    //MARK: Table View DataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return links.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        
        let source = links[indexPath.row].source
        
        if links.count != 0 {
            cell.textLabel?.text = source
            if source == "thevideo.me" ||
                source == "gorillavid.in" ||
                source == "bestreams.net" {
                cell.textLabel?.textColor = UIColor.greenColor()
//                    cell.imageView?.image = getImageWithColor(UIColor.greenColor())
            } else if source == "cloudzilla.to" {
//                cell.textLabel?.textColor = UIColor.yellowColor()
//                    cell.imageView?.image = getImageWithColor(UIColor.yellowColor())
            } else {
                cell.textLabel?.textColor = UIColor.blackColor()
//                cell.imageView?.image = nil
            }
        }
        return cell
    }
    
    //MARK: Helper Methods
    
    func getLinksFromQuery(objects: [AnyObject]!) {
        
        let linksFromQuery = (objects[0] as! PFObject)["links"] as! NSArray
        for link in linksFromQuery {
            let linkTuple = (link:link["link"] as? String, source: link["source"] as? String)
            if let source = linkTuple.source {
                if source != "Watch HD" &&
                    source != "promptfile.com" &&
                    source != "sockshare.com" &&
                    source != "putlocker.com" &&
                    source != "Sponsor Host" &&
                    source != "Promo Host" &&
                    source != "" {
                    self.links.append(link: linkTuple.link!, source: source)
                }
            }
        }
        self.tableView.reloadData()
    }
    
    func getLinksForMovie(movieLinks:NSArray) {
        for link in movieLinks {
            if let link = link as? Dictionary<String, String> {
                let source = link["source"]
                if source != "Watch HD" &&
                    source != "promptfile.com" &&
                    source != "sockshare.com" &&
                    source != "putlocker.com" &&
                    source != "Sponsor Host" &&
                    source != "Promo Host" &&
                    source != "" {
                        self.links.append(link: link["links"]!, source: source!)
                }
            }
        }
        self.tableView.reloadData()
    }
    
    // create an image with solid color background
    func getImageWithColor(color: UIColor) -> UIImage {
        let circle = CGRectMake(0, 0, 30, 30)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillEllipseInRect(context, circle);
        CGContextStrokeEllipseInRect(context, circle);
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 30, height: 30), false, 0)
        color.setFill()
        UIRectFill(circle)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

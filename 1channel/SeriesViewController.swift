//
//  SeriesCollectionViewController.swift
//  1channel
//
//  Created by Ankit Agarwal on 9/28/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

class SeriesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var seriesList = Array<Episode>()
    let episode = Episode()
    var selectedIndex = 0
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidAppear(animated: Bool) {
        getSupportedSeries()
    }

    //MARK: parse methods
    func getSupportedSeries() {
        seriesList = []
        let query = PFQuery(className: "Series")
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for object in objects {
                    let series = Episode()
                    series.seriesName = (object as PFObject)["name"] as String
                    series.seriesId = (object as PFObject)["seriesID"] as String
                    series.imageUrl = (object as PFObject)["image"] as String
                    self.seriesList.append(series)
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSeasons" {
            let stvc = segue.destinationViewController as SeasonsTableViewController
            let indexPath = (self.collectionView.indexPathsForSelectedItems() as Array<NSIndexPath>)[0]
            
            // variables being passed
            stvc.episode = seriesList[indexPath.row]
            
            // analytics
            let dimensions = [
                "seriesName": episode.seriesName,
            ]
            // Send the dimensions to Parse along with the 'search' event
            PFAnalytics.trackEvent("watchSeries", dimensions:dimensions)
        }
    }


    // MARK: UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.seriesList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as SeriesCollectionViewCell
        
        if seriesList.count != 0 {
            var seriesName = seriesList[indexPath.row].seriesName.stringByReplacingOccurrencesOfString("series_", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            seriesName = seriesName.stringByReplacingOccurrencesOfString("_", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)

            var url = NSURL.URLWithString(seriesList[indexPath.row].imageUrl)
            var data = NSData(contentsOfURL : url)
            cell.seriesImage.image = UIImage(data : data)
        }
        
        return cell
    }

    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath.row
    }

}

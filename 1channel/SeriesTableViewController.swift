//
//  SeriesTableViewController.swift
//  1channel
//
//  Created by Ankit Agarwal on 7/9/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class SeriesTableViewController: UITableViewController {

    var seriesList = NSDictionary()
    let episode = Episode()
    var seriesToDownload = NSDictionary()
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        readSeriesPlist()
        readSeriesToDownloadPlist()
        
//        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//            
//            // background thread
//            let manager = DataManager()
//            for key in self.seriesToDownload.allKeys {
//                let key = key as String
//                manager.downloadSeriesData(key, seriesId: self.seriesToDownload[key] as String)
//            }
//        })

    }
    
    
    //MARK: plist parsers
    func readSeriesPlist() {
        let path = NSBundle.mainBundle().pathForResource("seriesDownloaded", ofType: "plist")
        seriesList = NSDictionary(contentsOfFile: path)
    }
    
    
    func readSeriesToDownloadPlist() {
        let path = NSBundle.mainBundle().pathForResource("seriesList", ofType: "plist")
        seriesToDownload = NSDictionary(contentsOfFile: path)
    }
    
    
    //     #pragma mark - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSeasons" {
            let stvc = segue.destinationViewController as SeasonsTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow()

            episode.seriesId = (seriesList.allValues as NSArray)[indexPath.row] as String
            episode.seriesName = (seriesList.allKeys as NSArray)[indexPath.row] as String
            
            // variables being passed
            stvc.episode = episode
        }
    }
    
    
    //MARK: Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.seriesList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        if seriesList.count != 0 {
            let keys = seriesList.allKeys as NSArray
            let label = keys[indexPath.row] as String
            cell.textLabel.text = label
        }
        return cell
    }
}
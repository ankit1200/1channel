//
//  CollectionViewController.swift
//  1channel
//
//  Created by Ankit Agarwal on 9/28/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var seriesList = Array<Episode>()
    let episode = Episode()
    var movieList = Array<Movie>()
    let movie = Movie()
    var selectedIndex = 0
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var segmentControl: UISegmentedControl!
    
    override func viewDidAppear(animated: Bool) {
        if segmentControl.selectedSegmentIndex == 0 {
            getSupportedSeries()
        } else if segmentControl.selectedSegmentIndex == 1 {
            getMovies()
        }
    }

    //MARK: parse methods
    func getSupportedSeries() {
        seriesList = []
        let query = PFQuery(className: "Series")
        query.limit = 1000
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
    
    func getMovies() {
        movieList = []
        let query = PFQuery(className: "Movies")
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                var count = (objects as Array<PFObject>).count
                for object in objects {
                    let movie = Movie()
                    movie.name = (object as PFObject)["name"] as String
                    movie.id = (object as PFObject)["movieId"] as String
                    movie.imageUrl = (object as PFObject)["image"] as String
                    movie.links = (object as PFObject)["links"] as NSArray
                    self.movieList.append(movie)
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    //MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSeasons"{
            // destination view controller
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
        } else if segue.identifier == "showSources" {
            // destination view controller
            let ltvc = segue.destinationViewController as LinksTableViewController
            let indexPath = (self.collectionView.indexPathsForSelectedItems() as Array<NSIndexPath>)[0]
            
            // variables being passed
            ltvc.movie = movieList[indexPath.row]
            ltvc.isMovie = true
            
            // analytics
            let dimensions = [
                "movieName": episode.seriesName,
            ]
            // Send the dimensions to Parse along with the 'search' event
            PFAnalytics.trackEvent("watchMovie", dimensions:dimensions)
        }
    }


    // MARK: UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if segmentControl.selectedSegmentIndex == 0 {
            return self.seriesList.count
        } else {
            return self.movieList.count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if segmentControl.selectedSegmentIndex == 0 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("seriesCell", forIndexPath: indexPath) as SeriesCollectionViewCell
            
            if seriesList.count != 0 {
                var seriesName = seriesList[indexPath.row].seriesName.stringByReplacingOccurrencesOfString("series_", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                seriesName = seriesName.stringByReplacingOccurrencesOfString("_", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)

//                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var url = NSURL(string: self.seriesList[indexPath.row].imageUrl)
                    var data = NSData(contentsOfURL : url!)
                    cell.image.image = UIImage(data : data!)
//                })
            }
            
            return cell
        } else {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("movieCell", forIndexPath: indexPath) as MovieCollectionViewCell
            
            if movieList.count != 0 {
                var movieName = movieList[indexPath.row].name.stringByReplacingOccurrencesOfString("movie_", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                movieName = movieName.stringByReplacingOccurrencesOfString("_", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
                
//                dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    let url = NSURL(string: self.movieList[indexPath.row].imageUrl)
                    let data = NSData(contentsOfURL: url!)
                    cell.image.image = UIImage(data: data!)
//                })
            
            }
            return cell
        }
    }

    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath.row
    }
    
    
    @IBAction func segmentValueChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            getSupportedSeries()
        } else if sender.selectedSegmentIndex == 1 {
            getMovies()
        }
    }
}

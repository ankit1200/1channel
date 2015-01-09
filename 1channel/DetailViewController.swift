//
//  DetailViewController.swift
//  1channel
//
//  Created by Ankit Agarwal on 7/7/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit
import Foundation

extension String {
    func contains(other: String) -> Bool{
        var start = startIndex
        
        do{
            var subString = self[Range(start: start++, end: endIndex)]
            if subString.hasPrefix(other){
                return true
            }
            
        } while start != endIndex
        
        return false
    }
}

class DetailViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView : UIWebView!
    @IBOutlet var backButton: UIButton!
    @IBOutlet var forwardButton: UIButton!
    
    
    var linkAndSource:(link: String, source: String)? {
        didSet {
            self.configureView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
        self.webView.delegate = self
    }
    
    @IBAction func backButtonTapped(sender: UIButton) {
        webView.goBack()
    }
    
    @IBAction func forwardButtonTapped(sender: UIButton) {
        webView.goForward()
    }
    
    @IBAction func refreshButtonTapped(sender: AnyObject) {
        webView.reload()
    }
    
    
    let backButtonBlueImage     = UIImage(named: "backBlue")
    let backButtonGrayImage     = UIImage(named: "backGray")
    let forwardButtonBlueImage  = UIImage(named: "forwardBlue")
    let forwardButtonGrayImage  = UIImage(named: "forwardGray")
    
    // This function is called to set the colors of the back and forward buttons
    func setBackForwardButtons() {
        
        // Display the back button in blue color if a previous web page exists.
        // Otherwise, display the back button in gray color.
        if webView.canGoBack {
            backButton.setImage(backButtonBlueImage, forState: UIControlState.Normal)
        } else {
            backButton.setImage(backButtonGrayImage, forState: UIControlState.Normal)
        }
        
        // Display the forward button in blue color if a forward web page exists.
        // Otherwise, display the forward button in gray color.
        if webView.canGoForward {
            forwardButton.setImage(forwardButtonBlueImage, forState: UIControlState.Normal)
        } else {
            forwardButton.setImage(forwardButtonGrayImage, forState: UIControlState.Normal)
        }
    }
    
    //MARK: Web View Methods

    func loadAddressURL() {
        
        let request = NSURLRequest(URL: (NSURL(string: linkAndSource!.link))!)
        webView!.scalesPageToFit = true
        webView!.loadRequest(request)
    }
    
    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!, navigationType: UIWebViewNavigationType) -> Bool {
        
        let urlString = request.URL.absoluteString
        let source = getSourceName(linkAndSource!.source)
        
        if (urlString!.lowercaseString.rangeOfString("primewire") != nil) ||
            (urlString!.lowercaseString.rangeOfString(source) != nil) ||
            (urlString!.lowercaseString.rangeOfString(".mp4") != nil)
        {
            println("passed: \(urlString)")
            return true
        }
        println("failed: \(urlString)")
        return false
    }
    
    /******************************************************************************************
    * UIWebView Delegate Methods: These methods must be implemented whenever UIWebView is used.
    ******************************************************************************************/
    
    func webViewDidStartLoad(webView: UIWebView!) {
        // Starting to load the web page. Show the animated activity indicator in the status bar
        // to indicate to the user that the UIWebVIew object is busy loading the web page.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView!) {
        // Finished loading the web page. Hide the activity indicator in the status bar.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        // Call this function to set the colors of the back and forward buttons
        setBackForwardButtons()
    }
    
    func webView(webView: UIWebView!, didFailLoadWithError error: NSError!) {
        /*
        Ignore this error if the page is instantly redirected via javascript or in another way.
        NSURLErrorCancelled is returned when an asynchronous load is cancelled, which happens
        when the page is instantly redirected via javascript or in another way.
        */
        if error.code == NSURLErrorCancelled {
            return
        }
        
        // Call this function to set the colors of the back and forward buttons
        setBackForwardButtons()
        
        // An error occurred during the web page load. Hide the activity indicator in the status bar.
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        
        // Create the error message in HTML as a character string and store it into the local constant errorString
        let errorString = "<html><font size=+2 color='red'><p>An error occurred: <br />Possible causes for this error:<br />- No network connection<br />- Wrong URL entered<br />- Server computer is down</p></font></html>" + error.localizedDescription
        
        // Display the error message within the UIWebView object
        self.webView.loadHTMLString(errorString, baseURL: nil)
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.linkAndSource {
            if let loadLink = self.webView {
               loadAddressURL()
            }
        }
    }
    
    
    //MARK: helper methods
    func getSourceName(source: String) -> String {
        var sourceString = ""
        
        for char in source {
            if char == "." {
                return sourceString
            } else {
                sourceString = sourceString + [char]
            }
        }
        return source
    }
}


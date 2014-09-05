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
            
        }while start != endIndex
        
        return false
    }
}

class DetailViewController: UIViewController, UISplitViewControllerDelegate, UIWebViewDelegate {

    var masterPopoverController: UIPopoverController? = nil
    @IBOutlet weak var webView : UIWebView!
    
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
    
    
    //MARK: Split View delegates
    func splitViewController(svc: UISplitViewController!, willHideViewController aViewController: UIViewController!, withBarButtonItem barButtonItem: UIBarButtonItem!, forPopoverController pc: UIPopoverController!) {
        
        barButtonItem.title = "Select"
        self.navigationItem.setLeftBarButtonItem(barButtonItem, animated: true)
        self.masterPopoverController = pc;
    }
    
    func splitViewController(svc: UISplitViewController!, willShowViewController aViewController: UIViewController!, invalidatingBarButtonItem barButtonItem: UIBarButtonItem!)  {
        
        // Called when the view is shown again in the split view,
        // invalidating the button and popover controller.
        self.navigationItem.setLeftBarButtonItem(nil, animated: true)
        self.masterPopoverController = nil;
    }
    
    
    //MARK: Web View Methods

    func loadAddressURL() {
        
        let request = NSURLRequest(URL: (NSURL(string: linkAndSource!.link)))
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


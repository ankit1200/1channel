//
//  DetailViewController.swift
//  1channel
//
//  Created by Ankit Agarwal on 7/7/14.
//  Copyright (c) 2014 Appify. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var masterPopoverController: UIPopoverController? = nil
    var link:String? {
        didSet {
            self.configureView()
        }
    }
    
    @IBOutlet weak var webView : UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    
    //MARK: Web View Methods

    func loadAddressURL() {
        
        let request = NSURLRequest(URL: (NSURL(string: link)))
        webView!.loadRequest(request)
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.link {
            if let loadLink = self.webView {
               loadAddressURL()
            }
        }
    }
}


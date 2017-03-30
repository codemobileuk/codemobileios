//
//  WebViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 24/02/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    // MARK: - Properties
    @IBOutlet weak var codeMobileWebView: UIWebView!
    @IBOutlet weak var webSpinner: UIActivityIndicatorView!
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        codeMobileWebView.delegate = self
        let url = NSURL(string: Commands.WEBSITE_URL)
        let requestObj = NSURLRequest(url: url! as URL)
        codeMobileWebView.loadRequest(requestObj as URLRequest)
        webSpinner.startAnimating()
    }
    
    // MARK: - UIWebViewDelegate
    func webViewDidStartLoad(_ : UIWebView){
        webSpinner.startAnimating()
        webSpinner.isHidden = false
        
    }
    func webViewDidFinishLoad(_ : UIWebView){
        webSpinner.stopAnimating()
        webSpinner.isHidden = true
    }
}

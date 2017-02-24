//
//  WebViewController.swift
//  CodeMobile
//
//  Created by Louis Woods on 24/02/2017.
//  Copyright © 2017 Footsqueek. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var codeMobileWebView: UIWebView!
    @IBOutlet weak var webSpinner: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        codeMobileWebView.delegate = self
        let url = NSURL(string: Commands.WEBSITE_URL)
        // Do any additional setup after loading the view.
        let requestObj = NSURLRequest(url: url as! URL)
        codeMobileWebView.loadRequest(requestObj as URLRequest)
         webSpinner.startAnimating()
    }
    
    func webViewDidStartLoad(_ : UIWebView){
        webSpinner.startAnimating()
        webSpinner.isHidden = false
        
    }
    func webViewDidFinishLoad(_ : UIWebView){
        webSpinner.stopAnimating()
        webSpinner.isHidden = true
    }
    
    
}

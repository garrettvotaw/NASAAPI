//
//  VideoPlayerController.swift
//  NASAAPI
//
//  Created by Garrett Votaw on 6/12/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import UIKit
import WebKit

class VideoPlayerController: UIViewController, WKUIDelegate {

    @IBOutlet weak var webView: WKWebView!
    
    var videoURL: URL!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myRequest = URLRequest(url: videoURL)
        webView.load(myRequest)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        
    }
    
    @IBAction func exitPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    

}

//
//  APODViewerController.swift
//  NASAAPI
//
//  Created by Garrett Votaw on 6/11/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import UIKit

class APODViewerController: UIViewController {

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    lazy var apiClient: NasaApiClient = {
        return NasaApiClient(configuration: .default)
    }()
    
    var image: UIImage!
    var apod: APOD!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let hdurl = apod.hdurl {
            apiClient.getImageFrom(url: hdurl) {image, error in
                if let image = image {
                    self.imageView.image = image
                    self.setupView()
                } else if let error = error {
                    //FIXME: Add error handling
                    print(error)
                }
            }
        }
        
        scrollView.delegate = self
        imageView.image = image
        setupView()
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        imageView.sizeToFit()
        scrollView.contentSize = imageView.bounds.size
        updateZoomScale()
        updateConstraintsForSize(view.bounds.size)
    }
    
    var minZoomScale: CGFloat {
        let viewSize = view.bounds.size
        let widthScale = viewSize.width/imageView.bounds.width
        let heightScale = viewSize.height/imageView.bounds.height
        
        return min(widthScale, heightScale)
    }
    
    func updateZoomScale() {
        scrollView.minimumZoomScale = minZoomScale
        scrollView.zoomScale = minZoomScale
    }
    
    func updateConstraintsForSize(_ size: CGSize) {
        let verticalSpace = size.height - imageView.frame.height
        let horizontalSpace = size.width - imageView.frame.width
        let yOffSet = max(0, verticalSpace/2)
        let xOffSet = max(0, horizontalSpace/2)
        
        topConstraint.constant = yOffSet
        bottomConstraint.constant = yOffSet
        
        leadingConstraint.constant = xOffSet
        trailingConstraint.constant = xOffSet
        
    }

}

extension APODViewerController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        if scrollView.zoomScale < minZoomScale - 0.04 {
            dismiss(animated: true, completion: nil)
        }
        
        updateConstraintsForSize(view.bounds.size)
    }
}

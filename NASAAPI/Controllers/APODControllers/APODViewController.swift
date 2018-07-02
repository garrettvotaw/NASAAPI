//
//  ViewController.swift
//  NASAAPI
//
//  Created by Garrett Votaw on 6/11/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import UIKit

class APODViewController: UIViewController {

    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    lazy var apiClient: NasaApiClient = {
        return NasaApiClient(configuration: .default)
    }()
    var apod: APOD?
    var image: UIImage?
    private var transitionContext: UIViewControllerContextTransitioning?
    var modalCollapsedFrame: CGRect?
    var modalExpandedFrame: CGRect?
    var isPresenting = false
    var numberOfDaysPrior = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAPOD(date: Date())
    }

    func getAPOD(date: Date) {
        self.shareButton.isEnabled = false
        toggleActivityIndicator(on: true)
        apiClient.getAPOD(date: date) { [unowned self] apod, error in
            if let apod = apod {
                self.apod = apod
                self.titleLabel.text = apod.title
                self.textView.text = apod.explanation
                if apod.mediaType == "image" {
                    self.apiClient.getImageFrom(url: apod.url) { [unowned self] image, error in
                        if let image = image {
                            self.toggleActivityIndicator(on: false)
                            self.imageView.image = image
                            self.image = image
                            self.shareButton.isEnabled = true
                        } else if let error = error {
                            switch error {
                            case .jsonParsingFailure: self.presentAlert(title: "Parsing Error", message: "Oops! It looks like something went wrong on the backend!")
                            case .responseUnsuccessful: self.presentAlert(title: "Response Unsuccessful", message: "It looks like your network might be down. Please try again.")
                            default: self.presentAlert(title: "Something Went Wrong", message: "Oops! It looks like something went wrong on the backend!")
                            }
                        }
                    }
                } else {
                    self.toggleActivityIndicator(on: false)
                    self.imageView.image = #imageLiteral(resourceName: "VideoImagePlaceHolder")
                }
            } else if let error = error {
                switch error {
                    case .jsonParsingFailure: self.presentAlert(title: "Parsing Error", message: "Oops! It looks like something went wrong on the backend!")
                    case .responseUnsuccessful: self.presentAlert(title: "Response Unsuccessful", message: "It looks like your network might be down. Please try again.")
                    default: self.presentAlert(title: "Something Went Wrong", message: "Oops! It looks like something went wrong on the backend!")
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextvc = segue.destination as? APODViewerController,
        let image = self.image,
        let apod = self.apod else {return}
        nextvc.image = image
        nextvc.apod = apod
    }
    
    // Presents the Scroll view where the user can view the Hi-res image
    @IBAction func imageTapped(_ sender: Any) {
        guard let _ = imageView.image else {return}
        guard let storyboard = storyboard else {return}
        if apod?.mediaType == "image" {
            let modalController = storyboard.instantiateViewController(withIdentifier: String(describing: APODViewerController.self)) as! APODViewerController
            modalController.apod = self.apod
            modalController.image = self.image
            modalController.modalPresentationStyle = .custom
            modalController.modalTransitionStyle = .crossDissolve
            modalController.transitioningDelegate = self
            isPresenting = true
            modalCollapsedFrame = CGRect.init(x: imageView.frame.minX, y: imageView.frame.minY + navigationController!.navigationBar.frame.maxY, width: imageView.frame.width, height: imageView.frame.height)
            self.present(modalController, animated: true, completion: {
                self.isPresenting = false
            })
        } else {
            let modalController = storyboard.instantiateViewController(withIdentifier: String(describing: VideoPlayerController.self)) as! VideoPlayerController
            guard let apod = self.apod else {return}
            modalController.videoURL = apod.url
            isPresenting = true
            self.present(modalController, animated: true) {
                self.isPresenting = false
            }
        }
    }
    
    
    //Get's previous Days APOD
    @IBAction func previousTapped(_ sender: Any) {
        numberOfDaysPrior -= 1
        let day = Calendar.current.date(byAdding: .day, value: numberOfDaysPrior, to: Date())
        getAPOD(date: day!)
    }
    
    // Returns to today's APOD
    @IBAction func todayTapped(_ sender: Any) {
        getAPOD(date: Date())
    }
    
    func toggleActivityIndicator(on: Bool) {
        imageView.isHidden = on
        if on {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    
    // Opens a share sheet where the user can share/save the image
    @IBAction func shareTapped(_ sender: Any) {
        guard let image = image, let data = UIImageJPEGRepresentation(image, 1.0) else {return}
        let shareSheet = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        present(shareSheet, animated: true, completion: nil)
    }
    
}


//MARK: - Extensions

//MARK: UIViewControllerTransitioningDelegate methods
extension APODViewController: UIViewControllerTransitioningDelegate {

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

}

//MARK: UIViewControllerAnimatedTransitioning methods
extension APODViewController: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    //Core Function that performs the transition and calls the animations
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)

        modalCollapsedFrame = CGRect.init(x: imageView.frame.minX, y: imageView.frame.minY + navigationController!.navigationBar.frame.maxY, width: imageView.frame.width, height: imageView.frame.height)
        self.modalExpandedFrame = transitionContext.containerView.bounds

        var modalView: UIView?
        var destinationFrame: CGRect?

        if isPresenting {
            modalView = toView
            destinationFrame = modalExpandedFrame

            guard let modalView = modalView else {return}
            transitionContext.containerView.addSubview(modalView)

            guard let collapsedFrame = modalCollapsedFrame else {return}
            toView?.frame = collapsedFrame
            toView?.layoutIfNeeded()
        } else {
            modalView = fromView
            destinationFrame = modalCollapsedFrame
        }

        guard let modal = modalView, let frame = destinationFrame else {return}
        animateWithModalView(view: modal, destinationFrame: frame)

    }

    //Animation Function that animates the view
    func animateWithModalView(view: UIView, destinationFrame frame: CGRect) {

        UIView.animate(withDuration: self.transitionDuration(using: self.transitionContext), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            view.alpha = 0.0
            view.frame = frame
            view.layoutIfNeeded()
        }) { (didComplete) in
            self.transitionContext?.completeTransition(true)
        }
    }

}


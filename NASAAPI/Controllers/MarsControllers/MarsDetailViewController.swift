//
//  MarsDetailViewController.swift
//  NASAAPI
//
//  Created by Garrett Votaw on 6/22/18.
//  Copyright © 2018 Garrett Votaw. All rights reserved.
//

import UIKit
import MessageUI

class MarsDetailViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var roverImageView: UIImageView!
    
    var lblNew: UITextField?
    let client = NasaApiClient()
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roverImageView.image = image
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(userDidTap(_:)))
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(userDidPinch(sender:)))
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(userDidPan(sender:)))
        self.view.addGestureRecognizer(panRecognizer)
        self.view.addGestureRecognizer(tapRecognizer)
        self.view.addGestureRecognizer(pinchRecognizer)
    }
    
    @objc func userDidPinch(sender: UIPinchGestureRecognizer) {
        guard let lblNew = lblNew else {return}
        if sender.state == .changed {
            lblNew.font = UIFont(name: "Helvetica Bold", size: sender.scale * 50)
            lblNew.frame.size = CGSize(width: sender.scale * 500.0, height: sender.scale * 100)
        }
    }
    
    @objc func userDidTap(_ sender: UITapGestureRecognizer) {
        guard let lblNew = lblNew else {return}
        lblNew.resignFirstResponder()
    }
    
    @objc func userDidPan(sender: UIPanGestureRecognizer) {
        if sender.state == .changed {
            moveLabel(toPoint: sender.location(in: roverImageView))
        } else if sender.state == .cancelled || sender.state == .ended {
//            saveImage()
        }
    }
    
    func moveLabel(toPoint point: CGPoint) {
        guard let lblNew = lblNew else {return}
        lblNew.frame.origin = point
        lblNew.center = point
    }
    
    
    func textToImage(drawText text: String, atPoint point: CGPoint, view: UIView) {
        
        let strokeColor = UIColor.black
        let strokeWidth = -2
        
        guard let label = view as? UITextField else {return}
        label.frame = CGRect(x: point.x, y: point.y, width: 200.0, height: 40)
        label.center = point
        label.textAlignment = .center
        label.attributedText = NSAttributedString(string: text, attributes: [
            NSAttributedStringKey.strokeWidth: strokeWidth,
            NSAttributedStringKey.strokeColor: strokeColor
            ])
        label.font = UIFont(name: "Helvetica Bold", size: 30)!
        label.textColor = UIColor.white
        self.view.addSubview(label)
    }
    
    
    func saveImage() {
        UIGraphicsBeginImageContextWithOptions(roverImageView.bounds.size, false, UIScreen.main.scale)
        roverImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let flattenedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        roverImageView.image = flattenedImage
    }
    
    func getImageData() -> Data? {
        if let flatImage = roverImageView.image, let data = UIImagePNGRepresentation(flatImage) {
            return data
        } else {return nil}
    }
    
    
    @IBAction func addTextFieldPushed(_ sender: Any) {
        let txtField = UITextField()
        txtField.tintColor = .white
        txtField.delegate = self
        txtField.defaultTextAttributes = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.strokeWidth.rawValue: -2
        ]
        
        lblNew = txtField
        textToImage(drawText: "Tap to Edit", atPoint: roverImageView.center, view: lblNew!)
        
    }
    
    @IBAction func sendPushed(_ sender: Any) {
        if let lblNew = lblNew {
            lblNew.removeFromSuperview()
            roverImageView.addSubview(lblNew)
            saveImage()
            lblNew.removeFromSuperview()
        }
        guard let imageData = getImageData() else {return}
        let sheet = UIActivityViewController(activityItems: [imageData], applicationActivities: nil)
        self.present(sheet, animated: true, completion: nil)
        sheet.completionWithItemsHandler = {activityType, didComplete, modifiedItems, error in
            if didComplete {
                print("Hooray!")
            }
        }
//        let mailVC = MFMailComposeViewController()
//        mailVC.mailComposeDelegate = self
//        mailVC.setSubject("Message From Mars!")
//        mailVC.setToRecipients(["garrett@votaw.org"])
//        mailVC.setMessageBody("Checkout the latest image from the rover on Mars!", isHTML: false)
//        mailVC.addAttachmentData(imageData, mimeType: "image/jpeg", fileName: "messageFromMars.jpeg")
    }
    
}



extension MarsDetailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
    }
}















//
//  SimulatedDocumentCameraViewController.swift
//  A replacement for VNDocumentCameraViewController that lets us simulate document scanning without a device.
//
//  Created by Chris Rivers on 30/06/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

#if targetEnvironment(simulator)
import UIKit

final class VNDocumentCameraViewController: UIViewController {
    weak var delegate: VNDocumentCameraViewControllerDelegate?
    
    let scannedImage = UIImage(named: "ScannedPage")!
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .black
        
        isModalInPresentation = true
        
        let backgroundImage = UIImageView(image: scannedImage)
        backgroundImage.frame = view.bounds
        backgroundImage.contentMode = .scaleAspectFit
        backgroundImage.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(backgroundImage)
        
        let scanButton = UIButton(type: .system)
        scanButton.translatesAutoresizingMaskIntoConstraints = false

        scanButton.addConstraints([
            NSLayoutConstraint(item: scanButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44),
            NSLayoutConstraint(item: scanButton, attribute: .width, relatedBy: .equal, toItem: scanButton, attribute: .height, multiplier: 1, constant: 0)
        ])

        scanButton.setBackgroundImage(UIImage(systemName: "viewfinder.circle.fill"), for: .normal)
        scanButton.addTarget(self, action: #selector(didTapCapture), for: .touchUpInside)
        
        let cancelButton = UIButton(type: .system)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addConstraints([
            NSLayoutConstraint(item: cancelButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44),
            NSLayoutConstraint(item: cancelButton, attribute: .width, relatedBy: .equal, toItem: cancelButton, attribute: .height, multiplier: 1, constant: 0)
        ])

        cancelButton.setBackgroundImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        
        let buttonStackView = UIStackView(arrangedSubviews: [cancelButton, scanButton])
        buttonStackView.tintColor = .white
        buttonStackView.distribution = .equalSpacing
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 20
        view.addSubview(buttonStackView)
        
        view.addConstraints([
            NSLayoutConstraint(item: buttonStackView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: buttonStackView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerXWithinMargins, multiplier: 1, constant: 0)
        ])
        
        super.viewDidLoad()
    }
    
    @objc func didTapCapture() {
        delegate?.documentCameraViewController(self, didFinishWith: VNDocumentCameraScan(image: scannedImage))
    }
    
    @objc func didTapCancel() {
        delegate?.documentCameraViewControllerDidCancel(self)
    }
}

struct VNDocumentCameraScan {
    let pageCount = 1
    
    var title = "Mockument"
    var image: UIImage
    
    func imageOfPage(at index: Int) -> UIImage {
        return image
    }
}

protocol VNDocumentCameraViewControllerDelegate: class {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan)
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController)
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error)
}
#endif

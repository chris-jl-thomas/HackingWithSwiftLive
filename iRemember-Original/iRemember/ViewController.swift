//
//  ViewController.swift
//  iRemember
//
//  Created by Paul Hudson on 25/06/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import NaturalLanguage
import UIKit
import Vision
import VisionKit

class ViewController: UIViewController, VNDocumentCameraViewControllerDelegate {
    
    enum Section {
        case main
    }

    var documents = [ScannedDocument](from: "documents.json") ?? []

    var dataSource: UICollectionViewDiffableDataSource<Section, ScannedDocument>!
    var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "iRemember"

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createBasicLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseIdentifier)

        dataSource = UICollectionViewDiffableDataSource<Section, ScannedDocument>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, model: ScannedDocument) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.reuseIdentifier, for: indexPath) as? ImageCell else {
                fatalError("Unable to dequeue ImageCell.")
            }

            let document = self.documents[indexPath.item]
            let filename = UIApplication.documentsDirectory.appendingPathComponent(document.filename).appendingPathExtension("png")

            cell.imageView.image = UIImage(contentsOfFile: filename.path)

            return cell
        }

        view.addSubview(collectionView)
        reloadData(animated: false)

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(upload))
        let scan = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(scanDocument))
        let updateLayout = UIBarButtonItem(image: UIImage(systemName: "star"), style: .plain, target: self, action: #selector(changeLayout))
        navigationItem.rightBarButtonItems = [scan, updateLayout]
    }

    func reloadData(animated: Bool) {
        let snapshot = NSDiffableDataSourceSnapshot<Section, ScannedDocument>()
        snapshot.appendSections([.main])
        snapshot.appendItems(documents)
        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    func saveData() {
        documents.save(to: "documents.json")
    }

    @objc func upload() {
        let vc = UploadViewController()
        vc.documents = documents
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true)
    }

    func createBasicLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 150, height: 150)

        return layout
    }

    @objc func scanDocument() {
        let vc = VNDocumentCameraViewController()
        vc.delegate = self
        present(vc, animated: true)
    }

    @objc func changeLayout() {
        collectionView.setCollectionViewLayout(createBasicLayout(), animated: true)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        dismiss(animated: true)
        DispatchQueue.global(qos: .userInitiated).async {
            
            let request = VNRecognizeTextRequest()
            let requests = [request]
            
            for i in 0 ..< scan.pageCount {
                let pageImage = scan.imageOfPage(at: i)
                guard let imageData = pageImage.pngData() else { continue }
                
                let handler = VNImageRequestHandler(data: imageData)
                try? handler.perform(requests)
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    fatalError("Received invalid observations")
                }
                
                self.parse(observations, for: imageData)
            }
            
            if scan.pageCount > 0 {
                DispatchQueue.main.async {
                    self.saveData()
                    self.reloadData(animated: true)
                }
            }
        }
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        //
    }
    
    func parse(_ observations: [VNRecognizedTextObservation], for imageData: Data) {
        var pageText = ""
        for observation in observations {
            guard let bestCandidate = observation.topCandidates(1).first else { continue }
            pageText += "\(bestCandidate.string) "
        }
        
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = pageText
        let (sentiment, _) = tagger.tag(at: pageText.startIndex, unit: .paragraph, scheme: .sentimentScore)
        let document = ScannedDocument(text: pageText, sentiment: sentiment)
        try? imageData.write(to: document.url)
        documents.append(document)
        print(document)
    }
}

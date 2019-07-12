//
//  ViewController.swift
//  iRemember
//
//  Created by Paul Hudson on 25/06/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import CoreHaptics
import UIKit
import VisionKit
import Vision
import NaturalLanguage

class ViewController: UIViewController {
    enum Section {
        case main
    }
    
    var documents = [ScannedDocument](from: "documents.json") ?? []
    var engine: CHHapticEngine?
    
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
        
        initialiseCoreHapticsEngine()
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
        collectionView.setCollectionViewLayout(createCompositionalLayout(), animated: true)
    }
}

//MARK: VisionKit

extension ViewController: VNDocumentCameraViewControllerDelegate {
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        dismiss(animated: true)
        
        DispatchQueue.global(qos: .userInitiated).async{
            // scan the pages
            let request = VNRecognizeTextRequest()
            let requests = [request]
            
            print("pageCount", scan.pageCount)
            for i in 0 ..< scan.pageCount {
                let pageImage = scan.imageOfPage(at: i)
                guard let imageData = pageImage.pngData() else { continue }
                
                let handler = VNImageRequestHandler(data: imageData)
                try? handler.perform(requests)
                
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    fatalError("Received invalid observation")
                }
                self.parse(observations, for: imageData)
            }
            
            if scan.pageCount > 0 {
                DispatchQueue.main.async {
                    self.playSuccessHaptic()
                    self.saveData()
                    self.reloadData(animated: true)
                }
            }
        }
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        playFailedHaptic()
        dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        print(error)
        playFailedHaptic()
        dismiss(animated: true)
    }
    
    private func parse(_ observations: [VNRecognizedTextObservation], for imageData: Data) {
        var pageText = ""
        
        for observation in observations {
            guard let bestCandidate = observation.topCandidates(1).first else { continue }
            
            pageText += "\(bestCandidate.string)"
        }
        
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = pageText
        let (sentiment, _ ) = tagger.tag(at: pageText.startIndex, unit: .paragraph, scheme: .sentimentScore)
        
        let document = ScannedDocument(text: pageText, sentiment: sentiment)
        try? imageData.write(to: document.url)
        documents.append(document)
        
        print(document)
    }
}

//MARK: CoreHaptics
extension ViewController {
    
    private func initialiseCoreHapticsEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("there was an error starting the haptics engine: \(error.localizedDescription).")
        }
        
        engine?.resetHandler = { [weak self] in
            print("The engine reset")
            
            do {
                try self?.engine?.start()
            } catch {
                print("Failed to restart the engine")
            }
        }
    }
    
    private func playSuccessHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.5)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
    
    private func playFailedHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        var events = [CHHapticEvent]()
        
        for i in stride(from: 0, to: 1, by: 0.1) {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(1 - i))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(1 - i))
            
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: i, duration: 0.5)
            events.append(event)
        }
        
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Failed to play pattern: \(error.localizedDescription).")
        }
    }
}


//MARK: UICollectionViewCompositionalLayout

extension ViewController {
    func createCompositionalLayout() -> UICollectionViewLayout {
        let squareSize: CGFloat = 0.5
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(squareSize), heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let spacing: CGFloat = 5
        item.contentInsets = NSDirectionalEdgeInsets(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(squareSize))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
}

//
//  ViewController.swift
//  iRemember
//
//  Created by Paul Hudson on 25/06/2019.
//  Copyright © 2019 Hacking with Swift. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
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

    }

    @objc func changeLayout() {
        collectionView.setCollectionViewLayout(createBasicLayout(), animated: true)
    }
}

//
//  LevelSelectionCollectionViewController.swift
//  Missing Link
//
//  Created by Benjamin Share on 9/4/19.
//  Copyright © 2019 Benjamin Share. All rights reserved.
//

import UIKit

private let reuseIdentifier = "LevelSelectionViewCell"
private let headerIdentifier = "LevelSelectionViewHeader"

class LevelSelectionCollectionViewController: UICollectionViewController {
    
    // MARK: Properties
    private var levelData = [PuzzleLevel]()
    private var cells = [LevelSelectionCollectionViewCell]()
    private var levelSelected: Int!
    
    // Public Variables
    var packIndex: Int?
    var packProgress: PackProgress?
    var loggedInUser: LoggedInUser!
    
    // MARK: Outlets
    @IBOutlet weak var feedbackButton: UIBarButtonItem!
    
    // MARK: Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        self.collectionView!.register(LevelSelectionCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        fillCollectionFromArray()
        view.backgroundColor = globalBackgroundColor()
    }
    
    func setLevelData(puzzleLevels: [PuzzleLevel]) {
        self.levelData = puzzleLevels
    }
 
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return levelData.count
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath)
        return headerView
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! LevelSelectionCollectionViewCell
        
        cells.append(cell)
        updateCell(index: indexPath.row, initial: true)
        return cell
    }
    
    // MARK: Cells

    private func fillCollectionFromArray() {
        let count = levelData.count
        for i in 0...count-1 {
            collectionView.cellForItem(at: IndexPath(index: i))
        }
    }

    private func updateCell(index: Int, initial: Bool=false) {
        let imageFn: String
        switch packProgress!.levelProgresses![index].status {
        case .locked:
            imageFn = "Lock"
        case .unlocked:
            imageFn = "None"
        case .completed:
            imageFn = "CheckMark"
        }
        
        let cell = cells[index]
        if initial {
            cell.configure(imageFn: imageFn, labelText: String(index + 1))
            cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectLevel(_:))))
        } else {
            cell.updateDisplayedImage(imageFn: imageFn)
        }
    }
    
    // MARK: Pack Selection and Completion
    
    private func packComplete() {
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(rewindToPackSelection), userInfo: nil, repeats: false)
    }
    
    @objc func selectLevel(_ sender: UITapGestureRecognizer) {
        let touch = sender.location(in: collectionView)
        if let indexPath = collectionView!.indexPathForItem(at: touch) {
            levelSelected = indexPath.row
            if packProgress!.levelProgresses![indexPath.row].status == .locked {
                print("That level has to be unlocked first!")
            } else {
                performSegue(withIdentifier: "levelSelected", sender: self)
            }
        } else {
            print("Couldn't choose level")
        }
    }
    
    @objc func rewindToPackSelection() {
        performSegue(withIdentifier: "doneWithPack", sender: self)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "levelSelected":
            guard let puzzleViewController = segue.destination as? PuzzleViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            let level = levelData[levelSelected]
            level.updateWithProgress(progress: packProgress!.levelProgresses![levelSelected])
            puzzleViewController.level = level
            puzzleViewController.levelProgress = packProgress!.levelProgresses![levelSelected]
            puzzleViewController.levelIndex = levelSelected
            puzzleViewController.loggedInUser = loggedInUser
        case "doneWithPack":
            guard segue.destination is PackSelectionCollectionViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
        case "feedbackButton":
            let dest = segue.destination as! FeedbackViewController
            dest.loggedInUser = loggedInUser
            dest.source = .levelSelection
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "unknown")")
        }
    }
    
    @IBAction func unwindToLevelSelection(segue: UIStoryboardSegue) {
        if let source = segue.source as? PuzzleViewController {
            if source.levelProgress!.status == .completed {
                return
            }
            // Since we assume pack complete --> all levels complete, we can assume the pack is not yet complete. TODO: shift to set in puzzle controller
            source.levelProgress!.completeLevel()
            updateCell(index: source.levelIndex)
            loggedInUser.user.data.playData.updateOnLevelComplete()
            syncUserProgress()
            
            let wasLastLevel = source.levelIndex + 1 == levelData.count
            
            if wasLastLevel {
                packComplete()
            } else {
                packProgress?.nextLevel += 1
                packProgress?.levelProgresses![packProgress!.nextLevel].unlock(length: levelData[packProgress!.nextLevel].length())
                updateCell(index: source.levelIndex + 1)
                updateSyncedUserProgress(progress: loggedInUser.user.progress)
            }
        } else if !(segue.source is FeedbackViewController) {
            print("Unexpected source for LevelSelectionViewController: \(segue.source)")
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isMovingFromParent {
            let ps = self.navigationController?.viewControllers.last as! PackSelectionCollectionViewController
            ps.loggedInUser = loggedInUser
        }
    }
}

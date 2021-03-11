//
//  PackSelectionCollectionViewController.swift
//  Missing Link
//
//  Created by Benjamin Share on 10/26/19.
//  Copyright © 2019 Benjamin Share. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PackSelectionCell"
private let headerIdentifier = "PackSelectionViewHeader"

class PackSelectionCollectionViewController: UICollectionViewController {
    
    // MARK: Private Variables
//    private var packData = [PuzzlePack?]()
    private var cells = [PackSelectionCollectionViewCell]()
    private var packSelected: Int!
    
    private var sectionPackData = [String: [(String, PuzzlePack)?]]()
    private var currentSection: String = ""
    private var sectionIdMap = [(String, Int)]()
    
    // MARK: Public Variables
    public var loggedInUser: LoggedInUser!
    
    // MARK: Outlets
    @IBOutlet weak var feedbackButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(PackSelectionCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        parsePackData()
        currentSection = sectionIdMap[0].0
        fillCollectionFromArray()
        view.backgroundColor = globalBackgroundColor()
    }

    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionIdMap.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return VISIBLE_SECTIONS.map[currentSection]!.count
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath)
        (headerView as! PackSelectionHeaderView).headerTitle.text = "other"
        return headerView
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PackSelectionCollectionViewCell
        cells.append(cell)
        updateCell(index: indexPath.row, initial: true)
        return cell
    }
    
    // MARK: Pack Data
    private func parsePackData() {
        PACK_VARIABLES_GROUP.wait()
        
        for sectionName in VISIBLE_SECTIONS.map.keys {
            sectionIdMap.append((sectionName, VISIBLE_SECTIONS.map[sectionName]![0].id))
//            sectionIdMap.append((VISIBLE_SECTIONS.map[sectionName]!.map( { $0.name }), VISIBLE_SECTIONS.map[sectionName]![0].id))
        }
        sectionIdMap.sort(by: { $0.1 < $1.1 } )
        for (sectionName, _) in sectionIdMap {
            let names = VISIBLE_SECTIONS.map[sectionName]!.map( { $0.name} )
            let ids = VISIBLE_SECTIONS.map[sectionName]!.map( { $0.id} )
            
            sectionPackData[sectionName] = (0...names.count-1).map( { AGGREGATE_PACK_INFO.keys.contains(ids[$0]) ? ( names[$0], AGGREGATE_PACK_INFO[ids[$0]]! ) : nil } )
        }
    }
    
    private func fillCollectionFromArray() {
        let count = VISIBLE_SECTIONS.map[currentSection]!.count
        for i in 0...count-1 {
            collectionView.cellForItem(at: IndexPath(index: i))
        }
    }
    
    private func unlockPack(index: Int) {
        let name = VISIBLE_SECTIONS.map[currentSection]![index].name
        fetchDataForPacks(packs: [name])
        PACK_VARIABLES_GROUP.wait()
        
        let id = VISIBLE_SECTIONS.map[currentSection]![index].id
        let pack = AGGREGATE_PACK_INFO[id]!
        
        loggedInUser.user.progress.pack_progresses[name] = PackProgress(status: .locked)
        loggedInUser.user.progress.pack_progresses[name]!.unlock(pack: pack)
        sectionPackData[currentSection]![index] = (name, pack)
        updateCell(index: index)
    }
    
    // MARK: Cell Configuration
    
    private func updateCell(index: Int, initial: Bool=false) {
        let imageFn: String
        let cellName = VISIBLE_SECTIONS.map[currentSection]![index].name
        switch loggedInUser.user.progress.pack_progresses[cellName]?.status {
        case .unlocked:
            imageFn = "Unlocked"
        case .completed:
            imageFn = "FullStar"
        case .locked:
            fallthrough
        case .none:
            imageFn = "Lock"
        }
        
        let cell = cells[index]
        if initial {
            cell.configure(imageFn: imageFn, labelText: cellName)
            cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectPack(_:))))
        } else {
            cell.updateDisplayedImage(imageFn: imageFn)
        }
    }
    
    @objc func selectPack(_ sender: UITapGestureRecognizer) {
        let touch = sender.location(in: collectionView)
        if let indexPath = collectionView!.indexPathForItem(at: touch) {
            packSelected = indexPath.row
            if sectionPackData[currentSection]![packSelected] == nil {
                print("That pack has to be unlocked first!")
            } else {
                performSegue(withIdentifier: "packSelected", sender: self)
            }
        } else {
            print("Couldn't choose level")
        }
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "packSelected":
            guard let levelSelectionCollectionViewController = segue.destination as? LevelSelectionCollectionViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            levelSelectionCollectionViewController.setLevelData(puzzleLevels: (sectionPackData[currentSection]![packSelected]!.1.getLevels()))
            levelSelectionCollectionViewController.packProgress = loggedInUser.user.progress.pack_progresses[sectionPackData[currentSection]![packSelected]!.0]
            levelSelectionCollectionViewController.packIndex = packSelected
            levelSelectionCollectionViewController.loggedInUser = loggedInUser
        case "feedbackButton":
            let dest = segue.destination as! FeedbackViewController
            dest.loggedInUser = loggedInUser
            dest.source = .packSelection
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "unknown")")
        }
    }
    
    @IBAction func unwindToPackSelection(segue: UIStoryboardSegue) {
        if let source = segue.source as? LevelSelectionCollectionViewController {
            if segue.identifier != "doneWithPack" {
                return
            }
            if source.packProgress?.status == .completed {
                fatalError("doneWithPack segue from already-completed pack")
            }
            source.packProgress?.completePack()
            loggedInUser.user.data.playData.updateOnPackComplete()
            updateCell(index: source.packIndex!)
            if source.packIndex! + 1 != VISIBLE_SECTIONS.map[currentSection]!.count {
                unlockPack(index: source.packIndex! + 1)
            }
            updateSyncedUserProgress(progress: loggedInUser.user.progress)
        } else if !(segue.source is FeedbackViewController) {
            print("Unexpected source for PackSelectionViewController: \(segue.source)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.isMovingFromParent {
            if !loggedInUser.isGuest {
                let hp = self.navigationController?.viewControllers.last as! HomePageViewController
                hp.loggedInUser = loggedInUser
            }
        }
    }
}

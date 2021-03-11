//
//  Roulette.swift
//  Missing Link
//
//  Created by Benjamin Share on 11/6/20.
//  Copyright © 2020 Benjamin Share. All rights reserved.
//

import Foundation

// TODO: Figure out pointer stuff
private class RouletteElement<T: Codable>: Codable {
    var value: T
    var index: Int
    var next: RouletteElement?
    
    init(value: T, index: Int, next: RouletteElement? = nil) {
        self.value = value
        self.index = index
        self.next = next
    }
}

class Roulette<T: Codable>: Codable {
    private var front: RouletteElement<T>? = nil
    private var end: RouletteElement<T>? = nil
    private var elements = [RouletteElement<T>]()
    private var isComplete: Bool = false
    private let total: Int
    private var length: Int
    
    init(data: [T]) {
        self.length = data.count
        self.total = data.count
        if length == 0 {
            return
        }
        for ind in 0...data.count-1 {
            elements.append(RouletteElement<T>(value: data[ind], index: ind))
        }
        for ind in 0...length-1 {
            elements[ind].next = elements[(ind + 1) % length]
        }
        front = elements.first
        end = elements.last
    }
    
    func updateWithProgress(progress: LevelProgress) {
        if progress.status == .completed {
            complete()
            return
        }
        if elements.count != progress.puzzleStatuses!.count {
            fatalError("Progress length does not match puzzle length")
        }
        if progress.status == .completed {
            for ind in 0...elements.count-1 {
                let cur = elements[ind]
                let next = elements[(ind + 1) % elements.count]
                cur.next = next
            }
            isComplete = true
            front = elements[0]
            end = elements[length - 1]
            length = total
            return
        }
        var open_indices = [Int]()
        let statuses = progress.puzzleStatuses
        for ind in 0...statuses!.count-1 {
            switch statuses![ind] {
            case .completed:
                break
            case .unlocked:
                open_indices.append(ind)
            default:
                fatalError("Unexpected puzzle status at index \(ind)")
            }
        }
        if open_indices.isEmpty {
            fatalError("Received empty puzzle list when filling level")
        }
        for i in 0...open_indices.count - 1 {
            let cur = open_indices[i]
            let next = open_indices[(i + 1) % open_indices.count]
            elements[cur].next = elements[next]
            if next == progress.nextPuzzle {
                end = elements[cur]
                front = elements[next]
            }
        }
        length = open_indices.count
    }
    
    func nextValue() -> Any? {
        return front?.value
    }
    
    func currentIndex() -> Int {
        return front!.index
    }
    
    func skip() {
        if length == 0 {
            return
        }
        front = front?.next
        end = end?.next
    }
    
    // No check for complete here. Should be checked before call.
    func popFront() {
        switch length {
        case 0:
            return
        case 1:
            self.complete()
            break
        default:
            front = front?.next
            end?.next = front
            length -= 1
        }
    }
    
    private func complete() {
        length = elements.count
        for ind in 0...length - 1 {
            elements[ind].next = elements[(ind + 1) % length]
        }
        
        front = elements[0]
        end = elements.last
        isComplete = true
    }
    
    func isCompleted() -> Bool {
        return isComplete
    }
    
    func totalLength() -> Int {
        return total
    }
    
    func lengthRemaining() -> Int {
        return length
    }
}

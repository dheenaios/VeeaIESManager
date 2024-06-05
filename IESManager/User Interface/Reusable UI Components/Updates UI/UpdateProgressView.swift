//
//  UpdateProgressView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 24/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

class UpdateProgressView: LoadedXibView {
    @IBOutlet private weak var progressLabel: UILabel!
    @IBOutlet private weak var progressBar: UIProgressView!
    
    let empty: Float = 0.0
    let full: Float = 1.0
    let fillUpAnimationDuration = 1.2
    let pauseDuration = 0.5
    
    /// When the progress is 100% animate the bar filling and emptying until something changes
    var loopAnimationAtFull: Bool = false
    private var currentlyLooping = false
    
    // Progress represented in the bar. 0.0 = empty. 1.0 is full
    var progress: Float = 0 {
        didSet {
            if progress == full && loopAnimationAtFull {
                loopProgress()
                return
            }
            
            progressBar.setProgress(progress, animated: true)
            self.layoutIfNeeded()
        }
    }
    
    var progressText: String = "" {
        didSet {
            progressLabel.text = progressText
            self.layoutIfNeeded()
        }
    }
}

extension UpdateProgressView {
    private func loopProgress() {
        
        // Only call the following once
        if currentlyLooping { return }
        
        progressBar.setProgress(empty, animated: false)
        currentlyLooping = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + pauseDuration) {
            if !self.loopAnimationAtFull { return }
            self.setToFull()
        }
    }
    
    private func setToEmpty() {
        if !self.loopAnimationAtFull || progress != full {
            currentlyLooping = false
            return
        }
        
        progressBar.setProgress(empty, animated: false)
        layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + pauseDuration) {
            if !self.loopAnimationAtFull {
                self.currentlyLooping = false
                return
            }
            self.setToFull()
        }
    }
    
    private func setToFull() {
        if !self.loopAnimationAtFull || progress != full {
            self.currentlyLooping = false
            return
        }
        progressBar.setProgress(full, animated: true)
        layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + fillUpAnimationDuration) {
            if !self.loopAnimationAtFull || self.progress != self.full {
                self.currentlyLooping = false
                return
            }
            self.setToEmpty()
        }
    }
}

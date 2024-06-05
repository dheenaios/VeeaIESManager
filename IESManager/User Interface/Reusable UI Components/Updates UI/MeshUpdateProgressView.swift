//
//  MeshUpdateProgressView.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 24/11/2021.
//  Copyright © 2021 Veea. All rights reserved.
//

import UIKit

protocol MeshUpdateProgressViewFinishedProtocol: AnyObject {
    func finished()
}

class MeshUpdateProgressView: LoadedXibView {
    @IBOutlet weak var backingView: UIView!
    @IBOutlet weak var stepsProgressBar: UpdateProgressView! // Steps
    @IBOutlet weak var percentageProgressBar: UpdateProgressView! // Percentage
    
    weak var delegate: MeshUpdateProgressViewFinishedProtocol?
    
    private var currentStatus: MeshUpdateStatus?
    private var lastStatus: MeshUpdateStatus?
    
    private var incrementTo: Int?
    private var currentIncrement: Int?
    private var incrementTimer: Timer?
    
    override func loaded() {
        backingView.layer.cornerRadius = 15
        backingView.clipsToBounds = true
    }
    
    func updateProgress(status: MeshUpdateStatus) {
        self.currentStatus = status
        
        // Set the steps and percentage
        percentageProgressBar.progressText = "\(status.lastStep?.description ?? "")"
        percentageProgressBar.loopAnimationAtFull = true
        
        guard let lastStatus = lastStatus else { // Then this is the first update
            resetProgressToLatest(status: status)
            lastStatus = status
            
            return
        }
        
        // Check the difference between the last and current status
        // Since we are polling the API every 45 seconds, it may happen that after step 1,
        // we will get step 5. In that case, we will show step2 to step4 quick sequence with
        // intervals of 1 second. (Control central will also follow it)
        // If there is an error, then the number of steps in the process may change at any time.
        // Sometimes there may be no last steps
        guard let currentLastStep = status.lastStep,
              let previousLastStep = lastStatus.lastStep else {
                  resetProgressToLatest(status: status)
                  self.lastStatus = status
                  return
              }
        
        let diff = currentLastStep.step - previousLastStep.step
        
        if diff < 0 {
            stepsProgressBar.progressText = "Total progress - step \(status.lastStep?.step ?? 0) out of \(status.totalSteps)"
            update(totalProgressPercentage: status.progress,
                   currentStepPercentage: status.stepProgress)
            return
        }
        else if diff == 1 {
            stepsProgressBar.progressText = "Total progress - step \(status.lastStep?.step ?? 0) out of \(status.totalSteps)"
            update(totalProgressPercentage: status.progress,
                   currentStepPercentage: status.stepProgress)
        }
        else if diff > 1 { // Increment the progress bar one step per second as per VHM-871
            incrementInSteps(fromStep: lastStatus.lastStep!.step,
                             toStep: status.lastStep!.step)
            
            percentageProgressBar.progress = ((status.lastStep?.progress ?? 0) / 100)
        }
        else if diff < 0 {
            // If its less than 0, then there has been an error and the progress metrics we did have
            // have been replaced by another
            // Reset everything
            resetProgressToLatest(status: status)
        }
        
        self.lastStatus = status
    }
    
    private func resetProgressToLatest(status: MeshUpdateStatus) {
        stepsProgressBar.progressText = "Total progress - step \(status.lastStep?.step ?? 0) out of \(status.totalSteps)"
        update(totalProgressPercentage: status.progress,
               currentStepPercentage: status.stepProgress)
    }
    
    private func incrementInSteps(fromStep: Int, toStep: Int) {
        incrementTo = toStep
        currentIncrement = fromStep
        
        incrementTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let currentIncrement = self?.currentIncrement,
                  let incrementTo = self?.incrementTo else {
                      timer.invalidate()
                      return
                  }
            if currentIncrement >= incrementTo {
                timer.invalidate()
                
                if self?.stepsProgressBar.progress == 1.0 {
                    DispatchQueue.main.async {
                        self?.delegate?.finished()
                    }
                }
                
                return
            }
            
            DispatchQueue.main.async {
                self?.incrementOneStep()
            }
        }
    }
    
    private func incrementOneStep() {
        guard let totalSteps = lastStatus?.totalSteps else { return }
        
        currentIncrement! += 1
        
        // Overall progress
        let newProgressValue = Float(currentIncrement!) / Float(totalSteps)
        stepsProgressBar.progressText = "Total progress - step \(currentIncrement!) out of \(totalSteps)"
        stepsProgressBar.progress = newProgressValue
        
        // Current step
        guard let currentStatus = currentStatus else { return }
        let step = currentStatus.steps.reversed()[currentIncrement! - 1]
        percentageProgressBar.progressText = step.description
    }
    
    
    /// Update both items
    /// - Parameters:
    ///   - steps: The number of steps the overrall have completed
    ///   - percentage: The percentage complete the current step
    private func update(totalProgressPercentage: Float,
                        currentStepPercentage: Float) {
        stepsProgressBar.progress = (totalProgressPercentage / 100)
        percentageProgressBar.progress = (currentStepPercentage / 100)
        
        if totalProgressPercentage == 100 {
            delegate?.finished()
        }
    }
}

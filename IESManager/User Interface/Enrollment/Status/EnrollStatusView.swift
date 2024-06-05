//
//  EnrollStatusView.swift
//  VeeaHub Manager
//
//  Created by Niranjan Ravichandran on 1/29/19.
//  Copyright © 2019 Veea. All rights reserved.
//

import UIKit

enum EnrollSubtaskStatus {
    case pending
    case progress
    case complete
    case failed
}

struct EnrollStatusViewModel {
    let percentage: Double
    let approxTimeRemaining: Double
    
    struct Subtasks {
        let status: EnrollSubtaskStatus
        let text: String
    }
    
    let subtasks: [Subtasks]
//    let device: VHNode
//    let mesh: VHMesh

    var nextNonCompleteItem: Subtasks {
        for subtask in subtasks {
            if subtask.status == .pending {
                return subtask
            }
        }

        return Subtasks(status: .complete, text: "Complete")
    }
    
    var didFail: Bool {
        
        for subtask in subtasks {
            if subtask.status == .failed {
                return true
            }
        }
        
        return false
    }
    
    
    init(enrollStatus: EnrollStatusModel) {
        self.percentage = enrollStatus.percentage
        self.approxTimeRemaining = enrollStatus.approxTimeRemaining
        
        var tasks: [Subtasks] = []
        for item in enrollStatus.items {
            var status: EnrollSubtaskStatus = .pending
            if let percentage = item.percentage {
                if percentage == 100 {
                    status = .complete
                } else if percentage > 0 {
                    status = .progress
                } else if percentage == -1 {
                    status = .failed
                }
            }
            var statusText = item.name ?? ""
            if item.percentage != nil && item.percentage! != 0 {
                let percentageText = String.init(format: " %g%%", item.percentage!)
                statusText += percentageText
            }
            if status == .failed {
                statusText = item.name ?? "" + " - \("Failed".localized())" 
            }
            tasks.append(EnrollStatusViewModel.Subtasks(status: status, text: statusText))
        }
        self.subtasks = tasks
//        self.device = enrollStatus.device
//        self.mesh = enrollStatus.mesh
    }
    
}



class EnrollStatusView: UIView {
    
    fileprivate var subtasks: [EnrollSubtaskView] = []
    
    convenience init(frame: CGRect, items: [EnrollStatusViewModel.Subtasks]) {
        self.init(frame: frame)
        
        for (index, item) in items.enumerated() {
            let statusView = EnrollSubtaskView(status: item.status, text: item.text, frameWidth: frame.width)
            statusView.frame.origin.y = self.bounds.height
            statusView.tag = index
            self.push(statusView)
            self.addOffset(8)
            self.subtasks.append(statusView)
        }
    }
    
    func update(with newStausItems: [EnrollStatusViewModel.Subtasks]) {
        for (index, item) in newStausItems.enumerated() {
            self.subtasks[index].update(with: item.status, text: item.text)
        }
    }
    
}

fileprivate class EnrollSubtaskView: UIView {
    var icon: UIImageView!
    var textLabel: UILabel!
    
    convenience init(status: EnrollSubtaskStatus, text: String, frameWidth: CGFloat) {
        self.init(frame: CGRect(x: 0, y: 0, width: frameWidth, height: 30))
        icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 22, height: 22))
        icon.contentMode = .scaleAspectFill
        icon.backgroundColor = .clear
        circularStyle(icon)
        icon.centerInView(superView: self, mode: .vertical)
        self.addSubview(icon)
        
        let textOrigin =  icon.rightEdge + 8
        textLabel = UILabel(frame: CGRect(x: textOrigin, y: 0, width: self.bounds.width - textOrigin, height: 0))
        textLabel.text = text
        textLabel.lineBreakMode = .byTruncatingMiddle
        mediumLabelStyle(textLabel)
        textLabel.centerInView(superView: self, mode: .vertical)
        self.addSubview(textLabel)
        
        self.update(with: status, text: text)
    }
    
    func update(with status: EnrollSubtaskStatus, text: String) {
        if status == .complete {
            icon.image = UIImage(named: "checkmark-icon")
            icon.backgroundColor = .clear
            icon.tintColor = .clear
        } else if status == .pending {
            icon.backgroundColor = .vLightPurple
            icon.image = nil
        } else if status == .failed {
            icon.tintColor = .vRed
            icon.image = UIImage(named: "icon-cancel")?.withRenderingMode(.alwaysTemplate)
        } else {
            icon.backgroundColor = .vPurple
            icon.image = nil
        }
        self.textLabel.text = text
    }
}

//
//  MenuViewController.swift
//  MenuPicker
//
//  Created by Richard Stockdale on 22/07/2021.
//

import UIKit

class MenuViewController: UIViewController {
    
    struct MenuItemOption {
        let title: String
        var image: UIImage?
        var textColor: UIColor?
        var selected: Bool = false
    }
    
    private let headerHeight: CGFloat = 80
    private let rowHeight: CGFloat = 44
    
    @IBOutlet weak var tableView: UITableView!
    var completion: ((Int, String) -> Void)?
    
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    
    private var titleText: String?
    private var subTitleText: String?
    
    public var options: [MenuItemOption]? {
        didSet {
            if tableView != nil {
                tableView.reloadData()
            }
        }
    }
    
    public func showHeader(show: Bool) {
        if show {
            headerHeightConstraint.constant = headerHeight
            headerView.isHidden = false
            view.layoutIfNeeded()
        }
        else {
            headerHeightConstraint.constant = 0
            headerView.isHidden = true
            view.layoutIfNeeded()
        }
    }
    
    static func createMenuViewController(title: String,
                                         subTitle: String,
                                         options: [MenuItemOption],
                                         originView: UIView,
                                         offsetFromHorizontalCentreOfView: CGFloat = 0,
                                         completion: @escaping ((Int, String) -> Void)) -> MenuViewController {
        var rowsShown = options.count
        if options.count > 5 {
            rowsShown = 5
        }
        else if options.count == 0 {
            rowsShown = 1
        }
        
        let vc = UIStoryboard(name: "MenuPicker", bundle: nil).instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        vc.completion = completion
        vc.title = title
        vc.subTitleText = subTitle
        
        vc.options = options
        
        var height: CGFloat = CGFloat(rowsShown) * vc.rowHeight
        if !title.isEmpty {
            height = height + vc.headerHeight
        }
        
        vc.preferredContentSize = CGSize(width: 400,height: height)
        vc.modalPresentationStyle = .popover
        if let pres = vc.presentationController {
            pres.delegate = vc
        }
        
        if let pop = vc.popoverPresentationController {
            pop.sourceView = originView

            let originBounds = CGRect(x: 0, y: 0,
                                      width: originView.bounds.width + (offsetFromHorizontalCentreOfView * 2),
                                      height: originView.bounds.height)

            pop.sourceRect = originBounds
        }
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = title
        subTitleLabel.text = subTitleText
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.reloadData()
        
        showHeader(show: !(titleText?.isEmpty ?? false))
    }
}

extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let completion = completion,
              let options = options else {
                  return
              }
        
        self.dismiss(animated: true) {
            completion(indexPath.row, options[indexPath.row].title)
        }
    }
}

extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let options = options else {
            return 0
        }
        
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RowCell
        guard let options = options else {
            return cell
        }
        
        let rowOption = options[indexPath.row]
        cell.configure(config: rowOption)
        
        return cell
    }
}

extension MenuViewController : UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

class RowCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    
    func configure(config: MenuViewController.MenuItemOption) {
        titleLabel.text = config.title
        
        if let image = config.image {
            leftImageView.image = image
            titleLabel.textAlignment = .left
        }
        else {
            titleLabel.textAlignment = .center
        }
        
        if let textColor = config.textColor {
            titleLabel.textColor = textColor
        }

        titleLabel.font = config.selected ? FontManager.bold(size: 17.0) : FontManager.regular(size: 17)
    }
}

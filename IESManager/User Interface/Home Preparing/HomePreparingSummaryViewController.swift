//
//  HomePreparingSummaryViewController.swift
//  IESManager
//
//  Created by Richard Stockdale on 07/03/2022.
//  Copyright © 2022 Veea. All rights reserved.
//

import UIKit
import CoreMedia

class HomePreparingSummaryViewController: HomeUserBaseViewController {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var learnMoreButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var vm: HomePreparingSummaryViewModel!
    
    static func new(mesh: VHMesh,
                    meshDetailViewModel: MeshDetailViewModel) -> HomePreparingSummaryViewController {
        let vc = UIStoryboard(name: StoryboardNames.HomePreparing.rawValue, bundle: nil).instantiateInitialViewController() as! HomePreparingSummaryViewController
        vc.vm = HomePreparingSummaryViewModel(mesh: mesh,
                                              meshDetailViewModel: meshDetailViewModel)
        vc.vm.delegate = vc
        
        return vc
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func setTheme() {
        super.setTheme()
        
        infoLabel.font = FontManager.light(size: 18)
        infoLabel.setExistingTextWithLineSpacing()
        
        learnMoreButton.titleLabel?.font = FontManager.bigButtonText
        learnMoreButton.titleLabel?.textColor = InterfaceManager.shared.cm.themeTint.colorForAppearance
    }
    
    @IBAction func learnMoreTapped(_ sender: Any) {
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideNavBar = false
    }
}

extension HomePreparingSummaryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = vm.nodeTableCellModelForIndex(indexPath.row)
        let vc = HomePreparingNodeViewController.new(nodeTableCellModel: model)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomePreparingSummaryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        vm.numberOfDevices
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NameIndicatorSelectionCell
        let model = vm.deviceModelForIndex(indexPath.row)
        cell.configure(model: model)
        
        return cell
    }
}

extension HomePreparingSummaryViewController: MeshStateDelegate {
    func meshStateUpdated() {
        // TODO: Update the mesh states
    }
}

class HomePreparingSummaryViewModel {
    let mesh: VHMesh
    private let meshDetailViewModel: MeshDetailViewModel
    
    weak var delegate: MeshStateDelegate?
    
    init(mesh: VHMesh, meshDetailViewModel: MeshDetailViewModel) {
        self.mesh = mesh
        self.meshDetailViewModel = meshDetailViewModel
        self.meshDetailViewModel.delegate = self // Grab the delegate se we get infomed of the state updates
    }
    
    var numberOfDevices: Int {
        return meshDetailViewModel.cellViewModels.count
    }
    
    func nodeTableCellModelForIndex(_ index: Int) -> NodeTableCellModel {
        return meshDetailViewModel.cellViewModels[index]
    }
    
    func deviceModelForIndex(_ index: Int) -> ImageOptionView.ImageOptionViewModel {
        let model = meshDetailViewModel.cellViewModels[index]
        
        let name = model.device.formattedDeviceName
        let stateColor = stateColorForModel(model)
        let stateText = stateTextForModel(model)
        let locationImage = locationImageForModel(model)

        return ImageOptionView.ImageOptionViewModel(title: name,
                                                    image: locationImage,
                                                    subTitle: stateText,
                                                    indicatorColor: stateColor)
    }
    
    private func stateColorForModel(_ model: NodeTableCellModel) -> UIColor {
        // Could use the health state, BUT the colors do not seem to be the same as in the designs
        
        if model.isPreparingFailed {
            return InterfaceManager.shared.cm.statusRed.colorForAppearance
        }
        else if model.isPreparing {
            return InterfaceManager.shared.cm.statusGrey.colorForAppearance
        }
        
        return InterfaceManager.shared.cm.statusGreen.colorForAppearance
    }
    
    private func stateTextForModel(_ model: NodeTableCellModel) -> String {
        if model.isPreparingFailed {
            return "Failed to add VeeaHub".localized()
        }
        else if model.isPreparing {
            return "Preparing for first use ..".localized()
        }
        
        return "Installation complete".localized()
    }
    
    private func locationImageForModel(_ model: NodeTableCellModel) -> UIImage {
        guard let name = model.device.name else {
            return UIImage(named: "icon-error")!
        }
        
        return DefaultNodeDescriptionsAndImages.imageForTitle(name)
    }
}

extension HomePreparingSummaryViewModel: MeshDetailViewModelDelegate {
    func didUpdateMeshes(meshes: [VHMesh]) {
        delegate?.meshStateUpdated()
    }
}

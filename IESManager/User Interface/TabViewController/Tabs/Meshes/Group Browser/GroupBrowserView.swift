//
//  GroupBrowserView.swift
//  IESManager
//
//  Created by Richard Stockdale on 13/06/2023.
//  Copyright © 2023 Veea. All rights reserved.
//

import SwiftUI
import SharedBackendNetworking

protocol GroupBrowserSelectionDelegate {
    func selectionMade(group: GroupModel)
}

/// Entry point
struct GroupBrowserNavigationView: View {
    private var delegate: GroupBrowserSelectionDelegate
    private var topLevelGroups: UserGroupService
    private var selectedGroupsId: String
    private var selectedSegment: Int
    
    
    var body: some View {
        NavigationView {
            GroupBrowserView(delegate: delegate,
                             selectedGroupsId: selectedGroupsId,
                             groupService: topLevelGroups, selectedSegment: selectedSegment)
        }
    }
    
    static func newViewController(selectedGroupId: String,
                                  topLevelGroups: UserGroupService,
                                  delegate: GroupBrowserSelectionDelegate, selectedSegment: Int) -> UIViewController {
        let vc = HostingController(rootView: GroupBrowserNavigationView(delegate: delegate,
                                                                        topLevelGroups: topLevelGroups,
                                                                        selectedGroupsId: selectedGroupId, selectedSegment: selectedSegment))
        return vc
    }
}

struct GroupBrowserView: View {
    @State private var searchText = ""
    @State private var selectedGroupsId: String
    @State private var selectedSegment = 0
    
    private var delegate: GroupBrowserSelectionDelegate
    @ObservedObject var vm: GroupBrowserViewModel
    @EnvironmentObject var host: HostWrapper
    @State private var showFavs: Bool = true
    
    var body: some View {
        VStack {
            SearchBarView(text: $searchText,
                          placeholderText: "Search Groups...".localized(),
                          didChange: { newText in
                vm.searchQueryChanged(searchTerm: newText,selectedSegment: selectedSegment)
                
            })
            .padding(.top, 10)
            Picker("", selection: $selectedSegment) {
                Text("Groups").tag(0)
                Text("Favourites").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.top, 10)
            .onChange(of: selectedSegment) {segment in
                searchText = ""
                vm.searchQueryChanged(searchTerm: "",selectedSegment: selectedSegment)
            }
            
            List {
                if selectedSegment == 0 {
                    Section(header: Text("".localized())) {
                        ForEach(vm.groupDisplayDetails, id: \.self) { group in
                            if group.hasChildren {
                                NavigationLink {
                                    childGroupsBrowser(groupId: group.groupId)
                                } label: { groupRow(group: group) }
                                    .onAppear { self.loadMore(group: group) }
                            }
                            else {
                                groupRow(group: group)
                                    .onAppear { self.loadMore(group: group) }
                            }
                        }
                    }
                }
                else {
                    if !vm.favoriteGroupDisplayDetails.isEmpty {
                        Section(header: favsHeader) {
                            if showFavs {
                                ForEach(vm.favoriteGroupDisplayDetails, id: \.self) { group in
                                    if group.hasChildren {
                                        NavigationLink {
                                            childGroupsBrowser(groupId: group.groupId)
                                        } label: { groupRow(group: group) }
                                            .onAppear { self.loadMore(group: group) }
                                    }
                                    else {
                                        groupRow(group: group)
                                            .onAppear { self.loadMore(group: group) }
                                    }
                                }
                            }
                        }
                    }
                }
                
                if vm.isLoading {
                    HStack {
                        Image(systemName: "arrow.down.circle")
                            .foregroundColor(.gray)
                            .padding(.leading)
                        Text("Loading more groups...")
                            .foregroundColor(.gray)
                            .padding(.trailing)
                        Spacer()
                    }
                }
            }
            .listStyle(.insetGrouped)
            
            
            footerControls
        }
        
        .navigationBarTitle("Select Group", displayMode: .inline)
        .navigationBarItems(trailing: CloseButton(action: {
            host.controller?.dismiss(animated: true)
        }))
        .navigationBarItems(trailing: RefreshButton(action: {
            self.vm.refreshFavDataIfNeeded()
        }))
        .onAppear {
            self.showFavs = vm.showFavs
            vm.refreshFavDataIfNeeded()
            vm.updateGroupDisplayDetails()
        }
        .alert(isPresented: $vm.showFavError) {
            Alert(
                title: Text("Error".localized()),
                message: Text(vm.favErrorText),
                dismissButton: .cancel(Text("OK".localized()))
            )
        }
    }
    
    private func groupRow(group: GroupDisplayDetails) -> some View {
        GroupRow(model: group,
                 selectedId: selectedGroupsId) { selectionType in
            if selectionType == .groupSelection { selectedGroupsId = group.groupId }
            else if selectionType == .groupFavorite { vm.toggleFavorite(model: group) }
        }
    }
    
    private var favsHeader: some View {
        HStack {
            Text("".localized())
            Spacer()
            Button {
                vm.showFavs.toggle()
                showFavs.toggle()
            } label: {
                //vm.showFavs ? Image(systemName: "chevron.down") : Image(systemName: "chevron.up")
            }
        }
    }
    
    private var footerControls: some View {
        return VStack {
            //            HStack {
            //                Text(vm.breadcrumbs ?? "")
            //                    .font(.caption)
            //                    .foregroundColor(Color(UIColor.lightGray))
            //            }
            HStack {
                if selectedGroupsId == GroupModel.selectedModel?.id {
                    ActionButton(title: "Switch to Group",
                                 bgColor: InterfaceManager.shared.cm.statusGrey) {
                        host.controller?.dismiss(animated: true)
                    }
                }
                else {
                    ActionButton(title: "Switch to Group",
                                 bgColor: InterfaceManager.shared.cm.themeTint) {
                        guard let group = vm.switchToGroup(selectedGroup: selectedGroupsId) else {
                            host.controller?.dismiss(animated: true)
                            return
                        }
                        
                        host.controller?.dismiss(animated: true)
                        delegate.selectionMade(group: group)
                    }
                }
            }
            .padding([.bottom, .leading, .trailing], 16)
        }
    }
    
    private func loadMore(group: GroupDisplayDetails) {
        vm.isLoadThresholdItem(identifiableItem: group)
    }
    
    public init(delegate: GroupBrowserSelectionDelegate,
                selectedGroupsId: String,
                parentGroupId: String? = nil,
                groupService: GroupService,selectedSegment:Int) {
        self.delegate = delegate
        self._selectedGroupsId = State(initialValue: selectedGroupsId)
        self.vm = GroupBrowserViewModel(groupService: groupService)
        self.showFavs = vm.showFavs
        self.selectedSegment = selectedSegment
    }
    
    private func childGroupsBrowser(groupId: String) -> GroupBrowserView {
        let childGroupService = ChildGroupService(groupId: groupId)
        childGroupService.startInitialLoad()
        
        let view = GroupBrowserView(delegate: delegate,
                                    selectedGroupsId: selectedGroupsId,
                                    groupService: childGroupService, selectedSegment: selectedSegment)
        
        return view
    }
}



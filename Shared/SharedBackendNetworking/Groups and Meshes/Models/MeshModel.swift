//
//  MeshModel.swift
//  SharedBackendNetworking
//
//  Created by Richard Stockdale on 20/06/2022.
//
import SwiftUI
import Foundation

struct MeshModel: Codable, Equatable {
    let id: String!
    let name: String!
    var devices: [NodeModel]?
}

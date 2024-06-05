//
//  HubDataModel+MasApi.swift
//  VeeaHub Manager
//
//  Created by Richard Stockdale on 09/09/2020.
//  Copyright © 2020 Veea. All rights reserved.
//

import Foundation


// This extension deals with updating when connecting via the MAS API
extension HubDataModel {
     func getDataModelFromMasApi(connection: MasConnection) {
        ApiFactory.api.getMasApiIntermediaryModel(connection: connection) { (model, error) in
            if let error = error {
                self.reportModelUpdateError(message: "ERROR obtaining Hub data model: ".localized() + error.localizedDescription)
                return
            }
            
            guard let model = model else {
                self.reportModelUpdateError(message: "No Hub data model returned".localized())
                return
            }
            
            if model.baseModel == nil {
                self.reportModelUpdateError(message: "Refresh failed. Please try again".localized())
                return
            }

            self.baseDataModel = model.baseModel
            self.optionalAppDetails = model.optionalModel
            
            self.updateCompletedSucessfully(message: "Success".localized())
        }
    }
    
    func getDataModelFromMasApiForScan(connection: MasConnection) {
        ApiFactory.api.getMasApiIntermediaryModel(connection: connection) { (model, error) in
            if let error = error {
                self.reportModelUpdateError(message: "ERROR obtaining Hub data model: ".localized() + error.localizedDescription)
                return
            }
            
            guard let model = model else {
                self.reportModelUpdateError(message: "No Hub data model returned".localized())
                return
            }
            
            if model.baseModel == nil {
                self.reportModelUpdateError(message: "Refresh failed. Please try again".localized())
                return
            }
            
            self.baseDataModel = model.baseModel
            self.optionalAppDetails = model.optionalModel
            
            // self.updateCompletedSucessfully(message: "Success".localized())
            
            self.updateCompletedSucessfullyAfterScan(message: "Success".localized())
        }
    }
}

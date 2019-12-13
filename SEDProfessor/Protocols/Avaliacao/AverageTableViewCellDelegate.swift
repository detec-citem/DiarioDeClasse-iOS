//
//  AverageTableViewCellDelegate.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 26/12/18.
//  Copyright © 2018 PRODESP. All rights reserved.
//

import Foundation

protocol AverageTableViewCellDelegate: class {
    func averageTableViewCellButtonUpClicked(averageItem: AverageViewController.AverageItem?)
    func averageTableViewCellButtonDownClicked(averageItem: AverageViewController.AverageItem?)
    func averageTableViewCellButtonReloadClicked(averageItem: AverageViewController.AverageItem?)
}

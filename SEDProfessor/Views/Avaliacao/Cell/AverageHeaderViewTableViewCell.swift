//
//  AverageHeaderViewTableViewCell.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 21/02/17.
//  Copyright © 2017 PRODESP. All rights reserved.
//

import UIKit

protocol AverageHeaderViewTableViewCellDelegate {
    func averageHeaderViewTableViewCellDidSelect(type: AverageDao.AverageTypeModel?, button: UIButton?)
}

final class AverageHeaderViewTableViewCell: UITableViewCell {
    @IBOutlet fileprivate var titleButton: UIButton?
    var delegate: AverageHeaderViewTableViewCellDelegate?
    var type: AverageDao.AverageTypeModel? {
        didSet {
            accessoryType = .none
            guard let name = type?.name else { return }
            titleButton?.setTitle("❋ \(name.rawValue.uppercased())", for: .normal)
            titleButton?.tag = type?.id?.rawValue ?? .zero
        }
    }

    @IBAction fileprivate func didSelectType(sender: UIButton) {
        delegate?.averageHeaderViewTableViewCellDidSelect(type: type, button: sender)
    }
}

//
//  WeightedAverageTableViewCell.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 22/02/17.
//  Copyright © 2017 PRODESP. All rights reserved.
//

import GMStepper
import UIKit

protocol WeightedAverageTableViewCellDelegate {
    func weightedAverageTableViewCellDidStepperChanged(data: AverageViewController.WeightedData?, newWeight: Int?)
}

final class WeightedAverageTableViewCell: UITableViewCell {
    @IBOutlet fileprivate var nameLabel: UILabel?
    var delegate: WeightedAverageTableViewCellDelegate?
    var data: AverageViewController.WeightedData? {
        didSet {
            DispatchQueue.main.async {
                self.accessoryType = .none
                guard let id = self.data?.id, let name = self.data?.evaluation.nome else { return }
                let attributedText = NSMutableAttributedString(string: "\(id) ➢ ".uppercased(), attributes: Attributes.first)
                attributedText.append(NSAttributedString(string: name.uppercased(), attributes: Attributes.second))
                self.nameLabel?.attributedText = attributedText
                guard let weight = self.data?.weight else { return }
                let view = UIView(frame: CGRect(x: .zero, y: .zero, width: 70, height: 20))
                view.backgroundColor = .clear
                view.center = self.contentView.center
                let stepper = GMStepper(frame: view.bounds)
                stepper.minimumValue = 1
                stepper.value = Double(weight)
                stepper.buttonsBackgroundColor = Cores.defaultLight
                stepper.buttonsFont = .boldSystemFont(ofSize: 15)
                stepper.labelBackgroundColor = Cores.aplicativo
                stepper.labelFont = .systemFont(ofSize: 15)
                stepper.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                stepper.addTarget(self, action: #selector(self.stepperValueChanged(sender:)), for: .valueChanged)
                view.addSubview(stepper)
                self.accessoryView = view
            }
        }
    }

    fileprivate struct Attributes {
        static let first = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.black]
        static let second = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.black]
    }

    @objc fileprivate func stepperValueChanged(sender: GMStepper) {
        delegate?.weightedAverageTableViewCellDidStepperChanged(data: data, newWeight: Int(sender.value))
    }
}

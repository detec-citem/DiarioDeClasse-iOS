//
//  AverageTableViewCell.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 15/02/17.
//  Copyright © 2017 PRODESP. All rights reserved.
//

import UIKit

final class AverageTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet fileprivate weak var averageLabel: UILabel!
    @IBOutlet fileprivate weak var averageTitleLabel: UILabel!
    @IBOutlet fileprivate weak var downButton: UIButton!
    @IBOutlet fileprivate weak var reloadButton: UIButton!
    @IBOutlet fileprivate weak var studentNameLabel: UILabel!
    @IBOutlet fileprivate weak var upButton: UIButton!
    
    //MARK: Variables
    weak var delegate: AverageTableViewCellDelegate?
    var averageItem: AverageViewController.AverageItem? {
        didSet {
            configureCell()
        }
    }

    //MARK: - Actions
    @IBAction fileprivate func up() {
        delegate?.averageTableViewCellButtonUpClicked(averageItem: averageItem)
    }

    @IBAction fileprivate func down() {
        delegate?.averageTableViewCellButtonDownClicked(averageItem: averageItem)
    }

    @IBAction fileprivate func reload() {
        delegate?.averageTableViewCellButtonReloadClicked(averageItem: averageItem)
    }
    
    //MARK: Methods
    fileprivate func configureCell() {
        if let aluno = averageItem?.student {
            let attributesName = NSMutableAttributedString(string: String(aluno.numeroChamada) + " - ", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 16)])
            attributesName.append(NSAttributedString(string: aluno.nome.uppercased(), attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 12)]))
            studentNameLabel.attributedText = attributesName
            let ativo = aluno.alunoAtivo()
            downButton.isEnabled = ativo
            reloadButton.isEnabled = ativo
            upButton.isEnabled = ativo
            if ativo {
                averageLabel.textColor = .darkGray
                averageTitleLabel.textColor = .black
                downButton.tintColor = Cores.aplicativo
                reloadButton.tintColor = Cores.aplicativo
                studentNameLabel.textColor = .black
                upButton.tintColor = Cores.aplicativo
            }
            else {
                averageLabel.textColor = .lightGray
                averageTitleLabel.textColor = .lightGray
                downButton.tintColor = .darkGray
                reloadButton.tintColor = .darkGray
                studentNameLabel.textColor = .lightGray
                upButton.tintColor = .darkGray
            }
        }
        if let valor = averageItem?.roundedValue {
            if valor > 0 {
                averageLabel.text = String(valor.roundToDecimal(digits: 2))
            }
            else {
                averageLabel.text = "---"
            }
        }
    }
}

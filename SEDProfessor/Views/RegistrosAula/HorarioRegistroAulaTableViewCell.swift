//
//  HorarioRegistroAulaTableViewCell.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 19/09/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import UIKit

final class HorarioRegistroAulaTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet fileprivate weak var horarioLabel: UILabel!
    @IBOutlet fileprivate weak var checkbox: VKCheckbox!
    
    //MARK: Variables
    fileprivate var aula: Aula!
    fileprivate var indice: Int!
    var selecionada: Bool! {
        didSet {
            animarCheckBox()
        }
    }
    
    //MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        checkbox.line = .thin
        checkbox.bgColorSelected = Cores.defaultApp
        checkbox.bgColor = .white
        checkbox.borderColor = Cores.defaultApp
        checkbox.borderWidth = 2
        checkbox.color = .white
        checkbox.cornerRadius = 12
    }
    
    //MARK: Methods
    fileprivate func animarCheckBox() {
        checkbox.setOn(selecionada, animated: true)
    }
    
    func configurarCelula(aula: Aula, temLancamento: Bool, indice: Int) {
        self.aula = aula
        self.indice = indice
        horarioLabel.text = aula.inicioHora + " ás " + aula.fimHora
        if temLancamento {
            contentView.backgroundColor = Cores.fundoDiaComLancamento
        }
        else {
            contentView.backgroundColor = .white
        }
    }
}

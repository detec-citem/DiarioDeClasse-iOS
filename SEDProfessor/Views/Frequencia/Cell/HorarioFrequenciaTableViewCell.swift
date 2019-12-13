//
//  HorarioTableViewCell.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 19/09/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import UIKit

final class HorarioFrequenciaTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet fileprivate weak var editarButton: UIButton!
    @IBOutlet fileprivate weak var excluirButton: UIButton!
    @IBOutlet fileprivate weak var horarioLabel: UILabel!
    @IBOutlet fileprivate weak var checkbox: VKCheckbox!
    
    //MARK: Variables
    fileprivate weak var delegate: HorariosFrequenciaDelegate!
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
    
    //MARK: Actions
    @IBAction func editarFrequencia(_ sender: Any) {
        delegate.editarFrequencia(aula: aula)
    }
    
    @IBAction func excluirFrequencia() {
        delegate.excluirFrequencia(aula: aula, indice: indice)
    }
    
    //MARK: Methods
    fileprivate func animarCheckBox() {
        checkbox.setOn(selecionada, animated: true)
    }
    
    func configurarCelula(aula: Aula, temLancamento: Bool, indice: Int, delegate: HorariosFrequenciaDelegate) {
        self.aula = aula
        self.indice = indice
        self.delegate = delegate
        editarButton.isHidden = !temLancamento
        excluirButton.isHidden = !temLancamento
        horarioLabel.text = aula.inicioHora + "-" + aula.fimHora
        if temLancamento {
            contentView.backgroundColor = Cores.fundoDiaComLancamento
        }
        else {
            contentView.backgroundColor = .white
        }
    }
}

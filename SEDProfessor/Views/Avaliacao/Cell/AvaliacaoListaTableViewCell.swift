//
//  AvaliacaoListaTableViewCell.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 21/12/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import UIKit

final class AvaliacaoTableViewCell: UITableViewCell {
    //MARK: Outlets
    @IBOutlet fileprivate weak var nomeLabel: UILabel!
    @IBOutlet fileprivate weak var dataLabel: UILabel!
    @IBOutlet fileprivate weak var tipoAvaliacaoLabel: UILabel!
    
    //MARK: Variables
    weak var delegate: AvaliacaoDelegate!
    var indice: Int!
    var avaliacao: Avaliacao! {
        didSet {
            configureCell()
        }
    }

    //MARK: Actions
    @IBAction func editarAvaliacao(_ sender: Any) {
        delegate.editarAvaliacao(avaliacao: avaliacao)
    }
    
    @IBAction func removerAvaliacao(_ sender: Any) {
        delegate.removerAvaliacao(indice: indice, avaliacao: avaliacao)
    }
    
    //MARK: Methods
    fileprivate func configureCell() {
        nomeLabel.text = avaliacao.nome
        dataLabel.text = avaliacao.dataCadastro
        switch avaliacao.codigoTipoAtividade
        {
        case AtividadeCodigo.avaliacao.rawValue:
            tipoAvaliacaoLabel.text = Atividade.Avaliacao.rawValue
        case AtividadeCodigo.atividade.rawValue:
            tipoAvaliacaoLabel.text = Atividade.Atividade.rawValue
        case AtividadeCodigo.trabalho.rawValue:
            tipoAvaliacaoLabel.text = Atividade.Trabalho.rawValue
        case AtividadeCodigo.outros.rawValue:
            tipoAvaliacaoLabel.text = Atividade.Outros.rawValue
        default:
            tipoAvaliacaoLabel.text = Atividade.Outros.rawValue
        }
    }
}

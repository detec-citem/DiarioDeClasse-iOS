//
//  AvaliacaoDelegate.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 13/12/18.
//  Copyright © 2018 PRODESP. All rights reserved.
//

import Foundation

protocol AvaliacaoDelegate: class {
    func editarAvaliacao(avaliacao: Avaliacao)
    func removerAvaliacao(indice: Int, avaliacao: Avaliacao)
}

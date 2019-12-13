//
//  AvaliarAplicativoDelegate.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 14/11/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import Foundation

protocol AvaliarAplicativoDelegate: class {
    func avaliouAplicativo(estrelas: Int)
    func avaliarMaisTarde()
    func nunca()
}

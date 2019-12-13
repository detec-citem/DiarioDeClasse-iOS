//
//  AvaliarAplicativoViewController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 14/11/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//
import Cosmos
import UIKit

final class AvaliarAplicativoViewController: ViewController {
    //MARK: Outlets
    @IBOutlet weak var estrelasView: CosmosView!
    
    //MARK: Variables
    weak var delegate: AvaliarAplicativoDelegate!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        estrelasView.didTouchCosmos = { estrelas in
            self.dismiss(animated: true)
            self.delegate.avaliouAplicativo(estrelas: Int(estrelas))
        }
    }
    
    //MARK: Actions
    @IBAction func avaliarMaisTarde() {
        dismiss(animated: true)
        delegate.avaliarMaisTarde()
    }
    
    @IBAction func nunca() {
        dismiss(animated: true)
        delegate.nunca()
    }
}

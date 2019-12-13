//
//  DetalhesAlunoController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 09/03/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import UIKit

final class DetalhesAlunoController: ViewController {
    //MARK: Outlets
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var nomeUsuarioLabel: UILabel!
    @IBOutlet fileprivate var nomeAlunoLabel: UILabel!

    //MARK: Variables
    var aluno: Aluno!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.alunoDetalhe.localized
        if let nomeCompleto = LoginRequest.usuarioLogado?.nome {
            nomeUsuarioLabel.text = nomeCompleto.uppercased()
        }
        let nomeAluno = aluno.nome
        if !nomeAluno.isEmpty {
            nomeAlunoLabel.text = nomeAluno.uppercased()
        }
        tableView.reloadData()
    }
}

//MARK: UITableViewDataSource
extension DetalhesAlunoController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: DetalhesAlunoTableViewCell = tableView.dequeue(index: indexPath) {
            cell.aluno = aluno
            return cell
        }
        return UITableViewCell()
    }
}

//
//  AlunosViewController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 29/06/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.
//

import UIKit

final class AlunosViewController: ViewController {
    //MARK: Outlets
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var nomeUsuarioLabel: UILabel!
    @IBOutlet fileprivate var serieDisciplinaLabel: UILabel!

    //MARK: Variables
    fileprivate var alunos: [Aluno]?
    var turmaSerie: String!
    var turmaSelecionada: Turma!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.alunos.localized
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        nomeUsuarioLabel.text = LoginRequest.usuarioLogado!.nome.uppercased()
        serieDisciplinaLabel.text = turmaSerie.uppercased()
        let alunosSet = turmaSelecionada.alunos as? Set<Aluno>
        if alunosSet == nil {
            tableView.allowsSelection = false
        }
        else {
            alunos = alunosSet?.sorted {
                return $0.numeroChamada < $1.numeroChamada
            }
            tableView.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.DetalhesAluno.rawValue, let detalhesAlunoController = segue.destination as? DetalhesAlunoController, let indexPath = sender as? IndexPath {
            detalhesAlunoController.aluno = alunos?[indexPath.row]
        }
    }
}

//MARK: UITableViewDataSource
extension AlunosViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if let alunos = alunos, !alunos.isEmpty {
            return alunos.count
        }
        return .zero
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let alunos = alunos, let cell: AlunoTableViewCell = tableView.dequeue(index: indexPath) {
            cell.aluno = alunos[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
}

//MARK: UITableViewDelegate
extension AlunosViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Segue.DetalhesAluno.rawValue, sender: indexPath)
    }
}

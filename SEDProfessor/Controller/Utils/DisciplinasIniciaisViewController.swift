//
//  DisciplinasIniciaisViewController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 06/11/18.
//  Copyright © 2018 PRODESP. All rights reserved.
//

import UIKit

final class DisciplinasIniciaisViewController: ViewController {
    //MARK: Constants
    fileprivate struct Constants {
        static let disciplinaTableViewCell = "DisciplinaTableViewCell"
    }
    
    //MARK: Outlets
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    //MARK: Variables
    fileprivate var disciplinas: [Disciplina]!
    weak var delegate: DisciplinasIniciaisDelegate!
    var primeiraVez: Bool!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        disciplinas = DisciplinaDao.disciplinasAnosIniciais()?.sorted(by: { (disciplina1, disciplina2) -> Bool in
            return disciplina1.nome < disciplina2.nome
        })
        tableView.reloadData()
    }
    
    //MARK: Actions
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
        if primeiraVez, let navigationController = presentingViewController as? UINavigationController {
            navigationController.popViewController(animated: true)
        }
    }
}

//MARK: UITableViewDataSource
extension DisciplinasIniciaisViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return disciplinas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.disciplinaTableViewCell, for: indexPath)
        cell.textLabel?.text = disciplinas[indexPath.row].nome
        return cell
    }
}

//MARK: UITableViewDelegate
extension DisciplinasIniciaisViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let disciplina = disciplinas[indexPath.row]
        if delegate.podeSelecionar(disciplina: disciplina) {
            delegate.selecionouDisciplina(disciplina: disciplina)
            dismiss(animated: true)
        }
    }
}

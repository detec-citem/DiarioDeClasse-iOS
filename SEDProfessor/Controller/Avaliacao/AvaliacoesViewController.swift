//
//  AvaliacoesViewController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 18/12/18.
//  Copyright © 2018 PRODESP. All rights reserved.
//

import UIKit

final class AvaliacoesViewController: ViewController {
    //MARK: Constants
    fileprivate struct Constants {
        static let avaliacaoTableViewCell = "AvaliacaoTableViewCell"
        static let tiposAvaliacao = [Atividade.Todas.rawValue, Atividade.Avaliacao.rawValue, Atividade.Trabalho.rawValue, Atividade.Atividade.rawValue, Atividade.Outros.rawValue]
    }
    
    //MARK: Outlets
    @IBOutlet weak var avaliacoesTableView: UITableView!
    
    //MARK: Variables
    weak var delegate: AvaliacoesDelegate!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        avaliacoesTableView.reloadData()
    }
    
    //MARK: Actions
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
}

//MARK: UITableViewDataSource
extension AvaliacoesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.avaliacaoTableViewCell, for: indexPath)
        cell.textLabel?.text = Constants.tiposAvaliacao[indexPath.row]
        return cell
    }
}

//MARK: UITableViewDelegate
extension AvaliacoesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.selecionouAvaliacao(avaliacao: Constants.tiposAvaliacao[indexPath.row])
        dismiss(animated: true)
    }
}

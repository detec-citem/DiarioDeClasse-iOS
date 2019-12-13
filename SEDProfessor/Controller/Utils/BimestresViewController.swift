//
//  BimestresViewController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 18/12/18.
//  Copyright © 2018 PRODESP. All rights reserved.
//

import UIKit

final class BimestresViewController: ViewController {
    //MARK: Constants
    fileprivate struct Constants {
        static let bimestreTableViewCell = "BimestreTableViewCell"
    }
    
    //MARK: Outlets
    @IBOutlet fileprivate weak var bimestresTableView: UITableView!
    
    //MARK: Variables
    fileprivate lazy var bimestres = [Bimestre]()
    weak var delegate: BimestreDelegate!
    var disciplina: Disciplina!
    var turma: Turma!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let bimestres = BimestreDao.todosBimestres(disciplina: disciplina, turma: turma) {
            self.bimestres = bimestres
            bimestresTableView.reloadData()
        }
    }
    
    //MARK: Actions
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
}

//MARK: UITableViewDataSource
extension BimestresViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bimestres.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.bimestreTableViewCell, for: indexPath)
        cell.textLabel?.text = String(bimestres[indexPath.row].id)
        return cell
    }
}

//MARK: UITableViewDelegate
extension BimestresViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.selecionouBimestre(bimestre: bimestres[indexPath.row])
        dismiss(animated: true)
    }
}

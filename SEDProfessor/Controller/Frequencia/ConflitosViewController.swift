//
//  ConflitosViewController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 22/09/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import UIKit

final class ConflitosViewController: ViewController {
    //MARK: Constants
    fileprivate struct Constants {
        static let conflitoTableViewCell = "ConflitoTableViewCell"
    }
    
    //MARK: Outlets
    @IBOutlet fileprivate weak var horariosConflitoTableView: UITableView!
    
    //MARK: Variables
    fileprivate lazy var horariosConflito = [HorarioConflito]()
    var diasConflito: [DiaConflito]!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        diasConflito.sort { (diaConflito1, diaConflito2) -> Bool in
            if let dataDiaConflito1 = DateFormatter.dataDateFormatter.date(from: diaConflito1.dia), let dataDiaConflito2 = DateFormatter.dataDateFormatter.date(from: diaConflito2.dia) {
                return dataDiaConflito1 < dataDiaConflito2
            }
            return false
        }
        for diaConflito in diasConflito {
            if var horariosConflito = diaConflito.horarios.allObjects as? [HorarioConflito] {
                horariosConflito.sort { (horarioConflito1, horarioConflito2) -> Bool in
                    if let horario1 = DateFormatter.horarioFormatter.date(from: horarioConflito1.horario), let horario2 = DateFormatter.horarioFormatter.date(from: horarioConflito2.horario) {
                        return horario1 < horario2
                    }
                    return false
                }
                self.horariosConflito.append(contentsOf: horariosConflito)
            }
        }
        horariosConflitoTableView.reloadData()
    }
    
    //MARK: Actions
    @IBAction func sair(_ sender: Any) {
        dismiss(animated: true)
    }
}

//MARK: UITableViewDataSource
extension ConflitosViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return horariosConflito.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let horarioConflito = horariosConflito[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.conflitoTableViewCell, for: indexPath)
        cell.textLabel?.text = String(format: Localization.detalheConflito.localized, horarioConflito.diaConflito.dia, horarioConflito.horario)
        return cell
    }
}

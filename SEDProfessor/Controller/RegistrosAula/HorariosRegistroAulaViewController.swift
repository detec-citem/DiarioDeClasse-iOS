//
//  HorariosRegistroAulaViewController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 23/11/18.
//  Copyright © 2018 PRODESP. All rights reserved.
//

import MBProgressHUD
import UIKit

final class HorariosRegistroAulaViewController: ViewController {
    //MARK: Outlets
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var okBarButtonItem: UIBarButtonItem!
    
    //MARK: Variables
    fileprivate lazy var selecionadas = [Bool]()
    fileprivate lazy var temLancamento = [Bool]()
    weak var delegate: HorariosRegistroAulaDelegate!
    var primeiraVez: Bool!
    var diaLetivo: DiaLetivo!
    var disciplina: Disciplina!
    var turma: Turma!
    var aulas: [Aula]!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let numeroDeAulas = aulas.count
        selecionadas.reserveCapacity(numeroDeAulas)
        temLancamento.reserveCapacity(numeroDeAulas)
        aulas.sort(by: { (aula1, aula2) -> Bool in
            return aula1.inicioHora < aula2.inicioHora
        })
        for aula in aulas {
            selecionadas.append(false)
            if let dataAula = DateFormatter.dataDateFormatter.date(from: diaLetivo.dataAula) {
                let temFaltas = RegistroAulaDao.temRegistro(data: dataAula, aula: aula, bimestre: diaLetivo.bimestre, disciplina: disciplina, turma: turma)
                temLancamento.append(temFaltas)
            }
        }
        tableView.reloadData()
    }
    
    //MARK: Actions
    @IBAction func sair(_ sender: Any) {
        dismiss(animated: true)
        if primeiraVez, let navigationController = presentingViewController as? UINavigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    @IBAction func selecionouAulas(_ sender: Any) {
        let numeroAulas = selecionadas.count
        var aulasSelecionadas = [Aula]()
        for i in 0 ..< numeroAulas {
            if selecionadas[i] {
                aulasSelecionadas.append(aulas[i])
            }
        }
        dismiss(animated: true) {
            self.delegate.selecionouAulas(aulas: aulasSelecionadas)
        }
    }
}

//MARK: HorariosDelegate
extension HorariosRegistroAulaViewController: HorariosRegistroAulaDelegate {
    func selecionouAulas(aulas: [Aula]) {
    }
}

//MARK: UITableViewDataSource
extension HorariosRegistroAulaViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aulas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: HorarioRegistroAulaTableViewCell = tableView.dequeue(index: indexPath) {
            let indice = indexPath.row
            let aula = aulas[indice]
            let temLancamentoNoHorario = temLancamento[indice]
            cell.configurarCelula(aula: aula, temLancamento: temLancamentoNoHorario, indice: indice)
            return cell
        }
        return UITableViewCell()
    }
}

//MARK: UITableViewDelegate
extension HorariosRegistroAulaViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let linha = indexPath.row
        let selecionada = !selecionadas[linha]
        selecionadas[linha] = selecionada
        let cell = tableView.cellForRow(at: indexPath) as? HorarioRegistroAulaTableViewCell
        cell?.selecionada = selecionada
        var habilitarBotao = false
        if selecionada {
            habilitarBotao = true
        }
        else {
            for selecionada in selecionadas {
                if selecionada {
                    habilitarBotao = true
                    break
                }
            }
        }
        okBarButtonItem.isEnabled = habilitarBotao
    }
}

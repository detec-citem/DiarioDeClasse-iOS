//
//  FrequenciaConsultaViewController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 11/05/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import UIKit

final class FrequenciaConsultaViewController: ViewController {
    //MARK: Constants
    fileprivate struct Constants {
        static let frequenciaConsultaTableViewHeader = "FrequenciaConsultaTableViewHeader"
    }
    
    //MARK: Outlets
    @IBOutlet fileprivate var tableView: UITableView!

    //MARK: Variables
    fileprivate var periodoSelecionado: String?
    fileprivate var headerTitleLabel: UILabel?
    fileprivate var headerTextField: UITextField?
    fileprivate var alunos: [Aluno]!
    var turmaSerie: String!
    var turmaSelecionada: Turma!
    var disciplinaSelecionada: Disciplina!

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "FREQUÊNCIA - CONSULTA"
        if let alunos = turmaSelecionada.alunos as? Set<Aluno> {
            self.alunos = alunos.sorted(by: { (aluno1, aluno2) -> Bool in
                return aluno1.numeroChamada < aluno2.numeroChamada
            })
        }
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.tableViewScrollToTop(animated: true)
    }
}

//MARK: InputViewDelegate
extension FrequenciaConsultaViewController: InputViewDelegate {
    func input(valor: String) {
        headerTextField?.text = valor
        headerTextField?.resignFirstResponder()
        periodoSelecionado = valor
        tableView.tableViewScrollToTop(animated: true)
    }

    func inputCancelou() {
        headerTextField?.resignFirstResponder()
    }
}

//MARK: UITableViewDataSource
extension FrequenciaConsultaViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return alunos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aluno = alunos[indexPath.row]
        let chamada = aluno.numeroChamada
        let cell = tableView.dequeueReusableCell(withIdentifier: FrequenciaConsultaTableViewCell.className, for: indexPath) as! FrequenciaConsultaTableViewCell
        cell.alunoLabel.text = "\(chamada) - \(aluno.nome)".uppercased()
        cell.alunoLabel.setFont(font: .boldSystemFont(ofSize: 16), to: "\(chamada)")
        if let periodoSelecionado = periodoSelecionado, !periodoSelecionado.isEmpty {
            var faltas = UInt32()
            if let faltasModel = TotalFaltasAlunoDao.buscarFaltas(aluno: aluno, disciplina: disciplinaSelecionada)?.first {
                switch periodoSelecionado
                {
                case FaltasPeriodo.Anual.rawValue:
                    faltas = faltasModel.faltasAnuais
                case FaltasPeriodo.Bimestral.rawValue:
                    faltas = faltasModel.faltasBimestrais
                default:
                    break
                }
            }
            cell.faltaLabel.text = String(faltas)
        }
        return cell
    }
}

//MARK: UITableViewDelegate
extension FrequenciaConsultaViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: Constants.frequenciaConsultaTableViewHeader)
        header?.contentView.backgroundColor = .groupTableViewBackground
        headerTitleLabel = header?.viewWithTag(1) as? UILabel
        if let turmaSerie = turmaSerie, !turmaSerie.isEmpty {
            headerTitleLabel?.text = "\(#imageLiteral(resourceName: "escola")) \(turmaSerie.uppercased())"
        }
        else {
            headerTitleLabel?.text = "\(#imageLiteral(resourceName: "escola")) ---"
        }
        var periodo = FaltasPeriodo.Anual.rawValue
        if let periodoSelecionado = periodoSelecionado, !periodoSelecionado.isEmpty {
            periodo = periodoSelecionado
        }
        headerTextField = header?.viewWithTag(3) as? UITextField
        headerTextField?.text = periodo
        headerTextField?.textColor = Cores.defaultApp
        headerTextField?.inputView = InputView(comLista: [FaltasPeriodo.Anual.rawValue, FaltasPeriodo.Bimestral.rawValue, FaltasPeriodo.Sequencial.rawValue], delegate: self)
        return header?.contentView
    }
}

//MARK: UITextFieldDelegate
extension FrequenciaConsultaViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_: UITextField) {
        periodoSelecionado = nil
    }
}

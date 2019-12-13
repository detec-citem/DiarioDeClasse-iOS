//
//  RegistroAulaViewController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 21/08/15.
//  Copyright (c) 2019 PRODESP. All rights reserved.
//

import MZFormSheetPresentationController
import UIKit

final class RegistroAulaViewController: ViewController {
    //MARK: Constants
    fileprivate struct Constants {
        static let primeiro = "1º"
        static let segundo = "2º"
        static let terceiro = "3º"
        static let quarto = "4º"
        static let maximoCaracteresObservacao = 500
        static let calendarioNavigationController = "CalendarioNavigationController"
    }
    
    //MARK: Outlets
    @IBOutlet fileprivate weak var bimestreLabel: UILabel!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var bimestresCollectionView: UICollectionView!
    @IBOutlet fileprivate weak var descricaoTextView: UITextView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
    //MARK: Variables
    fileprivate lazy var primeiraVez = true
    fileprivate lazy var conteudos = [UInt32:[Conteudo]]()
    fileprivate lazy var arrayDadosBimestreCell = [String]()
    fileprivate lazy var habilidades = [Habilidade]()
    fileprivate lazy var habilidadeSelecionadas = [UInt32:[Habilidade]]()
    fileprivate var bimestreSelecionado: Bimestre!
    fileprivate var conteudoSelecionado: Conteudo?
    fileprivate var disciplinaAnosIniciais: Disciplina?
    fileprivate var grupo: Grupo!
    fileprivate var bimestres: [Bimestre]!
    fileprivate var registroAula: RegistroAula?
    lazy var frequencia = false
    var aulasSelecionadas: [Aula]!
    var bimestreAtual: Bimestre!
    var calendarioLetivo: [DiaLetivo]!
    var dataDeLancamento: Date!
    var diaLetivoSelecionado: DiaLetivo!
    var disciplinaSelecionada: Disciplina?
    var turmaSelecionada: Turma!
    var turmaSerie: String!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Localization.registroDeAulas.localized
        let backBarButton = UIBarButtonItem(image: UIImage(named: "back")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(back))
        backBarButton.imageInsets = UIEdgeInsets(top: 2, left: -8, bottom: .zero, right: .zero)
        navigationItem.leftBarButtonItem = backBarButton
        arrayDadosBimestreCell.reserveCapacity(4)
        arrayDadosBimestreCell.append(Constants.primeiro)
        arrayDadosBimestreCell.append(Constants.segundo)
        arrayDadosBimestreCell.append(Constants.terceiro)
        arrayDadosBimestreCell.append(Constants.quarto)
        if !frequencia {
            dataDeLancamento = Date()
        }
        if let disciplinaSelecionada = disciplinaSelecionada {
            bimestres = BimestreDao.todosBimestres(disciplina: disciplinaSelecionada, turma: turmaSelecionada)
            bimestreSelecionado = bimestres.first
            bimestresCollectionView.selectItem(at: IndexPath(row: .zero, section: .zero), animated: true, scrollPosition: .top)
        }
        if disciplinaSelecionada?.disciplinaAnosIniciais() == true {
            disciplinaAnosIniciais = disciplinaSelecionada
            mudarDisciplinaInicial("")
        }
        else {
            navigationItem.rightBarButtonItem = nil
            carregarData()
        }
    }
    
    //MARK: Actions
    @IBAction func mudarDisciplinaInicial(_ sender: Any) {
        if let navigationController = storyboard?.instantiateViewController(withIdentifier: DisciplinasIniciaisViewController.className) as? UINavigationController, let disciplinasIniciaisViewController = navigationController.viewControllers.first as? DisciplinasIniciaisViewController {
            disciplinasIniciaisViewController.primeiraVez = primeiraVez
            disciplinasIniciaisViewController.delegate = self
            presentFormSheetViewController(viewController: navigationController)
        }
    }
    
    @IBAction fileprivate func registrarAula() {
        let dataString = DateFormatter.dataDateFormatter.string(from: dataDeLancamento)
        var registroAulaParaSalvar: RegistroAula!
        if let registroAula = registroAula {
            registroAulaParaSalvar = registroAula
        }
        else {
            registroAulaParaSalvar = CoreDataManager.sharedInstance.criarObjeto(tabela: Tabelas.registroAula)
            registroAulaParaSalvar.id = -1
        }
        registroAulaParaSalvar.enviado = false
        registroAulaParaSalvar.dataCriacao = dataString
        registroAulaParaSalvar.observacoes = descricaoTextView.text
        registroAulaParaSalvar.bimestre = bimestreAtual
        registroAulaParaSalvar.grupo = grupo
        registroAulaParaSalvar.turma = turmaSelecionada
        registroAulaParaSalvar.horarios = NSSet(array: aulasSelecionadas)
        var habilidadesSelecionadas = [Habilidade]()
        var habilidadesRegistroAula = [HabilidadeRegistroAula]()
        for bimestre in bimestres {
            if let conteudos = self.conteudos[bimestre.id] {
                for conteudo in conteudos {
                    if let habilidades = self.habilidadeSelecionadas[conteudo.id] {
                        for habilidade in habilidades {
                            habilidadesSelecionadas.append(habilidade)
                            let habilidadeRegistroAula = HabilidadeRegistroAulaDao.salvar(selecionada: true, habilidade: habilidade, registroAula: registroAulaParaSalvar)
                            habilidadesRegistroAula.append(habilidadeRegistroAula)
                        }
                    }
                }
            }
        }
        registroAulaParaSalvar.habilidadesRegistroAula = NSSet(array: habilidadesRegistroAula)
        RegistroAulaDao.salvar(insertRegistroAula: registroAulaParaSalvar)
        HabilidadeRegistroAulaDao.remover(registroAula: registroAulaParaSalvar, habilidades: habilidadesSelecionadas)
        CoreDataManager.sharedInstance.salvarBanco()
        let ok = UIAlertAction(title: Localization.ok.localized, style: .default, handler: { _ in
            if self.frequencia {
                self.navigationController?.popToRootViewController(animated: true)
            }
        })
        UIAlertController.criarAlerta(titulo: Localization.registroSalvo.localized, mensagem: Localization.sucessoRegistro.localized, estilo: .alert, acoes: [ok], alvo: self)
    }
    
    //MARK: Methods
    @objc fileprivate func back() {
        if conteudoSelecionado == nil {
            navigationController?.popViewController(animated: true)
        }
        else {
            mostrarConteudos()
        }
    }
    
    fileprivate func carregarHabilidades() {
        if let habilidadesConteudo = conteudoSelecionado?.habilidades as? Set<Habilidade> {
            titleLabel.text = Localization.habilidades.localized
            habilidades = habilidadesConteudo.sorted(by: { (habilidade1, habilidade2) -> Bool in
                return habilidade1.id < habilidade2.id
            })
        }
        tableView.reloadData()
    }
    
    fileprivate func carregarData() {
        if !frequencia {
            mostrarCalendario()
        }
        else {
            selecionouAulas(aulas: self.aulasSelecionadas)
        }
    }
 
    fileprivate func mostrarConteudos() {
        conteudoSelecionado = nil
        titleLabel.text = Localization.conteudos.localized
        tableView.reloadData()
    }
    
    fileprivate func mostrarCalendario() {
        if let calendarioNavigationController = storyboard?.instantiateViewController(withIdentifier: Constants.calendarioNavigationController) as? UINavigationController, let calendarioViewController = calendarioNavigationController.viewControllers.first as? CalendarioViewController {
            calendarioViewController.bimestreAtual = bimestreAtual
            calendarioViewController.calendarioLetivo = calendarioLetivo
            calendarioViewController.turmaSelecionada = turmaSelecionada
            calendarioViewController.delegate = self
            presentFormSheetViewController(viewController: calendarioNavigationController)
        }
    }
}

//MARK: CalendarioDelegate
extension RegistroAulaViewController: CalendarioDelegate {
    func cancelouSelecao() {
        navigationController?.popViewController(animated: true)
    }
    
    func podeSelecionar(diaLetivo: DiaLetivo) -> Bool {
        return true
    }
    
    func selecionouDiaLetivo(data: Date, diaLetivo: DiaLetivo) {
        if let disciplinaSelecionada = disciplinaSelecionada, let aulas = AulaDao.buscarAulas(bimestre: bimestreAtual, disciplina: disciplinaSelecionada, turma: turmaSelecionada), let horariosRegistroAulaNavigationController = storyboard?.instantiateViewController(withIdentifier: HorariosRegistroAulaViewController.className) as? UINavigationController, let horariosRegistroAulaViewController = horariosRegistroAulaNavigationController.viewControllers.first as? HorariosRegistroAulaViewController {
            horariosRegistroAulaViewController.primeiraVez = primeiraVez
            horariosRegistroAulaViewController.aulas = aulas
            horariosRegistroAulaViewController.diaLetivo = diaLetivo
            horariosRegistroAulaViewController.disciplina = disciplinaSelecionada
            horariosRegistroAulaViewController.turma = turmaSelecionada
            horariosRegistroAulaViewController.delegate = self
            presentFormSheetViewController(viewController: horariosRegistroAulaNavigationController)
        }
    }
    
    func temLancamentoNaData(data: Date) -> Bool {
        if let disciplinaSelecionada = disciplinaSelecionada {
            return RegistroAulaDao.temRegistro(data: data, bimestre: bimestreAtual, disciplina: disciplinaSelecionada, turma: turmaSelecionada)
        }
        return false
    }
}

//MARK: DisciplinasIniciaisDelegate
extension RegistroAulaViewController: DisciplinasIniciaisDelegate {
    func podeSelecionar(disciplina: Disciplina) -> Bool {
        return true
    }
    
    func selecionouDisciplina(disciplina: Disciplina) {
        primeiraVez = false
        disciplinaSelecionada = disciplina
        if primeiraVez {
            if !frequencia {
                tableView.reloadData()
            }
            else {
                carregarData()
            }
        }
        else {
            selecionouAulas(aulas: self.aulasSelecionadas)
        }
    }
}

//MARK: HorariosRegistroAulaDelegate
extension RegistroAulaViewController: HorariosRegistroAulaDelegate {
    func selecionouAulas(aulas: [Aula]) {
        aulasSelecionadas = aulas
        if let dataDeLancamento = dataDeLancamento, let discplinaSelecionada = disciplinaSelecionada {
            registroAula = RegistroAulaDao.acessarRegistroAula(data: dataDeLancamento, bimestre: bimestreAtual, discplina: discplinaSelecionada, turma: turmaSelecionada, aulas: aulas)
            descricaoTextView.text = registroAula?.observacoes
            if let disciplina = disciplinaSelecionada {
                grupo = GrupoDao.buscarGrupos(serie: turmaSelecionada.serie, codigoTipoEnsino: turmaSelecionada.codigoTipoEnsino, disciplina: disciplina)?.first
            }
            if conteudos.isEmpty {
                conteudos.reserveCapacity(bimestres.count)
            }
            conteudos.removeAll(keepingCapacity: true)
            habilidadeSelecionadas.removeAll(keepingCapacity: false)
            for bimestre in bimestres {
                if let conteudosDoBimestre = ConteudoDao.conteudos(bimestre: bimestre, grupo: grupo) {
                    conteudos[bimestre.id] = conteudosDoBimestre
                    if let habilidadesRegistroAula = registroAula?.habilidadesRegistroAula as? Set<HabilidadeRegistroAula> {
                        for conteudo in conteudosDoBimestre {
                            let codigoConteudo = conteudo.id
                            for habilidadeRegistroAula in habilidadesRegistroAula {
                                let habilidade = habilidadeRegistroAula.habilidade
                                if !habilidadeSelecionadas.keys.contains(codigoConteudo) {
                                    habilidadeSelecionadas[codigoConteudo] = [Habilidade]()
                                }
                                habilidadeSelecionadas[codigoConteudo]?.append(habilidade)
                            }
                        }
                    }
                }
            }
            carregarHabilidades()
        }
    }
}

//MARK: UICollectionViewDataSource
extension RegistroAulaViewController: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return arrayDadosBimestreCell.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell: BimestreCollectionViewCell = collectionView.dequeue(index: indexPath) {
            cell.bimestre = arrayDadosBimestreCell[indexPath.item]
            return cell
        }
        return UICollectionViewCell()
    }
}

//MARK: UICollectionViewDelegate
extension RegistroAulaViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = indexPath.item
        bimestreSelecionado = bimestres[item]
        bimestreLabel.text = Localization.bimestreSelecionado.localized + String(item + 1)
        mostrarConteudos()
    }
}

//MARK: UITableViewDataSource
extension RegistroAulaViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if conteudoSelecionado == nil, let conteudosDoBimestre = conteudos[bimestreSelecionado.id] {
            return conteudosDoBimestre.count
        }
        return habilidades.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let linha = indexPath.row
        if conteudoSelecionado == nil, let conteudosDoBimestre = conteudos[bimestreSelecionado.id], let cell: ConteudoTableViewCell = tableView.dequeue(index: indexPath) {
            var selecionado = false
            let conteudo = conteudosDoBimestre[linha]
            let codigoConteudo = conteudo.id
            if habilidadeSelecionadas.keys.contains(codigoConteudo), let habilidades1 = habilidadeSelecionadas[codigoConteudo], let habilidades2 = conteudo.habilidades as? Set<Habilidade>, !habilidades1.isEmpty {
                for habilidade1 in habilidades1 {
                    for habilidade2 in habilidades2 {
                        if habilidade1.id == habilidade2.id {
                            selecionado = true
                            break
                        }
                    }
                    if selecionado {
                        break
                    }
                }
            }
            cell.configurarCelula(selecionado: selecionado, row: linha, conteudo: conteudo)
            return cell
        }
        if let conteudoSelecionado = conteudoSelecionado, let cell: HabilidadeTableViewCell = tableView.dequeue(index: indexPath) {
            var selecionada = false
            let habilidade = habilidades[linha]
            if let habilidadesSelecionadas = habilidadeSelecionadas[conteudoSelecionado.id] {
                for habilidadeSelecionada in habilidadesSelecionadas {
                    if habilidadeSelecionada.id == habilidade.id {
                        selecionada = true
                        break
                    }
                }
            }
            cell.configurarCelula(selecionada: selecionada, row: linha, habilidade: habilidade)
            return cell
        }
        return UITableViewCell()
    }
}

//MARK: UITableViewDelegate
extension RegistroAulaViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let linha = indexPath.row
        if conteudoSelecionado == nil, let conteudosDoBimestre = conteudos[bimestreSelecionado.id] {
            conteudoSelecionado = conteudosDoBimestre[linha]
            carregarHabilidades()
        }
        else if let conteudoSelecionado = conteudoSelecionado, let cell = tableView.cellForRow(at: indexPath) {
            var selecionada = false
            var indice: Int = .zero
            let codigoConteudo = conteudoSelecionado.id
            let habilidade = habilidades[linha]
            if let habilidadesSelecionadas = habilidadeSelecionadas[codigoConteudo] {
                for habilidadeSelecionada in habilidadesSelecionadas {
                    if habilidadeSelecionada.id == habilidade.id {
                        selecionada = true
                        break
                    }
                    indice += 1
                }
            }
            if selecionada {
                habilidadeSelecionadas[codigoConteudo]?.remove(at: indice)
                cell.accessoryType = .none
            }
            else {
                if !habilidadeSelecionadas.keys.contains(codigoConteudo) {
                    habilidadeSelecionadas[codigoConteudo] = [Habilidade]()
                }
                habilidadeSelecionadas[codigoConteudo]?.append(habilidade)
                cell.accessoryType = .checkmark
            }
        }
    }
}

//MARK: UITextViewDelegate
extension RegistroAulaViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= Constants.maximoCaracteresObservacao
    }
}

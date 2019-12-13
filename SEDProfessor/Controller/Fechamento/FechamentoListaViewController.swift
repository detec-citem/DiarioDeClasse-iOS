//
//  FechamentoListaViewController.swift
//  SEDProfessor
//
//  Created by Richard on 06/01/17.
//  Copyright © 2017 PRODESP. All rights reserved.
//

import UIKit

final class FechamentoListaViewController: ViewController {
    //MARK: Constants
    fileprivate struct Constants {
        static let carouselImage = "carousel-50"
        static let listaImage = "lista"
    }
    
    //MARK: Outlets
    @IBOutlet fileprivate var backButton: UIBarButtonItem!
    @IBOutlet fileprivate var containerHeaderView: UIView!
    @IBOutlet fileprivate var finishButton: UIBarButtonItem!
    @IBOutlet fileprivate var nextButton: UIBarButtonItem!
    @IBOutlet fileprivate var scrollView: UIScrollView!
    @IBOutlet fileprivate var serieDisciplinaLabel: UILabel!
    @IBOutlet fileprivate var tableView: UITableView!

    //MARK: Variables
    fileprivate lazy var isSyncFinished = false
    fileprivate lazy var indexAlunoSelecionado: Int = 1
    fileprivate lazy var numeroAlunosAtivos: Int = .zero
    fileprivate lazy var numeroUltimoAluno = UInt16.max
    fileprivate lazy var listaViewsAlunos = [AlunoFechamentoView]()
    fileprivate var alunos: [Aluno]!
    fileprivate lazy var listButton = UIBarButtonItem()
    fileprivate lazy var screenWidth = view.frame.size.width
    var turmaSerie: String!
    var bimestreAtual: Bimestre!
    var disciplinaSelecionada: Disciplina!
    var fechamentoTurma: FechamentoTurma!
    var tipoTurma: TipoTela!
    var turmaSelecionada: Turma!

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Localization.fechamentoLancamento.localized
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 13), NSAttributedString.Key.foregroundColor: UIColor.white]
        scrollView.bounces = true
        containerHeaderView.backgroundColor = .groupTableViewBackground
        containerHeaderView.setShadow(enable: true)
        backButton.title = Localization.anterior.localized
        finishButton.title = Localization.finalizar.localized
        serieDisciplinaLabel.text = turmaSerie.uppercased()
        UIViewController.showButtonItem(buttons: [finishButton, backButton], isShow: false)
        UIViewController.set(buttons: [backButton, finishButton, nextButton], font: .boldSystemFont(ofSize: 12))
        setupListButton(type: .vertical)
        if var alunos = turmaSelecionada.alunos.allObjects as? [Aluno], !alunos.isEmpty {
            alunos.sort(by: { (aluno1, aluno2) in
                aluno1.numeroChamada < aluno2.numeroChamada
            })
            numeroUltimoAluno = alunos.last!.numeroChamada
            self.alunos = alunos
        }
        for aluno in alunos {
            if aluno.alunoAtivo() {
                numeroAlunosAtivos += 1
            }
        }
        setNextButton(isList: false, isHidden: false)
        listButton.isEnabled = !alunos.isEmpty
        for view in scrollView.subviews {
            if view is AlunoFrequenciaView {
                view.removeFromSuperview()
            }
        }
        listaViewsAlunos.removeAll()
        updateUI()
    }

    //MARK: Actions
    @IBAction fileprivate func goBack() {
        indexAlunoSelecionado -= 1
        back(hasClick: true)
    }

    @IBAction fileprivate func goNext() {
        indexAlunoSelecionado += 1
        next(hasClick: true)
    }

    @IBAction fileprivate func finalizar(sender _: UIBarButtonItem) {
        let sim = UIAlertAction(title: Localization.sim.localized, style: .default) { action in
//            let items = self.getItemsToSync()
//            if !items.items.isEmpty, let filter = items.filter {
//                Loading.showLoading(view: self.view)
//                Requests.startSyncProcess(withType: .fechamentos, fechamentoTurmaCurrentFilter: filter) { error in
//                    Loading.hideLoading(view: self.view)
//                    var action: UIAlertAction!
//                    var message: String!
//                    if let error = error, !error.isEmpty {
//                        message = error
//                        action = UIAlertAction(title: ButtonText.Ok.rawValue, style: .destructive, handler: nil)
//                    } else {
//                        message = MessageText.RealizadoComSucesso.rawValue
//                        action = UIAlertAction(title: ButtonText.Ok.rawValue, style: .default, handler: { [weak self] _ in
//                            self?.updateUI()
//                        })
//                    }
//                    UIAlertController.createAlert(title: TitleText.Lancamento.rawValue, message: message, style: .alert, actions: [action], target: self)
//                }
//            }
        }
        UIAlertController.criarAlerta(titulo: Localization.fechamento.localized, mensagem: Localization.confirmarLancamentoFechamento.localized, estilo: .alert, acoes: [UIAlertAction(title: Localization.nao.localized, style: .destructive, handler: nil), sim], alvo: self)
    }

    //MARK: Methods
    @objc fileprivate func iniciar() {
        indexAlunoSelecionado = 1
        scrollView.setContentOffset(.zero, animated: true)
        setupListButton(type: .vertical)
        setNextButton(isList: false, isHidden: false)
        setFinishButton(enable: false, isHidden: true)
    }

    @objc fileprivate func listar() {
        backButton.setHidden(hidden: true)
        setNextButton(isList: true, isHidden: true)
        setupListButton(type: .horizontal)
        var enable: Bool!
        var alunosAtivos = [Aluno]()
        for aluno in alunos {
            if aluno.alunoAtivo() {
                alunosAtivos.append(aluno)
            }
        }
        if !alunos.isEmpty {
            let fechamamentosAlunos = getItemsToSync().items.first?.fechamentosAlunos.allObjects as? [FechamentoAluno] ?? []
            if !fechamamentosAlunos.isEmpty && fechamamentosAlunos.count == alunos.count {
                enable = true
            }
        }
        else {
            enable = false
        }
        setFinishButton(enable: enable, isHidden: false)
        tableView.isHidden = false
        tableView.reloadData()
    }

    fileprivate func back(hasClick _: Bool, isTable _: Bool = false) {
        backButton.setHidden(hidden: false)
        if indexAlunoSelecionado != 1 {
            setNextButton(isList: false, isHidden: false)
            tableView.isHidden = true
        }
        else {
            backButton.setHidden(hidden: true)
        }
    }

    fileprivate func getItemsToSync() -> (items: [FechamentoTurma], filter: FilteredFechamentoCurrentToSync?) {
        var result: (items: [FechamentoTurma], filter: FilteredFechamentoCurrentToSync?) = ([], nil)
        let bimestre = fechamentoTurma.bimestre
        let turma = fechamentoTurma.turma
        let disciplina = fechamentoTurma.disciplina
        let serie = fechamentoTurma.serie
        let tipoFechamento = fechamentoTurma.tipoFechamento
        let filter: FilteredFechamentoCurrentToSync = (bimestre.id, turma.id, disciplina.id, serie, tipoFechamento.codigo)
        if let fechamentoTurma = FechamentoTurmaDao.buscarFechamento(id: "ID-" + String(bimestre.id) + "-" + String(disciplina.id) + "-" + String(serie) + "-" + String(tipoFechamento.codigo) + "-" + String(turma.id)) {
            result = ([fechamentoTurma], filter)
        }
        return result
    }

    fileprivate func next(hasClick: Bool, hasClickInStudent: Bool = false, isTable: Bool = false) {
        backButton.setHidden(hidden: false)
        if indexAlunoSelecionado == alunos.count {
            setNextButton(isList: true, isHidden: false)
        }
        else if indexAlunoSelecionado > alunos.count {
            listar()
        }
        if hasClick || isTable {
            if hasClickInStudent, indexAlunoSelecionado + 1 == alunos.count {
                setNextButton(isList: true, isHidden: false)
            }
            var index = indexAlunoSelecionado
            if !hasClickInStudent {
                index -= 1
            }
            DispatchQueue.main.async {
                self.scrollView.setContentOffset(CGPoint(x: CGFloat(index) * self.screenWidth, y: .zero), animated: true)
            }
        }
    }

    fileprivate func setFinishButton(enable: Bool, isHidden: Bool) {
        if isSyncFinished {
            finishButton.title = Localization.finalizado.localized
        }
        else {
            finishButton.title = Localization.finalizar.localized
        }
        finishButton.setHidden(hidden: isHidden)
        finishButton.isEnabled = enable
    }

    fileprivate func setNextButton(isList: Bool, isHidden: Bool) {
        nextButton.title = isList ? Localization.listar.localized : Localization.proximo.localized
        nextButton.setHidden(hidden: isHidden)
    }

    fileprivate func setAlunoSelecionado(index: Int?, isTable: Bool = false) {
        if let index = index {
            if index > indexAlunoSelecionado {
                indexAlunoSelecionado = index
                next(hasClick: false, isTable: isTable)
            }
            else if index < indexAlunoSelecionado {
                indexAlunoSelecionado = index
                back(hasClick: false, isTable: isTable)
            }
            if isTable && index == alunos.count {
                indexAlunoSelecionado = index
                setNextButton(isList: true, isHidden: false)
                backButton.setHidden(hidden: false)
            }
        }
    }

    fileprivate func setupListButton(type: TypeListButton) {
        listButton.tag = type.rawValue
        switch type {
        case .vertical:
            listButton = UIBarButtonItem(image: UIImage(named: Constants.listaImage), style: .plain, target: self, action: #selector(listar))
        default:
            listButton = UIBarButtonItem(image: UIImage(named: Constants.carouselImage), style: .plain, target: self, action: #selector(iniciar))
        }
        navigationItem.rightBarButtonItem = listButton
    }

    fileprivate func updateUI() {
        var i: Int = .zero
        for aluno in alunos {
            var totalFaltasAluno: TotalFaltasAluno?
            totalFaltasAluno = TotalFaltasAlunoDao.buscarFaltas(aluno: aluno, disciplina: disciplinaSelecionada)?.first
            var averageAluno: Average?
            let turmaId = turmaSelecionada.id
            let disciplinaId = disciplinaSelecionada.id
            let bimestreId = bimestreAtual.id
            let alunoId = aluno.id
            averageAluno = AverageDao.averageComId(id: "ID-\(alunoId)-\(bimestreId)-\(disciplinaId)-\(turmaId)")
            var fechamentoAluno: FechamentoAluno?
//            if let matricula = aluno.matricula, let fechamentoTurma = fechamentoTurmaModel?.fechamentoTurma {
//                fechamentoAluno = FechamentoAlunoModel.getData(predicate: NSPredicate(format: "id == %@", "ID-" + String(fechamentoTurma.id) + "-" + String(matricula)))?.first
//            }

            if listaViewsAlunos.count > i {
                listaViewsAlunos[i].set(fechamentoAluno: fechamentoAluno, averageAluno: averageAluno, totalFaltasAluno: totalFaltasAluno)
                listaViewsAlunos[i].set(aluno: aluno, count: numeroUltimoAluno)
            }
            else {
                let alunoView = AlunoFechamentoView(frame: CGRect(x: .zero, y: .zero, width: screenWidth, height: scrollView.frame.height))
                alunoView.backgroundColor = .clear
                alunoView.frame.origin.x = (screenWidth * CGFloat(i)) + ((screenWidth / 2) - (alunoView.frame.size.width / 2))
                alunoView.delegate = self

                if Utils.isDevice(device: .iPhone4s) {
                    alunoView.frame.origin.y = (scrollView.frame.size.height / 2) - (alunoView.frame.size.height / 2)
                }
                else {
                    alunoView.frame.origin.y = ((scrollView.frame.size.height / 2) - (alunoView.frame.size.height / 2)) - 40
                }

                alunoView.set(fechamentoAluno: fechamentoAluno, averageAluno: averageAluno, totalFaltasAluno: totalFaltasAluno)
                alunoView.set(aluno: aluno, count: numeroUltimoAluno)

                scrollView.addSubview(alunoView)
                listaViewsAlunos.append(alunoView)
            }
            i += 1
        }
        if let serverDate = fechamentoTurma.dateServer, !serverDate.isEmpty, let fechamentosAlunos = fechamentoTurma.fechamentosAlunos as? Set<FechamentoAluno>, !fechamentosAlunos.isEmpty, numeroAlunosAtivos == fechamentosAlunos.count {
            isSyncFinished = true
        }
        else {
            isSyncFinished = false
        }
        scrollView.contentSize = CGSize(width: screenWidth * CGFloat(self.alunos.count), height: .zero)
        scrollView.setContentOffset(.zero, animated: true)
        tableView.reloadData()
    }
}

//MARK: AlunoFechamentoDelegate
extension FechamentoListaViewController: AlunoFechamentoDelegate {
    func alunoFechamento(atribuiuFechamento: AlunoFechamentoView) {
        if let dataServer = fechamentoTurma.dateServer, !dataServer.isEmpty {
            fechamentoTurma.dateServer = nil
            FechamentoTurmaDao.salvar(fechamentoTurma: fechamentoTurma)
        }
//        if let aluno = atribuiuFechamento.getAluno() {
//             FechamentoAlunoModel.saveData(object: FechamentoAlunoModel(faltas: atribuiuFechamento.getFaltas(), faltasAcumuladas: atribuiuFechamento.getFaltasAcumuladas(), faltasCompensadas: atribuiuFechamento.getFaltasCompensadas(), nota: atribuiuFechamento.getNota(), aluno: aluno, fechamentoTurma: fechamentoTurma))
//        }
        CoreDataManager.sharedInstance.salvarBanco()
        if indexAlunoSelecionado != alunos.count {
            next(hasClick: true, hasClickInStudent: true)
            indexAlunoSelecionado += 1
        }
    }
}

//MARK: UITableViewDataSource
extension FechamentoListaViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return listaViewsAlunos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell: FechamentoTableViewCell = tableView.dequeue(index: indexPath) {
            cell.alunoFechamentoView = listaViewsAlunos[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
}

//MARK: UITableViewDelegate
extension FechamentoListaViewController: UITableViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if tableView.isHidden {
            setAlunoSelecionado(index: Int(round(scrollView.contentOffset.x / screenWidth)) + 1)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.isHidden = true
        backButton.setHidden(hidden: false)
        setNextButton(isList: false, isHidden: false)
        setFinishButton(enable: false, isHidden: true)
        setupListButton(type: .vertical)
        setAlunoSelecionado(index: indexPath.row + 1, isTable: true)
    }
}

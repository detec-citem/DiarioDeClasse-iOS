//
//  AverageViewController.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 14/02/17.
//  Copyright © 2017 PRODESP. All rights reserved.
//

import UIKit

protocol AverageViewControllerDelegate {
    func averageViewControllerFinishWithTimer()
}

final class AverageViewController: ViewController {
    //MARK: Types
    typealias AverageItem = (roundedValue: Float, average: Average, student: Aluno)
    typealias WeightedData = (id: Int32, evaluation: Avaliacao, weight: Int)
    
    //MARK: Constants
    fileprivate struct Constants {
        static let tableViewTag: Int = 1
        static let headerTableViewTag: Int = 2
        static let weightedTableViewTag: Int = 3
        static let bottomFirst: CGFloat = -162
        static let bottomSecond: CGFloat = .zero
        static let heightMinimum: CGFloat = 95
        static let heightGreater: CGFloat = height - (size.height * 67 / 100)
        static let heightGreateriPad: CGFloat = height - (size.height * 75 / 100)
        fileprivate static let height = size.height - 95
        fileprivate static let size = AvaliacaoViewController().view.frame.size
    }
    
    //MARK: Outlets
    @IBOutlet fileprivate weak var classLabel: UILabel!
    @IBOutlet fileprivate weak var disciplineLabel: UILabel!
    @IBOutlet fileprivate weak var averageTypeButton: UIButton!
    @IBOutlet fileprivate weak var headerView: UIView!
    @IBOutlet fileprivate weak var headerViewContraintHeight: NSLayoutConstraint!
    @IBOutlet fileprivate weak var tableHeaderView: UITableView!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var tableViewContraintBottom: NSLayoutConstraint!
    @IBOutlet fileprivate weak var weightedTableView: UITableView!
    @IBOutlet fileprivate weak var weightedViewConstraintBottom: NSLayoutConstraint!
    @IBOutlet fileprivate weak var weightedView: UIView!
    
    //MARK: Variables
    fileprivate lazy var headerViewIsExpanded = false
    fileprivate var averageItems: [AverageItem]?
    fileprivate var averageTypes: [AverageDao.AverageTypeModel]?
    fileprivate var weightedTableData: [WeightedData]?
    fileprivate var targetItem: UIViewController?
    fileprivate var selectedAverageType: AverageDao.AverageTypeModel?
    var delegate: AverageViewControllerDelegate?
    var bimestre: Bimestre!
    var disciplina: Disciplina!
    var turma: Turma!
    var avaliacoes: [Avaliacao]!
    
    fileprivate struct RowHeight {
        static let `default`: CGFloat = 80
        static let minor: CGFloat = 44
        static let defaultHeader: CGFloat = 30
    }

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Localization.medias.localized
        headerView.setShadow(enable: true)
        classLabel.text = turma.nome.uppercased()
        disciplineLabel.text = disciplina.nome.uppercased()
        tableHeaderView.separatorStyle = .none
        weightedTableView.backgroundColor = .clear
        setAverageTypeButton()
        setWeightedView()
        getData()
        tableView.reloadData()
    }
    
    //MARK: Actions
    @IBAction fileprivate func dismiss() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction fileprivate func chooseAverageTypeButtonClicked() {
        setHeaderViewExpanded()
    }

    @IBAction fileprivate func save() {
        if let averageItems = averageItems, !averageItems.isEmpty {
            var averageItemsFiltered: Int = .zero
            var roundedValues: Int = .zero
            for averageItem in averageItems {
                if averageItem.student.alunoAtivo() {
                    averageItemsFiltered += 1
                    let roundedValue = averageItem.roundedValue
                    if floor(roundedValue) == roundedValue && roundedValue <= 10 {
                        roundedValues += 1
                    }
                }
            }
            if averageItemsFiltered == roundedValues {
                for averageItem in averageItems {
                    setupAverage(student: averageItem.student, value: averageItem.roundedValue)
                }
                let alertController = UIAlertController(title: Localization.lancamento.localized + " ♨︎", message: Localization.realizadoComSucesso.localized, preferredStyle: UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet)
                present(alertController, animated: true, completion: nil)
                targetItem = alertController
                Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(dismissItemAndGoAway), userInfo: nil, repeats: false)
            }
            else {
                let alertController = UIAlertController(title: "Erro ⚠️", message: Localization.mediasNaoArredondadadas.localized, preferredStyle: UIDevice.current.userInterfaceIdiom == .pad ? .alert : .actionSheet)
                present(alertController, animated: true, completion: nil)
                targetItem = alertController
                Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(dismissItem), userInfo: nil, repeats: false)
            }
        }
    }
    
    @IBAction fileprivate func weightedViewDismiss() {
        weightedTableData = []
        selectedAverageType = AverageDao.AverageTypeModel(id: .weighted, name: .weighted)
        setWeightedView(animate: true) {
            self.setHeaderViewExpanded {
                self.calculateAverageTypeSelected()
            }
        }
    }

    @objc fileprivate func dismissItem() {
        targetItem?.dismiss(animated: true, completion: nil)
    }

    @objc fileprivate func calculateAverageTypeSelected() {
        getData(changedType: true)
        tableView.reloadData()
    }

    @objc fileprivate func dismissItemAndGoAway() {
        targetItem?.dismiss(animated: true, completion: nil)
        dismiss()
        delegate?.averageViewControllerFinishWithTimer()
    }

    fileprivate func setAverageTypeButton(type: TypeName? = nil) {
        var newType: TypeName?
        if type == nil, let averageTypeName = (turma.alunos as? Set<Aluno>)?.first?.average.selectedType {
            newType = TypeName(rawValue: averageTypeName)
        }
        else if let type = type {
            newType = type
        }
        else {
            newType = .arithmetic
        }
        averageTypeButton.setTitle(newType?.rawValue.uppercased(), for: .normal)
        var cor: UIColor!
        if headerViewIsExpanded {
            cor = Cores.confirmaNota
        }
        else {
            cor = Cores.aplicativo
        }
        averageTypeButton.setTitleColor(cor, for: .normal)
    }

    fileprivate func avaliacaoValida(evaluation: Avaliacao?) -> Bool {
        var count: Int = .zero
        var alunosAtivos: [Aluno]!
        if let alunos = turma.alunos as? Set<Aluno> {
            alunosAtivos = [Aluno]()
            for aluno in alunos {
                if let notas = aluno.notasAluno as? Set<NotaAluno> {
                    var notasDaAvaliacao: Int = .zero
                    for nota in notas {
                        if nota.avaliacao.id == evaluation?.id {
                            notasDaAvaliacao += 1
                        }
                    }
                    if notasDaAvaliacao > 0 {
                        count += 1
                    }
                }
            }
        }
        var avaliacaoValida: Bool!
        if let avaliacao = evaluation {
            var dataVazia = false
            if let dataServidor = avaliacao.dataServidor {
                dataVazia = dataServidor.isEmpty
            }
            avaliacaoValida = !dataVazia && avaliacao.valeNota
        }
        return count == alunosAtivos.count && avaliacaoValida
    }

    fileprivate func setupAverage(student: Aluno, value: Float?) {
        if let bimestreId = bimestre?.id, let turmaId = turma?.id, let disciplinaId = disciplina?.id, let notas = student.notasAluno as? Set<NotaAluno> {
            var notasValidas = [NotaAluno]()
            for nota in notas {
                if avaliacaoValida(evaluation: nota.avaliacao) {
                    notasValidas.append(nota)
                }
            }
            if !notasValidas.isEmpty {
                let averageId = "ID-\(bimestreId)-\(turmaId)-\(disciplinaId)-\(student.id)"
                var mapPoints = [Float]()
                mapPoints.reserveCapacity(notasValidas.count)
                for nota in notasValidas {
                    mapPoints.append(nota.nota)
                }
                var tipo: TypeName!
                if let name = selectedAverageType?.name {
                    tipo = name
                }
                else {
                    tipo = TypeName(rawValue: student.average.selectedType)
                }
                var initialValue: Float = .zero
                if let tipo = tipo {
                    switch tipo
                    {
                    case .arithmetic:
                        for nota in mapPoints {
                            initialValue += nota
                        }
                        initialValue /= Float(mapPoints.count)
                        if initialValue > 10 {
                            initialValue = 10
                        }
                    case .weighted:
                        if !notasValidas.isEmpty {
                            var multiplicacoes = [Float]()
                            var pesos = [Int]()
                            for nota in notasValidas {
                                let avaliacao = nota.avaliacao
                                let peso = AverageDao.AverageTypeModel.WeightedModel.getData(fromEvaluation: avaliacao)
                                let notaValor = nota.nota
                                if let pesoValor = peso?.weight {
                                    let multiplicacao = notaValor * Float(pesoValor)
                                    multiplicacoes.append(multiplicacao)
                                    pesos.append(pesoValor)
                                }
                            }
                            if !multiplicacoes.isEmpty && !pesos.isEmpty {
                                var somaMultiplicacoes: Float = .zero
                                var somaPesos: Int = .zero
                                for multiplicacao in multiplicacoes {
                                    somaMultiplicacoes += multiplicacao
                                }
                                for peso in pesos {
                                    somaPesos += peso
                                }
                                initialValue = somaMultiplicacoes / Float(somaPesos)
                                if initialValue > 10 {
                                    initialValue = 10
                                }
                            }
                        }
                    case .sum:
                        for nota in mapPoints {
                            initialValue += nota
                        }
                    }
                }
                var newValue: Float!
                if let value = value, value > 0, student.average.numberEvaluations as! Int == notasValidas.count {
                    newValue = value
                }
                else {
                    newValue = initialValue
                }
                var type: TypeName!
                if let typeName = selectedAverageType?.name {
                    type = typeName
                }
                else {
                    type = TypeName(rawValue: student.average.selectedType)
                }
                let average = Average(id: averageId, value: newValue, initialValue: initialValue, numberEvaluations: notasValidas.count, selectedType: type, student: student)
                AverageDao.salvar(average: average)
                CoreDataManager.sharedInstance.salvarBanco()
            }
        }
    }

    fileprivate func setHeaderViewExpanded(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 1, animations: {
            var height: CGFloat!
            if UIDevice.current.userInterfaceIdiom == .pad {
                if self.headerViewIsExpanded {
                    height = Constants.heightMinimum
                }
                else {
                    height = Constants.heightGreateriPad
                }
            }
            else if self.headerViewIsExpanded {
                height = Constants.heightMinimum
            }
            else {
                height = Constants.heightGreater
            }
            self.headerViewContraintHeight.constant = height
            self.headerViewIsExpanded = !self.headerViewIsExpanded
            self.view.layoutIfNeeded()
        }, completion: { completed in
            if completed {
                if self.headerViewIsExpanded {
                    self.averageTypes = AverageDao.AverageTypeModel.getData()
                }
                else {
                    self.averageTypes = []
                }
                self.tableHeaderView.reloadData()
                if let name = self.selectedAverageType?.name {
                    self.weightedTableData = []
                    self.setAverageTypeButton(type: name)
                    self.setWeightedView(animate: true)
                    completion?()
                }
                else {
                    self.setAverageTypeButton()
                }
            }
        })
    }

    fileprivate func setWeightedView(isHidden: Bool = true, animate: Bool = false, completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 1, animations: {
            if isHidden {
                self.weightedViewConstraintBottom.constant = Constants.bottomFirst
            }
            else {
                self.weightedViewConstraintBottom.constant = Constants.bottomSecond
            }
            if animate {
                self.view.layoutIfNeeded()
            }
        }, completion: { completed in
            if completed {
                self.weightedView.setShadow(enable: true)
                self.weightedTableView.reloadData()
                completion?()
            }
        })
    }

    fileprivate func setWeightedTableData() {
        if let avaliacoes = avaliacoes, !avaliacoes.isEmpty {
            weightedTableData = []
            for avaliacao in avaliacoes {
                if avaliacao.valeNota == true {
                    var item: WeightedData?
                    if avaliacaoValida(evaluation: avaliacao) {
                        item = (avaliacao.id, avaliacao, 1)
                    }
                    if let saved = AverageDao.AverageTypeModel.WeightedModel.getData(fromEvaluationModel: avaliacao), let id = saved.id, let weight = saved.weight, let evaluation = saved.evaluation, self.avaliacaoValida(evaluation: evaluation) {
                        item = (id, evaluation, weight)
                    }
                    else {
                        let model = AverageDao.AverageTypeModel.WeightedModel(weight: 1, evaluation: avaliacao)
                        AverageDao.AverageTypeModel.WeightedModel.save(model: model)
                    }
                    if let object = item {
                        weightedTableData?.append(object)
                    }
                }
            }
        }
    }

    fileprivate func getData(changedType: Bool = false) {
        if let alunos = turma.alunos as? Set<Aluno>, !changedType, !alunos.isEmpty, let type = alunos.first?.average.selectedType {
            switch type
            {
            case TypeName.arithmetic.rawValue:
                selectedAverageType = AverageDao.AverageTypeModel(id: .arithmetic, name: .arithmetic)
            case TypeName.weighted.rawValue:
                selectedAverageType = AverageDao.AverageTypeModel(id: .weighted, name: .weighted)
            case TypeName.sum.rawValue:
                selectedAverageType = AverageDao.AverageTypeModel(id: .sum, name: .sum)
            default:
                break
            }
            averageItems = []
            for aluno in alunos {
                setupAverage(student: aluno, value: changedType ? nil : aluno.average.value)
                if let student = AlunoDao.alunoComId(alunoId: aluno.id) {
                    let item: AverageItem = (student.average.value, student.average, student)
                    averageItems?.append(item)
                }
            }
        }
        averageItems?.sort {
            $0.student.numeroChamada < $1.student.numeroChamada
        }
    }

    fileprivate func setAverageItems(item: AverageItem) {
        if averageItems == nil {
            averageItems = []
        }
        if averageItems?.isEmpty == true {
            averageItems?.append(item)
        }
        else if let medias = averageItems {
            var novasMedias = [AverageViewController.AverageItem]()
            for media in medias {
                var duplicados = true
                for novaMedia in novasMedias {
                    if novaMedia.average.id == media.average.id && novaMedia.student.id == media.student.id {
                        duplicados = false
                        break
                    }
                }
                if !duplicados {
                    novasMedias.append(media)
                }
            }
            var filter = [AverageViewController.AverageItem]()
            for novaMedia in novasMedias {
                if novaMedia.average.id != item.average.id && novaMedia.student.id != item.student.id {
                    filter.append(novaMedia)
                }
            }
            if !filter.isEmpty {
                novasMedias = filter
            }
            novasMedias.append(item)
            averageItems = novasMedias.sorted {
                $0.student.numeroChamada < $1.student.numeroChamada
            }
        }
        tableView.reloadData()
    }
}

//MARK: AverageHeaderViewTableViewCellDelegate
extension AverageViewController: AverageHeaderViewTableViewCellDelegate {
    func averageHeaderViewTableViewCellDidSelect(type: AverageDao.AverageTypeModel?, button _: UIButton?) {
        if type?.id != TypeId.weighted {
            selectedAverageType = type
        }
        if type?.id == TypeId.weighted { // View com as avaliações e seus respectivos pesos
            setWeightedTableData()
            setWeightedView(isHidden: false, animate: true)
        }
        else {
            setHeaderViewExpanded {
                Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.calculateAverageTypeSelected), userInfo: nil, repeats: false)
            }
        }
    }
}

//MARK: AverageTableViewCellDelegate
extension AverageViewController: AverageTableViewCellDelegate {
    func averageTableViewCellButtonUpClicked(averageItem: AverageViewController.AverageItem?) {
        if let averageItem = averageItem {
            var roundedValue = averageItem.average.initialValue
            if roundedValue <= 10 {
                if roundedValue.truncatingRemainder(dividingBy: 1) >= 0.5 {
                    roundedValue = ceilf(roundedValue)
                }
                else {
                    roundedValue = floorf(roundedValue)
                }
            }
            else {
                roundedValue = 10
            }
            let item: AverageItem = (roundedValue, averageItem.average, averageItem.student)
            setAverageItems(item: item)
        }
    }
    
    func averageTableViewCellButtonDownClicked(averageItem: AverageViewController.AverageItem?) {
        if let averageItem = averageItem {
            var roundedValue = averageItem.average.initialValue
            if roundedValue <= 10 {
                if roundedValue.truncatingRemainder(dividingBy: 1) <= 0.5 {
                    roundedValue = floorf(roundedValue)
                }
                else {
                    roundedValue = ceilf(roundedValue)
                }
            }
            else {
                roundedValue = 10
            }
            let item: AverageItem = (roundedValue, averageItem.average, averageItem.student)
            setAverageItems(item: item)
        }
    }
    
    func averageTableViewCellButtonReloadClicked(averageItem: AverageViewController.AverageItem?) {
        if let averageItem = averageItem {
            if averageItem.roundedValue == averageItem.average.initialValue { return }
            let item: AverageItem = (averageItem.average.initialValue, averageItem.average, averageItem.student)
            setAverageItems(item: item)
        }
        
    }
}

//MARK: UITableViewDataSource
extension AverageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        switch tableView.tag
        {
        case Constants.tableViewTag:
            if let averageItems = averageItems {
                return averageItems.count
            }
        case Constants.headerTableViewTag:
            if let averageTypes = averageTypes {
                return averageTypes.count
            }
        case Constants.weightedTableViewTag:
            if let weightedTableData = weightedTableData {
                return weightedTableData.count
            }
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch tableView.tag
        {
        case Constants.tableViewTag:
            if let cell = defaultCell as? AverageTableViewCell {
                cell.delegate = self
                cell.averageItem = averageItems?[indexPath.row]
            }
        case Constants.headerTableViewTag:
            if let cell = defaultCell as? AverageHeaderViewTableViewCell {
                cell.delegate = self
                cell.type = averageTypes?[indexPath.row]
            }
        case Constants.weightedTableViewTag:
            if let cell = defaultCell as? WeightedAverageTableViewCell {
                cell.delegate = self
                cell.data = weightedTableData?[indexPath.row]
            }
        default:
            break
        }
        return defaultCell
    }
}

//MARK: UITableViewDelegate
extension AverageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        switch tableView.tag
        {
        case Constants.tableViewTag:
            if let averageItems = averageItems, !averageItems.isEmpty {
                return RowHeight.default
            }
            return RowHeight.minor
        case Constants.headerTableViewTag:
            if let averageTypes = averageTypes, !averageTypes.isEmpty {
                return RowHeight.defaultHeader
            }
            return 0
        default:
            return RowHeight.minor
        }
    }
}

//MARK: WeightedAverageTableViewCellDelegate
extension AverageViewController: WeightedAverageTableViewCellDelegate {
    func weightedAverageTableViewCellDidStepperChanged(data: AverageViewController.WeightedData?, newWeight: Int?) {
        if let weight = newWeight, let evaluation = data?.evaluation {
            let model = AverageDao.AverageTypeModel.WeightedModel(weight: weight, evaluation: evaluation)
            AverageDao.AverageTypeModel.WeightedModel.save(model: model)
            setWeightedTableData()
        }
    }
}

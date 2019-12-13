//
//  CoreDataManager.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 29/08/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import CoreData
import Foundation

struct Tabelas {
    static let aluno = "Aluno"
    static let aula = "Aula"
    static let avaliacao = "Avaliacao"
    static let average = "Average"
    static let bimestre = "Bimestre"
    static let conteudo = "Conteudo"
    static let curriculo = "Curriculo"
    static let diaConflito = "DiaConflito"
    static let diaFrequencia = "DiaFrequencia"
    static let diaLetivo = "DiaLetivo"
    static let disciplina = "Disciplina"
    static let faltaAluno = "FaltaAluno"
    static let fechamentoAluno = "FechamentoAluno"
    static let fechamentoTurma = "FechamentoTurma"
    static let frequencia = "Frequencia"
    static let grupo = "Grupo"
    static let habilidade = "Habilidade"
    static let habilidadeRegistroAula = "HabilidadeRegistroAula"
    static let horarioConflito = "HorarioConflito"
    static let horarioFrequencia = "HorarioFrequencia"
    static let notaAluno = "NotaAluno"
    static let registroAula = "RegistroAula"
    static let tipoFechamentoBimestre = "TipoFechamentoBimestre"
    static let totalFaltasAluno = "TotalFaltasAluno"
    static let turma = "Turma"
    static let usuario = "Usuario"
}

final class CoreDataManager {
    //MARK: Singleton
    static let sharedInstance = CoreDataManager()

    //MARK: CoreData stack
    fileprivate lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1]
    }()

    fileprivate lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "DiarioClasse", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    fileprivate lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("DiarioClasse.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."

        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch {
            var dict = [String: Any]()
            dict[NSLocalizedDescriptionKey] = "Failed to initxialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var contextoPrincipal: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        managedObjectContext.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType);
        return managedObjectContext
    }()
    
    //MARK: Constants
    fileprivate struct Constants {
        static let funcaoMaximo = "max:"
    }
    
    func buscarDados<T: NSManagedObject>(tabela: String, predicate: NSPredicate? = nil, unique: Bool = false, propertiesToFetch: [String]? = nil, sortBy: String? = nil, contexto: NSManagedObjectContext = CoreDataManager.sharedInstance.contextoPrincipal) -> [T]? {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: tabela)
        fetchRequest.predicate = predicate
        fetchRequest.propertiesToFetch = propertiesToFetch
        if unique {
            fetchRequest.fetchLimit = 1
        }
        if sortBy != nil {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortBy, ascending: true)]
        }
        do {
            return try contexto.fetch(fetchRequest) as? [T]
        }
        catch {
        }
        return nil
    }
    
    func criarContexto() -> NSManagedObjectContext {
        let contexto = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        contexto.parent = contextoPrincipal
        return contexto
    }

    func criarObjeto<T: NSManagedObject>(tabela: String, contexto: NSManagedObjectContext = CoreDataManager.sharedInstance.contextoPrincipal) -> T {
        return NSEntityDescription.insertNewObject(forEntityName: tabela, into: contexto) as! T
    }
    
    func deletarObjeto(objeto: NSManagedObject) {
        contextoPrincipal.delete(objeto)
    }

    func deletarBancoDeDados() {
        deletarDados(tabela: Tabelas.aluno)
        deletarDados(tabela: Tabelas.aula)
        deletarDados(tabela: Tabelas.avaliacao)
        deletarDados(tabela: Tabelas.average)
        deletarDados(tabela: Tabelas.bimestre)
        deletarDados(tabela: Tabelas.conteudo)
        deletarDados(tabela: Tabelas.curriculo)
        deletarDados(tabela: Tabelas.diaConflito)
        deletarDados(tabela: Tabelas.diaFrequencia)
        deletarDados(tabela: Tabelas.diaLetivo)
        deletarDados(tabela: Tabelas.disciplina)
        deletarDados(tabela: Tabelas.faltaAluno)
        deletarDados(tabela: Tabelas.fechamentoAluno)
        deletarDados(tabela: Tabelas.fechamentoTurma)
        deletarDados(tabela: Tabelas.frequencia)
        deletarDados(tabela: Tabelas.grupo)
        deletarDados(tabela: Tabelas.habilidade)
        deletarDados(tabela: Tabelas.habilidadeRegistroAula)
        deletarDados(tabela: Tabelas.horarioConflito)
        deletarDados(tabela: Tabelas.horarioFrequencia)
        deletarDados(tabela: Tabelas.notaAluno)
        deletarDados(tabela: Tabelas.registroAula)
        deletarDados(tabela: Tabelas.tipoFechamentoBimestre)
        deletarDados(tabela: Tabelas.totalFaltasAluno)
        deletarDados(tabela: Tabelas.turma)
        deletarDados(tabela: Tabelas.usuario)
        contextoPrincipal.reset()
    }

    func deletarDados(tabela: String, predicate _: NSPredicate? = nil, contexto: NSManagedObjectContext = CoreDataManager.sharedInstance.contextoPrincipal) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: tabela)
        fetchRequest.includesPropertyValues = false
        do {
            try persistentStoreCoordinator.execute(NSBatchDeleteRequest(fetchRequest: fetchRequest), with: contexto)
        }
        catch {
        }
    }
    
    func getCount(entity: String, predicate: NSPredicate? = nil, contexto: NSManagedObjectContext = CoreDataManager.sharedInstance.contextoPrincipal) -> Int {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity)
        fetchRequest.includesPropertyValues = false
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = predicate
        do {
            return try contexto.count(for: fetchRequest)
        }
        catch {
        }
        return 0
    }
    
    func maximo(entity: String, campo: String) -> UInt32 {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entity)
        fetchRequest.fetchLimit = 1
        fetchRequest.resultType = .dictionaryResultType
        let maxExpressionDescription = NSExpressionDescription()
        maxExpressionDescription.expressionResultType = .integer32AttributeType
        maxExpressionDescription.name = campo
        maxExpressionDescription.expression = NSExpression(forFunction: Constants.funcaoMaximo, arguments: [NSExpression(forKeyPath: campo)])
        fetchRequest.propertiesToFetch = [maxExpressionDescription]
        do {
            let resultado = try contextoPrincipal.fetch(fetchRequest).first as! [String:UInt32]
            return resultado[campo]!
        }
        catch {
        }
        return .zero
    }
    
    func resetarContexto() {
        contextoPrincipal.reset()
    }
    
    func rollback() {
        contextoPrincipal.rollback()
    }
    
    func salvarBanco() {
        if contextoPrincipal.hasChanges {
            contextoPrincipal.performAndWait {
                do {
                    try contextoPrincipal.save()
                }
                catch {
                    let error = error as NSError
                    NSLog("Unresolved error \(error), \(error.userInfo)")
                    abort()
                }
            }
        }
    }
}

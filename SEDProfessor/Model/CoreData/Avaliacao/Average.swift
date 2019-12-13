//
//  Average.swift
//  SEDProfessor
//
//  Created by Richard Leh on 10/01/17.
//  Copyright © 2017 PRODESP. All rights reserved.
//

import CoreData

@objc(Average)

final class Average: NSManagedObject {
    //MARK: Variables
    @NSManaged var id: String
    @NSManaged var value: Float
    @NSManaged var initialValue: Float
    @NSManaged var selectedType: String
    @NSManaged var numberEvaluations: NSNumber
    @NSManaged var student: Aluno
    
    //MARK: Constructor
    init(id: String, value: Float, initialValue: Float, numberEvaluations: Int, selectedType: TypeName, student: Aluno) {
        let context = CoreDataManager.sharedInstance.contextoPrincipal
        super.init(entity: NSEntityDescription.entity(forEntityName: Tabelas.average, in: context)!, insertInto: context)
        self.id = id
        self.value = value
        self.initialValue = initialValue
        self.selectedType = selectedType.rawValue
        self.student = student
        self.numberEvaluations = numberEvaluations as NSNumber
    }
}

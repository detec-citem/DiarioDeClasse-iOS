//
//  Home.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 05/08/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import Foundation

final class MenuItem {
    //MARK: Variables
    var imageName: String?
    var title: String?
    var enabled: Bool = true
    
    //MARK: Constructors
    init() {
    }

    init(image: Imagens, title: TipoTurmaNome) {
        imageName = image.rawValue
        self.title = title.rawValue
    }
}

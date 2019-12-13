//
//  Utils.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 18/08/16.
//  Copyright © 2016 PRODESP. All rights reserved.
//

import MZFormSheetPresentationController
import UIKit

let DEVICE = UIDevice.current.userInterfaceIdiom

let iPad = DEVICE == .pad

typealias TotalAulas = (aulasAno: UInt32?, aulasBimestre: UInt32?)

enum TextPosition: Int {
    case to = 0
    case after = 1
    case before = 2
    case from = 3
}

/// Todos os métodos globais deverão existir aqui
final class Utils {
    static func changeControllerWithAnimation(identifier: String, target: AnyObject?) {
        if let rootViewController = target?.storyboard??.instantiateViewController(withIdentifier: identifier) {
            let application = UIApplication.shared
            let keyWindow = application.keyWindow
            keyWindow?.rootViewController = rootViewController
            keyWindow?.makeKeyAndVisible()
            let viewAnimacao = UIView(frame: rootViewController.view.frame)
            viewAnimacao.backgroundColor = .white
            rootViewController.view.addSubview(viewAnimacao)
            UIView.animate(withDuration: 1.5, animations: {
                viewAnimacao.alpha = 0
            }, completion: { _ in
                viewAnimacao.removeFromSuperview()
                application.isNetworkActivityIndicatorVisible = false
                if application.isIgnoringInteractionEvents {
                    application.endIgnoringInteractionEvents()
                }
            })
        }
    }
    
    static func getDeviceHeightValueFrom(view: UIView, percent: CGFloat) -> CGFloat {
        let result = view.frame.size.height * percent / 100
        return result
    }
    
    static func getSegueIdentifier(tipoTurma: TipoTurma) -> String {
        switch tipoTurma {
        case .frequenciaLancamento:
            return Segue.LancamentoFrequencia.rawValue
        case .registroLancamento:
            return Segue.RegistroLancamento.rawValue
        case .avaliacaoLancamento:
            return Segue.LancamentoAvaliacao.rawValue
        case .frequenciaConsulta:
            return Segue.ConsultaFrequencia.rawValue
        default:
            return ""
        }
    }
    
    static func isDevice(device: AlturaAparelho) -> Bool {
        let screen = UIScreen.main.bounds
        if device.rawValue == screen.height {
            return true
        }
        return false
    }
}

//
//  ExcluirFrequenciaRequest.swift
//  SEDProfessor
//
//  Created by Victor Bozelli Alvarez on 19/09/19.
//  Copyright © 2019 PRODESP. All rights reserved.
//

import Foundation

final class ExcluirFrequenciaRequest {
    //MARK: Constants
    fileprivate struct Constants {
        static let parametroCodigoDisciplina = "CodigoDisciplina"
        static let parametroCodigoTurma = "CodigoTurma"
        static let parametroDataDaAula = "DataDaAula"
        static let parametroHorarioInicioAula = "HorarioInicioAula"
        static let salvarFrequenciasApi = "Frequencia/ExcluirFrequencia"
    }
    
    //MARK: Methods
    static func excluirFrequencia(aula: Aula, diaLetivo: DiaLetivo, turma: Turma, completion: @escaping (Bool,String?) -> Void) {
        if let url = URL(string: Requests.Configuracoes.urlServidor + Constants.salvarFrequenciasApi) {
            var frequenciaJson: [String:Any] = [Constants.parametroCodigoDisciplina:aula.disciplina.id,Constants.parametroCodigoTurma:turma.id,Constants.parametroHorarioInicioAula:aula.inicioHora]
            if let dataAula = DateFormatter.dataDateFormatter.date(from: diaLetivo.dataAula) {
                frequenciaJson[Constants.parametroDataDaAula] = DateFormatter.isoDataFormatter.string(from: dataAula)
            }
            var request = URLRequest(url: url)
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: frequenciaJson)
                Requests.requestData(requisicao: request, metodoHttp: .post, completion: { data, error, _ in
                    DispatchQueue.main.async {
                        completion(error == nil, Requests.getMensagemErro(error: error))
                    }
                })
            }
            catch {
                completion(false, Requests.getMensagemErro(error: error))
            }
        }
    }
}

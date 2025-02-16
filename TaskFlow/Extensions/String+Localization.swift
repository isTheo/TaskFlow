//
//  String+Localization.swift
//  TaskFlow
//
//  Created by Matteo Orru on 16/02/25.
//

import Foundation


extension String {
    // Restituisce la stringa localizzata dal file Localizable.strings
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    // Restituisce la stringa localizzata con parametri formattati
    func localized(with arguments: CVarArg...) -> String {
        String(format: self.localized, arguments: arguments)
    }
}

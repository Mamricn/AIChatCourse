//
//  Binding+EXT.swift
//  AIChatCourse
//
//  Created by Marcin Turek on 19/02/2026.
//

import Foundation
import SwiftUI

extension Binding where Value == Bool {
    
    
    init<T>(ifNotNil value: Binding<T?>){
        self.init {
            value.wrappedValue != nil
        } set: { newValue in
            if !newValue {
                value.wrappedValue = nil
            }
        }
    }
}


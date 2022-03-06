//
//  Bindable.swift
//  Chia
//
//  Created by Bohan Wu on 2/21/22.
//

import Foundation


class Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }
    
    var observer: ((T?)->())?
    
    func bind(observer: @escaping (T?) ->()) {
        self.observer = observer
    }
    
}

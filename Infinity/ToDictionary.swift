//
//  ToDictionary.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-26.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import Foundation

extension CollectionType {
    func toDictionary<K, V>
        (transform:(element: Self.Generator.Element) -> (key: K, value: V)?) -> [K : V] {
        var dictionary = [K : V]()
        for e in self {
            if let (key, value) = transform(element: e) {
                dictionary[key] = value
            }
        }
        return dictionary
    }
}

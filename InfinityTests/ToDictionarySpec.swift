//
//  ToDictionarySpec.swift
//  Infinity
//
//  Created by Taimur Ayaz on 2016-09-29.
//  Copyright © 2016 Taimur Ayaz. All rights reserved.
//

import UIKit
import Quick
import Nimble
@testable import Infinity

class TestClass {
    var key: String
    var value: Int
    
    init(key: String, value: Int) {
        self.key = key
        self.value = value
    }
}

class ToDictionarySpec: QuickSpec {
    
    override func spec() {
        
        var sample: [TestClass] = []
        
        for i in 0..<100 {
            sample.append(TestClass(key: "key:\(i)", value: i))
        }
        
        describe("To Dictionary") {
            it("should contain equal elements") {
                let sampleDictionary = sample.toDictionary({ ($0.key, $0.value) })
                expect(sampleDictionary.count).to(equal(sample.count))
            }
            
            it("should parse correctly") {
                let sampleDictionary = sample.toDictionary({ ($0.key, $0.value) })
                for i in 0..<sample.count {
                    expect(sampleDictionary["key:\(i)"]).to(equal(i))
                }
            }
        }
    }
}

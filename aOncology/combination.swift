//
//  combination.swift
//  aOncology
//
//  Created by Philippe-Faurie on 4/21/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation
// Calculate the unique combinations of elements in an array
// taken some number at a time when no element is allowed to repeat

class Combination_C{
    
        public func combinationsWithoutRepetitionFrom<T>(elements: [T], taking: Int) -> [[T]] {
        guard elements.count >= taking else { return [] }
        guard elements.count > 0 && taking > 0 else { return [[]] }
        
        if taking == 1 {
            return elements.map {[$0]}
        }
        
        var combinations = [[T]]()
        for (index, element) in elements.enumerated() {
            var reducedElements = elements
            reducedElements.removeFirst(index + 1)
            combinations += combinationsWithoutRepetitionFrom(elements: reducedElements, taking: taking - 1).map {[element] + $0}
        }
        
        return combinations
    }

    
    func cnk (_ n: Int, choose k: Int) -> Int {
        var result = 1
        for i in 0..<k {
            result *= (n - i)
            result /= (i + 1)
        }
        return result
    }
    
}


//
//  GeneData.swift
//  aOncology
//
//  Created by Philippe-Faurie on 5/8/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation

var list1 = Set(dicDTRelL.keys)                // Target - Drugs
var list2 = Set(dicTSubsL.keys)                // Target - Target
var geneDataList = list1.union(list2)    // All


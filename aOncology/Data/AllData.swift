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

var pathoSynL   = Array(pathoSynData.keys)     // list of disesase synonyms

var synGene = Array (synoGeneData.keys)

//var geneDataList = synGene                    // All synonyms
//var geneDataList = list1.union(list2)         // All

var geneDataList = Array (list1.union(list2)) + synGene                       // All synonyms



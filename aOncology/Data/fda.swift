//
//  fda.swift
//  aOncology
//
//  Created by Philippe-Faurie on 5/15/18.
//  Copyright © 2018 Philippe-Faurie. All rights reserved.
//

import Foundation


//-------------------------------
// List of drugs with BB warning
/*
var bbWarningL = [

    "anastrozole",
    "bevacizumab",
    "busulfan",
    "cisplatin",
    "cyclophosphamide",
    "daunorubicin",
    "erlotinib",
    "etoposide",
    "exemestane",
    "fluorouracil",
    "fulvestrant",
    "imatinib",
    "irinotecan",
    "lapatinib",
    "letrozole",
    "mechlorethamine",
    "methotrexate",
    "paclitaxel",
    "ponatinib",
    "raloxifene",
    "rituximab",
    "tamoxifen",
    "trastuzumab",
]
*/
var bbWarningL = drugLabels.keys

var drugLabels = [
    "abaloparatide":  "Risk Of Osteosarcoma",
    "adalimumab":  "Serious Infections And Malignancy" ,
    "adalimumab-adbm":  "Serious Infections And Malignancy",
    "ado-trastuzumab emtansine":  "Hepatotoxicity, Cardiac Toxicity, Embryo-fetal Toxicity" ,
    "alemtuzumab":  "Autoimmunity, Infusion Reactions, And Malignancies" ,
    "betrixaban":  "Spinal/epidural Hematoma",
    "bevacizumab":  "Gastrointestinal Perforations, Surgery And Wound Healing Complications, And Hemorrhage",
    "bevacizumab-awwb":  "Gastrointestinal Perforations, Surgery And Wound Healing Complications, And Hemorrhage",
    "bexarotene":  "Birth Defects",
    "blinatumomab":  "Cytokine Release Syndrome And Neurological Toxicities",
    "brentuximab vedotin":  "Progressive Multifocal Leukoencephalopathy (pml)",
    "brodalumab":  "Suicidal Ideation And Behavior",
    "busulfan":  "Myelosuppression",
    "cabazitaxel":  "Neutropenia And Hypersensitivity" ,
    "cabozantinib":  "Perforations And Fistulas, And Hemorrhage",
    "capecitabine":  "Capecitabine-warfarin Interaction",
    "carboplatin":  "Bone Marrow Suppression, Vomiting, Anaphylactic-like Reactions",
    "celecoxib":  "Risk Of Serious Cardiovascular And Gastrointestinal Events" ,
    "certolizumab":  "Serious Infections And Malignancy" ,
    "cetuximab":  "Serious Infusion Reactions And Cardiopulmonary Arrest" ,
    "cisplatin":  "Renal Toxicity, Myelosuppression, Nausea, Vomiting, Ototoxicity, Anaphylactic-like Reactions",
    "cladribine":  "Bone Marrow Suppression",
    "daclizumab":  "Hepatic Injury Including Autoimmune Hepatitis And Other Immune-mediated Disorders" ,
    "deutetrabenazine":  "Depression And Suicidality In Patients With Huntingtonís Disease",
    "dinutuximab":  "Serious Infusion Reactions And Neurotoxicity" ,
    "docetaxel":  "Toxic Deaths, Hepatotoxicity, Neutropenia, Hypersensitivity Reactions, And Fluid Retention" ,
    "doxorubicin":  "Cardiomyopathy, Secondary Malignancies, Extravasation And Tissue Necrosis, And Severe Myelosuppression" ,
    "eculizumab":  "Serious Meningococcal Infections" ,
    "efalizumab":  "Risk Of Progressive Multifocal Leukoencephalopathy (pml)" ,
    "epirubicin":  "Severe Or Life-threatening Hematological And Other Adverse Reactions" ,
    "everolimus":  "Malignancies And Serious Infections,  Kidney Graft Thrombosis; Nephrotoxicity; And Mortality In Heart Transplantation",
    "furoateumeclidiniumvilanterol":  "Asthma-related Death",
    "golimumab":  "Serious Infections And Malignancy",
    "goserelin":  "Warnings And Precautions",
    "hyaluronidaserituximab":  "Severe Mucocutaneous Reactions, Hepatitis  B Virus Reactivation And Progressive Multifocal  Leukoencephalopathy",
    "idelalisib":  "Hepatotoxicity",
    "infliximab":  "Serious Infections And Malignancy" ,
    "infliximab-abda":  "Serious Infections And Malignancy",
    "infliximab-dyyb":  "Serious Infections And Malignancy",
    "ipilimumab":  "Immune-mediated Adverse Reactions" ,
    "irinotecan":  "Diarrhea And Myelosuppression",
    "itraconazole":  "Congestive Heart Failure, Cardiac Effects And Drug Interactions" ,
    "lapatinib":  "Hepatotoxicity" ,
    "lenalidomide":  "Embryo-fetal Toxicity, Hematologic Toxicity, And Venous And Arterial Thromboembolism" ,
    "macitentan":  "Embryo-fetal Toxicity",
    "metformin":  "Lactic Acidosis " ,
    "methotrexate":  "Severe Toxic Reactions, Including Embryofetal Toxicity And Death " ,
    "mifepristone":  "Termination Of Pregnancy" ,
    "mitomycin":  "Warning (no Title)",
    "natalizumab":  "Progressive Multifocal Leukoencephalopathy" ,
    "necitumumab":  "Cardiopulmonary Arrest And Hypomagnesemia" ,
    "nelarabine":  "Neurologic Adverse Reactions" ,
    "nilotinib":  "Qt Prolongation And Sudden Deaths" ,
    "nilutamide":  "Interstitial Pneumonitis" ,
    "obinutuzumab":  "Hepatitis B Virus Reactivation And Progressive Multifocal Leukoencephalopathy" ,
    "ofatumumab":  "Hepatitis B Virus Reactivation And Progressive Multifocal Leukoencephalopathy" ,
    "oxaliplatin":  "Anaphylactic Reactions",
    "paclitaxel":  "Neutropenia" ,
    "panitumumab":  "Dermatologic Toxicity" ,
    "panobinostat":  "Fatal And Serious Toxicities: Severe Diarrhea And Cardiac Toxicities" ,
    "pazopanib":  "Hepatotoxicity" ,
    "pertuzumab":  "Left Ventricular Dysfunction And Embryofetal Toxicity" ,
    "pibrentasvir":  "Risk Of Hepatitis B Virus Reactivation In Patients Coinfected With Hcv And Hbv",
    "plecanatide":  "Risk Of Serious Dehydration In Pediatric Patients",
    "pomalidomide":  "Embryo-fetal Toxicity And Venous And Arterial Thromboembolism" ,
    "ponatinib":  "Arterial Occlusion, Venous Thromboembolism, Heart Failure And Hepatotoxicity",
    "raloxifene":  "Increased Risk Of Venous Thromboembolism And Death From Stroke " ,
    "ramucirumab":  "Hemorrhage, Gastrointestinal Perforation, And Impaired Wound Healing " ,
    "regorafenib":  "Hepatotoxicity",
    "reslizumab":  "Anaphylaxis" ,
    "rituximab":  "Fatal Infusion Reactions, Severe  Mucocutaneous Reactions, Hepatitis B Virus  Reactivation And Progressive Multifocal  Leukoencephalopathy" ,
    "sarilumab":  "Risk Of Serious Infections",
    "sirolimus":  "Immunosuppression, Use Is Not Recommended In Liver Or Lung Transplant Patients" ,
    "sonidegib":  "Embryo-fetal Toxicity" ,
    "sulindac":  "Cardiovascular Risk, Gastrointestinal Risk",
    "sunitinib":  "Hepatotoxicity " ,
    "tamoxifen":  "Uterine Malignancies, Stroke, Pulmonary Embolism",
    "teniposide":  "Warning (no Title Provided)",
    "tocilizumab":  "Risk Of Serious Infections" ,
    "tofacitinib":  "Serious Infections And Malignancy" ,
    "topotecan":  "Bone Marrow Suppression" ,
    "toremifene":  "Qt Prolongation" ,
    "tositumomab":  "Serious Allergic Reactions/anaphylaxis, Prolonged And Severe Cytopenias, And Radiation Exposure" ,
    "trastuzumab":  "Cardiomyopathy, Infusion Reactions, Embryo-fetal Toxicity And Pulmonary Toxicity.",
    "vandetanib":  "Qt Prolongation, Torsades De Pointes, And Sudden Death" ,
    "vinorelbine":  "Myelosuppression  " ,
    "vismodegib":  "Embryo-fetal Toxicity",
    "voxilaprevir":  "Risk Of Hepatitis B Virus Reactivation In  Patients Coinfected With Hcv And Hbv",
    "ziv-aflibercept":  "Hemorrhage, Gastrointestinal Perforation, Compromised Wound Healing" ,
]


 /*
"abaloparatide" : [ "Risk Of Osteosarcoma" ]
"adalimumab" : [ "Serious Infections And Malignancy" ]
"adalimumab-adbm" : [ "Serious Infections And Malignancy" ]
"ado-trastuzumab emtansine" : [ "Hepatotoxicity, Cardiac Toxicity, Embryo-fetal Toxicity" ]
"alemtuzumab" : [ "Autoimmunity, Infusion Reactions, And Malignancies" ]
"betrixaban" : [ "Spinal/epidural Hematoma" ]
"bevacizumab" : [ "Gastrointestinal Perforations, Surgery And Wound Healing Complications, And Hemorrhage" ]
"bevacizumab-awwb" : [ "Gastrointestinal Perforations, Surgery And Wound Healing Complications, And Hemorrhage" ]
"bexarotene" : [ "Birth Defects" ]
"blinatumomab" : [ "Cytokine Release Syndrome And Neurological Toxicities" ]
"brentuximab vedotin" : [ "Progressive Multifocal Leukoencephalopathy (pml)" ]
"brodalumab" : [ "Suicidal Ideation And Behavior" ]
"busulfan" : [ "Myelosuppression" ]
"cabazitaxel" : [ "Neutropenia And Hypersensitivity" ]
"cabozantinib" : [ "Perforations And Fistulas, And Hemorrhage" ]
"capecitabine" : [ "Capecitabine-warfarin Interaction" ]
"carboplatin" : [ "Bone Marrow Suppression, Vomiting, Anaphylactic-like Reactions" ]
"celecoxib" : [ "Risk Of Serious Cardiovascular And Gastrointestinal Events" ]
"certolizumab" : [ "Serious Infections And Malignancy" ]
"cetuximab" : [ "Serious Infusion Reactions And Cardiopulmonary Arrest" ]
"cisplatin" : [ "Renal Toxicity, Myelosuppression, Nausea, Vomiting, Ototoxicity, Anaphylactic-like Reactions" ]
"cladribine" : [ "Bone Marrow Suppression" ]
"daclizumab" : [ "Hepatic Injury Including Autoimmune Hepatitis And Other Immune-mediated Disorders" ]
"deutetrabenazine" : [ "Depression And Suicidality In Patients With Huntington's Disease" ]
"dinutuximab" : [ "Serious Infusion Reactions And Neurotoxicity" ]
"docetaxel" : [ "Toxic Deaths, Hepatotoxicity, Neutropenia, Hypersensitivity Reactions, And Fluid Retention" ]
"doxorubicin" : [ "Cardiomyopathy, Secondary Malignancies, Extravasation And Tissue Necrosis, And Severe Myelosuppression" ]
"eculizumab" : [ "Serious Meningococcal Infections" ]
"efalizumab" : [ "Risk Of Progressive Multifocal Leukoencephalopathy (pml)" ]
"epirubicin" : [ "Severe Or Life-threatening Hematological And Other Adverse Reactions" ]
"everolimus" : [ "Malignancies And Serious Infections,  Kidney Graft Thrombosis; Nephrotoxicity; And Mortality In Heart Transplantation" ]
"furoateumeclidiniumvilanterol" : [ "Asthma-related Death" ]
"golimumab" : [ "Serious Infections And Malignancy" ]
"goserelin" : [ "Warnings And Precautions" ]
"hyaluronidaserituximab" : [ "Severe Mucocutaneous Reactions, Hepatitis  B Virus Reactivation And Progressive Multifocal  Leukoencephalopathy" ]
"idelalisib" : [ "Hepatotoxicity" ]
"infliximab" : [ "Serious Infections And Malignancy" ]
"infliximab-abda" : [ "Serious Infections And Malignancy" ]
"infliximab-dyyb" : [ "Serious Infections And Malignancy" ]
"ipilimumab" : [ "Immune-mediated Adverse Reactions" ]
"irinotecan" : [ "Diarrhea And Myelosuppression" ]
"itraconazole" : [ "Congestive Heart Failure, Cardiac Effects And Drug Interactions" ]
"lapatinib" : [ "Hepatotoxicity" ]
"lenalidomide" : [ "Embryo-fetal Toxicity, Hematologic Toxicity, And Venous And Arterial Thromboembolism" ]
"macitentan" : [ "Embryo-fetal Toxicity" ]
"metformin" : [ "Lactic Acidosis " ]
"methotrexate" : [ "Severe Toxic Reactions, Including Embryofetal Toxicity And Death " ]
"mifepristone" : [ "Termination Of Pregnancy" ]
"natalizumab" : [ "Progressive Multifocal Leukoencephalopathy" ]
"necitumumab" : [ "Cardiopulmonary Arrest And Hypomagnesemia" ]
"nelarabine" : [ "Neurologic Adverse Reactions" ]
"nilotinib" : [ "Qt Prolongation And Sudden Deaths" ]
"nilutamide" : [ "Interstitial Pneumonitis" ]
"obinutuzumab" : [ "Hepatitis B Virus Reactivation And Progressive Multifocal Leukoencephalopathy" ]
"ofatumumab" : [ "Hepatitis B Virus Reactivation And Progressive Multifocal Leukoencephalopathy" ]
"oxaliplatin" : [ "Anaphylactic Reactions" ]
"paclitaxel" : [ "Neutropenia" ]
"panitumumab" : [ "Dermatologic Toxicity" ]
"panobinostat" : [ "Fatal And Serious Toxicities: Severe Diarrhea And Cardiac Toxicities" ]
"pazopanib" : [ "Hepatotoxicity" ]
"pertuzumab" : [ "Left Ventricular Dysfunction And Embryofetal Toxicity" ]
"pibrentasvir" : [ "Risk Of Hepatitis B Virus Reactivation In Patients Coinfected With Hcv And Hbv" ]
"plecanatide" : [ "Risk Of Serious Dehydration In Pediatric Patients" ]
"pomalidomide" : [ "Embryo-fetal Toxicity And Venous And Arterial Thromboembolism" ]
"ponatinib" : [ "Arterial Occlusion, Venous Thromboembolism, Heart Failure And Hepatotoxicity" ]
"raloxifene" : [ "Increased Risk Of Venous Thromboembolism And Death From Stroke " ]
"ramucirumab" : [ "Hemorrhage, Gastrointestinal Perforation, And Impaired Wound Healing " ]
"regorafenib" : [ "Hepatotoxicity" ]
"reslizumab" : [ "Anaphylaxis" ]
"rituximab" : [ "Fatal Infusion Reactions, Severe  Mucocutaneous Reactions, Hepatitis B Virus  Reactivation And Progressive Multifocal  Leukoencephalopathy" ]
"sarilumab" : [ "Risk Of Serious Infections" ]
"sirolimus" : [ "Immunosuppression, Use Is Not Recommended In Liver Or Lung Transplant Patients" ]
"sonidegib" : [ "Embryo-fetal Toxicity" ]
"sulindac" : [ "Cardiovascular Risk, Gastrointestinal Risk" ]
"sunitinib" : [ "Hepatotoxicity " ]
"tamoxifen" : [ "Uterine Malignancies, Stroke, Pulmonary Embolism" ]
"teniposide" : [ "Warning (no Title Provided)" ]
"tocilizumab" : [ "Risk Of Serious Infections" ]
"tofacitinib" : [ "Serious Infections And Malignancy" ]
"topotecan" : [ "Bone Marrow Suppression" ]
"toremifene" : [ "Qt Prolongation" ]
"tositumomab" : [ "Serious Allergic Reactions/anaphylaxis, Prolonged And Severe Cytopenias, And Radiation Exposure" ]
"trastuzumab" : [ "Cardiomyopathy, Infusion Reactions, Embryo-fetal Toxicity And Pulmonary Toxicity." ]
"vandetanib" : [ "Qt Prolongation, Torsades De Pointes, And Sudden Death" ]
"vinorelbine" : [ "Myelosuppression  " ]
"vismodegib" : [ "Embryo-fetal Toxicity" ]
"voxilaprevir" : [ "Risk Of Hepatitis B Virus Reactivation In  Patients Coinfected With Hcv And Hbv" ]
"ziv-aflibercept" : [ "Hemorrhage, Gastrointestinal Perforation, Compromised Wound Healing" ]
]
*/

/*
var approvedCombo : [String: [String: Int]] =

"abarelix" : "prostate cancer"

abemaciclib + fulvestrant : breast
abiraterone : CRPC or CSPC ( castration-resistant prostate cancer, castration-sensitive prostate cancer)
adalimumab
ado-trastuzumab emtansine : breast : HER2-positive
afatinib : NSCLC : EGFR
alectinib :NSCLC : ALK-positive
asparaginase: ALL
atezolizumab: urothelial carcinoma, NSCLC
avelumab: urothelial carcinoma , Merkel cell carcinoma (MCC)
axitinib: renal cell carcinoma
belinostat: peripheral T-cell lymphoma (PTCL)
bevacizumab + irinotecan : colorectal, glioblastoma
bevacizumab + topotecan : servical
bexarotene : T-cell lymphoma
bicalutamide : prostate
bleomycin : Squamous Cell Carcinoma, Hodgkin’s disease, non-Hodgkin’s lymphoma, Testicular Carcinoma, Malignant Pleural Effusion

blinatumomab: ALL
bortezomib: multiple myeloma, mantle cell lymphoma
bosutinib: CML
brentuximab vedotin: Hodgkin lymphoma, systemic anaplastic large cell lymphoma
brigatinib: NSCLC
cabozantinib: advanced renal cell carcinoma (RCC)
carfilzomib + lenalidomide + dexamethasone: multiple myeloma
carmustine: Brain tumors glioblastoma, brainstem glioma, medulloblastoma,
astrocytoma, ependymoma, and metastatic brain tumors, Hodgkin's lymphoma
carmustine + prednisone : multiple myeloma
ceritinib : NSCLC : ALK
cetuximab + platinum : Head and Neck
cetuximab + folfiri  : Colorectal
cetuximab +irinotecan             : Colorectal
clofarabine: ALL 1-21 yo
cobimetinib + vemurafenib: melanoma : BRAF V600E, BRAF V600K
copanlisib : follicular lymphoma (FL)
crizotinib : NSCLC : ALK + ROS1-positive
dabrafenib :melanoma , NSCLC , anaplastic thyroid cancer (ATC) : BRAF V600E
daratumumab + bortezomib, melphalan and prednisone : multiple myeloma
dasatinib : Philadelphia chromosome-positive (Ph+) (CML), Ph+ ALL
degarelix : Prostate
durvalumab : NSCLG,  urothelial carcinoma, PD-L1
enasidenib : AML
enzalutamide : castration-resistant prostate cancer
eribulin : breast, liposarcoma
erlotinib : NSCLC
*/




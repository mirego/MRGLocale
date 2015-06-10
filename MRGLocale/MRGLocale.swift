//
//  MRGLocale.swift
//  MRGLocale
//
//  Created by Daniel Levesque on 2015-03-18.
//  Copyright (c) 2015 Mirego. All rights reserved.
//

import Foundation

func MRGString(key:String) -> String {
    return MRGLocale.sharedInstance().localizedStringForKey(key)
}
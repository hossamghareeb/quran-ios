//
//  Sura.swift
//  Quran
//
//  Created by Mohamed Afifi on 4/22/16.
//  Copyright © 2016 Quran.com. All rights reserved.
//

import Foundation


struct Sura: QuranPageReference {
    let order: Int
    let isMAkki: Bool
    let numberOfAyahs: Int
    let startPageNumber: Int
}

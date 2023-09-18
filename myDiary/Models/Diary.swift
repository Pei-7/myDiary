//
//  Diary.swift
//  myDiary
//
//  Created by 陳佩琪 on 2023/9/17.
//

import Foundation

struct Diary: Codable {
    var records: [Records]?
}

struct Records: Codable {
    var id: String?
    var fields: Fields?
}

struct Fields: Codable {
    var date: String?
    var mood: String?
    var eat: String?
    var special: String?
    var plan: String?
//    var pictureURL: String?
}

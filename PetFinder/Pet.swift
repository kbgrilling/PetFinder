//
//  Pet.swift
//  PetFinder
//
//  Created by KENNETH BLUE on 9/28/18.
//  Copyright © 2018 Kenneth Blue. All rights reserved.
//

class PetsResultArray: Codable, CustomStringConvertible {
	var description: String
	
	var lastOffset = 0
	var pets = [Pet]()
	
}

class Pet: Codable {
	var name: String?
	var description: String?
	var thumbnailImageURL: String?
	var imageURL: String?
}



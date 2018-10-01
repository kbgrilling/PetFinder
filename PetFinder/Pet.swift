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
	var id: String?
	var name: String?
	var description: String?
	var thumbnailImageURL: String?
	var imageURL: String?
	var phoneNumber: String?
	var address1: String?
	var address2: String?
	var city: String?
	var state: String?
	var zip: String?
	var email: String?
	var age: String?
	var size: String?
	var gender: String?
	var breed: [String] = []
	
}



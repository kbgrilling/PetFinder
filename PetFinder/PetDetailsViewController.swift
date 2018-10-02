//
//  PetDetailsViewController.swift
//  PetFinder
//
//  Created by KENNETH BLUE on 10/1/18.
//  Copyright © 2018 Kenneth Blue. All rights reserved.
//

import UIKit

class PetDetailsViewContoller: UIViewController {
	
	@IBOutlet weak var PetAgeLabel: UILabel!
	@IBOutlet weak var PetSizeLabel: UILabel!
	@IBOutlet weak var PetGenderLabel: UILabel!
	@IBOutlet weak var PetBreedLabel: UILabel!
	@IBOutlet weak var PetDescriptionLabel: UILabel!
	@IBOutlet weak var ContactLabel: UILabel!
	@IBOutlet weak var ShelterEmailLabel: UILabel!
	@IBOutlet weak var ShelterPhoneLabel: UILabel!
	@IBOutlet weak var ShelterAddressLabel: UILabel!
	@IBOutlet weak var PetImageView: UIImageView!
	
	
	var thisPet = Pet()
	var imageDownloadTask: URLSessionDownloadTask?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = thisPet.name
		PetDescriptionLabel.text = thisPet.description
		PetAgeLabel.text = "Age: \(thisPet.age!)"
		PetSizeLabel.text = "Size: \(thisPet.size!)"
		PetGenderLabel.text = "Gender: \(thisPet.gender!)"
		PetBreedLabel.text = "Breed:"
		if thisPet.breed.count == 1 {
			PetBreedLabel.text = "Breed: \(thisPet.breed[0])"
		} else if thisPet.breed.count > 1{
			for (index, breed) in thisPet.breed.enumerated() {
				if index == 0 {
					PetBreedLabel.text! += " \(breed)"
				} else {
					PetBreedLabel.text! += ", \(breed)"
				}
				
			}
		} else {
			PetBreedLabel.text! += " Unknown"
		}
		PetBreedLabel.sizeToFit()
		PetDescriptionLabel.sizeToFit()
		
		if let petEmail = thisPet.email {
			ShelterEmailLabel.text = petEmail
		} else {
			ShelterEmailLabel.text = " "
		}
		
		if let petPhone = thisPet.phoneNumber {
			ShelterPhoneLabel.text = petPhone
		} else {
			ShelterPhoneLabel.text = " "
		}
		if let petAddress = thisPet.address1, let petCity = thisPet.city, let petState = thisPet.state, let petZip = thisPet.zip {
			ShelterAddressLabel.text = "\(petAddress)\n\(petCity), \(petState) \(petZip)"
		}
		ContactLabel.text = "Contact \(thisPet.name!)"
		
		
		if let bigImageURL = thisPet.imageURL {
			let imageURL = URL(string: bigImageURL)
			imageDownloadTask = PetImageView.loadImage(url: imageURL!)
			
		} else {
			PetImageView.image = UIImage(named: "NOICON")
		}
	}
	
	
}

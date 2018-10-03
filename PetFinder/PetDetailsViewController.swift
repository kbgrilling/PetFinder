//
//  PetDetailsViewController.swift
//  PetFinder
//
//  Created by KENNETH BLUE on 10/1/18.
//  Copyright © 2018 Kenneth Blue. All rights reserved.
//

import UIKit
import MapKit

class PetDetailsViewContoller: UIViewController {
	
	@IBOutlet weak var PetAgeLabel: UILabel!
	@IBOutlet weak var PetSizeLabel: UILabel!
	@IBOutlet weak var PetGenderLabel: UILabel!
	@IBOutlet weak var PetBreedLabel: UILabel!
	@IBOutlet weak var PetImageView: UIImageView!
	@IBOutlet weak var PetContactDescriptionTableView: UITableView!
	//pet object received from pet search VC
	var thisPet = Pet()
	//download task for images
	var imageDownloadTask: URLSessionDownloadTask?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = thisPet.name
		
		PetAgeLabel.text = "Age: \(thisPet.age!)"
		PetSizeLabel.text = "Size: \(thisPet.size!)"
		PetGenderLabel.text = "Gender: \(thisPet.gender!)"
		PetBreedLabel.text = "Breed:"
		//loop thourgh breed array. Check to see if there are multiple breeds
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

		
		if let bigImageURL = thisPet.imageURL {
			let imageURL = URL(string: bigImageURL)
			imageDownloadTask = PetImageView.loadImage(url: imageURL!)
			
		} else {
			PetImageView.image = UIImage(named: "NOICON")
		}
		//allows the description row to be dynamic in height
		PetContactDescriptionTableView.rowHeight = UITableView.automaticDimension
		PetContactDescriptionTableView.estimatedRowHeight = 44
	}
	
	
}

extension PetDetailsViewContoller: UITableViewDelegate, UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 3
		default:
			return 1
		}
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "Contact \(thisPet.name!)"
		default:
			return "\(thisPet.name!)'s Description"
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		//tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath)
		if indexPath.section == 0 {
			
			let cell = tableView.dequeueReusableCell(withIdentifier: "shelterContactCell", for: indexPath)
			let contactTypeLabel = cell.viewWithTag(2000) as! UILabel
			let contactLabel = cell.viewWithTag(2001) as! UILabel
			switch indexPath.row {
			case 0:
				contactTypeLabel.text = "Email"
				if let petEmail = thisPet.email {
					contactLabel.text = petEmail
				} else {
					contactLabel.text = "No Email :("
				}
				//return cell
			case 1:
				contactTypeLabel.text = "Phone"
				if let petPhone = thisPet.phoneNumber {
					contactLabel.text = petPhone
				} else {
					contactLabel.text = "No Phone"
				}
				
			case 2:
				contactTypeLabel.text = "Address"
				if let petAddress = thisPet.address1, let petCity = thisPet.city, let petState = thisPet.state, let petZip = thisPet.zip {
					contactLabel.text = "\(petAddress), \(petCity), \(petState) \(petZip)"
				} else {
					contactLabel.text = "Address missing"
				}
			default:
				contactLabel.text = "Information is missing."
				contactTypeLabel.text = "Missing info."
			}
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "petDescriptionCell", for: indexPath)
			let petDescriptionLabel = cell.viewWithTag(2002) as! UILabel
			petDescriptionLabel.text = thisPet.description
			
			return cell
		}
		
	
	}
	
	
}


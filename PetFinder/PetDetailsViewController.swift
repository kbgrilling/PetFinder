//
//  PetDetailsViewController.swift
//  PetFinder
//
//  Created by KENNETH BLUE on 10/1/18.
//  Copyright © 2018 Kenneth Blue. All rights reserved.
//

import UIKit

class PetDetailsViewContoller: UIViewController {
	
	
	@IBOutlet weak var PetDescriptioin: UILabel!
	@IBOutlet weak var PetImageView: UIImageView!
	
	var thisPet = Pet()
	var imageDownloadTask: URLSessionDownloadTask?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.title = thisPet.name
		PetDescriptioin.text = thisPet.description
		if let bigImageURL = thisPet.imageURL {
			let imageURL = URL(string: bigImageURL)
			imageDownloadTask = PetImageView.loadImage(url: imageURL!)
			
		} else {
			PetImageView.image = UIImage(named: "NOICON")
		}
	}
	
	
}

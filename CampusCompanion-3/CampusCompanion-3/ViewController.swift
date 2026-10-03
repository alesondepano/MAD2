//
//  ViewController.swift
//  CampusCompanion-3
//
//  Created by alesondepano on 10/3/26.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "Campus Companion"
        imageView.image = UIImage(systemName: "graduationcap.fill")
        imageView.tintColor = .systemBlue
        imageView.accessibilityLabel = "Campus Companion graduation cap"
    }

    @IBAction func getStartedTapped(_ sender: UIButton) {
        subtitleLabel.text = "Let's get started!"
    }
}

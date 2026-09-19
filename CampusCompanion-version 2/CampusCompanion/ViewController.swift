import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var getStartedButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = "Campus Companion"
    }

    @IBAction func getStartedPressed(_ sender: UIButton) {

        subtitleLabel.text = "Let's get started!"

        titleLabel.textColor = .systemBlue

        getStartedButton.setTitle("Welcome!", for: .normal)

        view.backgroundColor = .systemYellow
    }
    
    @IBAction func exploreButtonTapped(_ sender: UIButton) {
    performSegue(withIdentifier: "ShowDetailSegue", sender: self)
    }
}

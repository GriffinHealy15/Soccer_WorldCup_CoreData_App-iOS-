    //
    //  TeamCell.swift
    //  WorldCup
    //
    //  Created by Griffin Healy on 3/15/19.
    //  Copyright © 2019 Griffin Healy. All rights reserved.
    //

import UIKit

class TeamCell: UITableViewCell {

  // MARK: - IBOutlets
  @IBOutlet weak var teamLabel: UILabel!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var flagImageView: UIImageView!

  // MARK: - View Life Cycle
  override func prepareForReuse() {
    super.prepareForReuse()

    teamLabel.text = nil
    scoreLabel.text = nil
    flagImageView.image = nil
  }
}

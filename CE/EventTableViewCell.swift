//Event App with data from veranstaltungen.kaernten.at
//Copyright (C) 2015  Raphael Seher
//
//This program is free software; you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation; either version 2 of the License, or
//(at your option) any later version.
//
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License along
//with this program; if not, write to the Free Software Foundation, Inc.,
//51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

import UIKit

class EventTableViewCell: UITableViewCell {
  
  @IBOutlet weak var eventImageView: UIImageView!
  @IBOutlet weak var eventTitleLabel: UILabel!
  @IBOutlet weak var eventCategorieLabel: UILabel!
  @IBOutlet weak var eventLocationLabel: UILabel!
  @IBOutlet weak var eventStartDate: UILabel!
  @IBOutlet weak var eventEndDate: UILabel!
  @IBOutlet weak var eventStartDateLabel: UILabel!
  @IBOutlet weak var eventEndDateLabel: UILabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

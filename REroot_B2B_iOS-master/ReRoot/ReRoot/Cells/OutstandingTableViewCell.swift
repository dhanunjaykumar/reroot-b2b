//
//  OutstandingTableViewswift
//  REroot
//
//  Created by Dhanunjay Kumar Mocharla on 19/11/19.
//  Copyright © 2019 ReRoot. All rights reserved.
//

import UIKit

class OutstandingTableViewCell: UITableViewCell {

    @IBOutlet weak var moreThanNinetyDaysLabel: UILabel!
    @IBOutlet weak var sixtyToNinetyDaysLabel: UILabel!
    @IBOutlet weak var thirtyToSixtyDaysLabel: UILabel!
    @IBOutlet weak var thirtyDaysLabel: UILabel!
    @IBOutlet weak var receivedAmountLabel: UILabel!
    @IBOutlet weak var invoiceAmountLabel: UILabel!
    @IBOutlet weak var addFollowUpButton: UIButton!
    @IBOutlet weak var timelineButton: UIButton!
    @IBOutlet weak var subContentView: UIView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var whatsAppButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var cusPhoneLabel: UILabel!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var unitNameLabel: UILabel!
    @IBOutlet weak var unitDetailsLabel: UILabel!
    
    var outstandingData : CustomerOutstanding = CustomerOutstanding.init(){
        didSet{
            unitNameLabel.text = String(format: "%@ (%@)", outstandingData.unitDisplayName ?? "",outstandingData.description1 ?? "")
            unitDetailsLabel.text = String(format: "%@ | %@ | %@", outstandingData.projectName ?? "",outstandingData.blockName ?? "",outstandingData.towerName ?? "")
            customerNameLabel.text = outstandingData.customerName
            emailLabel.text = outstandingData.customerEmail
            cusPhoneLabel.text = "+" + (outstandingData.customerPhoneCode ?? "") + " " + (outstandingData.customerPhoneNumber ?? "")
            
            amountLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,((outstandingData.demandLetterAmount + outstandingData.demandLetterTax) - outstandingData.totalReceipt))
            invoiceAmountLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")! ,(outstandingData.demandLetterAmount + outstandingData.demandLetterTax))
            receivedAmountLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,outstandingData.totalReceipt)
            
            thirtyDaysLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,outstandingData.lessThanThirtyDaysAmt)
            thirtyToSixtyDaysLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,outstandingData.thirtyToSixtyDaysAmt)
            sixtyToNinetyDaysLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,outstandingData.sixtyToNinetyDaysAmt)
            moreThanNinetyDaysLabel.text = String(format: "%@ %.2f",RRUtilities.sharedInstance.getCurrencySymbol(forCurrencyCode: "INR")!,outstandingData.greaterThanNinetyDaysAmt)

        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        subContentView.layer.cornerRadius = 6
        
        subContentView.layer.cornerRadius = 4
        subContentView.layer.borderWidth = 2
        subContentView.layer.borderColor = UIColor.clear.cgColor
        subContentView.layer.shadowRadius = 4
        subContentView.layer.masksToBounds = false
        subContentView.layer.shadowOffset = CGSize(width: 0, height: 0)
        subContentView.layer.shadowRadius = 2
        subContentView.layer.shadowOpacity = 0.3

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

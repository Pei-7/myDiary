//
//  EntryViewController.swift
//  myDiary
//
//  Created by 陳佩琪 on 2023/9/17.
//

import UIKit

class EntryViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate {
    
    
    @IBOutlet var contentTableView: UITableView!
    var diaryEntries: Diary?
    var diaryFields = Fields()
    let question = ["今天還好嗎？","都吃了些什麼？","有發生什麼特別的事情嗎？","明天有什麼計畫嗎？","期待明天又是嶄新的一天！"]
    var response: [String] = []
    var cellCount = 2

    @IBOutlet var inputTextView: UITextView!
    @IBOutlet var submitButton: UIButton!
    
    @IBOutlet var inputTextViewBottomConstraint: NSLayoutConstraint!
    
    var entryID: String?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = contentTableView.dequeueReusableCell(withIdentifier: "\(DateTableViewCell.self)", for: indexPath) as! DateTableViewCell
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            cell.dateLabel.text = "─ \( dateFormatter.string(from: date)) ─"
            return cell
            
        } else if (indexPath.row-1) % 2 == 0 {
            
            let cell = contentTableView.dequeueReusableCell(withIdentifier: "\(TopicTableViewCell.self)", for: indexPath) as! TopicTableViewCell
            
            if indexPath.row  == cellCount - 1 {
                
                cell.topicTextView.text = "         "
                cell.ellipsisImageView.isHidden = false
                cell.ellipsisImageView.image = UIImage(systemName: "ellipsis")
                cell.ellipsisImageView.addSymbolEffect(.variableColor)
                
                Timer.scheduledTimer(withTimeInterval: 1.6, repeats: false) { _ in
                    cell.topicTextView.text = self.question[(indexPath.row-1)/2]
                    cell.topicTextView.setNeedsLayout()
                    cell.topicTextView.layoutIfNeeded()
                    cell.ellipsisImageView.isHidden = true
                }
            } else {
                cell.ellipsisImageView.isHidden = true
                cell.topicTextView.text = self.question[(indexPath.row-1)/2]
            }
            
            return cell
        } else {
            let cell = contentTableView.dequeueReusableCell(withIdentifier: "\(ResponseTableViewCell.self)", for: indexPath) as! ResponseTableViewCell
            if response.count > 0 {
                let index = (indexPath.row/2) - 1
                cell.responseTextView.text = response[index]
            } else {
                print("ResponseTableViewCell error")
            }

            return cell
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentTableView.dataSource = self
        contentTableView.delegate = self
        inputTextView.delegate = self
        NotificationCenter.default.addObserver(self,
        selector: #selector(keyboardWillShow),
        name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
        selector: #selector(keyboardWillHide),
        name: UIResponder.keyboardWillHideNotification, object: nil)
        
        diaryFields.data = Date()

        inputTextView.layer.borderWidth = 0.4
        inputTextView.layer.borderColor = UIColor.lightGray.cgColor
        inputTextView.layer.cornerRadius = 18
        inputTextView.clipsToBounds = true
        inputTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        inputTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -48).isActive = true
    }
    
    fileprivate func updateUI() {
        let indexPath = IndexPath(row: cellCount-1, section: 0)
        contentTableView.reloadData()
        contentTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        if cellCount > 8 {
            inputTextView.isEditable = false
            submitButton.isEnabled = false
        }
    }
    
    @IBAction func submit(_ sender: UIButton) {
        if let textContent = inputTextView.text {
            response.append(textContent)
            switch response.count {
            case 1:
                diaryFields.mood = textContent
            case 2:
                diaryFields.eat = textContent
            case 3:
                diaryFields.special = textContent
            case 4:
                diaryFields.plan = textContent
            default:
                print("error here! response.count = ",response.count)
            }
        }

        inputTextView.text = nil
        cellCount = response.count * 2 + 1
        updateUI()
        
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
            self.cellCount = (self.response.count + 1) * 2
            self.updateUI()
            
//            if self.cellCount > 8 {
//                self.inputTextView.isEditable = false
//                self.submitButton.isEnabled = false
//            }
        }
        
        print(diaryFields)
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {

            print("99999",keyboardSize.height)
            let constant = keyboardSize.height+16
                inputTextViewBottomConstraint = inputTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -constant)
                inputTextViewBottomConstraint.isActive = true

        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
            inputTextViewBottomConstraint.isActive = false
    }


    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

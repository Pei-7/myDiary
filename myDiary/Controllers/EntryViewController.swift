//
//  EntryViewController.swift
//  myDiary
//
//  Created by 陳佩琪 on 2023/9/17.
//

import UIKit

class EntryViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate {
    
    var runCount = 0
    var todaysEntryCompletion = false
    
    @IBOutlet var contentTableView: UITableView!
    var diaryRecord: Records?
    var diaryFields = Fields()
    let question = ["今天還好嗎？","都吃了些什麼？","有發生什麼特別的事情嗎？","明天有什麼計畫嗎？","期待明天又是嶄新的一天！"]
    var cellCount = 2

    @IBOutlet var inputTextView: UITextView!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var inputTextViewBottomConstraint: NSLayoutConstraint!
    
    
    var entryID: String?
    var httpMethod: String?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = contentTableView.dequeueReusableCell(withIdentifier: "\(DateTableViewCell.self)", for: indexPath) as! DateTableViewCell
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: date)
            cell.dateLabel.text = "─ \(dateString) ─"
            diaryFields.date = dateString
            return cell
            
        } else if indexPath.row % 2 != 0 {
            
            let cell = contentTableView.dequeueReusableCell(withIdentifier: "\(TopicTableViewCell.self)", for: indexPath) as! TopicTableViewCell
            let index = (indexPath.row - 1) / 2
            var timer: Timer?
            
            if indexPath.row  == cellCount - 1, todaysEntryCompletion == false {
                //                print("whoooooo",indexPath.row)
            
                cell.topicTextView.text = "         "
                cell.ellipsisImageView.isHidden = false
                cell.ellipsisImageView.image = UIImage(systemName: "ellipsis")
                cell.ellipsisImageView.addSymbolEffect(.variableColor)
                timer = Timer.scheduledTimer(withTimeInterval: 1.6, repeats: false) { _ in
                    DispatchQueue.main.async {
                        if self.todaysEntryCompletion == false {
                            cell.topicTextView.text = self.question[index]
                            //print("*****",indexPath.row,index,self.question[index])
                            cell.topicTextView.setNeedsLayout()
                            cell.topicTextView.layoutIfNeeded()
                            cell.ellipsisImageView.isHidden = true
                            }
                        }
                    }
                } else {
                    cell.ellipsisImageView.isHidden = true
                    cell.topicTextView.text = self.question[index]
                }

            print("55555","todaysEntryCompletion",todaysEntryCompletion,cellCount,indexPath.row,index,self.question[index])

            return cell
        } else {
            let cell = contentTableView.dequeueReusableCell(withIdentifier: "\(ResponseTableViewCell.self)", for: indexPath) as! ResponseTableViewCell
            
                let response = [diaryFields.mood,diaryFields.eat,diaryFields.special,diaryFields.plan]
                let index = (indexPath.row/2) - 1
                cell.responseTextView.text = response[index]
           
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
        
        inputTextView.layer.borderWidth = 0.4
        inputTextView.layer.borderColor = UIColor.lightGray.cgColor
        inputTextView.layer.cornerRadius = 18
        inputTextView.clipsToBounds = true
        inputTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        inputTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -48).isActive = true
        
        checkTodaysEntry { _ in
            DispatchQueue.main.async {
                print("4444 cellCount",self.cellCount)
                if self.cellCount == 10 {
                    self.todaysEntryCompletion = true
                }
                self.updateUI()
            }
        }
        
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {

//            print("99999",keyboardSize.height)
            let constant = keyboardSize.height+16
                inputTextViewBottomConstraint = inputTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -constant)
                inputTextViewBottomConstraint.isActive = true

        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
            inputTextViewBottomConstraint.isActive = false
    }


    
    fileprivate func updateUI() {
        print("88888 cellCount",cellCount)
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
            switch cellCount {
            case 2:
                diaryFields.mood = textContent
            case 4:
                diaryFields.eat = textContent
            case 6:
                diaryFields.special = textContent
            case 8:
                diaryFields.plan = textContent
            default:
                print("diaryFields update error",cellCount,textContent)
            }
        }

        inputTextView.text = nil
        cellCount += 1
        print("66666 cellCount",cellCount)
        updateUI()
        
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
            if self.httpMethod == "POST" {
                self.cellCount += 1
            } else {
                self.cellCount += 2
            }
            print("77777 cellCount",self.cellCount)
            self.updateUI()
        }
        
        checkTodaysEntry { id in
            if let id {
                self.httpMethod = "PUT"
            } else {
                self.httpMethod = "POST"
            }
            self.updateEntry()
        }
        
    }
    

    func checkTodaysEntry(completion: @escaping (String?) -> Void) {
        
        let urlString = "https://api.airtable.com/v0/appI4Y35bwZbDskfU/Diary"
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Bearer patPNWqWJBv5mGaXK.5f39bcb46ee41efb4907b6c5714bf6a90967a531a02d74e50f396d8e831a0b9f", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            let decoder = JSONDecoder()
            if let data {
                do {
                    let entries = try decoder.decode(Diary.self, from: data)
                    if let records = entries.records {
                        for record in records {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let date = dateFormatter.string(from: Date())
//                            print("date check:",record.fields?.date,date)
                            if record.fields?.date == date {
                                self.diaryRecord = record
                                self.updateCellCount()
                                self.entryID = record.id
                            }
                        }
                        completion(self.entryID)
//                        print("diaryRecord",self.diaryRecord)
                    }
                } catch {
                    print("decoder error",error)
                    completion(nil)
                }
            }
        }.resume()
        
    }
    
    
    func updateCellCount() {
        if let mood = diaryRecord?.fields?.mood {
            cellCount = 4
            diaryFields.mood = mood
        }
        if let eat = diaryRecord?.fields?.eat {
            cellCount = 6
            diaryFields.eat = eat
        }
        if let special = diaryRecord?.fields?.special {
            cellCount = 8
            diaryFields.special = special
        }
        if let plan = diaryRecord?.fields?.plan {
            cellCount = 10
            diaryFields.plan = plan
        }
        print("updateCellCount",cellCount)
    }
    
    func updateEntry() {
        runCount += 1
        print("runCount:",runCount)
        
        var entryToUpdate = Diary()
        var record = Records(fields: diaryFields)
        entryToUpdate.records = [record]
        if let entryID {
            entryToUpdate.records?[0].id = entryID
        }
//        print("99999",httpMethod,entryToUpdate.records)
        
        let urlString = "https://api.airtable.com/v0/appI4Y35bwZbDskfU/Diary"
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        print("httpMethod",httpMethod)
        urlRequest.httpMethod = httpMethod
        urlRequest.setValue("Bearer patPNWqWJBv5mGaXK.5f39bcb46ee41efb4907b6c5714bf6a90967a531a02d74e50f396d8e831a0b9f", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(entryToUpdate)
            urlRequest.httpBody = data
//            print("* update content:",String(data: urlRequest.httpBody!, encoding: .utf8) ?? "post error")
        } catch {
            print("encode error",error)
        }
    
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                            print("* HTTP Status Code: \(httpResponse.statusCode)")
                        }
            if let data, let response = String(data: data, encoding: .utf8) {
//                print("00000",response)
            }

        }.resume()
        
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

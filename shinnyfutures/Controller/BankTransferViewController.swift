//
//  BankTransferViewController.swift
//  shinnyfutures
//
//  Created by chenli on 2018/8/30.
//  Copyright © 2018年 shinnytech. All rights reserved.
//

import UIKit
import SwiftyJSON
import DeepDiff

class BankTransferViewController:  UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    // MARK: Properties
    var transfers = [JSON]()
    let dataManager = DataManager.getInstance()
    let dateFormat = DateFormatter()
    var isRefresh = true
    var bankIds = [String]()
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var future_password: UITextField!
    @IBOutlet weak var bank_password: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var bank_label: UILabel!
    @IBOutlet weak var currency_label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormat.dateFormat = "HH:mm:ss"

        //Configure the bank
        let bank = DropDownBtn.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        bank.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        bank.setTitle("银行列表加载中...", for: .normal)
        bank.contentHorizontalAlignment = .left
        bank.translatesAutoresizingMaskIntoConstraints = false
        bank.tag = 101

        //Add bank to the View Controller
        self.view.addSubview(bank)

        //bank Constraints, add width/height constrait to itself, add left/right/top/bottom to superVierw
        bank.superview?.addConstraint(NSLayoutConstraint.init(item: bank, attribute: .left, relatedBy: .equal, toItem: future_password, attribute: .left, multiplier: 1.0, constant: 0))
        bank.superview?.addConstraint(NSLayoutConstraint.init(item: bank, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: -20))
        bank.superview?.addConstraint(NSLayoutConstraint.init(item: bank, attribute: .top, relatedBy: .equal, toItem: bank_label, attribute: .top, multiplier: 1.0, constant: 0))
        bank.heightAnchor.constraint(equalToConstant: 30).isActive = true

        //Configure the bank
        let currency = DropDownBtn.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        currency.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        currency.setTitle("币种列表加载中...", for: .normal)
        currency.contentHorizontalAlignment = .left
        currency.translatesAutoresizingMaskIntoConstraints = false
        currency.tag = 102

        //Add bank to the View Controller
        self.view.addSubview(currency)

        //bank Constraints, add width/height constrait to itself, add left/right/top/bottom to superVierw
        currency.superview?.addConstraint(NSLayoutConstraint.init(item: currency, attribute: .left, relatedBy: .equal, toItem: future_password, attribute: .left, multiplier: 1.0, constant: 0))
        currency.superview?.addConstraint(NSLayoutConstraint.init(item: currency, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: -20))
        currency.superview?.addConstraint(NSLayoutConstraint.init(item: currency, attribute: .top, relatedBy: .equal, toItem: currency_label, attribute: .top, multiplier: 1.0, constant: 0))
        currency.heightAnchor.constraint(equalToConstant: 30).isActive = true

        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {

        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: Notification.Name(CommonConstants.RtnTDNotification), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: Notification.Name(CommonConstants.RtnTDNotification), object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        print("银期转帐页销毁")
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        future_password.resignFirstResponder()
        bank_password.resignFirstResponder()
        amount.resignFirstResponder()
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return transfers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "BankTransferTableViewCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BankTransferTableViewCell  else {
            fatalError("The dequeued cell is not an instance of BankTransferTableViewCell.")
        }


        if transfers.count != 0 {
            let transfer = transfers[indexPath.row]
            let datetime = transfer[TransferConstants.datetime].doubleValue
            let date = Date(timeIntervalSince1970: (datetime / 1000000000))
            cell.datetime.text = dateFormat.string(from: date)
            let amount = transfer[TransferConstants.amount].floatValue
            if amount > 0 {cell.amount.textColor = UIColor.red}
            else {cell.amount.textColor = UIColor.green}
            cell.amount.text = "\(amount)"
            let currency = transfer[TransferConstants.currency].stringValue
            cell.currency.text = currency
            let result = transfer[TransferConstants.error_msg].stringValue
            cell.result.text = result
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 35.0))
        headerView.backgroundColor = UIColor.darkGray
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 35.0))
        stackView.distribution = .fillEqually
        let datetime = UILabel()
        datetime.text = "转账时间"
        datetime.textAlignment = .center
        let amount = UILabel()
        amount.text = "转账金额"
        amount.textAlignment = .right
        let currency = UILabel()
        currency.text = "币种"
        currency.textAlignment = .center
        let result = UILabel()
        result.text = "转账结果"
        result.textAlignment = .center
        stackView.addArrangedSubview(datetime)
        stackView.addArrangedSubview(amount)
        stackView.addArrangedSubview(currency)
        stackView.addArrangedSubview(result)
        headerView.addSubview(stackView)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollToScrollStop = !scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
        if scrollToScrollStop { isRefresh = true }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let dragToDragStop = scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
            if dragToDragStop { isRefresh = true }
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isRefresh = false
    }

    // MARK: objc Methods
    @objc private func loadData() {
        let user = dataManager.sRtnTD[dataManager.sUser_id]
        let bank = self.view.viewWithTag(101) as! DropDownBtn
        let currency = self.view.viewWithTag(102) as! DropDownBtn
        if bank.dropView.dropDownOptions.isEmpty {
            let banks = user[RtnTDConstants.banks].dictionaryValue.map{$0.value}
            for bankData in banks {
                bankIds.append(bankData[BankConstants.id].stringValue)
                bank.dropView.dropDownOptions.append(bankData[BankConstants.name].stringValue)
                bank.dropView.tableView?.reloadData()
            }
            if !banks.isEmpty{
                bank.dropView.selected_index = 0
                bank.setTitle(bank.dropView.dropDownOptions[0], for: .normal)
            }else{
                bank.setTitle("无", for: .normal)
            }
        }

        if currency.dropView.dropDownOptions.isEmpty {
            let currencies = user[RtnTDConstants.accounts].dictionaryValue.map{$0.key}
            for currencyData in currencies {
                currency.dropView.dropDownOptions.append(currencyData)
                currency.dropView.tableView?.reloadData()
            }
            if !currencies.isEmpty{
                currency.dropView.selected_index = 0
                currency.setTitle(currency.dropView.dropDownOptions[0], for: .normal)
            }else{
                currency.setTitle("无", for: .normal)
            }
        }

        if !isRefresh{return}
        let transfers_tmp = user[RtnTDConstants.transfers].dictionaryValue.sorted{ $0.value[TransferConstants.datetime].stringValue > $1.value[TransferConstants.datetime].stringValue }.map {$0.value}

        if transfers.count == 0 {
            transfers = transfers_tmp
            tableview.reloadData()
        } else {
            let oldData = transfers
            transfers = transfers_tmp
            let change = diff(old: oldData, new: transfers)
            tableview.reload(changes: change, section: 0, insertionAnimation: .none, deletionAnimation: .none, replacementAnimation: .none, completion: {_ in})
        }

    }

    //MARK: Actions
    @IBAction func future_bank(_ sender: UIButton) {
        transfer(direction: false)
    }

    @IBAction func bank_future(_ sender: UIButton) {
        transfer(direction: true)
    }

    func transfer(direction: Bool) {
        let future_account = dataManager.sUser_id
        if future_account.isEmpty{
            ToastUtils.showNegativeMessage(message: "登录账户为空～")
            return
        }

        guard let future_password = self.future_password.text else {
            ToastUtils.showNegativeMessage(message: "资金密码为空～")
            return
        }

        guard let bank_password = self.bank_password.text else{
            ToastUtils.showNegativeMessage(message: "银行密码为空～")
            return
        }

        guard let amount = self.amount.text else {
            ToastUtils.showNegativeMessage(message: "转账金额为空～")
            return
        }

        guard let amountF = Float(amount) else {
            ToastUtils.showNegativeMessage(message: "转账金额格式错误～")
            return
        }

        let bankBtn = self.view.viewWithTag(101) as! DropDownBtn
        if bankBtn.dropView.selected_index == -1 || bankIds.isEmpty || bankBtn.dropView.selected_index >= bankIds.count{
            ToastUtils.showNegativeMessage(message: "没有绑定银行或银行列表没有正确加载～")
            return
        }
        let bank_id = bankIds[bankBtn.dropView.selected_index]

        let currencyBtn = self.view.viewWithTag(102) as! DropDownBtn
        if currencyBtn.dropView.selected_index == -1 || currencyBtn.dropView.dropDownOptions.isEmpty || currencyBtn.dropView.selected_index >= currencyBtn.dropView.dropDownOptions.count{
            ToastUtils.showNegativeMessage(message: "币种列表没有正确加载～")
            return
        }
        let currency = currencyBtn.dropView.dropDownOptions[currencyBtn.dropView.selected_index]

        if direction {
            TDWebSocketUtils.getInstance().sendReqBankTransfer(future_account: future_account, future_password: future_password, bank_id: bank_id, bank_password: bank_password, currency: currency, amount: fabsf(amountF))
        }else{
            TDWebSocketUtils.getInstance().sendReqBankTransfer(future_account: future_account, future_password: future_password, bank_id: bank_id, bank_password: bank_password, currency: currency, amount: -fabsf(amountF))
        }

    }

    @IBAction func futurePasswordDone(_ sender: UITextField) {
        future_password.resignFirstResponder()
    }

    @IBAction func bankPasswordDone(_ sender: UITextField) {
        bank_password.resignFirstResponder()
    }

    @IBAction func amountDone(_ sender: UITextField) {
        amount.resignFirstResponder()
    }
}

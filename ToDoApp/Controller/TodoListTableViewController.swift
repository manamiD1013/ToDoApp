//
//  TodoListTableViewController.swift
//  ToDoApp
//
//  Created by 土井　麻菜美 on 2018/08/21.
//  Copyright © 2018年 Manami. All rights reserved.
//

import UIKit

import UserNotifications
@objc protocol ListDelegate {
    
    func todoCount()
   
    }
class TodoListTableViewController: UITableViewController, MyDelegate{
    @IBOutlet var customTableView: UITableView!
    weak static var delegate: ListDelegate? = nil
    //TodoCollectionクラスのインスタンスを定義
    let todoCollection = TodoCollection.sharedInstance
    var todo = Todo()
    let sectionTitles:NSArray = ["action","complete"]
    var checkedTodoList:[Bool] = []
     var indexNum:[Int] = []
    let saveString = "checkList"
    let test:[Todo] = []
    static let sharedInstance = TodoListTableViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        ContainerViewController.delegate = self
        todoCollection.fetchTodos()
       todoCollection.completefetchTodos()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section] as? String
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.todoCollection.todos.count
        } else if section == 1 {
            return self.todoCollection.completeTodos.count
        } else {
            return 0
        }
    }
    //セルの中に表示される内容を指定
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = customTableView.dequeueReusableCell(withIdentifier: "customCell") as!  TableViewCell
        if indexPath.section == 0{
            if !self.todoCollection.todos.isEmpty{
                let todo = self.todoCollection.todos[indexPath.row]
                cell.cellLabel.text = todo.title
                cell.descriptLabel.text = todo.descript
                cell.dateLabel.text = todo.date
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
        }else {
            if !self.todoCollection.completeTodos.isEmpty{
                let todo = self.todoCollection.completeTodos[indexPath.row]
                cell.cellLabel.text = todo.title
                cell.descriptLabel.text = todo.descript
                cell.dateLabel.text = todo.date
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            let todo = self.todoCollection.todos[indexPath.row]
                todo.todoDone = true
                let i = self.todoCollection.todos[indexPath.row]
                self.todoCollection.todos.remove(at: indexPath.row)
                self.todoCollection.addCompleteTodos(todo: i)
                print(self.todoCollection.completeTodos)
                self.tableView.reloadData()
                TodoListTableViewController.delegate?.todoCount()
        }else{
            let todo = self.todoCollection.completeTodos[indexPath.row]
                todo.todoDone = false
                let i = self.todoCollection.completeTodos[indexPath.row]
                self.todoCollection.completeTodos.remove(at: indexPath.row)
                self.todoCollection.addTodoCollection(todo: i)
                self.tableView.reloadData()
                TodoListTableViewController.delegate?.todoCount()
        }
        self.todoCollection.save()
        self.todoCollection.completeSave()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        self.tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        customTableView.estimatedRowHeight = 20 //セルの高さ
        return UITableViewAutomaticDimension //自動設定
    }
    //セルをスワイプした時にボタンを表示
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 0{
            let edit = editAction(at: indexPath)
            let delete = deleteAction(at: indexPath)
            return UISwipeActionsConfiguration(actions: [delete, edit])
        }else{
            let delete = deleteAction(at: indexPath)
            return UISwipeActionsConfiguration(actions: [delete])
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //編集ボタンをクリックした時にセルの中にある情報をNewTodoViewControllerに渡す
        if segue.identifier == "Edit" {
            let nav = segue.destination as! UINavigationController
            let todoController = nav.topViewController as! NewTodoViewController
            todoController.editTodoTitle = todo.title
            todoController.editDescription = todo.descript
            todoController.editDate = todo.date
            todoController.editId = todo.id
            todoController.editAble = todo.isEditAble
            todoController.pathIdRow = todo.todoId
            todoController.pathIdSection = todo.todoSelection
        }
    }
    //編集ボタンを押した時の処理
    func editAction(at indexPath: IndexPath) ->UIContextualAction {
        if indexPath.section == 0{
              todo = self.todoCollection.todos[indexPath.row]
        }
        //パスの番号を取得
        todo.todoId = indexPath.row
        todo.todoSelection = indexPath.section
        let action = UIContextualAction(style: .normal, title: "Edit") {(action, view, completation) in
          self.performSegue(withIdentifier: "Edit", sender: self)
        }
        //文字の代わりにアイコンを配置し、backgroungColorを設定
        action.image = #imageLiteral(resourceName: "edit.png")
        action.backgroundColor = UIColor(red: 216/255, green: 212/255, blue: 215/255, alpha: 1)
        return action
    }
    //deleteボタンを押して時の処理
    func deleteAction(at indexPath: IndexPath) ->UIContextualAction {
        //ローカル通知を削除するためのIDを設定
        if indexPath.section == 0{
            todo = self.todoCollection.todos[indexPath.row]
        }else{
            todo = self.todoCollection.completeTodos[indexPath.row]
        }
        let id = "\(todo.id)"
        let action = UIContextualAction(style: .normal, title: "Delete"){(action, view, completation) in
            //削除をするかの確認を行うためのアラートを表示
            let alert = UIAlertController(title: "ToDoを削除しますか？", message: "削除されたToDoは復元できません", preferredStyle: UIAlertControllerStyle.alert)
          //アラートにボタンを追加
             let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
                if indexPath.section == 0{
                    self.todoCollection.todos.remove(at: indexPath.row)
                }else{
                    self.todoCollection.completeTodos.remove(at: indexPath.row)
                }
                if self.todo.todoDone{
                }else{
                    TodoListTableViewController.delegate?.todoCount()
                }
            self.todoCollection.save()
           self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.middle)
            // 通知の削除
           UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                        }
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel) { (action: UIAlertAction) in
             }
            //アラートを表示
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
            completation(true)
        }
        //文字の代わりにアイコンを配置し、backgroungColorを設定
        action.image = #imageLiteral(resourceName: "trash")
        action.backgroundColor = UIColor(red: 244/255, green: 198/255, blue: 207/255, alpha: 1)
        return action
    }
    func didTapTrashButton() {
        let todo = todoCollection.completeTodos
        //ローカル通知を削除するためのIDを設定
            for todoBool in todo{
                print(todoBool.todoDone)
                checkedTodoList.append(todoBool.todoDone)
                print(checkedTodoList)
                let alert = UIAlertController(title: "完了したToDoを削除します", message: "削除されたToDoは復元できません。\nよろしいですか？", preferredStyle: UIAlertControllerStyle.alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
                    //チェックマークが付いたセルが何番目のセルかを表すための配列
                    let index = self.checkedIndedxList(checkedList: self.checkedTodoList,tf: true)
                    let sortIndex = index.sorted(by: {$0 > $1
                    })
                    print(sortIndex)
                    for path in sortIndex{
                        let id = todo[path].id
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                       TodoListTableViewController.delegate?.todoCount()
                    }
                    self.todoCollection.completeTodos.removeAll()
                    self.customTableView.reloadData()
                    self.todoCollection.save()
                    self.indexNum = []
                    self.checkedTodoList = []
                }
                let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action: UIAlertAction) in
                    // キャンセルが押されたときの処理
                    self.dismiss(animated: true, completion: nil)
                    self.checkedTodoList.removeAll()
                    self.indexNum.removeAll()
                }
                alert.addAction(cancelAction)
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    func checkedIndedxList(checkedList: Array<Bool>,tf: Bool) -> Array<Int>{
        var i = 0
        for bool in checkedTodoList {
            if bool == tf {
                indexNum.append(i)
            }
            i += 1
        }
    return indexNum
    }
    func save(){
        let defaults1 = UserDefaults.standard
        defaults1.set(self.checkedTodoList, forKey: self.saveString)
        let defaults2 = UserDefaults.standard
        defaults2.set(self.indexNum, forKey: self.saveString)
    }
    }


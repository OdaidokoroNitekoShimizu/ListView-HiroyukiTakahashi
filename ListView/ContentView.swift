//
//  ContentView.swift
//  ListView
//
//  Created by hiroyuki takahashi on R 7/11/02.
//

import SwiftUI

struct ContentView: View {
    var body: some View {

        FirstView()
        //        SecondView()
    }
}


//リストを表示するView
struct FirstView: View {
    //"TasksData"というキーでUserDefaultsに保存されたものを監視
    @AppStorage("TasksData") private var tasksData = Data()
    // タスクを入れておくための配列
    @State var tasksArray: [Task] = []

    //画面生成時にtasksDataをデコードした値をtasksArrayに入れる
    init() {
        if let decodedTasks = try? JSONDecoder().decode([Task].self, from: tasksData) {
            _tasksArray = State(initialValue: decodedTasks) //@State var tasksArrayという変数のため
            print(tasksArray)
        }
    }

    var body: some View {
        NavigationStack{//画面の管理等に使用する
            //"Add New TaskをタップするとSecondViewへ遷移するようにリンク設定"
            NavigationLink {
                SecondView(tasksArray: $tasksArray)
                    .navigationTitle(Text("Add Task"))
            } label: {//見た目の部分
                Text("Add New Task")
                    .font(.system(size: 20,weight: .bold))
                    .padding()
            }

            List {
                //ExampleTask中のtaskListをList内にForEachを使ってすべて表示
                //                ExampleTask().taskList//設計図にあるものを実体化するそのなかでtaskListにアクセスする。
                //task = 掃除
                //ForEachを使う際はid 識別子が必要 1,2,3とか番号ではなく
                //                id: \.selfを使って付与する
                //Identifiable構造体の場合はid: \.self不要

                //tasksArrayの中身をリストに表示

                ForEach(tasksArray) { task in
                    Text(task.taskItem)
                }

                .onMove { from,to in
                    //リストを並べ替えたときに実行する処理
                    replaceRow(from, to)
                }
                .onDelete(perform: remove)


            }
            .toolbar(content: {
                EditButton()
            })

            .navigationTitle("Task List")//ナビゲーションのタイトル
        }
        .padding()
    }

    //並び替え処理と並び替え後の保存
    func replaceRow(_ from: IndexSet, _ to: Int){
        tasksArray.move(fromOffsets: from, toOffset: to) //配列内での並び替え
        if let encodedArray = try? JSONEncoder().encode(tasksArray) {
            tasksData = encodedArray // エンコードできたらAppStorageに渡す(保存・更新)
        }
    }

    func remove(index: IndexSet) {
        tasksArray.remove(atOffsets: index)
        if let encodedArray = try? JSONEncoder().encode(tasksArray) {
            tasksData = encodedArray // エンコードできたらAppStorageに渡す(保存・更新)
        }
    }
}

//タスク追加画面の構造体
struct SecondView: View {
    //1つ前の画面に戻るための変数dismissを定義
    @Environment(\.dismiss) private var dismiss
    // テキストフィールドに入力された文字を格納する変数
    @State private var task: String = ""
    //Taskの配列
    //    @State var tasksArray: [Task] = []
    @Binding var tasksArray: [Task]


    var body: some View {

        //        Text("エラー回避用")//エラー回避のため、後で消す
        //Taskを入力するフィールド
        TextField("Enter your task", text: $task)//Binding<String>*/が出る時は＠がつく変数を用意しないといけない
            .textFieldStyle(.roundedBorder)
            .padding()
        //タスク追加ボタン
        Button {
            //ボタンを押した時の処理
            addTask(newTask: task)
            task = "" //テキストフィールドの初期化
            print(tasksArray) //tasksArrayの中身をコンソールに出力
        } label: {
            Text("Add")
        }
        .buttonStyle(.borderedProminent)
        .tint(.teal)
        .padding()

        Spacer() //スペースを埋める
    }

    //Task保存追加の関数
    //引数を受け取りたいので新しいnewTaskをつける
    func addTask(newTask: String) {
        //テキストフィールドが空白ではないときだけ処理
        if !newTask.isEmpty {
            let task = Task(taskItem: newTask)//Task実体化　インスタンス化
            var array = tasksArray //一時的な配列arrayにtasksArrayを渡す　エンコードが必ずうまくいくとは限らない、うまくいった時だけ保存、最新の状態にする。
            array.append(task)//taskを配列arrayに追加

            //エンコードがうまくいったらUserDefaultsに保存
            if let encodedData = try? JSONEncoder().encode(array) {
                UserDefaults.standard.set(encodedData, forKey: "TasksData")//保存処理
                tasksArray = array //最新のTaskの配列をtasksArrayに反映
                dismiss()//きた道をもどる　前の画面に戻る
            }
        }
    }
}

//#Preview("SecondView") {
//    SecondView()
//}

#Preview("FirstView")  {
    FirstView()
}

#Preview {
    ContentView()
}

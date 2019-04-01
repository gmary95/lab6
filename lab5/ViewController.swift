//
//  ViewController.swift
//  lab5
//
//  Created by Mary Gerina on 3/25/19.
//  Copyright © 2019 Mary Gerina. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var NText: NSTextFieldCell!
    @IBOutlet weak var outPutTable: NSTableView!
    @IBOutlet weak var statisticsTable: NSTableView!
    
    var N = 0
    
    var timeIntervalFrequencys: [FrequencyModel] = []
    var answersFrequencys: [FrequencyModel] = []
    var timeInterviewFrequencys : [FrequencyModel] = []
    var resultArr: [ImitationModel] = []
    
    var P: Double?
    var L: Double?
    var Q: Double?
    var T: Double?
    var R: Double?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let N = 100
        
        let arr1 = [25, 35, 18, 10, 8, 4]
        let arr2 = [25, 75]
        let arr3 = [40, 45, 15]
        
        var prevProbability = 0.0
        var prevCount = 0
        for i in 0 ..< arr1.count {
            timeIntervalFrequencys.append(FrequencyModel(time: i, count: arr1[i], N: N, prevProbability: prevProbability, prevCount: prevCount))
            prevProbability = timeIntervalFrequencys[i].cumProbability
            prevCount = timeIntervalFrequencys[i].rndInterval.max + 1
        }
        
        prevProbability = 0.0
        prevCount = 0
        for i in 0 ..< arr2.count {
            answersFrequencys.append(FrequencyModel(time: i, count: arr2[i], N: N, prevProbability: prevProbability, prevCount: prevCount))
            prevProbability = answersFrequencys[i].cumProbability
            prevCount = timeIntervalFrequencys[i].rndInterval.max + 1
        }
        
        prevProbability = 0.0
        prevCount = 0
        for i in 0 ..< arr3.count {
            timeInterviewFrequencys.append(FrequencyModel(time: (i + 1) * 2, count: arr3[i], N: N, prevProbability: prevProbability, prevCount: prevCount))
            prevProbability = timeInterviewFrequencys[i].cumProbability
            prevCount = timeIntervalFrequencys[i].rndInterval.max + 1
        }
        
        print("Gen")
    }
    
    
    @IBAction func startimitation(_ sender: Any) {
        N = Int(NText.title) ?? 100
        
        var results: [ImitationModel] = []
        
        var timeVisible = 0
        var nowTime = 0
        for i in 1 ... N {
            let number = i
            let rnd1 = (0...99).randomElement()
            let x1 = find(in: timeIntervalFrequencys, rndNumber: rnd1!)
            timeVisible += x1
            let first = FirstExperiment(number: number, rnd1: rnd1!, x1: x1, timeVisible: timeVisible)
            var second: SecondExperiment?
            var third: ThirdExperiment?
            
            if timeVisible > nowTime || (x1 == 0 && timeVisible >= nowTime){
                let rnd2 = (0...99).randomElement()
                let x2 = find(in: answersFrequencys, rndNumber: rnd2!)
                second = SecondExperiment(rnd2: rnd2!, x2: x2)
                
                if x2 == 1 {
                    let rnd3 = (0...99).randomElement()
                    let x3 = find(in: timeInterviewFrequencys, rndNumber: rnd3!)
                    let start = timeVisible
                    let end = start + x3
                    nowTime = end
                    third = ThirdExperiment(rnd3: rnd3!, x3: x3, start: start, end: end)
                }
            }
            
            results.append(ImitationModel(firstExperiment: first, secondExperiment: second, thirdExperiment: third))
        }
        resultArr = results
        
        self.P = calcP()
        self.L = calcL()
        self.Q = calcQ()
        self.T = calcT()
        self.R = calcR()
        
        outPutTable.reloadData()
        statisticsTable.reloadData()
    }
    
    func random(in range: Range<Int>) -> Int {
        return  Int(arc4random_uniform(UInt32(range.endIndex - range.startIndex))) + range.startIndex
    }
    
    func find(in array: [FrequencyModel], rndNumber: Int) -> Int {
        var result = 0
        array.forEach { elem in
            if rndNumber >= elem.rndInterval.min && rndNumber <= elem.rndInterval.max {
                result = elem.time
            }
        }
        return result
    }
    
    func calcNUnserv() -> Int {
        var count = 0
        for i in 0 ..< resultArr.count {
            if resultArr[i].thirdExperiment == nil {
                count += 1
            }
        }
        return count
    }
    
    func getTMod() -> Int {
        let t = 0
        for i in (0 ..< resultArr.count).reversed() {
            if resultArr[i].thirdExperiment != nil {
             return resultArr[i].thirdExperiment!.end
            }
        }
        return t
    }
    
    func calcP() -> Double {
        var result: Double = Double(calcNUnserv())
        result /= Double(N)
        return result
    }
    
    func calcL() -> Double {
        var result = 0.0
        for i in resultArr {
            result += Double(i.thirdExperiment?.x3 ?? 0)
        }
        result /= Double(getTMod())
        return result
    }
    
    func calcQ() -> Double {
        var result = 0.0
        for i in resultArr {
            result += Double(i.thirdExperiment?.x3 ?? 0)
        }
        result /= Double(N - calcNUnserv())
        return result
    }
    
    func calcT() -> Double {
        var result = 0.0
        for i in resultArr {
            if let entity = i.thirdExperiment {
                result += Double(entity.end - entity.start)
            }
        }
        result /= Double(N - calcNUnserv())
        return result
    }
    
    func calcR() -> Double {
        var result = 0.0
        for i in resultArr {
            if let entity = i.thirdExperiment {
                result += 1.0 * Double(entity.end - entity.start)
            }
        }
        result /= Double(getTMod())
        return result
    }
}

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == outPutTable {
            return N
        }
        return 1
    }
}

extension ViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiersTable {
        static let ICell = "IID"
        static let Rnd1Cell = "Rnd1ID"
        static let X1Cell = "X1ID"
        static let TimeCell = "TimeID"
        static let Rnd2Cell = "Rnd2ID"
        static let X2Cell = "X2ID"
        static let Rnd3Cell = "Rnd3ID"
        static let X3Cell = "X3ID"
        static let StartCell = "StartID"
        static let EndCell = "EndID"
    }
    
    fileprivate enum CellIdentifiersStatisticsTable {
        static let PCell = "PID"
        static let LCell = "LID"
        static let QCell = "QID"
        static let TCell = "TID"
        static let RCell = "RID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView == outPutTable {
            return self.loadCalculation(tableView, viewFor: tableColumn, row: row)
        }
        if tableView == statisticsTable {
            return self.loadStatistics(tableView, viewFor: tableColumn, row: row)
        }
        return nil
    }
    
    
    func loadCalculation(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSTableCellView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
        
        if resultArr.count > 0 {
            let result = resultArr[row]
            if tableColumn == tableView.tableColumns[0] {
                text = "\(result.firstExperiment.number)"
                cellIdentifier = CellIdentifiersTable.ICell
            } else if tableColumn == tableView.tableColumns[1] {
                text = "\(result.firstExperiment.rnd1)"
                cellIdentifier = CellIdentifiersTable.Rnd1Cell
            } else if tableColumn == tableView.tableColumns[2] {
                text = "\(result.firstExperiment.x1)"
                cellIdentifier = CellIdentifiersTable.X1Cell
            } else if tableColumn == tableView.tableColumns[3] {
                text = "\(result.firstExperiment.timeVisible)"
                cellIdentifier = CellIdentifiersTable.TimeCell
            } else if tableColumn == tableView.tableColumns[4] {
                text = result.secondExperiment?.rnd2.description ?? "-"
                cellIdentifier = CellIdentifiersTable.Rnd2Cell
            } else if tableColumn == tableView.tableColumns[5] {
                text = result.secondExperiment?.x2.description ?? "-"
                cellIdentifier = CellIdentifiersTable.X2Cell
            } else if tableColumn == tableView.tableColumns[6] {
                text = result.thirdExperiment?.rnd3.description ?? "-"
                cellIdentifier = CellIdentifiersTable.Rnd3Cell
            } else if tableColumn == tableView.tableColumns[7] {
                text = result.thirdExperiment?.x3.description ?? "-"
                cellIdentifier = CellIdentifiersTable.X3Cell
            } else if tableColumn == tableView.tableColumns[8] {
                text = result.thirdExperiment?.start.description ?? "-"
                cellIdentifier = CellIdentifiersTable.StartCell
            } else if tableColumn == tableView.tableColumns[9] {
                text = result.thirdExperiment?.end.description ?? "-"
                cellIdentifier = CellIdentifiersTable.EndCell
            }
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    func loadStatistics(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSTableCellView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
        
        if tableColumn == tableView.tableColumns[0] {
            if let p = P {
                text = "\(p.rounded(toPlaces: 6))"
            }
            cellIdentifier = CellIdentifiersStatisticsTable.PCell
        } else if tableColumn == tableView.tableColumns[1] {
            if let l = L {
                text = "\(l.rounded(toPlaces: 6))"
            }
            cellIdentifier = CellIdentifiersStatisticsTable.LCell
        } else if tableColumn == tableView.tableColumns[2] {
            if let q = Q {
                text = "\(q.rounded(toPlaces: 6))"
            }
            cellIdentifier = CellIdentifiersStatisticsTable.QCell
        } else if tableColumn == tableView.tableColumns[3] {
            if let t = T {
                text = "\(t.rounded(toPlaces: 6))"
            }
            cellIdentifier = CellIdentifiersStatisticsTable.TCell
        } else if tableColumn == tableView.tableColumns[4] {
            if let r = R {
                text = "\(r.rounded(toPlaces: 6))"
            }
            cellIdentifier = CellIdentifiersStatisticsTable.RCell
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}



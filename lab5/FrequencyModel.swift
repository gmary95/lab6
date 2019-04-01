class FrequencyModel {
    var time: Int
    var count: Int
    var probability: Double
    var cumProbability: Double
    var rndInterval: RandomInterval
    
    init(time: Int, count: Int, N: Int, prevProbability: Double, prevCount: Int) {
        self.time = time
        self.count = count
        self.probability = Double(count) / Double(N)
        self.cumProbability = prevProbability + probability
        self.rndInterval = RandomInterval(min: prevCount, max: prevCount + count - 1)
    }
}

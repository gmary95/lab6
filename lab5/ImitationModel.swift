class ImitationModel {
    var firstExperiment: FirstExperiment
    var secondExperiment: SecondExperiment?
    var thirdExperiment: ThirdExperiment?
    
    
    init(firstExperiment: FirstExperiment, secondExperiment: SecondExperiment? = nil, thirdExperiment: ThirdExperiment? = nil) {
        self.firstExperiment = firstExperiment
        self.secondExperiment = secondExperiment
        self.thirdExperiment = thirdExperiment
    }
}

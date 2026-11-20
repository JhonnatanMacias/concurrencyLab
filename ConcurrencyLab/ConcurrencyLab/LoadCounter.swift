actor LoadCounter {
    private var successfulLoads = 0

    func recordSuccessfulLoad() -> Int {
        successfulLoads += 1
        return successfulLoads
    }
}

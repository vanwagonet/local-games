extension Lobby {
    func startScramble(size: Scramble.Size = .five) async -> String {
        let id = Scramble.ID.next(avoiding: scrambles.keys)
        scrambles[id] = Scramble(id: id, players: playerIDs, size: size)
        notify(event: "redirect", data: Scramble.path(id))
        playerIDs = []
        return Scramble.path(id)
    }

    func scramble(for id: Session.ID) async -> Scramble? {
        for game in scrambles.values where await game.remaining > .zero {
            if await game.players.contains(id) {
                return game
            }
        }
        return nil
    }
}

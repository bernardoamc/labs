use std::collections::HashMap;

const WINNING_PART_1: u64 = 1_000;
const PLAYER_1_A0: u64 = 6;
const PLAYER_2_A0: u64 = 15;
const DISTANCE: u64 = 18;

const WINNING_PART_2: u64 = 21;
const ROLLS: [(u64, u64); 7] = [(3, 1), (4, 3), (5, 6), (6, 7), (7, 6), (8, 3), (9, 1)];

#[derive(Clone, Copy, Debug, Hash)]
struct Player {
    position: u64,
    score: u64,
    winning_score: u64,
}

impl Player {
    fn new(position: u64, winning_score: u64) -> Self {
        Self {
            score: 0,
            position,
            winning_score,
        }
    }

    fn turn(&mut self, score: u64) {
        self.position = (self.position + score - 1) % 10 + 1;
        self.score += self.position;
    }

    fn winner(&self) -> bool {
        self.score >= self.winning_score
    }
}

impl PartialEq for Player {
    fn eq(&self, other: &Self) -> bool {
        self.position == other.position && self.score == other.score
    }
}
impl Eq for Player {}
type Universe = (Player, Player);

// Arithmetic progression: (an= a1 + (n−1) * d)
// Distance is 18 (gap between rolls)
// Player 1 starts with value 6 (1+2+3)
// Play 2 starts with value 15 (4+5+6)
fn part1(player_1: u64, player_2: u64) -> u64 {
    let mut player_1 = Player::new(player_1, WINNING_PART_1);
    let mut player_2 = Player::new(player_2, WINNING_PART_1);
    let mut rolls = 0;
    let mut turn = 0;

    loop {
        turn += 1;
        let turn_score = PLAYER_1_A0 + (turn - 1) * DISTANCE;
        player_1.turn(turn_score);
        rolls += 3;

        if player_1.winner() {
            break;
        }

        let turn_score = PLAYER_2_A0 + (turn - 1) * DISTANCE;
        player_2.turn(turn_score);
        rolls += 3;

        if player_2.winner() {
            break;
        }
    }

    if player_1.winner() {
        rolls * player_2.score
    } else {
        rolls * player_1.score
    }
}

fn quantum_play(
    current_player: Player,
    other_player: Player,
    winning_states: &mut HashMap<Universe, (u64, u64)>,
) -> (u64, u64) {
    if winning_states.contains_key(&(current_player, other_player)) {
        return *winning_states.get(&(current_player, other_player)).unwrap();
    }

    if current_player.winner() {
        return (1, 0);
    }

    if other_player.winner() {
        return (0, 1);
    }

    let mut current_wins_total = 0;
    let mut other_wins_total = 0;

    for (roll, freq) in ROLLS {
        let mut current_player = current_player.clone();
        current_player.turn(roll);

        let (other_wins, current_wins) = quantum_play(other_player, current_player, winning_states);

        current_wins_total += freq * current_wins;
        other_wins_total += freq * other_wins;
    }

    winning_states.insert(
        (current_player, other_player),
        (current_wins_total, other_wins_total),
    );

    return (current_wins_total, other_wins_total);
}

fn part2(player_1_pos: u64, player_2_pos: u64) -> u64 {
    let player_1 = Player::new(player_1_pos, WINNING_PART_2);
    let player_2 = Player::new(player_2_pos, WINNING_PART_2);
    let mut winning_states = HashMap::new();

    let (player_1_wins, player_2_wins) = quantum_play(player_1, player_2, &mut winning_states);
    player_1_wins.max(player_2_wins)
}

fn main() {
    println!("Part 1: {}", part1(8, 3));
    println!("Part 2: {}", part2(8, 3));
}

#[cfg(test)]
mod tests {
    use crate::{part1, part2};

    #[test]
    fn part_1() {
        let result = part1(4, 8);
        assert_eq!(739785, result);
    }

    #[test]
    fn part_2() {
        let result = part2(4, 8);
        assert_eq!(444356092776315, result);
    }
}

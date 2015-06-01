class Tile

  def initialize(bomb_status, position, board)
    @bomb_status = bomb_status
    @flagged = false
    @revealed = false
    @position = position

  end

  def reveal
    revealed = true
  end

  def neighbors
    x = @position[0]
    y = @position[1]
    output = []
    n = [[x+1,y+1], [x, y+1], [x, y-1], [x+1, y-1], [x+1, y], [x-1, y], [x-1, y+1], [x-1, y-1]]
    valid = n.select {|coord| coord[0] >=0 && coord[0] < 9 && coord[1] >= 0 && coord[1] < 9}
    valid.each {|coord| output << position(coord)}

    output
  end


  def neighbor_bomb_count
    counter = 0

    neighbors.each {|tile| counter +=1 if tile.bombed?}
    counter
  end

end

class Board

  def initialize(num)

    bombs = Array.new(81, :clear)
    (0..9).each {|i| bombs[i] = :bombed}
    bombs = bombs.shuffle
    bombs_idx = 0
    @board = [[],[],[],[],[],[],[],[],[]] * 9
    9.times do |idx|
      9.times do |idx2|
        if bombs[bombs_idx] == :bombed
         @board[idx][idx2] = Tile.new(true, [idx,idx2], self)
        else
         @board[idx][idx2] = Tile.new(false, [idx,idx2], self)
        end
       bombs_idx += 1
       end
     end
  end

  def position(pos)
    @board[pos]
  end

end

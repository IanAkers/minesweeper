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

  attr_accessor :board

  def initialize(num)

    bombs = Array.new(81, :clear)
    (0..9).each {|i| bombs[i] = :bombed}
    bombs = bombs.shuffle
    bombs_idx = 0
    @board = []

    9.times {|i| board << [[],[],[],[],[],[],[],[],[]]}

    9.times do |idx|
      9.times do |idx2|
        if bombs[bombs_idx] == :bombed
         board[idx][idx2] = Tile.new(true, [idx,idx2], self)
        else
         board[idx][idx2] = Tile.new(false, [idx,idx2], self)
        end
       bombs_idx += 1
       end
     end
     p board
  end

  def position(pos)
    board[pos[0], pos[1]]
  end
end


class Game

  def initialize(bombs)
    @game_board = Board.new(bombs)
  end

  def reveal(tile_pos)
  tile = @game_board.position(tile_pos)

  if tile.bomb_status
    raise "Game Over :-("
  else
    bomb_count = tile.neighbor_bomb_count
    tile.reveal
  end

  display_board
end

  def display_board
    displayed_board = []

    9.times {|i| displayed_board << [[],[],[],[],[],[],[],[],[]]}

    displayed_board.each_with_index do |row, index1|
      row.each_with_index do |pos, index2|

        tile = @game_board.position(pos)
        if tile.revealed
          displayed_board[index1][index2] = tile.neighbor_bomb_count
        else
          displayed_board[index1][index2] = "-"
        end
      end
    end
    puts displayed_board
  end

  def turn
    puts "Please choose a tile. Ex. [0,0]"
    tile = gets.chomp
    

    display_board
  end
end

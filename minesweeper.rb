class Tile

  attr_accessor :revealed, :flagged

  def initialize(bomb_status, position, board)
    @bomb_status = bomb_status
    @flagged = false
    @revealed = false
    @position = position

  end

  def reveal
    revealed = true
  end

  def flag
    @flagged = true
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

  def initialize(size, num_bombs)
    @board = seed_board(size, num_bombs)
  end


  def seed_board(size, num_bombs)

    bomb_array = bomb_array_generator(size, num_bombs)
    bomb_idx = 0
    board = blank_board(9)

    9.times do |idx|
      9.times do |idx2|
      if bomb_array.include?(bomb_idx)
       board[idx][idx2] = Tile.new(true, [idx,idx2], self)
      else
       board[idx][idx2] = Tile.new(false, [idx,idx2], self)
      end
     bomb_idx += 1
     end
    end
    board
  end

  def bomb_array_generator(size, num_bombs)
    bombs = []
    until bombs.count == num_bombs
      random = rand(size ** 2)

      bombs << random unless bombs.include?(random)
    end

      bombs
  end


  def position(pos)
    board[pos[0]][pos[1]]
  end

  def blank_board(size)

    blank_board = []
    9.times {|i| blank_board << [[],[],[],[],[],[],[],[],[]]}

    blank_board
  end
end



class Game

  attr_accessor :game_board

  def initialize(size, bombs)
    @game_board = Board.new(size, bombs)
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
    displayed_board = Board.blank_board(9)

    displayed_board.each_with_index do |row, index1|
      row.each_with_index do |pos, index2|

        tile = @game_board.position([index1, index2])
        if tile.revealed
          displayed_board[index1][index2] = tile.neighbor_bomb_count
        elsif tile.flagged
          displayed_board[index1][index2] = '*'
        else
          displayed_board[index1][index2] = "-"
        end
      end
    end
  displayed_board.each {|el| puts el}
  end

  def turn
    puts "Please choose a tile. Ex. [0,0]"
    input = gets.chomp
    tile = game_board.position(input)
    tile.reveale
    tile.reveal_neighbors

    display_board
  end
end

require "byebug"

class Tile

  attr_accessor :revealed, :flagged, :board, :bomb_status, :position

  def initialize(bomb_status, position, board)
    @bomb_status = bomb_status
    @flagged = false
    @revealed = false
    @position = position
    @board = board
  end

  def reveal
    @revealed = true
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
    valid.each {|coord| output << board.position(coord)}

    output
  end


  def neighbor_bomb_count
    counter = 0

    neighbors.each {|tile| counter += 1 if tile.bomb_status}
    counter
  end


  def reveal_neighbors
    # return nil if self.neighbor_bomb_count > 0
    nbers = self.neighbors
    visited = []
    until nbers.empty?
      el = nbers.shift
      if el.neighbor_bomb_count == 0 && !el.bomb_status
        el.reveal
        visited << el
        el.neighbors.each { |n| nbers << n if !visited.include?(n) }
      end
    end
    # vis = visited.select { |visitor| visitor.neighbor_bomb_count == 0}
  end
end



class Board

  attr_accessor :board

  def initialize(num_bombs)
    @board = seed_board(num_bombs)
  end


  def seed_board(num_bombs)

    bomb_array = bomb_array_generator(num_bombs)
    bomb_idx = 0
    board = Board.blank_board

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

  def bomb_array_generator(num_bombs)
    bombs = []
    until bombs.count == num_bombs
      random = rand(9 ** 2)

      bombs << random unless bombs.include?(random)
    end

      bombs
  end


  def position(pos)
    board[pos[0]][pos[1]]
  end

  def self.blank_board

    blank_board = []
    9.times {|i| blank_board << [[],[],[],[],[],[],[],[],[]]}

    blank_board
  end
end



class Game

  attr_accessor :game_board, :displayed_board

  def initialize( bombs)
    @game_board = Board.new(bombs)
    @displayed_board = display_board
  end


  def display_board
    displayed_board = Board.blank_board

    displayed_board.each_with_index do |row, index1|
      row.each_with_index do |pos, index2|
        tile = @game_board.position([index1, index2])
        if tile.revealed || ( tile.neighbors.any? {|n| n.revealed && !n.bomb_status && n.neighbor_bomb_count < 1 } )
          displayed_board[index1][index2] = tile.neighbor_bomb_count.to_s
        elsif tile.flagged
          displayed_board[index1][index2] = 'F'
        else
          displayed_board[index1][index2] = '-'
        end
      end
    end
  displayed_board
  end

  def turn
    while display_board.any? {|row| row.include?('-')}
      puts "Choose to flag or reveal"
      choice = gets.chomp.downcase.strip
      if choice == "reveal"
        puts "Please choose a tile. Ex. [0,0]"
        input = gets.chomp
        x = input[1].to_i
        y = input[3].to_i
        tile = game_board.position([x,y])
        raise "Game Over :-(" if tile.bomb_status
        tile.reveal
        tile.reveal_neighbors unless tile.neighbor_bomb_count > 0
      elsif choice == "flag"
        puts "Please choose a tile. Ex. [0,0]"
        input = gets.chomp
        x = input[1].to_i
        y = input[3].to_i
        tile = game_board.position([x,y])
        tile.flag
      end
        display_board.each do |row|
          print "#{row}" + "\n"
        end

    end
    puts "You win!"
  end
end

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
    # nbers = self.neighbors
    # until nbers.empty?
    #   el = nbers.shift
    #   if el.neighbor_bomb_count == 0
    #     el.reveal
    #     el.neighbors.each { |n| nbers << n if !nbers.include?(n) }
    #   end
    # end
    nbers = self.neighbors
    visited = []
    until nbers.empty?
      el = nbers.shift
      if el.neighbor_bomb_count == 0
        el.reveal
        visited << el
        el.neighbors.each { |n| nbers << n if !visited.include?(n) }
      end
    end

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
    board = Board.blank_board(9)

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

  def self.blank_board(size)

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

  # def reveal(tile_pos)
  #   tile = @game_board.position(tile_pos)
  #
  #   if tile.bomb_status
  #     raise "Game Over :-("
  #   else
  #     bomb_count = tile.neighbor_bomb_count
  #     tile.reveal
  #   end
  #
  #   display_board
  # end

  def display_board
    displayed_board = Board.blank_board(9)

    displayed_board.each_with_index do |row, index1|
      row.each_with_index do |pos, index2|
        # debugger
        tile = @game_board.position([index1, index2])
        if tile.revealed
          displayed_board[index1][index2] = tile.neighbor_bomb_count
        elsif tile.flagged
          displayed_board[index1][index2] = 'F'
        else
          displayed_board[index1][index2] = "-"
        end
      end
    end
  displayed_board
  end

  def turn
    10.times do


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
        tile.reveal_neighbors
      elsif choice == "flag"
        puts "Please choose a tile. Ex. [0,0]"
        input = gets.chomp
        x = input[1].to_i
        y = input[3].to_i
        tile = game_board.position([x,y])
        tile.flag
      end

        print display_board
      end
  end
end

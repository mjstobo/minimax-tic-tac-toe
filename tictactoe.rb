require "pp"

### Classes

class Board
  attr_accessor :gameBoard, :remainingMoves, :hasGameBeenDecided

  def initialize()
    @gameBoard = Array.new(3) { Array.new(3, "") }
    @remainingMoves = 9
    @hasGameBeenDecided = false
  end

  def printBoard
    @gameBoard.each do |row|
      puts row.inspect
    end
  end

  def updateBoard(posX, posY, playerId)
    @gameBoard[posX][posY] = playerId
  end

  def resetBoard()
    @gameBoard = Array.new(3) { Array.new(3, "") }
    @remainingMoves = 9
    @hasGameBeenDecided = false
  end
end

class Player
  attr_accessor :id, :name, :rowScore, :diagScore, :rDiagScore, :columnScore

  def initialize(type = nil)
    @rowScore = 0
    @diagScore = 0
    @rDiagScore = 0
    @columnScore = 0
    @type = type

    if type == "CPU"
      @id = "CPU"
      @name = "CPU"
    else
      puts "What is your player symbol?"
      @id = gets.chomp
      puts "What is your player name?"
      @name = gets.chomp
    end
  end

  def updateScore(type)
    return type += 1
  end

  def resetScore(type = nil)
    if !type
      @rowScore = 0
      @diagScore = 0
      @rDiagScore = 0
      @columnScore = 0
    else
      type = 0
    end
  end
end

### Methods ###

def playerSelectMovePosition(board, player)
  ### determine valid moves remaining
  haveAllPositionsBeenTaken(board)

  if !board.hasGameBeenDecided
    board.printBoard()
    puts "Make your move, 1 - 9 [1 from top left to 9 bottom right]"
    puts "#{player.name}'s turn. They are #{player.id} on the board."
    position = gets.chomp.to_i
    calcPosition = calcXY(position)
    posX, posY = calcPosition
    validMove = checkForValidMove(board, posX, posY)
    if calcPosition.class == String
      playerSelectMovePosition(board, player)
    else
      if validMove
        board.updateBoard(posX, posY, player.id)
        checkForWinCondition(board, player)
      else
        puts "Invalid move. Position already taken"
        playerSelectMovePosition(board, player)
      end
    end
  end
end

def calcXY(position)
  case position
  when 1
    posX = 0
    posY = 0
  when 2
    posX = 0
    posY = 1
  when 3
    posX = 0
    posY = 2
  when 4
    posX = 1
    posY = 0
  when 5
    posX = 1
    posY = 1
  when 6
    posX = 1
    posY = 2
  when 7
    posX = 2
    posY = 0
  when 8
    posX = 2
    posY = 1
  when 9
    posX = 2
    posY = 2
  else
    error = "Invalid submission."
  end

  if error
    return error
  end

  return [posX, posY]
end

def checkForWinCondition(board, player)
  if !board.hasGameBeenDecided
    validateRowScore(board, player)
    validateDiagScore(board, player)
    validatedRDiagScore(board, player)
    validateColumnScore(board, player)

    player.resetScore()
  end
end

def validateDiagScore(board, player)
  index = 0
  for x in board.gameBoard
    index += 1
    if x[index - 1] == player.id
      player.diagScore = player.updateScore(player.diagScore)
    end

    if player.diagScore == 3
      declareWinner(player)
      board.hasGameBeenDecided = true
      break
    end
  end
  player.resetScore(player.diagScore)
end

def validateRowScore(board, player)
  board.gameBoard.each do |row|
    for i in row
      if i == player.id
        player.rowScore = player.updateScore(player.rowScore)
      end

      if player.rowScore == 3
        declareWinner(player)
        board.hasGameBeenDecided = true
        break
      end
    end
    ## Reset the row score within this iteration to prevent it overflowing to the next iteration (e.g. scoring calculated in this row only)
    player.rowScore = player.resetScore(player.rowScore)
  end
end

def validateColumnScore(board, player)
  colIndex = 0
  rowIndex = 0

  for x in board.gameBoard
    while board.gameBoard[rowIndex][colIndex] == player.id
      rowIndex += 1
      player.columnScore = player.updateScore(player.columnScore)

      if player.columnScore == 3
        declareWinner(player)
        board.hasGameBeenDecided = true
        break
      end
    end

    player.columnScore = player.resetScore(player.columnScore)
    rowIndex = 0
    colIndex += 1
  end
end

def validatedRDiagScore(board, player)
  index = 0
  for row in board.gameBoard
    index += 1
    if row[-1 - index + 1] == player.id
      player.rDiagScore = player.updateScore(player.rDiagScore)
    end

    if player.rDiagScore == 3
      declareWinner(player)
      board.hasGameBeenDecided = true
      break
    end
  end
  player.resetScore(player.rDiagScore)
end

def checkForValidMove(board, posX, posY)
  pos = board.gameBoard[posX][posY]
  if pos.empty?
    return true
  else
    puts "Not a valid move."
    return false
  end
end

def haveAllPositionsBeenTaken(board)
  remainingMoves = 9
  board.gameBoard.each do |row|
    for i in row
      if i.nil? || i.empty?
      else
        remainingMoves -= 1
      end
    end

    if remainingMoves == 0
      puts " "
      puts " "
      puts "The game is a draw!"
      puts " "
      puts " "
      board.hasGameBeenDecided = true
    end
  end
end

def declareWinner(player)
  puts " ~~ "
  puts " ~~ "
  puts "The winner is #{player.name}!"
  puts " ~~ "
  puts " ~~ "
end

def resetGame(board, playerOne, playerTwo)
  puts "Would you like to play again? Y for Yes, N for No"

  playAgain = gets.chomp.downcase

  if playAgain == "y"
    board.resetBoard()
    gameManager(board, playerOne, playerTwo)
  elsif playAgain == "n"
    puts "Thanks for playing!"
  else
    puts "Incorrect input."
    resetGame(board, playerOne, playerTwo)
  end
end

def gameManager(board, playerOne, playerTwo)
  while (!board.hasGameBeenDecided)
    playerSelectMovePosition(board, playerOne)
    playerSelectMovePosition(board, playerTwo)
  end

  board.printBoard()
  resetGame(board, playerOne, playerTwo)
end

### execute

board = Board.new()
playerOne = Player.new()
playerTwo = Player.new("CPU")

gameManager(board, playerOne, playerTwo)
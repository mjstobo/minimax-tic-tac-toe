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
      @id = "O"
      @name = "CPU"
    else
      @id = "X"
      puts "What is your player name?"
      @name = gets.chomp
      puts = "You are playing as X"
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
  board.printBoard()

  if !board.hasGameBeenDecided
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
        winningMove = checkForWinCondition(board, player)
        if winningMove
          board.hasGameBeenDecided = true
          declareWinner(player)
        end
      else
        puts "Invalid move. Position already taken"
        playerSelectMovePosition(board, player)
      end
    end
  end
end

def cpuSelectMovePosition(board, cpu)
  origBoard = board
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
    rowWin = validateRowScore(board, player)
    diagWin = validateDiagScore(board, player)
    rDiagWin = validatedRDiagScore(board, player)
    colWin = validateColumnScore(board, player)

    if rowWin || diagWin || rDiagWin || colWin
      player.resetScore()
      return true
    else
      player.resetScore()
      return false
    end
  end
end

def validateDiagScore(board, player)
  index = 0
  foundWinningScore = false

  for x in board.gameBoard
    index += 1
    if x[index - 1] == player.id
      player.diagScore = player.updateScore(player.diagScore)
    end

    if player.diagScore == 3
      foundWinningScore = true
      break
    end
  end

  if foundWinningScore
    return true
  else
    player.resetScore(player.diagScore)
    return false
  end
end

def validateRowScore(board, player)
  foundWinningScore = false
  board.gameBoard.each do |row|
    for i in row
      if i == player.id
        player.rowScore = player.updateScore(player.rowScore)
      end

      if player.rowScore == 3
        foundWinningScore = true
        break
      end
    end
  end
  if foundWinningScore
    return true
  else
    ## Reset the row score within this iteration to prevent it overflowing to the next iteration (e.g. scoring calculated in this row only)
    player.resetScore(player.rowScore)
    return false
  end
end

def validateColumnScore(board, player)
  colIndex = 0
  rowIndex = 0
  foundWinningScore = false

  for x in board.gameBoard
    while board.gameBoard[rowIndex][colIndex] == player.id
      rowIndex += 1
      player.columnScore = player.updateScore(player.columnScore)

      if player.columnScore == 3
        foundWinningScore = true
        break
      end
    end

    if foundWinningScore
      player.resetScore(player.columnScore)
      return true
    else
      player.resetScore(player.columnScore)
      return false
    end

    rowIndex = 0
    colIndex += 1
  end
end

def validatedRDiagScore(board, player)
  index = 0
  foundWinningScore = false
  for row in board.gameBoard
    index += 1
    if row[-1 - index + 1] == player.id
      player.rDiagScore = player.updateScore(player.rDiagScore)
    end

    if player.rDiagScore == 3
      foundWinningScore = true
      break
    end
  end

  if foundWinningScore
    player.resetScore(player.rDiagScore)
    return true
  else
    player.resetScore(player.rDiagScore)
    return false
  end
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
    puts "Incorrect input. Please choose again."
    resetGame(board, playerOne, playerTwo)
  end
end

def gameManager(board, playerOne, playerTwo)
  while (!board.hasGameBeenDecided)
    playerSelectMovePosition(board, playerOne)
    playerSelectMovePosition(board, playerTwo)
  end
  resetGame(board, playerOne, playerTwo)
end

### execute

board = Board.new()
playerOne = Player.new()
playerTwo = Player.new("CPU")

gameManager(board, playerOne, playerTwo)

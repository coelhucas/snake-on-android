local cellSize  = 32 -- Width and height of cells.
local gridLines = {}

local windowWidth, windowHeight = love.graphics.getDimensions()

difficulty = 0
timeToUpdate = 0.2
timeToNextTick = 0.3
gameState = 0 -- 0 ingame 2 game-over
score = 0

snakeDirection = "right"

vectors = {
  left = { x = -1, y = 0 },
  up = { x = 0, y = -1 },
  down = { x = 0, y = 1 },
  right = { x = 1, y = 0 }
}

food = { 8, 3 }

snake = {
  {
    x = 3,
    y = 4
  },
  {
    x = 4,
    y = 4
  },
  {
    x = 5,
    y = 4
  }
}

-- Vertical lines.
for x = cellSize, windowWidth, cellSize do
	local line = {x, 0, x, windowHeight}
	table.insert(gridLines, line)
end
-- Horizontal lines.
for y = cellSize, windowHeight, cellSize do
	local line = {0, y, windowWidth, y}
	table.insert(gridLines, line)
end

function isPositionInvalid(x, y)
  if x < 0 then return true
  elseif y < 0 then return true
  elseif x * cellSize > windowWidth then return true
  elseif y * cellSize > windowHeight then return true
  end
  
  for i, v in ipairs(snake) do 
    if v.x == x and v.y == y then return true end
  end
  
  return false
end

function sortNewFoodPosition()
  fx, fy = love.math.random(windowWidth), love.math.random(windowHeight)
  newX, newY = math.floor(fx / cellSize), math.floor(fy / cellSize)
  
  if isPositionInvalid(newX, newY) then
    sortNewFoodPosition()
  else
    food[1] = newX
    food[2] = newY
  end
end

function updateSnake()
  newX, newY = snake[#snake].x + vectors[snakeDirection].x, snake[#snake].y + vectors[snakeDirection].y
  
  -- Lose condition
  if isPositionInvalid(newX, newY) then
    gameState = 1
  end
  
  table.insert(snake, { x = newX, y = newY })
  table.remove(snake, 1)
  
  local snakeHead = snake[#snake]
  local fx, fy = food[1], food[2]
  
  -- Eat food, increase difficulty
  if snakeHead.x == fx and snakeHead.y == fy then 
    table.insert(snake, 1, snake[1])
    difficulty = difficulty + 0.001
    score = score + 10
    sortNewFoodPosition()
  end
end

function love.touchpressed( id, x, y, dx, dy, pressure )
  if snakeDirection == "right" then snakeDirection = "down"
  elseif snakeDirection == "down" then snakeDirection = "left"
  elseif snakeDirection == "left" then snakeDirection = "up"
  else snakeDirection = "right"
  end
end

function love.update(dt)
  if gameState == 0 then
    timeToNextTick = timeToNextTick - dt
    
    if timeToNextTick <= (0 + difficulty) then 
      timeToNextTick = timeToUpdate
      updateSnake()
    end
  end
end

function love.draw()
  love.graphics.setColor(255, 255, 255)
	love.graphics.setLineWidth(2)

	for i, line in ipairs(gridLines) do
        -- Uncomment to draw grid
		-- love.graphics.line(line)
	end
	
	for i, part in ipairs(snake) do
	  if i == #snake then love.graphics.setColor(200, 100, 80) end
	  love.graphics.rectangle("fill", cellSize * part.x, cellSize * part.y, cellSize, cellSize)
	end
 
 love.graphics.setColor(255, 255, 0)
 love.graphics.print(score, 100, 100)
 if #food >= 0 then love.graphics.rectangle("fill", cellSize * food[1], cellSize * food[2], cellSize, cellSize) end
 
 if gameState == 1 then
    love.graphics.print("GAME OVER", windowWidth / 2, windowHeight / 2)   
  end
end
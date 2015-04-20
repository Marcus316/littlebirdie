debug = false

canDrop = true
dropTimerMax = 1.4
dropTimer = dropTimerMax
dropImg = nil

droppings = {}

spawnTimerMax = 5
spawnTimer = spawnTimerMax
enemyImg = nil
numEnemies = 0

enemies = {}

bulletTimerMax = 0.4
bulletTimer = bulletTimerMax
bulletImg = nil

bullets = {}

moveInstr = true
dropInstr = true

bgImg = nil
player = { x = 100, y = 50, speed = 200, img = nil }
isAlive = true
score = 0

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function love.load(arg)
  bgImg = love.graphics.newImage('assets/bg.png')
  playerFull = love.graphics.newImage('assets/playerfull.png')
  playerPart = love.graphics.newImage('assets/playerpart.png')
  player.img = playerFull
  dropImg = love.graphics.newImage('assets/dropping.png')
  enemyImg = love.graphics.newImage('assets/enemy.png')
  bulletImg = love.graphics.newImage('assets/bullet.png')
end

function love.update(dt)
  dropTimer = dropTimer - (1 * dt)
  if dropTimer < 0 then
    dropTimer = 0
    canDrop = true
    player.img = playerFull
  end

  spawnTimer = spawnTimer - (1 * dt + (score / 500))
  if spawnTimer < 0 and numEnemies < (5 + (score / 100)) then
    spawnTimer = spawnTimerMax
    numEnemies = numEnemies + 1
    randomNumber = math.random(3, love.graphics.getWidth() - 67)
    newEnemy = { x = randomNumber, y = 600, img = enemyImg }
    table.insert(enemies, newEnemy)
  end

  bulletTimer = bulletTimer - (1 * dt)
  if bulletTimer < 0 then
    bulletTimer = bulletTimerMax
    for i, enemy in ipairs(enemies) do
      randomNumber = math.random(1, 10)
      if randomNumber > 7 then
        newBullet = {x = enemy.x + 10, y = 555, img = bulletImg}
	table.insert(bullets, newBullet)
      end
    end
  end

  for i, enemy in ipairs(enemies) do
    if enemy.y > 562 then
      enemy.y = enemy.y - (200 * dt)
    end
  end
  
  for i, bullet in ipairs(bullets) do
    bullet.y = bullet.y - (300 * dt)
    
    if bullet.y < 0 then
      table.remove(bullets, i)
      if isAlive then
        score = score + 1
      end
    end
  end
  
  for i, dropping in ipairs(droppings) do
    dropping.y = dropping.y + (200 * dt)
    
    if dropping.y > 600 then
      table.remove(droppings, i)
    end
  end

  for i, enemy in ipairs(enemies) do
    for j, dropping in ipairs(droppings) do
      if CheckCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(), dropping.x, dropping.y, dropping.img:getWidth(), dropping.img:getHeight()) then
        table.remove(bullets, j)
        table.remove(enemies, i)
	numEnemies = numEnemies - 1
        score = score + 100
      end
    end
  end  
  
  for i, bullet in ipairs(bullets) do
    if CheckCollision(bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight())
    and isAlive then
      table.remove(bullets, i)
      isAlive = false
    end
  end
  
  if love.keyboard.isDown('escape') then
    love.event.push('quit')
  end
  
  if not isAlive and love.keyboard.isDown('r') then
     bullets = {}
     droppings = {}
     enemies = {}
     numEnemies = 0
     
     player.x = 100
     player.y = 50
     
     score = 0
     isAlive = true
   end
  
  if love.keyboard.isDown('left') then
    player.x = player.x - player.speed*dt
    moveInstr = false
    if player.x < 3 then
      player.x = 3
    end
  elseif love.keyboard.isDown('right') then
    player.x = player.x + player.speed*dt
    moveInstr = false
    if player.x > 733 then
      player.x = 733
    end
  end
  
  if love.keyboard.isDown(' ') and canDrop and isAlive then
    newDrop = { x = player.x + 30, y = player.y + 64, img = dropImg }
    table.insert(droppings, newDrop)
    canDrop = false
    dropInstr = false
    dropTimer = dropTimerMax
    player.img = playerPart
  end
end

function love.draw(dt)
  love.graphics.draw(bgImg, 0, 0)
  love.graphics.print("Score: " .. tostring(score), 0, 0)
  
  if moveInstr then
    love.graphics.print("Use left and right arrow keys to move the bird.", 200, 0)
  elseif dropInstr then
    love.graphics.print("Press the SPACEBAR to drop a load", 200, 0)
  else
    love.graphics.print("Press the ESC to quit the game", 200, 0)
  end
  
  if isAlive then
    love.graphics.draw(player.img, player.x, player.y)
  else
    love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
  end
  
  for i, dropping in ipairs(droppings) do
    love.graphics.draw(dropping.img, dropping.x, dropping.y)
  end
  
  for i, enemy in ipairs(enemies) do
    love.graphics.draw(enemy.img, enemy.x, enemy.y)
  end
  
  for i, bullet in ipairs(bullets) do
    love.graphics.draw(bullet.img, bullet.x, bullet.y)
  end
  
end

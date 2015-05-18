local Quad = love.graphics.newQuad

function love.load()
  character = { x = 50, y = 50, sprites = 8, quads = {}, idle = true, direction = 1, iteration = 1 }
  character.player = love.graphics.newImage("sprite.png")

  timer = 0.1

  for i = 1, character.sprites do
    -- newQuad(x, y, width, height, sprite width, sprite height)
    character.quads[i] = Quad((i - 1) * 32, 0, 32, 32, 256, 32);
  end
end

function love.update(dt)
  if not character.idle then
    timer = timer + dt

    if timer > 0.2 then
      timer = 0.1
      character.iteration = character.iteration + 1

      if love.keyboard.isDown('right') then
        character.x = character.x + 5
      end

      if love.keyboard.isDown('left') then
        character.x = character.x - 5
      end

      if character.iteration > character.sprites then
        character.iteration = 1
      end
    end
  end
end

function love.keypressed(key)
  character.direction = 1
  character.idle = false

  if key == 'left' then character.direction = -1 end
end

function love.keyreleased(key)
  character.idle = true
  character.iteration = 1
  character.direction = 1
end

function love.draw()
  love.graphics.draw(character.player, character.quads[character.iteration], character.x, character.y, 0, character.direction, 1)
end

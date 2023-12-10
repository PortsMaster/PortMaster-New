gw = 1280
gh = 960

defaultFont = love.graphics.getFont()

resolutionList = {
                  {2560, 1440},
                  {1920, 1080},
                  {1600, 900},
                  {1366, 768}, 
                  {1280, 720}, 
                  {1024, 576}, 
                  {640, 480}}



window_width = love.graphics.getWidth()
window_height = love.graphics.getHeight()

buttonSmallFont = love.graphics.newFont("assets/roboto.ttf", 24)

squareButtonsmallFont = love.graphics.newFont("assets/roboto.ttf", 48)
squareButtonBigFont = love.graphics.newFont("assets/roboto.ttf", 124)

mx, my = love.mouse.getPosition()

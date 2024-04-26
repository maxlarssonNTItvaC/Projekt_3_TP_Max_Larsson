require 'ruby2d'

set title: "mqueenrun"
set fullscreen: true

backGround1 = Sprite.new('img/dessertbackground.jpg')
backGround2 = Sprite.new('img/dessertbackground.jpg', x:800)

hero = Sprite.new('img/mqueen.png',
width: 30,
height: 86,
clip_width: 30,
y: 320
)


update do
    backGround1.x -= 3
    backGround2.x -= 3

end

show
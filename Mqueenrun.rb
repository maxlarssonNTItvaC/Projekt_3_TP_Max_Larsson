require 'ruby2d'  # Laddar in Ruby2D-biblioteket som används för att skapa spelet

# Konfigurerar spel-fönstrets titel och dimensioner
set title: "MqueenRun"
set width: 800
set height: 400

# Laddar och spelar bakgrundsmusik
music = Music.new('LifeIsAHighway.mp3')  # sökvägen till musikfilen
music.volume = 50  # Sätter volymen till 50%
music.loop = true  # Sätter musiken att spelas om och om igen
music.play  # Startar musiken

# Laddar bakgrundsbilden
background_image = Image.new(
  'img/dessertbackground.jpg',  # sökvägen till bakgrundsbilden
  width: 800,  # Sätter bildens bredd till 800 pixlar
  height: 400,  # Sätter bildens höjd till 400 pixlar
  z: -1  # Säkerställer att bakgrunden är bakom andra objekt (lägre z-värde innebär längre bak i visningsordningen)
)

# Definierar Dino-klassen för spelaren
class Dino
  attr_reader :x, :y, :height, :width  # Gör dessa attribut tillgängliga för att läsas utanför klassen

  def initialize
    @x = 50  # Sätter initial x-position för dino
    @y = 300  # Sätter initial y-position för dino
    @height = 48  # Sätter dinons höjd
    @width = 48  # Sätter dinons bredd
    @velocity = 2  # Initial hastighet för dino
    @gravity = 0.8  # Gravitationens styrka som påverkar dino
    @jump_power = -15  # Hur högt dino hoppar
    @on_ground = true  # Boolean värde för att kolla om dino är på marken

    # Skapar en sprite för dino (Mqueen)
    @dino = Sprite.new(
      'img/mqueen.png',  # Sökvägen till spritens bild
      width: 70,  # Sätter dinons sprite-bredd
      height: 60,  # Sätter dinons sprite-höjd
      clip_width: 86,  # Bredden på varje animationens klipp
      y: @y  # Sätter initial y-position för spriten
    )
  end

  # Metod för att få dino att hoppa
  def jump
    return unless @on_ground  # Avslutar om dino inte är på marken

    @velocity = @jump_power  # Sätter hastigheten till hoppstyrkan
    @on_ground = false  # Indikerar att dino inte längre är på marken
  end

  # Metod för att flytta dino, hanterar gravitation och landning
  def move
    @velocity += @gravity  # Ökar hastigheten med gravitationen
    @y += @velocity  # Uppdaterar dinons y-position baserat på hastigheten

    if @y >= 300  # Kollar om dino har landat på marken
      @y = 300  # Återställer y-positionen till marknivån
      @velocity = 0  # Nollställer hastigheten
      @on_ground = true  # Indikerar att dino är på marken
    end

    @dino.y = @y  # Uppdaterar sprite-positionen till den nya y-positionen
  end
end

# Definierar Cactus-klassen för hinder
class Cactus
  attr_reader :x, :y, :width, :height  # Gör dessa attribut tillgängliga för att läsas utanför klassen

  def initialize(x)
    @x = x  # Sätter initial x-position för kaktusen
    @y = 300  # Sätter initial y-position för kaktusen
    @width = 60  # Sätter kaktusens bredd
    @height = 60  # Sätter kaktusens höjd
    @speed = 5  # Hastighet som kaktusen rör sig med

    # Skapar en bild för kaktusen (hindret)(Chick Hicks)
    @cactus = Image.new(
      'img/ChickHicks.png',  # Sökvägen till bilden för hindret
      x: @x,  # Sätter initial x-position för bilden
      y: @y,  # Sätter initial y-position för bilden
      width: @width,  # Sätter bildens bredd
      height: @height  # Sätter bildens höjd
    )
  end

  # Metod för att flytta kaktusen till vänster
  def move
    @x -= @speed  # Minskar kaktusens x-position med dess hastighet
    @cactus.x = @x  # Uppdaterar bildens x-position
  end

  # Kontroll för att se om kaktusen är utanför skärmen
  def off_screen?
    @x + @width < 0  # Returnerar sant om kaktusen är helt utanför skärmens vänstra kant
  end
end

# Initierar dino och en tom array för kaktusar
dino = Dino.new  # Skapar en ny dino-instans
cactus = []  # Skapar en tom array för kaktusar

# Variabler för att hålla reda på senaste kaktusens spawn-position och ett minimalt avstånd
last_cactus_spawn = 800  # Sätter startvärde för senaste spawn-positionen
min_distance_between_cacti = 200  # Minsta avstånd mellan två kaktusar

# Poängsystem
points = 0  # Startar poängen på 0
point_text = Text.new("Points: #{points}", x: 10, y: 10, size: 20, color: 'black')  # Skapar en text som visar poäng

# Spelloopen
update do
  # Slumpar fram en ny kaktus
  if last_cactus_spawn < (800 - min_distance_between_cacti) && rand(100) < 2
    cactus.push(Cactus.new(800))  # Skapar och lägger till en ny kaktus i arrayen
    last_cactus_spawn = 800  # Återställer spawn-positionen
  end

  # Flyttar varje kaktus och tar bort de som är utanför skärmen
  cactus.each(&:move)  # Anropar move-metoden på varje kaktus
  cactus.reject!(&:off_screen?)  # Tar bort kaktusar som är utanför skärmen

  # Flyttar dino
  dino.move  # Anropar move-metoden på dino

  # Kollisionsdetektion mellan dino och kaktusar
  cactus.each do |c|
    if dino.y + dino.height >= 300 && dino.y <= 350 &&  # Kollar om dino är i kaktusens höjdområde
       dino.x - 20 >= c.x && dino.x <= c.x + c.width  # Kollar om dino är i kaktusens x-område
      close  # Stänger spelet om en kollision inträffar
    end
  end

  # Uppdaterar poäng
  points += 1  # Ökar poängen med 1
  point_text.text = "Piston cup points: #{points}"  # Uppdaterar poängtexten

  # Flyttar spawn-punkten närmare dino
  last_cactus_spawn -= 5  # Minskar avståndet till nästa spawn-punkt
end

# Får dino att hoppa när mellanslagstangenten trycks ned
on :key_down do |event|
  if event.key == 'space'  # Kollar om mellanslagstangenten trycks ned
    dino.jump  # Får dino att hoppa
  end
end

# Visar fönstret
show  # Startar spelet

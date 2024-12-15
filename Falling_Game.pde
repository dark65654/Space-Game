int gamestate = 1;  // Game state //<>//

class Player {
  float x, y, dx, dy, angle;
  float health;
  float stamina;
  float speed;
  PImage shipImage;
  float radius;  // To detect collisions

  Player(float x, float y, PImage shipImage) {
    this.x = x;
    this.y = y;
    this.speed = 5;
    this.health = 100;
    this.stamina = 100;
    this.shipImage = shipImage;
    this.angle = atan2(dy, dx);
    this.radius = 60; // Set a radius for the player collision (based on ship size)
  }

  void move() {
    if (keyUp) {
      x -= cos(angle + 1.5) * speed;
      y -= sin(angle + 1.5) * speed;
    }
    if (keyDown) {
      x += cos(angle + 1.5) * speed;
      y += sin(angle + 1.5) * speed;
    }
    if (keyLeft) {
      angle -= 0.1;
    }
    if (keyRight) {
      angle += 0.1;
    }
    this.IsSprinting();
  }

  void keyPressed() {
    if (key == 'w') {
      keyUp = true;
    }
    if (key == 's') {
      keyDown = true;
    }
    if (key == 'a') {
      keyLeft = true;
    }
    if (key == 'd') {
      keyRight = true;
    }
    if (keyCode == SHIFT) {
      keyShift = true;
    }
  }

  void keyReleased() {
    if (key == 'w') {
      keyUp = false;
    }
    if (key == 's') {
      keyDown = false;
    }
    if (key == 'a') {
      keyLeft = false;
    }
    if (key == 'd') {
      keyRight = false;
    }
    if (keyCode == SHIFT) {
      keyShift = false;
    }
  }

  void IsSprinting() {
    if (keyShift && stamina > 0) {
      speed = 10;
      stamina -= 5;
    }

    if (!keyShift && stamina >= 0 && stamina < 100) {
      speed = 5;
      stamina += 5;
    }
  }


  void displaystatus() {
    
    fill(255);
    text(stamina, 25, 25);
    text(health, width - 75, 25);
  }


  // Check if the laser collides with the player
  boolean checkCollision(Laser laser) {
    float distance = dist(x, y, laser.x, laser.y);
    return distance < radius;  // If the distance is less than the radius, collision occurs
  }

  void draw() {
    pushMatrix();
    translate(x, y);
    rotate(angle);
    imageMode(CENTER);
    image(shipImage, 0, 0);
    imageMode(CORNER);
    popMatrix();
  }
}

class Enemy {
  float x, y;
  PImage enemyImage;
  Laser laser;

  // Constructor to initialize the enemy with a position, image, and laser type
  Enemy(float x, float y, PImage enemyImage, PImage laserImage, Player player, boolean heatSeeking) {
    this.x = x;
    this.y = y;
    this.enemyImage = enemyImage;

    // Choose laser type based on heatSeeking flag
    if (heatSeeking) {
      laserImage = loadImage("LaserMain2.png");
      laser = new HeatSeekingLaser(x, y, laserImage, player);
    } else {
      laser = new StraightLaser(x, y, laserImage, player.x, player.y);
    }
  }

  void move() {
  }

  void fire() {
    laser.move();  // Move the laser
  }

  Laser getLaser() {
    return laser;  // Return the laser object
  }

  void respawnLaser(Player player) {
    if (!laser.isActive) {
      laser.respawn(x, y, player.x, player.y);  // Respawn laser at enemy's position
    }
  }

  void draw() {
    rect(x, y, 25, 25);  // Draw enemy
    laser.draw();         // Draw laser
  }
}

class Laser {
  float x, y;
  float speed;
  PImage laserImage;
  boolean isActive;  // Flag to determine if the laser is active or should be deleted
  float angle;  // The angle of movement for the laser

  Laser(float x, float y, PImage laserImage, float targetX, float targetY) {
    this.x = x;
    this.y = y;
    this.laserImage = laserImage;
    this.speed = 8.0; // Default speed for lasers
    this.isActive = true;  // Laser is initially active
    this.angle = atan2(targetY - y, targetX - x); // Set the angle to the player (target)
  }

  // Move the laser based on its angle
  void move() {
    x += cos(angle) * speed;
    y += sin(angle) * speed;
  }

  // Deactivate the laser (removes it from the screen)
  void deactivate() {
    isActive = false;
  }

  // Respawn the laser at a given position and reset it to its original state
  void respawn(float spawnX, float spawnY, float targetX, float targetY) {
    this.x = spawnX;  // Reset the laser's position to spawn point
    this.y = spawnY;
    this.isActive = true;  // Reactivate the laser
    this.angle = atan2(targetY - y, targetX - x); // Recalculate angle to target
  }

  boolean isOffScreen() {
    return y < 0 || y > height || x < 0 || x > width; // Off-screen if beyond any edge
  }

  void draw() {
    if (isActive) {
      pushMatrix();
      translate(x, y);
      rotate(angle);  // Rotate laser according to its angle
      imageMode(CENTER);
      image(laserImage, 0, 0);
      imageMode(CORNER);
      popMatrix();
    }
  }
}

// HeatSeekingLaser class inherits from Laser
class HeatSeekingLaser extends Laser {
  Player target;  // The target is the player in this case

  HeatSeekingLaser(float x, float y, PImage laserImage, Player target) {
    super(x, y, laserImage, target.x, target.y);  // Initialize angle to point directly at the player
    this.target = target;
    this.speed = 10.0; // Slower speed for heat-seeking laser
  }

  // Override the move method for heat-seeking behavior
  @Override
    void move() {
    // Recalculate the angle towards the player every frame
    angle = atan2(target.y - y, target.x - x);

    // Move the laser toward the player
    x += cos(angle) * speed;
    y += sin(angle) * speed;
  }
}

// StraightLaser class inherits from Laser
class StraightLaser extends Laser {
  StraightLaser(float x, float y, PImage laserImage, float targetX, float targetY) {
    super(x, y, laserImage, targetX, targetY); // Set angle to directly point at the player
    this.speed = 16;
  }

  @Override
    // Move the laser based on its angle
    void move() {
    x += cos(angle) * speed;
    y += sin(angle) * speed;
  }
}

Player player;
Laser laser;
Enemy[] enemies;

PImage SpaceShip, LaserImage, EnemyImage, backgroundImage;

boolean keyUp = false;
boolean keyDown = false;
boolean keyLeft = false;
boolean keyRight = false;
boolean keyShift = false;
boolean keySpace = false;

void setup() {
  size(1333, 750);
  backgroundImage = loadImage("Space.png");
  SpaceShip = loadImage("Player_Fast.png");
  LaserImage = loadImage("LaserMain.png");
  EnemyImage = loadImage("Enemy.png");

  player = new Player(200, 300, SpaceShip);
  laser = new Laser(0, 0, LaserImage, 0, 0); // Default laser, doesn't move

  int numEnemies = 2;  // Set the number of enemies here
  enemies = new Enemy[numEnemies];

  // Create enemies with random laser types
  for (int i = 0; i < numEnemies; i++) {
    boolean heatSeeking = random(1) > 0.5;  // Randomly decide whether the enemy has a heat-seeking laser
    println("Enemy " + i + " heatSeeking: " + heatSeeking);  // Debugging line to see the random result
    enemies[i] = new Enemy(random(0, 1300), random(0, 700), EnemyImage, LaserImage, player, heatSeeking);
  }
}


void draw() {
  background(0);

  switch (gamestate) {
  case 1:
    gamestate += 1;
    break;
  case 2:
    gamestate += 1;
    break;
  case 3:
    EnemeyHandler();

    player.displaystatus();
    player.draw();
    player.move();
    break;
  case 4:
    break;
  }
}

void EnemeyHandler() {
  // Fire and draw lasers for each enemy
  for (int i = 0; i < enemies.length; i++) { // i means index to select each enemey ex. i = 0 = Enemey 0
    // Fire the laser for each enemy
    enemies[i].fire();
    enemies[i].move();

    // Get the laser from the enemy and check if it is off-screen
    Laser enemyLaser = enemies[i].getLaser();

    if (enemyLaser.isOffScreen()) {
      enemyLaser.deactivate();  // Deactivate the laser if it went off-screen
    }

    enemies[i].draw();  // Draw the enemies and their lasers

    // Check for collisions between the player and the enemy laser
    if (enemyLaser.isActive && player.checkCollision(enemyLaser)) {
      println("Collision detected! Laser removed.");
      player.health -= 1;
      enemyLaser.deactivate();  // Deactivate (remove) the laser upon collision
    }

    // Respawn the laser if it was deactivated (after collision or off-screen)
    if (!enemyLaser.isActive) {
      enemies[i].respawnLaser(player);  // Respawn the laser if it's deactivated
    }
  }
}

void keyPressed() {
  player.keyPressed();
}

void keyReleased() {
  player.keyReleased();
}

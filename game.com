<!DOCTYPE html>
<html>
<head>
  <title>Car Racing Game</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <style>
    body{
      margin:0;
      overflow:hidden;
      background:#111;
      font-family:Arial;
    }

    #gameArea{
      width:300px;
      height:100vh;
      background:#444;
      margin:auto;
      position:relative;
      overflow:hidden;
      border-left:5px solid white;
      border-right:5px solid white;
    }

    .roadLine{
      width:10px;
      height:80px;
      background:white;
      position:absolute;
      left:145px;
    }

    .car{
      width:50px;
      height:80px;
      position:absolute;
      border-radius:10px;
    }

    #player{
      background:red;
      bottom:20px;
      left:125px;
    }

    .enemy{
      background:yellow;
      top:-100px;
    }

    #score{
      position:absolute;
      top:10px;
      left:10px;
      color:white;
      font-size:18px;
      z-index:10;
    }

    #gameOver{
      position:absolute;
      top:40%;
      width:100%;
      text-align:center;
      color:white;
      font-size:22px;
      display:none;
    }
  </style>
</head>

<body>

<div id="gameArea">
  <div id="score">Score: 0</div>
  <div id="gameOver">GAME OVER<br>Tap To Restart</div>
  <div class="car" id="player"></div>
</div>

<script>
let gameArea = document.getElementById("gameArea");
let player = document.getElementById("player");
let scoreDisplay = document.getElementById("score");
let gameOverText = document.getElementById("gameOver");

let playerX = 125;
let score = 0;
let speed = 6;
let gameRunning = true;

let enemy = document.createElement("div");
enemy.classList.add("car","enemy");
enemy.style.left = "125px";
enemy.style.top = "-100px";
gameArea.appendChild(enemy);

let enemyY = -100;

// Create road lines
for(let i=0;i<5;i++){
  let line = document.createElement("div");
  line.classList.add("roadLine");
  line.style.top = (i*150) + "px";
  gameArea.appendChild(line);
}

// Touch control
document.addEventListener("touchmove", function(e){
  let touchX = e.touches[0].clientX;
  let rect = gameArea.getBoundingClientRect();
  playerX = touchX - rect.left - 25;

  if(playerX < 0) playerX = 0;
  if(playerX > 250) playerX = 250;

  player.style.left = playerX + "px";
});

function moveRoadLines(){
  let lines = document.querySelectorAll(".roadLine");
  lines.forEach(function(line){
    let top = parseInt(line.style.top);
    top += speed;
    if(top > window.innerHeight){
      top = -100;
    }
    line.style.top = top + "px";
  });
}

function gameLoop(){
  if(!gameRunning) return;

  enemyY += speed;
  enemy.style.top = enemyY + "px";

  if(enemyY > window.innerHeight){
    enemyY = -100;
    enemy.style.left = Math.floor(Math.random()*5)*50 + "px";
    score++;
    scoreDisplay.innerText = "Score: " + score;
  }

  moveRoadLines();

  let playerRect = player.getBoundingClientRect();
  let enemyRect = enemy.getBoundingClientRect();

  if(!(playerRect.bottom < enemyRect.top ||
       playerRect.top > enemyRect.bottom ||
       playerRect.right < enemyRect.left ||
       playerRect.left > enemyRect.right)){
    gameRunning = false;
    gameOverText.style.display = "block";
  }

  requestAnimationFrame(gameLoop);
}

gameArea.addEventListener("click", function(){
  if(!gameRunning){
    location.reload();
  }
});

gameLoop();
</script>

</body>
</html>
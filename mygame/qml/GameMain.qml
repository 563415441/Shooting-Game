import Felgo 3.0
import QtQuick 2.0
import GameDataType 1.0
GameWindow {

 screenWidth: 960
 screenHeight: 640


 property bool splashFinished: false
 onSplashScreenFinished: { splashFinished = true}
 property int monstersDestroyed
 onMonstersDestroyedChanged: {
   if(monstersDestroyed > 19) {
           // you won the game, shot at 20 monsters
     changeToGameOverScene(true)
   }
 }
 property int scroe:0
 property int level: 1

 EntityManager {
   id: entityManager
   entityContainer: scene
 }


 BackgroundMusic {
   source: "../assets/snd/background-music-aac.wav"
 }

Rectangle {
   anchors.fill: parent
   color: "#cce6ff"             // make a color background for the window
}


Scene
    {
      id:menuScene
      Rectangle{
          width:parent.width
          height: parent.height / 4
          anchors.top: parent.top
          color: "#cce6ff"
      Text {
          id: gameName
          anchors.centerIn: parent
          text: qsTr("Kill Them All")
          font.pixelSize: 70

      }
      }
      Column{
          spacing: 10
          anchors.centerIn: parent
          Rectangle{
              id:play
              width: 100
              height: 30
              color: "#e9e9e9"
              Text {
                  id: playbutton
                  text: qsTr("PLAY")
                  anchors.centerIn: parent
                  font.pixelSize: 18
                  color:"black"
              }
              MouseArea{
                  id:playArea
                  anchors.fill: parent
                  onClicked:{
                  scene.visible = true
                      menuScene.visible = false
                  }
              }
          }
          Rectangle{
              id:ct
              width: 100
              height: 30
              color: "#e9e9e9"
              Text {
                  id: ctbutton
                  text: qsTr("CONTINUE")
                  anchors.centerIn: parent
                  font.pixelSize: 18
                  color:"black"
              }
              MouseArea{
                  anchors.fill: parent
                  onClicked:{
                  scene.visible = true
                      menuScene.visible = false
                  }
              }
          }

      }


  }

 Scene {
   id: scene
          // the "logical size" - the scene content is auto-scaled to match the GameWindow size
   visible: false
   width: 480
   height: 320
  // GameData{
    //   id:gameData
  // }
   Text {
       x:10
       y:10
       text:scroe
   }

   Text {
       x:240
       y:10
       text: level
   }
   Rectangle{
       id:backbutton
       width: 30
       height: 30
       color: "#cce6ff"
       x:400
       y:20
       Text {
           anchors.fill: parent
           text: qsTr("back")
           font.pixelSize: 10
       }
       MouseArea{
           anchors.fill: parent
           onClicked: {
               monstersDestroyed = 0
               entityManager.removeEntitiesByFilter(["projectile", "monster","increaseSpeed"])
               scene.visible = false
               menuScene.visible = true

           }
       }
   }

   PhysicsWorld { id: physicsWorld;debugDrawVisible: false} // put it anywhere in the Scene, so the collision detection between monsters and bomb can be done

 Player{
       id: player
       x: 16
       y: 280
       MouseArea {
         id: playerTouchArea

         width: player.width*2
         height: player.height*2
         anchors.verticalCenterOffset: -20
         anchors.horizontalCenterOffset: 0
         anchors.centerIn: player

         drag.target: player
                 // Moving players on the x-axis
         drag.axis: Drag.XAxis
                 // limit the minimum and maximum of the drag area
         drag.minimumX: 0
         drag.maximumX: scene.width-player.width
                // the player is only enabled if the game is ready or running

       }
 }
 Component  {

     id: monster

     EntityBase {
         entityType: "monster"

         MultiResolutionImage {
             id: monsterImage
             source: "../assets/img/Target.png"
         }

         x:utils.generateRandomValueBetween(0,400)

         NumberAnimation on y  {    //Monsters appear from the top of the screen.
             from:-monsterImage.height
             to:scene.height
             duration: utils.generateRandomValueBetween(2000, 4000)
             onStopped: {
                 console.debug("monster reached base - change to gameover scene because the player lost")
                 scene.visible = false
                 gameOverScene.visible = true
                 next.visible = false  //Show exit button only
             }
         }

         BoxCollider {
             anchors.fill: monsterImage // make the collider as big as the image
             collisionTestingOnlyMode: true
             fixture.onBeginContact: {


                 var collidedEntity = other.getBody().target
                 console.debug("collided with entity", collidedEntity.entityType)

                 if(collidedEntity.entityType === "projectile") {
                     monstersDestroyed++
                     scroe++
                     // remove the projectile entity
                     collidedEntity.removeEntity()
                     // remove the monster
                     removeEntity()

                 }
             }
         }// BoxCollider
     }

        // EntityBase
      }// Component


   Component {
     id: projectile

     EntityBase {
       entityType: "projectile"

       MultiResolutionImage {
         id: projectileImage
         source: "../assets/img/bomb.png"
       }

       // these values can then be set when a new projectile is created in the MouseArea below
       property point destination
       property int moveDuration

       PropertyAnimation on x {
         from: player.x
         to: destination.x
         duration: moveDuration
       }

       PropertyAnimation on y {
         from: player.y
         to: destination.y
         duration: moveDuration
       }

       BoxCollider {
         anchors.fill: projectileImage
         collisionTestingOnlyMode: true
       }
     }
   }

   Component  {

          id: increaseSpeed

          EntityBase {
            entityType: "increaseSpeed"
            width: 10
            height: 10
            MultiResolutionImage {
              id: increaseImage
              source: "../assets/img/star.png"
            }

         x:utils.generateRandomValueBetween(0,400)

         NumberAnimation on y  {
         from:-increaseImage.height
         to:scene.height
         duration: utils.generateRandomValueBetween(2000, 3000)
            }

            BoxCollider {
              anchors.fill: increaseImage // make the collider as big as the image
              collisionTestingOnlyMode: true
              fixture.onBeginContact: {


                var collidedEntity = other.getBody().target
                console.debug("collided with entity", collidedEntity.entityType)
                if(collidedEntity.entityType === "player") {
                    launchingSpeed.interval = 150
                    jiasu.running = true
                    removeEntity()
                }
            }
          }
        }
   }
   SoundEffect {
     id: projectileCreationSound
     source: "../assets/snd/pew-pew-lei.wav"
   }

   Rectangle{
       // A fixed point, used as a bomb destination
       id:mb
       width:1
       height: 1
       x:player.x+1  //Permanently above the aircraft
       y:1
       color: "black"
   }


 }

 Scene {
   id: gameOverScene
   visible: false
   Column{
       spacing: 10
       anchors.centerIn: parent
       Rectangle{
           id:next
           width: 100
           height: 30
           color: "#e9e9e9"
           Text {
               anchors.centerIn: parent
               text: qsTr("Next Level")
               font.pixelSize: 18
           }
           MouseArea{
               anchors.fill: parent
               onClicked: {
                   scene.visible = true
                   creatMonster.interval -= 100
                   launchingSpeed.interval += 50
                   level++
                   gameOverScene.visible = false
               }
           }

       }
       Rectangle{
           id:quit
           width:100
           height: 30
           color: "#e9e9e9"
           Text {
               anchors.centerIn: parent
               text: qsTr("Quit")
               font.pixelSize: 18
           }
           MouseArea{
               anchors.fill: parent
               onClicked: {
                   monstersDestroyed = 0
                   scroe = 0
                   level = 1
                   entityManager.removeEntitiesByFilter(["projectile", "monster","increaseSpeed"])
                   gameOverScene.visible = false
                   menuScene.visible = true

               }
           }

       }
   }
 }

 Timer {
     id:creatMonster
   running: scene.visible == true && splashFinished // only enable the creation timer, when the gameScene is visible
   repeat: true
   interval: 1000 // a new target is spawned every second
   onTriggered: addTarget()
 }
 Timer {
     id:launchingSpeed
   running: scene.visible == true && splashFinished
   repeat: true
   interval: 400
   onTriggered: launchBobms()
 }
 Timer{
     id:jiasu
     running: false
     repeat:false
     interval: 5000
     onTriggered:recoverySpeed()
}
 Timer {
     id:creatStar
   running: scene.visible == true && splashFinished // only enable the creation timer, when the gameScene is visible
   repeat: true
   interval: 10000 //a new start is spawned 10 seconds
   onTriggered: addStar()
 }
 function addStar() {
   console.debug("create a new star")
   entityManager.createEntityFromComponent(increaseSpeed)
 }
 function addTarget() {
   console.debug("create a new monster")
   entityManager.createEntityFromComponent(monster)
 }
 function recoverySpeed() {
     launchingSpeed.interval = 400
 }

 function changeToGameOverScene() {
   gameOverScene.visible = true
   scene.visible = false
     next.visible = true
   monstersDestroyed = 0

   // reset the game variables and remove all projectiles and monsters

   entityManager.removeEntitiesByFilter(["projectile", "monster","increaseSpeed"])
 }


 function launchBobms() {

     // Launch a bomb at a fixed point

         var offset = Qt.point(
               mb.x - player.x,
               mb.y - player.y
               );


         // Determine where we wish to shoot the projectile to
         var realX = scene.gameWindowAnchorItem.width
         var ratio = offset.y / offset.x
         var realY = (realX * ratio) + player.y
         var destination = Qt.point(realX, realY)

         // Determine the length of how far we're shooting
         var offReal = Qt.point(realX - player.x, realY - player.y)
         var length = Math.sqrt(offReal.x*offReal.x + offReal.y*offReal.y)
         var velocity = 480  //bomb speed
         var realMoveDuration = length / velocity * 1000

         entityManager.createEntityFromComponentWithProperties(projectile, {"destination": destination, "moveDuration": realMoveDuration})

         projectileCreationSound.play()

 }
}

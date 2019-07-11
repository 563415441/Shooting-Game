import Felgo 3.0
import QtQuick 2.0


EntityBase {
  id: player
  entityType: "player"
  width: 27
  height: 40

MultiResolutionImage {
    id:playerImage
    source: "../assets/img/plane.png"
    anchors.centerIn: box
  }
BoxCollider {
    id:box
  anchors.fill: playerImage
  collisionTestingOnlyMode: true
}
}

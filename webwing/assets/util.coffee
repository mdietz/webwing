window.Util =
  xAxis: new THREE.Vector3(1,0,0);
  yAxis: new THREE.Vector3(0,1,0);
  zAxis: new THREE.Vector3(0,0,1);

  # Assumes scale is 1.0
  rotObj: (object, axis, radians) ->
    rotateQuaternion = new THREE.Quaternion()
    rotateQuaternion.setFromAxisAngle( axis, radians )
    object.quaternion.multiply( rotateQuaternion )
    object.quaternion.normalize()
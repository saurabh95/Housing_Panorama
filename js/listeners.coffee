root = exports ? this
onPointerDownPointerX = undefined
onPointerDownPointerY = undefined
onPointerDownLon = undefined
onPointerDownLat =undefined
keyMax = 7
keySpeed = 2

on_window_resize = ->
	camera.aspect = window.innerWidth / window.innerHeight
	camera.updateProjectionMatrix()
	root.renderer.setSize window.innerWidth, window.innerHeight
	return

touch_handler = (event) ->
	touches = event.changedTouches
	first = touches[0]
	type = ''
	switch event.type
		when 'touchstart'
			type = 'mousedown'
		when 'touchmove'
			type = 'mousemove'
		when 'touchend'
			type = 'mouseup'
		else
			return
	simulatedEvent = document.createEvent('MouseEvent')
	simulatedEvent.initMouseEvent type, true, true, window, 1, first.screenX, first.screenY, first.clientX, first.clientY, false, false, false, false, 0, null
	first.target.dispatchEvent simulatedEvent
	event.preventDefault()
	return

on_mouse_down = (event) ->
	event.preventDefault()
	root.Config.isUserInteracting = true
	onPointerDownPointerX = event.clientX
	onPointerDownPointerY = event.clientY
	onPointerDownLon = root.Config.lon
	onPointerDownLat = root.Config.lat
	vector = new (THREE.Vector3)
	container = document.getElementById('container')
	vector.set event.clientX / container.offsetWidth * 2 - 1, -(event.clientY / container.offsetHeight) * 2 + 1, 0.5
	vector.unproject root.camera
	root.raycaster.set root.camera.position, vector.sub(root.camera.position).normalize()
	intersects = root.raycaster.intersectObjects(root.scene.children, true)
	if intersects.length > 0 and intersects[0].object.name == 'hotspot'
		root.Transition.start intersects[0].object.hotspot_id
	return

on_mouse_move = (event) ->
	if root.Config.isUserInteracting == true
		mouseSpeed = 0.3
		root.Config.lon = (onPointerDownPointerX - (event.clientX)) * mouseSpeed + onPointerDownLon
		root.Config.lat = (event.clientY - onPointerDownPointerY) * mouseSpeed + onPointerDownLat
	return

on_mouse_up = (event) ->
	root.Config.isUserInteracting = false
	root.Config.stop_time = Date.now()
	root.Config.autoplay = false
	return

on_mouse_wheel = (event) ->
	if event.wheelDeltaY
		root.camera.fov -= event.wheelDeltaY * 0.05
	else if event.wheelDelta
		root.camera.fov -= event.wheelDelta * 0.05
	else if event.detail
		root.camera.fov += event.detail * 1.0
	root.camera.fov = Math.max(60, Math.min(90, camera.fov))
	root.camera.updateProjectionMatrix()
	return

on_key_down = (event) ->
	near_id = undefined
	if !event
		event = window.event
	root.Config.isUserInteracting = true
	keyPressed = event.keyCode
	if keyPressed == 37
		root.Config.lon -= keySpeed
	else if keyPressed == 39
		root.Config.lon += keySpeed
	else if keyPressed == 38
		if root.Transition.moving == false
			near_id = root.Hotspot.front_nearest_hotspot()
			if near_id != -1
				root.Transition.start near_id
	else if keyPressed == 40
		if root.Transition.moving == false
			near_id = root.Hotspot.back_nearest_hotspot()
			if near_id != -1
				root.Transition.start near_id
	if root.Config.isUserInteracting == true
		if keySpeed < keyMax
			keySpeed += 1
	return

on_key_up = (event) ->
	root.Config.isUserInteracting = false
	keySpeed = 2
	root.Config.stop_time = Date.now()
	root.Config.autoplay = false
	return

container = document.getElementById('container')
container.addEventListener 'mousedown', on_mouse_down, false
container.addEventListener 'mousemove', on_mouse_move, false
container.addEventListener 'mouseup', on_mouse_up, false
container.addEventListener 'mousewheel', on_mouse_wheel, false
container.addEventListener 'DOMMouseScroll', on_mouse_wheel, false
container.addEventListener 'touchstart', touch_handler, false
container.addEventListener 'touchmove', touch_handler, false
container.addEventListener 'touchend', touch_handler, false
document.addEventListener 'keydown', on_key_down, false
document.addEventListener 'keyup', on_key_up, false
window.addEventListener 'resize', on_window_resize, false



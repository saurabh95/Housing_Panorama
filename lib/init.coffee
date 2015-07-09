root = {}
camera = undefined
scene = undefined
renderer = undefined
texture_placeholder = undefined
raycaster = new (THREE.Raycaster)
blur_images = {}
clear_images = {}
active = undefined
is_fullscreen = false
Config = 
	img_name: ['mobile_r'
		'mobile_l' 
		'mobile_u' 
		'mobile_d' 
		'mobile_f' 
		'mobile_b'
	]
	isUserInteracting: false
	lon: 0
	lat: 0
	stop_time:undefined
	autoplay : true
	webgl: true
	current_lon: undefined
	target_lon: undefined
	current_lat: undefined
	target_lat: undefined

go_fullscreen = ->
	container = $("#" + DirectPano.pano_div_id)
	container.width(window.innerWidth + 'px').height(window.innerHeight + 'px')
	
	renderer.setSize container.outerWidth(), container.outerHeight()
	
	image = $("#"+DirectPano.image_div_id)
	image.css({
		'visibility': 'hidden'
		})
	camera.aspect = container.outerWidth() / container.outerHeight()
	camera.updateProjectionMatrix()
	is_fullscreen = true
	return

escape_fullscreen = ->
	container = $("#"+DirectPano.pano_div_id)
	
	container.width(DirectPano.initial_width + 'px').height(DirectPano.initial_height + 'px')
	
	renderer.setSize container.outerWidth(), container.outerHeight()
	
	image = $("#"+DirectPano.image_div_id)
	image.css({
		'visibility': 'visible'
		})
	camera.aspect = container.outerWidth() / container.outerHeight()
	camera.updateProjectionMatrix()
	is_fullscreen = false
	return


detect_webgl = ->
	try
		canvas = $('<canvas/>')
		return ! !(window.WebGLRenderingContext and (canvas[0].getContext('webgl') or canvas[0].getContext('experimental-webgl')))
	catch e
		Config.webgl = false
		return false

init = ->
	container = $("#"+DirectPano.pano_div_id)

	container.width(DirectPano.initial_width + 'px').height(DirectPano.initial_height + 'px')
	scene = new (THREE.Scene)
	
	texture_placeholder = $('<canvas/>').width(128).height(128)
	
	renderer = if detect_webgl() then new (THREE.WebGLRenderer) else new (THREE.CanvasRenderer)
	
	renderer.setPixelRatio window.devicePixelRatio

	container.append(renderer.domElement)
	renderer.setSize container.outerWidth(), container.outerHeight()
	camera = new (THREE.PerspectiveCamera)(65, container.outerWidth() / container.outerHeight(), 1, 1100)
	camera.target = new (THREE.Vector3)(0, 0, 0)
	$('#'+ DirectPano.image_div_id).bind 'touchstart click', ->
		go_fullscreen()
		return
	panos_list = $("#panos-list")
	i = 0
	while i < 22
		if DirectPano.pano[i][0]
			panos_list.append("<div id='panos-list-entry-" + i + "'>" + DirectPano.pano[i][0] + "</div>")
			$("#panos-list-entry-" + i).attr('pano_id', parseInt(i))
			$("#panos-list-entry-" + i).bind 'click touchstart', ->
				if root.Transition.moving == false
					$('div[id^=panos-list-entry-]').removeClass('active')
					this.className = 'active'
					root.Transition.start(null, parseInt(this.getAttribute('pano_id')))
				return
		i++
	return

destroy = (dfrd)->
	root.Hotspot = undefined
	
	for prop in clear_images
		clear_images[prop] = null
	
	for prop in blur_images
		blur_images[prop] = null
	
	clear_images= {}
	blur_images = {}
	
	Config.lon = 0
	Config.lat = 0
	Config.stop_time = undefined
	Config.autoplay  = true
	return

$(window).resize ->
	container = $("#" + DirectPano.pano_div_id)
	if(is_fullscreen == false)
		container.width(Math.min(DirectPano.initial_width, window.innerWidth) + 'px').height(Math.min(DirectPano.initial_height, window.innerHeight) + 'px')
	else
		container.width(window.innerWidth + 'px').height(window.innerHeight + 'px')
	renderer.setSize container.outerWidth(), container.outerHeight()
	camera.aspect = container.outerWidth() / container.outerHeight()
	camera.updateProjectionMatrix()
	return

init()

root.destroy = destroy
root.Config = Config
root.camera = camera
root.scene = scene
root.renderer = renderer
root.blur_images = blur_images
root.clear_images = clear_images
root.texture_placeholder = texture_placeholder
root.raycaster = raycaster
root.escape_fullscreen = escape_fullscreen
module.exports = root

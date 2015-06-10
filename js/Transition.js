var Transition = 
{
    path : "",
    currentPano : 0,
    panoNum : 0,
    moving : false
};

Transition.init = function( path)
{
    Transition.path = path;

    var path = path + "1/" + "mobile_";
    Transition.blurPano = new Pano(1,true);
    var clearPano1 = new Pano(1,false);
    var clearPano2 = new Pano(1,false);

    Transition.blurPano.createPano(path,0.0);
    clearPano1.createPano(path,1.0);
    clearPano2.createPano(path,0.0);

    Transition.clearPano = [clearPano1,clearPano2];

    Transition.preloadImages();  
};

Transition.preloadImages = function()
{
    for(var i = 0; i < Hotspot.hotspotAngles[Transition.currentPano].length; i++)
    {
        var source = Hotspot.hotspotAngles[Transition.currentPano][i][0];
        if(!images[source])
        { 
            var path = Transition.path + "blur_" + (source + 1) + "/mobile_";  
            var temp = [];
            for(var j = 0; j < 6; j++)
            {
                var image = new Image();
                image.src = path + Config.imgName[j] + ".jpg";
                temp.push(image);
            }
            images[source] = temp;
        }
    }
};

Transition.start = function(hotspot_id)
{
    var pano_id = Hotspot.hotspotAngles[Transition.currentPano][hotspot_id][0];
    var hotspot_angle = Hotspot.hotspotAngles[Transition.currentPano][hotspot_id][1] - 90;
    var dist = Hotspot.hotspotAngles[Transition.currentPano][hotspot_id][2];

    Transition.moving = true;
    var rotate_angle = hotspot_angle - Config.lon;

    while(rotate_angle > 180)
    {
        rotate_angle = rotate_angle - 360;
    }
    while(rotate_angle < -180)
    {
        rotate_angle = rotate_angle + 360;
    }


    function loadBlurPano (pano_id, hotspot_angle ,dist)
    {
        var path = Transition.path+"blur_" + (pano_id + 1) + "/mobile_";

        var dfrd = [];
        for(var i = 0; i < 6 ; i++)
            dfrd[i] = $.Deferred();

        for(var i = 0; i < 6; i++)
        {
            Transition.blurPano.mesh.material.materials[i].map.dispose();
            Transition.blurPano.mesh.material.materials[i].map = Transition.blurPano.getTexture(path + Config.imgName[i] + ".jpg", dfrd[i], true, i);
            Transition.blurPano.mesh.material.materials[i].opacity = 0;
        }

        Transition.blurPano.mesh.position.x = dist*Math.cos(THREE.Math.degToRad(hotspot_angle ));
        Transition.blurPano.mesh.position.z = dist*Math.sin(THREE.Math.degToRad(hotspot_angle ));

        return $.when(dfrd[0], dfrd[1], dfrd[2], dfrd[3], dfrd[4], dfrd[5]).done(function(){
        }).promise();
    }


    function loadClearPano( pano_id )
    {

        var path = Transition.path + (pano_id + 1) + "/mobile_";

        var dfrd = [];
        for(var i = 0; i < 6; i++)
            dfrd[i] = $.Deferred();

        Transition.clearPano[Transition.panoNum].mesh.visible = true;
        for(var i = 0; i < 6; i++)
        {
            Transition.clearPano[Transition.panoNum].mesh.material.materials[i].map.dispose();
            Transition.clearPano[Transition.panoNum].mesh.material.materials[i].map = Transition.clearPano[Transition.panoNum].getTexture(path + Config.imgName[i] + ".jpg", dfrd[i], false, i);
            Transition.clearPano[Transition.panoNum].mesh.material.materials[i].opacity = 0;
        } 
        return $.when(dfrd[0], dfrd[1], dfrd[2], dfrd[3], dfrd[4], dfrd[5]).done(function(){
        }).promise();

    }


    function oldpanoToBlurpano ( pano_id, hotspot_angle,dist,rotate_angle)
    {
        var time1 = 0.4;
        var rotate_angle = Config.lon + rotate_angle;

        TweenLite.to(Config, time1, {lon: rotate_angle, lat: 0, ease: Power0.easeOut});

        var time = 2;
        var del = 0.3;
        TweenLite.to(Transition.blurPano.mesh.position, time, {x: 0, z: 0, delay:del,ease: Expo.easeOut});

        dist *= -1; 

        for(var i = 0; i < 6; i++)
        {
            TweenLite.to(Transition.clearPano[Transition.panoNum].mesh.material.materials[i], time, {opacity: 0,delay:del, ease: Expo.easeOut});
        }

        for(var i = 0; i < 6; i++)
        {
            TweenLite.to(Transition.blurPano.mesh.material.materials[i], time, {opacity: 1, delay:del,ease: Expo.easeOut});
        }

        TweenLite.to(Transition.clearPano[Transition.panoNum].mesh.position, time, {x:dist*Math.cos(THREE.Math.degToRad(hotspot_angle )),z:dist*Math.sin(THREE.Math.degToRad(hotspot_angle )),delay:del,ease: Expo.easeOut,onComplete: checkNewPanoLoad, onCompleteParams: [ pano_id ]});

    }


    function checkNewPanoLoad ( pano_id )
    {
        Transition.clearPano[Transition.panoNum].mesh.position.x = 0;
        Transition.clearPano[Transition.panoNum].mesh.position.z = 0;
        Transition.clearPano[Transition.panoNum].mesh.visible = false;
        for(var i = 0; i < 6; i++)
        {

            Transition.clearPano[Transition.panoNum].mesh.material.materials[i].opacity = 0;
            Transition.clearPano[Transition.panoNum].mesh.material.materials[i].map.dispose();
            Transition.blurPano.mesh.material.materials[i].opacity = 1;
        }

        Transition.panoNum = (Transition.panoNum + 1)%2;

        loadClearPano(pano_id).done(function(){

            blurpanoToNewpano(pano_id);
            Transition.preloadImages();

        });
    }

    function blurpanoToNewpano ( pano_id )
    {
        var time = 0.5;
        for(var i = 0; i < 6; i++)
        {
            TweenLite.to(Transition.blurPano.mesh.material.materials[i], time, {opacity: 0, ease: Power0.easeOut});
        }
        for(var i = 0; i < 6; i++)
        {
            if(i == 5)
            {
                TweenLite.to(Transition.clearPano[Transition.panoNum].mesh.material.materials[i], time, {opacity: 1, ease: Power0.easeOut, onComplete: Hotspot.addHotspots, onCompleteParams:[ pano_id ]});
            }
            else
            {
                TweenLite.to(Transition.clearPano[Transition.panoNum].mesh.material.materials[i], time, {opacity: 1, ease: Power0.easeOut});
            }
        }
    }

    Hotspot.removeHotspots();
    Transition.currentPano = pano_id;
    loadBlurPano(pano_id,hotspot_angle,dist).done(function(){
        oldpanoToBlurpano(pano_id, hotspot_angle,dist,rotate_angle);

    });

};
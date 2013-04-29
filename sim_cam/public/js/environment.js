/*jslint browser: true*/
/*jslint newcap: false*/
/*jslint nomen: true */
/*global $, _, jQuery, Backbone, console, alert, THREE, requestAnimationFrame, Base64Binary, Highcharts, imagediff */
/*jshint globalstrict: true*/

/**TODO:
 * Template for Calibration
 * Making 
 *
 */

var SimCam = {
    "Version"  : 0.001,
    "Template" : {},
    "Constructor" : {
        "Collection": {},
        "Model"  :    {},
        "View"   :    {},
        "Router" :    {}
    },
    "Util" : {
        "DEG2RAD" : function (d) { return d * (Math.PI/180); },
        "RAD2DEG" : function (r) { return r * (180/Math.PI); }
    }
};



SimCam.captures_needed_for_calibration = 4;

/*Model Constructors*/

SimCam.Constructor.Model.Generic = Backbone.Model.extend({});

/*Collection Contructors*/
SimCam.Constructor.Collection.Calibrations = Backbone.Collection.extend({
    latest_results : function () {
        "use strict";
        var that, latest;
        that = this;
        latest = that.at(that.length - 1);
        return latest.get('result');
    },
    distortions_series_parameters : function () {
        "use strict";
        var that, results, series;
        that = this;
        results = that.map(function (m) { return m.get('result'); });

        series = [ ];
        series.push({ name: 'r1', data:  _.map(results, function (m) { return parseFloat(m.distortion[0], 10); }) });
        series.push({ name: 'r2', data:  _.map(results, function (m) { return parseFloat(m.distortion[1], 10); }) });
        series.push({ name: 't1', data:  _.map(results, function (m) { return parseFloat(m.distortion[2], 10); }) });
        series.push({ name: 't2', data:  _.map(results, function (m) { return parseFloat(m.distortion[3], 10); }) });
        series.push({ name: 'r3', data:  _.map(results, function (m) { return parseFloat(m.distortion[4], 10); }) });

        series.push({ name: 'fx', data:  _.map(results, function (m) { return parseFloat(m.intrinsics[0], 10); }) });
        series.push({ name: 'fy', data:  _.map(results, function (m) { return parseFloat(m.intrinsics[4], 10); }) });
        series.push({ name: 'cx', data:  _.map(results, function (m) { return parseFloat(m.intrinsics[2], 10); }) });
        series.push({ name: 'cy', data:  _.map(results, function (m) { return parseFloat(m.intrinsics[5], 10); }) });

        return series;
    }
});

SimCam.Constructor.Collection.Captures = Backbone.Collection.extend({
    to_calibrate : function () {
        "use strict";
        var that = this, mapped, url_str = '?';
        // map the collection in just the checked inputs
        mapped = that.map(function (m) { return m.get('checked')['in']; });
        _.each(mapped, function (o) {
            url_str += 'images=' + o + '&';
        });
        return url_str;
    }
});



/*Templates*/

SimCam.Template.ResultsModal = '<div id="results_modal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="results_modal_label" aria-hidden="true">' +
/*          '<div class="modal-header">' +
          '  <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>' +
          '  <h3 id="results_modal_label">Results</h3>' +
          '</div>' +
*/
          '<div class="modal-body">' +
          '  <p>One fine body…</p>' +
          '</div>' +
          '<div class="modal-footer">' +
          '  <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>' +
          '</div>' +
          '</div>';

SimCam.Template.MainFrame = '<iframe src="/iframes/environment.html" allowfullscreen="true" webkitallowfullscreen="true" mozallowfullscreen="true" allowfullscreen="true" webkitallowfullscreen="true" mozallowfullscreen="true" frameborder="0" class="simcam_iframe" width="100%" height="100%" ></iframe>';

SimCam.Template.SideMenu = {
    "pinhole" : '<h5>Pinhole Camera Model</h5>' +
                '<li class="nav-header">Field of View</li>' +
                '<li><a href="javascript:void(0)"><input type="text" name="fov" class="span1 pinhole_sidemenu_input"/></a></li>' +
                '<li class="nav-header">Sensor Size in Pixels</li>' +
                '<li><a href="javascript:void(0)">X: <input type="text" name="u" class="span1 pinhole_sidemenu_input"/></a></li>' +
                '<li><a href="javascript:void(0)">Y: <input type="text" name="v" class="span1 pinhole_sidemenu_input"/></a></li>' +
                '<li class="nav-header">Aspect Ratio</li>' +
                '<li><a href="javascript:void(0)"><input type="text" name="aspect" class="span1 pinhole_sidemenu_input"/></a></li>' +
                '<li class="nav-header">Far</li>' +
                '<li><a href="javascript:void(0)"><input type="text" name="far" class="span1 pinhole_sidemenu_input" disabled="true" /></a></li>' +
                '<li class="nav-header">Near</li>' +
                '<li><a href="javascript:void(0)"><input type="text" name="near" class="span1 pinhole_sidemenu_input" disabled="true" /></a></li>',
    "distortions" : '<h5>Distortions</h5>' +
                '<li class="nav-header">Radial Distortions</li>' +
                '<li><a href="javascript:void(0)">K1: <input type="text" name="r1" class="span1 distortions_sidemenu_input"/></a></li>' +
                '<li><a href="javascript:void(0)">K2: <input type="text" name="r2" class="span1 distortions_sidemenu_input"/></a></li>' +
                '<li><a href="javascript:void(0)">K3: <input type="text" name="r3" class="span1 distortions_sidemenu_input"/></a></li>' +
                '<li class="nav-header">Tangential Distortions</li>' +
                '<li><a href="javascript:void(0)">P1: <input type="text" name="t1" class="span1 distortions_sidemenu_input"/></a></li>' +
                '<li class="nav-header">Far</li>' +
                '<li><a href="javascript:void(0)">P2: <input type="text" name="t2" class="span1 distortions_sidemenu_input" /></a></li>',
    "calibration" : '<li class="nav-header">Calibration</li>' +
                '<li><input type="button" name="capture" class="btn btn_primary calibration_sidemenu_input" value="Capture Image" /></li>' +
                '<li class="nav-header"> </li>' +
                '<li><input type="button" name="results" class="btn btn_primary calibration_sidemenu_input" value="View Current Results" disabled="disabled" /></li>',
    "matrix" : '<h5>Apply Matrix</h5>' +
                '<li><input type="button" class="btn btn-primary matrix_sidemenu_apply_btn" value="Apply" /></li>',
    "webcam" :  '<li class="nav-header">Webcam Calibration</li>' +
                '<li><input type="button" name="capture" class="btn btn_primary calibration_sidemenu_input" value="Capture Image" /></li>' +
                '<li><input type="button" name="results" class="btn btn_primary calibration_sidemenu_input" value="View Current Results" disabled="disabled" /></li>'

};


SimCam.Template.Modal = {
    'obj_RT' : ' <div class="well" id="object_rt" style="z-index:11; width:200px; position:absolute; bottom:20px; right:0px;"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button><dl><dt>Position</dt><dd><span id="x"> <span class="values"></span></span>, <span id="y"> <span class="values"> </span></span>, <span id="z"> <span class="values"> </span></span></dd><dt>Rotation</dt><dd> <span id="rx"> <span class="values"> </span></span>, <span id="ry"> <span class="values"> </span></span>, <span id="rz"> <span class="values"> </span></span></dd> </dl></div>',
    'calibration': '<ul class="nav nav-tabs" id="modal_tab">' +
                      '<li><a href="#modal_nav_current_params" data-toggle="tab">Parameters</a></li>' +
                      '<li><a href="#modal_nav_current_graph" data-toggle="tab">Graphs</a></li>' +
                      '<li><a href="#modal_nav_current_diff" data-toggle="tab">Efficacy</a></li>' +

                   '</ul>' +
                    '<div class="tab-content">' +
                        '<div id="modal_nav_current_params" class="tab-pane">' +
                            '<h3>Intrinsics:</h3>' +
                            '<% var li_s = latest_intrinsics %>' +
                            '<% var ld_s = latest_distortion %>' +
                            '<table class="table tabled-bordered">' +
                            '<tr><td><%= parseFloat(li_s[0], 10) %></td><td><%= parseFloat(li_s[1], 10) %></td><td><%= parseFloat(li_s[2], 10) %></td></tr>' +
                            '<tr><td><%= parseFloat(li_s[3], 10) %></td><td><%= parseFloat(li_s[4], 10) %></td><td><%= parseFloat(li_s[5], 10) %></td></tr>' +
                            '<tr><td><%= parseFloat(li_s[6], 10) %></td><td><%= parseFloat(li_s[7], 10) %></td><td><%= parseFloat(li_s[8], 10) %></td></tr>' +
                            '</table>' +
                            '<h3>Distortions:</h3>' +
                            '<table class="table tabled-bordered">' +
                            '<tr><td><%= parseFloat(ld_s[0], 10) %></td><td><%= parseFloat(ld_s[1], 10) %></td><td><%= parseFloat(ld_s[2], 10) %></td><td><%= parseFloat(ld_s[3], 10) %></td><td><%= parseFloat(ld_s[4], 10) %></td></tr>' +
                            '</table>' +

                        '</div>' +
                        '<div id="modal_nav_current_graph" class="tab-pane">' +
                            '<div id="calibration_chart_container" style="width:100%; height:100%;">Loading ...</div>' +
                        '</div>' +
                        '<div id="modal_nav_current_diff" class="tab-pane">' +
                            '<table class="table">' +
                            '<thead><tr>' +
                                '<td>Undistorted:</td>' +
                                '<td>Distorted:</td>' +
                                '<td>Corrected:</td>' +
                                '<td>Difference:</td>' +
                            '</tr></thead>' +
                            '<tbody id="difference_image_show" style="max-height:320px; overflow-y:scroll;"></tbody>' +
                            '</table>' +
                        '</div>' +
                    '</div>'

};


/*View Constructors*/

SimCam.Constructor.View.ObjectRTModal = Backbone.View.extend({
    initialize: function (options) {
        "use strict";
        var that;
        that = this;

        that.$el.hide();

        that.app = options.app;

        that.app.models.camera.bind('move', that.set_object, that);
        that.app.models.grid.bind('move', that.set_object, that);

    },
    events : {
        "click .values" : "on_click_values",
        "change input" : "on_change_input",
        "click .close" : "on_click_close"
    },
    set_object : function (object, model) {
        "use strict";
        var that = this;

        that.current_model = model;
        that.current_object = object;
        that.$('#x').html( '<span class="values">' + that.current_model.position.x  + '</span>');
        that.$('#y').html( '<span class="values">' + that.current_model.position.y  + '</span>');
        that.$('#z').html( '<span class="values">' + that.current_model.position.z  + '</span>');
        that.$('#rx').html( '<span class="values">' + SimCam.Util.RAD2DEG(that.current_model.rotation.x ) + '</span>');
        that.$('#ry').html( '<span class="values">' + SimCam.Util.RAD2DEG(that.current_model.rotation.y ) + '</span>');
        that.$('#rz').html( '<span class="values">' + SimCam.Util.RAD2DEG(that.current_model.rotation.z ) + '</span>');



        that.$el.show();
    },
    on_click_values : function (e) {
        "use strict";
        var that,
        curTarget = $(e.currentTarget);
        that = this;

        console.log('asds');
        curTarget.parent().html( '<input style="width:50px" name="'+ curTarget.parent().attr('id')  + '" value="' + curTarget.text() + '" />' );
        
        
    },
    on_change_input : function (e) {
        "use strict";
        var that, name, val,
        curTarget = $(e.currentTarget);
        that = this;
        name = curTarget.attr('name');
        val = curTarget.val();
        switch( name ) {
            case 'x':
                that.current_model.position.x = val;
                break;
            case 'y':
                that.current_model.position.y = val;
                break;
            case 'z':
                that.current_model.position.z = val;
                break;
            case 'rx':
                that.current_model.rotation.x = SimCam.Util.DEG2RAD(val);
                break;
             case 'ry':
                that.current_model.rotation.y = SimCam.Util.DEG2RAD(val);
                break;
            case 'rz':
                that.current_model.rotation.z = SimCam.Util.DEG2RAD(val);
                break;
            default:
                break;
        }
            console.log(that.current_object);
            that.current_object.trigger('move', that.current_object, that.current_model );
        
        
    },
    on_click_close: function(e) {
        this.$el.hide();
    }
});

SimCam.Constructor.View.MainWebCamView = Backbone.View.extend({

    initialize: function (options) {
        var that = this;
        that.cv_el = options.cv_el;
        that.calibration = options.app.models.calibration;
        that.captures = that.calibration.get('captures');
        that.$el.html('<center><video id="video" width="640" height="480" autoplay></video></center>');
        that.cv_el.html('<canvas id="canvas" width="640" height="480" style="width:200px">');

        that.cv_el_canvas = that.cv_el.find('canvas')[0];
        var ctx = that.cv_el_canvas.getContext("2d");
        var video = that.$('#video')[0],
        videoObj = { "video": true },
        errBack = function(error) {
            console.log("Video capture error: ", error.code); 
        };
    
        if(navigator.getUserMedia) { 
            navigator.getUserMedia(videoObj, function(stream) {
                video.src = stream;
                video.play();
            }, errBack);
        } else if(navigator.webkitGetUserMedia) {
            navigator.webkitGetUserMedia(videoObj, function(stream){
                video.src = window.webkitURL.createObjectURL(stream);
                video.play();
            }, errBack);
        }

        var ws_capture_url = 'ws://'+location.hostname+':8080/api/ws_check';
        var ws_calibration_url = 'ws://'+location.hostname+':8080/api/ws_calibration';

        var sidebar_viewer = options.view.side_bar_viewer;

        var capture_btn = sidebar_viewer.$el.find('[name="capture"]');
        var results_btn = sidebar_viewer.$el.find('[name="results"]');


        capture_btn.on('click', function() {
            ctx.drawImage(video, 0, 0, 640, 480); 
                capture_btn.attr('disabled', 'disabled');

            if( that.socket ) {
                that.socket.close();
                that.socket = undefined;
            }
            if (typeof(WebSocket) !== 'undefined') {
              console.log("Using a standard websocket");
              that.socket = new WebSocket(ws_capture_url);
            } else if (typeof(MozWebSocket) !== 'undefined') {
              console.log("Using MozWebSocket")
              that.socket = new MozWebSocket(ws_capture_url);
            } else {
              Messenger().post("Your browser does not support web sockets. Cannot perform webcam calibration");
            }

            that.socket.onopen = function (e) {
                var req = { "image" : that.cv_el_canvas.toDataURL(), "type" : "base64" };

                that.socket.send( JSON.stringify( req ) );
                Messenger().post('Captured image sent for processing!');

            };
            that.socket.onmessage = function (e) {
                var res = JSON.parse(e.data );
                console.log( e.data );
                if( res.result == "256" ) {
                    Messenger().post('Calibration Grid Found! See captured images below!');

                    var current_capture = new SimCam.Constructor.Model.Generic({});
                    current_capture.set('checked', res );
                    that.captures.add( current_capture );
                    if( that.captures.length >= 4) {
                        results_btn.removeAttr('disabled');
    
                    }
                } else {
                    Messenger().post('Calibration Grid not Found');
                }
                capture_btn.removeAttr('disabled');

            };

            that.socket.onclose = function (e) {
            };
            that.socket.onerror = function (e) {
            }; 

        });
    }
});

SimCam.Constructor.View.MainCanvas = Backbone.View.extend({
    initialize: function (options) {
        "use strict";
        var that, light, jsonLoader, xplane, yplane, zplane;
        that = this;

        that.bind('rendered', function () { if (options.render_cb) { options.render_cb(this); } }, that);
        that.mouse =  new THREE.Vector2();
        that.offset = new THREE.Vector3();

        that.camera = new THREE.PerspectiveCamera(35, that.$el.innerWidth() / that.$el.innerHeight(), 1, 10000);
        that.camera.position.set(45, 45, 45);

        that.controls = new THREE.OrbitControls(that.camera, that.$('canvas')[0]);
        that.controls.rotateSpeed = 1.0;
        that.controls.zoomSpeed = 1.2;
        that.controls.panSpeed = 0.8;
        that.controls.noZoom = false;
        that.controls.noPan = false;
        that.controls.staticMoving = true;
        that.controls.dynamicDampingFactor = 0.3;

        that.scene = new THREE.Scene();
        that.objects = $([]);

        that.scene.add(new THREE.AmbientLight(0x505050));

        light = new THREE.SpotLight(0xffffff, 1.5);
        light.position.set(0, 500, 2000);
        light.castShadow = true;

        light.shadowCameraNear = 200;
        light.shadowCameraFar = that.camera.far;
        light.shadowCameraFov = 50;

        light.shadowBias = -0.00022;
        light.shadowDarkness = 0.5;

        light.shadowMapWidth = 2048;
        light.shadowMapHeight = 2048;
        that.lights = $([]);
        that.lights.push(light);

        that.scene.add(light);

        jsonLoader = new THREE.JSONLoader();
        jsonLoader.load("/3d_objs/camera.js", function (geometry) {
            var cam_obj, material, cube;
            cam_obj = new THREE.Mesh(geometry, new THREE.MeshLambertMaterial({color: 0x2200cc}));

            cam_obj.material.ambient = cam_obj.material.color;

            cam_obj.position.set(0, 0, 15);

            cam_obj.scale.set(1, 1, 1);
            cam_obj.rotation.set(0, 0, 0);
            cam_obj.model = that.options.app.models.camera;
            //cam_obj.castShadow = false;
            //cam_obj.receiveShadow = false;
            material = new THREE.MeshLambertMaterial({
                map: THREE.ImageUtils.loadTexture("/img/grid.gif")
            });

            material.map.needsUpdate = true;

            cube = new THREE.Mesh(
                new THREE.CubeGeometry(8, 5, 0.1),
                material
            );
            cube.model = that.options.app.models.grid;
            cube.model.trigger('move', cube.model, cube);
            cube.overdraw = true;
            that.scene.add(cube);
            that.objects.push(cube);

            cube.position.set(0, 0, 0);

            that.scene.add(cam_obj);

            that.objects.push(cam_obj);
            
            cam_obj.model.trigger('move', cam_obj.model, cam_obj);
            console.log('triggered move');

        });

        that.plane = new THREE.Mesh(new THREE.PlaneGeometry(4000, 4000, 4, 4), new THREE.MeshBasicMaterial({ color: 0x000000, opacity: 0.25, transparent: true, wireframe: true }));
        xplane = new THREE.Mesh(new THREE.PlaneGeometry(4000, 4000, 4, 4), new THREE.MeshBasicMaterial({ color: 0xCC0000, opacity: 0.25, transparent: true, wireframe: true }));
        yplane = new THREE.Mesh(new THREE.PlaneGeometry(4000, 4000, 4, 4), new THREE.MeshBasicMaterial({ color: 0x00CC00, opacity: 0.25, transparent: true, wireframe: true }));
        zplane = new THREE.Mesh(new THREE.PlaneGeometry(4000, 4000, 4, 4), new THREE.MeshBasicMaterial({ color: 0x0000CC, opacity: 0.25, transparent: true, wireframe: true }));

        yplane.rotation.set(0, 1.57079633, 0);
        zplane.rotation.set(1.57079633, 0, 0);

        that.scene.add(xplane);
        that.scene.add(yplane);
        that.scene.add(zplane);

        that.plane.visible = false;
        that.scene.add(that.plane);

        that.projector = new THREE.Projector();

        that.renderer = new THREE.WebGLRenderer({antialias: true, clearColor: 0x888888, clearAlpha: 255, canvas: that.$('canvas')[0]});
        that.renderer.sortObjects = false;
        that.renderer.setSize(that.$el.innerWidth(), that.$el.innerHeight());

        that.renderer.shadowMapEnabled = true;
        that.renderer.shadowMapSoft = true;

        //that.el.appendChild(that.renderer.domElement );

        /*
           renderer.domElement.addEventListener( 'mousemove', onDocumentMouseMove, false );
           renderer.domElement.addEventListener( 'mousedown', onDocumentMouseDown, false );
           renderer.domElement.addEventListener( 'mouseup', onDocumentMouseUp, false );


           window.addEventListener( 'resize', onWindowResize, false );
           */
        $(window).on('resize', function () {that.on_resize(); });
        that.animate();
    },
    set_from_camera : function ( camera ) {
        var cam_obj = this.objects[1];
//        this.scale.getScaleFromMatrix( camera.matrix );
        console.log('sdsd');

        var mat = new THREE.Matrix4().extractRotation( camera.matrix );
        cam_obj.rotation.setEulerFromRotationMatrix( mat, camera.eulerOrder );

        cam_obj.position.getPositionFromMatrix( camera.matrix );

    },
    to_screen_xy: function (o) {
        "use strict";
        var that, pos, camera, jqdiv, projScreenMat, object, obj;
        that = this;
        camera = that.camera;
        jqdiv = that.$el;
        obj = that.objects[o];
        pos = obj.position.clone();
        projScreenMat = new THREE.Matrix4();
        projScreenMat.multiply(camera.projectionMatrix, camera.matrixWorldInverse);
        projScreenMat.multiplyVector3(pos);

        return { x: (pos.x + 1) * jqdiv.width() / 2 + jqdiv.offset().left,
             y: (-pos.y + 1) * jqdiv.height() / 2 + jqdiv.offset().top };

    },
    events : {
        'mousemove canvas' : 'on_canvas_mmove',
        'mousedown canvas' : 'on_canvas_mdown',
        'mouseup canvas'   : 'on_canvas_mup'
    },
    on_canvas_mmove : function (event) {
        "use strict";
        event.preventDefault();
        var vector, ray, intersects, loc, forward, target, axis, sinAngle, cosAngle, angle, rotation_measuring_mesh;
        this.mouse.x = (event.clientX / this.$el.innerWidth()) * 2 - 1;
        this.mouse.y = -(event.clientY / this.$el.innerHeight()) * 2 + 1;

        vector = new THREE.Vector3(this.mouse.x, this.mouse.y, 0.5);
        this.projector.unprojectVector(vector, this.camera);

        ray = new THREE.Ray(this.camera.position, vector.subSelf(this.camera.position).normalize());

        this.controls.enabled = true;
        if (this.SELECTED) {
            this.controls.enabled = false;

            intersects = ray.intersectObject(this.plane);
            if (intersects[0] && intersects[0].point) {
                if (event.shiftKey) {
                    loc = intersects[0].point.subSelf(this.offset);
                    vector = new THREE.Vector3(0, 0, 0);

                    vector.sub(this.SELECTED.position, loc);

                    // Direction we are already facing (without rotation)
                    forward = new THREE.Vector3(0, 0, -1);

                    // Direction we want to be facing (towards mouse pointer)
                    target = vector.normalize();

                    // Axis and angle of rotation
                    axis = new THREE.Vector3().cross(forward, target);
                    sinAngle = axis.length(); // |u x v| = |u|*|v|*sin(a)
                    cosAngle = forward.dot(target); // u . v = |u|*|v|*cos(a)
                    angle = Math.atan2(sinAngle, cosAngle); // atan2(sin(a),cos(a)) = a
                    axis.normalize();
                    rotation_measuring_mesh = new THREE.Mesh();
                    rotation_measuring_mesh.useQuaternion = true;
                    rotation_measuring_mesh.quaternion.setFromAxisAngle(axis, angle);
                    this.SELECTED.rotation.set(rotation_measuring_mesh.quaternion.x, rotation_measuring_mesh.quaternion.y, rotation_measuring_mesh.quaternion.z);
                    this.SELECTED.rotation.multiplyScalar(rotation_measuring_mesh.quaternion.w);
                } else {
                    this.SELECTED.position.copy(intersects[0].point.subSelf(this.offset));
                }
                this.SELECTED.model.trigger('move', this.SELECTED.model, this.SELECTED);
            }
            return;

        }


        intersects = ray.intersectObjects(this.objects);

        if (intersects.length > 0) {

            if (this.INTERSECTED !== intersects[0].object) {

                if (this.INTERSECTED) {
                    this.INTERSECTED.material.color.setHex(this.INTERSECTED.currentHex);
                }

                this.INTERSECTED = intersects[0].object;
                this.INTERSECTED.currentHex = this.INTERSECTED.material.color.getHex();

                this.plane.position.copy(this.INTERSECTED.position);
                this.plane.lookAt(this.camera.position);
                this.plane.rotation.copy(this.camera.rotation);

            }

            this.el.style.cursor = 'pointer';

        } else {

            if (this.INTERSECTED) {
                this.INTERSECTED.material.color.setHex(this.INTERSECTED.currentHex);
            }

            this.INTERSECTED = null;

            this.el.style.cursor = 'auto';

        }


    },
    on_canvas_mdown : function (event) {
        "use strict";
        var that, vector, ray, intersects;
        that = this;

        event.preventDefault();

        vector = new THREE.Vector3(that.mouse.x, that.mouse.y, 0.5);
        that.projector.unprojectVector(vector, that.camera);

        ray = new THREE.Ray(that.camera.position, vector.subSelf(that.camera.position).normalize());

        intersects = ray.intersectObjects(that.objects);

        if (intersects.length > 0) {

            that.controls.enabled = false;

            that.SELECTED = intersects[0].object;

            intersects = ray.intersectObject(that.plane);
            that.offset.copy(intersects[0].point).subSelf(that.plane.position);

            that.el.style.cursor = 'move';

        }


    },
    on_canvas_mup : function (event) {
        "use strict";
        event.preventDefault();
        this.controls.enabled = true;

        if (this.INTERSECTED) {
            this.plane.position.copy(this.INTERSECTED.position);
            this.INTERSECTED.model.trigger('move', this.INTERSECTED.model, this.INTERSECTED);

            this.SELECTED = null;
        }

        this.el.style.cursor = 'auto';

    },
    on_resize : function (event) {
        "use strict";
        this.camera.aspect = this.$el.innerWidth() / this.$el.innerHeight();
        this.camera.updateProjectionMatrix();

        this.renderer.setSize(this.$el.innerWidth(), this.$el.innerHeight());


    },
    animate : function () {
        "use strict";
        var that = this;
        requestAnimationFrame(function () {that.animate(); });
        that.render();
    },
    render : function () {
        "use strict";
        var that;
        that = this;

        if (that.rendered === undefined && that.objects.length > 0) {
            that.rendered = true;
            that.trigger('rendered');
        }
	    that.controls.update();
        that.renderer.render(that.scene, that.camera);
    }
});

SimCam.Constructor.View.SideCanvas = Backbone.View.extend({
    initialize: function (options) {
        "use strict";
        var that, light, cc, material, cube, cv;
        that = this;
        that.options = options;
        
        that.camera = new THREE.PerspectiveCamera();
        cc = options.app.models.camera;

        cc.set('fov', that.camera.fov);
        cc.set('aspect', that.camera.aspect);
        cc.set('far', that.camera.far);
        cc.set('near', that.camera.near);
        cc.set('u', 200);
        cc.set('v', 200);
        cc.trigger('set', cc);
        that.camera.position.set(0, 0, 15);

        that.scene = new THREE.Scene();
        that.scene.add(new THREE.AmbientLight(0x505050));

        light = new THREE.SpotLight(0xffffff, 1.5);
        light.position.set(0, 500, 2000);
        light.castShadow = true;

        light.shadowCameraNear = 200;
        light.shadowCameraFar = that.camera.far;
        light.shadowCameraFov = 50;

        light.shadowBias = -0.00022;
        light.shadowDarkness = 0.5;

        light.shadowMapWidth = 2048;
        light.shadowMapHeight = 2048;
        that.scene.add(light);

        that.texture_loaded = false;

        material = new THREE.MeshLambertMaterial({
            map: THREE.ImageUtils.loadTexture("/img/grid.gif", undefined, function () { that.texture_loaded = true; })
        });

        material.map.needsUpdate = true;

        cube = new THREE.Mesh(new THREE.CubeGeometry(8, 5, 0.1), material);
        cube.overdraw = true;
        that.scene.add(cube);
        that.grid = cube;
        that.camera.lookAt(that.grid);
        that.camera.rotation.set(0, 0, 0);
        cv = that.$('canvas');

        that.renderer = new THREE.WebGLRenderer({antialias: true, clearColor: 0x888888, clearAlpha: 255, canvas: that.$('canvas')[0]});
        that.renderer.sortObjects = false;
        that.renderer.setSize(cv.innerHeight(), cv.innerWidth());

        options.app.models.grid.bind('move', function (o, m) {that.update_grid(o, m); });
        options.app.models.camera.bind('move', function (o, m) {that.update_cam(o, m); });
        options.app.models.camera.bind('update_pinhole_params', function (m) { that.on_update_pinhole_params(m); });
        options.app.models.camera.bind('update_distortions_params', function (m) { that.on_update_distortions_params(m); });

        options.app.models.calibration.bind('request_capture', function (m) { that.on_request_capture(m); });


        $(window).on('resize', function () { that.on_resize(); });

        that.update_current_data_url = true;
        that.animate();
        that.on_resize();
    },
    events : {
    },
    on_resize : function () {
        "use strict";
        var that, width, cv, camera;
        that = this;
        camera = that.options.app.models.camera;

        width = camera.get('u');

        cv = that.$el;
        if (that.renderer) {
            that.renderer.setSize(width * that.camera.aspect, width);
        }

    },
    animate : function () {
        "use strict";
        var that = this;
        requestAnimationFrame(function () { that.animate(); });
        if (that.texture_loaded) {
            that.render();
        }

    },
    render : function () {
        "use strict";
        var that = this;
        that.renderer.render(that.scene, that.camera);
        if (that.update_current_data_url) {
            that.current_image = that.$('canvas')[0].toDataURL();

            that.on_update_current_image();
            that.update_current_data_url = false;
        }
    },
    update_grid : function (model, obj) {
        "use strict";
        var that, grid;
        that = this;
        grid = that.options.app.models.grid;
        grid.set('position', [obj.position.x, obj.position.y, obj.position.z]);
        grid.set('rotation', [obj.rotation.x, obj.rotation.y, obj.rotation.z]);
        that.grid.position.copy(obj.position);
        that.grid.rotation.copy(obj.rotation);
        that.update_current_data_url = true;
    },
    update_cam : function (model, obj) {
        "use strict";
        var that, cam;
        that = this;
        cam = that.options.app.models.camera;
        cam.set('position', [obj.position.x, obj.position.y, obj.position.z]);
        cam.set('rotation', [obj.rotation.x, obj.rotation.y, obj.rotation.z]);

        that.camera.position.copy(obj.position);
        that.camera.rotation.copy(obj.rotation);
        that.update_current_data_url = true;

    },
    get_mean_image : function (data_url) {
        "use strict";
        var that, total, sum, arr;
        that = this;

        arr = Base64Binary.decode(data_url);
        total = arr.length;

        sum = 0;
        _.each(arr, function (obj) {
            sum += obj;
        });

        return (sum / total);
    },
    update_distortion_image : function () {
        "use strict";
        var that, ImageConstructor, camera_model, image_model, params, distortion_url_bit;
        that = this;
        if (that.loading_image) {
            return false;
        }
        that.loading_image = true;
        camera_model = that.options.app.models.camera;
        
        distortion_url_bit = '';
        params = ['t1', 't2', 'r1', 'r2', 'r3'];
        _.each(params, function (param) {
            var param_model = camera_model.get(param);
            if (param_model) {
                distortion_url_bit += param + '=' + param_model + '&';
            }
        });

        if (distortion_url_bit === '') {
            that.loading_image = false;
            that.current_distortion = undefined;
            that.current_image_undistorted = undefined;
            return false;
        }

        ImageConstructor = Backbone.Model.extend({ url: '/api/image' });

        image_model = new ImageConstructor({
//            "image": atob(that.current_image.replace('data:image/png;base64,', '')),      
            "image": that.current_image,
            "type" : 'base64'
        });
        that.current_distortion = undefined;
        image_model.save({ },
            {
                success : function (data, textStatus, jqXHR) {
                    var dist_url, image, image_element;
                    that.current_image_undistorted = data.get('img');
                    dist_url  = '/api/distort/' + data.get('img') + '?' + distortion_url_bit;
                    $.getJSON(dist_url, function (d) {
                        var dist_image_src = '/uploads/' + d.out;
                        that.current_distortion = d;

                        image_element = that.$('img');
                        if (image_element.length > 0) {
                            image_element.attr('src', dist_image_src);
                        } else {
                            image_element = $('<img style="position:absolute; z-index: 2; top:0px; right: 0px" src="' + dist_image_src + '" />');
                            that.$el.append(image_element);
                        }
                    });
                    that.loading_image = false;
                },
                error : function () { that.loading_image = false; }
            });
    },
    on_update_current_image: function () {
        "use strict";
        var that = this;
        that.update_distortion_image();

    },
    on_update_pinhole_params: function (model) {
        "use strict";
        var that, attrs;
        that = this;
        _.each(['fov', 'near', 'far', 'aspect'], function (param) {
            var value = model.get(param);
            if (value) {
                that.camera[param] = value;
            }
        });
        that.camera.updateProjectionMatrix();
        that.on_resize();
        that.render();
    },
    on_update_distortions_params: function (model) {
        "use strict";
        var that;
        that = this;
        that.on_update_current_image();
    },
    on_request_capture: function (model) {
        "use strict";
        var that, current_capture, cc_img, check_url, check_data;
        that = this;

        current_capture = new SimCam.Constructor.Model.Generic({});

        current_capture.set('undistorted', { url : that.current_image, img: that.current_image_undistorted });
        current_capture.set('distorted', that.current_distortion);

        check_url = '/api/check';
        check_data = undefined;
        if (that.current_distortion) {
            cc_img = that.current_distortion.out;
            check_url += '/' + cc_img;
        } else if (that.current_image_undistorted) {
            cc_img = that.current_image_undistorted;
            check_url += '/' + cc_img;
        } else {
            cc_img = that.current_image;
            current_capture.set('type', 'base64');
            check_data = { 'type' : 'base64', 'image' : cc_img};
        }

        current_capture.set('camera', that.options.app.models.camera.toJSON());
        current_capture.set('grid', that.options.app.models.grid.toJSON());


        $.getJSON(check_url, check_data, function (data) { current_capture.set('checked', data); })
            .done(function () {
                var captures = model.get('captures');
                current_capture.set('image', cc_img);
                if (parseInt(current_capture.get('checked').result, 10) === 256) {
                    captures.add(current_capture);
                } else {
                    Messenger().post("Couldn't find the grid in the camera view!");
                }
            });
    }
});


SimCam.Constructor.View.SideMenu = Backbone.View.extend({
    initialize: function (options) {
        "use strict";
        var that;
        that = this;
        that.app = options.app;
        that.render(options.mode);
        that.app.models.camera.bind('set', that.on_camera_model_set, that);
        that.app.models.calibration.get('captures').bind('add', that.on_add_capture, that);
        that.app.models.calibration.get('calibrations').bind('add', that.on_add_calibration, that);

    },
    events : {
        'keyup .pinhole_sidemenu_input' : 'on_change_pinhole_sidemenu_input',
        'keyup .distortions_sidemenu_input' : 'on_change_distortions_sidemenu_input',
        'click [name="capture"]' : 'on_click_capture_btn',
//        'click [name="calibrate"]' : 'on_click_calibrate_btn',
        'click [name="results"]' : 'on_click_results_btn'
    },
    render: function (mode) {
        "use strict";
        var that, template;
        that = this;
        template = SimCam.Template.SideMenu[mode.type];
        if (template === undefined) {
            template = 'Sidemenu template not implemented for: ' + mode.type;
        }
        that.$('.body').html(template);

    },
    on_camera_model_set: function (model) {
        "use strict";
        var that, attrs;
        that = this;
        attrs = model.attributes;
        _.each(attrs, function (value, name) {
            that.$('[name="' + name + '"]').val(value);
        });
    },
    on_change_pinhole_sidemenu_input : function (e) {
        "use strict";
        var that, cur_target, name, value, cm, u, v;
        that = this;
        cur_target = $(e.currentTarget);
        name = cur_target.attr('name');
        value = cur_target.val();
        cm = that.app.models.camera;
        cm.set(name, value);

        if (name === 'u') {
            u = value;
            v = cm.get('v');
            cm.set('aspect', u / v);
            that.$('[name="aspect"]').val(u / v);
        } else if (name === 'v') {
            v = value;
            u = cm.get('u');
            cm.set('aspect', u / v);
            that.$('[name="aspect"]').val(u / v);
        }
        cm.trigger('update_pinhole_params', cm);

    },
    on_change_distortions_sidemenu_input : function (e) {
        "use strict";
        var that, cur_target, name, value, cm;
        that = this;
        cur_target = $(e.currentTarget);
        name = cur_target.attr('name');
        value = cur_target.val();
        cm = that.app.models.camera;
        cm.set(name, value);
        cm.trigger('update_distortions_params', cm);
    },
    on_click_capture_btn : function () {
        "use strict";
        var that = this;
        that.app.models.calibration.trigger('request_capture', that.app.models.calibration);
    },
    on_click_calibrate_btn : function () {
        "use strict";
        var that = this;
        that.app.models.calibration.trigger('request_calibrate', that.app.models.calibration);

    },
    on_click_results_btn : function () {
        "use strict";
        var that = this;
        that.app.models.calibration.trigger('request_results', that.app.models.calibration);

    },
    on_add_capture : function (model) {
        "use strict";
        var that, captures;
        that = this;
        captures = that.app.models.calibration.get('captures');
        if (captures.length >= SimCam.captures_needed_for_calibration) {
            //enable the calibration button
//            that.$('[name="calibrate"]').removeAttr('disabled');
            that.on_click_calibrate_btn();
        }
    },
    on_add_calibration : function () {
        "use strict";
        var that;
        that = this;
        //enable the results button
        that.$('[name="results"]').removeAttr('disabled');
    }

});

SimCam.Constructor.View.BottomBarImage = Backbone.View.extend({
    initialize: function (options) {
        "use strict";

    }
});

SimCam.Constructor.View.BottomBar = Backbone.View.extend({
    initialize: function (options) {
        "use strict";
        var that;
        that = this;
        if (options.mode.type !== 'calibration' && options.mode.type !== 'webcam') {
            that.$el.hide();
            return;
        }

        that.model = options.app.models.calibration;
        that.collection = that.model.get('captures');

        that.$('.bottom_bar_image_holder').html('');

        that.collection.bind('add', that.on_add_capture, that);
    },
    on_add_capture: function (model) {
        "use strict";
        var that, img_holder;
        that = this;
        that.$('.captured_count').html(that.collection.length);
        img_holder = that.$('.bottom_bar_image_holder');

        //TODO: Make into a view with a remove button?
        img_holder.append('<img src="/uploads/' + model.get('checked').out +  '" class="bottom_bar_img" />');

    }
});

SimCam.Constructor.View.ResultsModal = Backbone.View.extend({
    initialize: function (options) {
        "use strict";
        var that;
        that = this;
        that.options = options;
        that.app     = options.app;
//        that.$el.modal('hide');
    },
    events : {
        'hidden' : 'on_hidden',
        'a[href="#modal_nav_current_graph"] shown'  : 'on_graph_tab_shown'
    },
    on_hidden : function () {
        "use strict";
        var that = this;
        console.log('hidden');
        if (that.chart) {
            that.chart.destroy();
            that.chart = null;
        }
    },
    on_graph_tab_shown : function () {
        "use strict";
        var that = this;
        if (that.after_shown) {
            that.after_shown();
            that.after_shown = null;
        }

    },
    set_up_calibration : function (options) {
        "use strict";
        var that, collection, diff_grid, m_reverse;
        that = this;
        collection = options.data;
        options.latest_results = collection.latest_results();
        options.latest_intrinsics = options.latest_results.intrinsics;
        options.latest_distortion = options.latest_results.distortion;

        that.$('.modal-body').html(_.template(SimCam.Template.Modal[options.type], options));
        that.$('#calibration_chart_container').html('loading ...');

        that.after_shown = function () {
            var env = that.$('#calibration_chart_container');
            that.chart = new Highcharts.Chart({
                chart: {
                    renderTo: 'calibration_chart_container',
                    type: 'line',
                    events: {
                        load: function (event) {
                        //When is chart ready?
                        }
                    },
                    height : 400,
                    width  : env.innerWidth() * 0.9
                },
                legend : {
                    useHTML: true,
                    foating: true,
                    align: 'right',
                    layout: 'vertical',
                    verticalAlign: 'top'
                },
                title: {
                    text: 'Distortions & Intrinsics Parameters'
                },
                xAxis: {
                    title: { text: 'Calibration Attempts' }
                },
                yAxis: {
                    title: {
                        text: 'Values'
                    }
                },
                series: collection.distortions_series_parameters()
            });
        
        };

        diff_grid = that.$('#difference_image_show');

        diff_grid.html('');
        m_reverse = collection.models;
        _.each(collection.models, function (model, i) {
            var tr, captures, lc, correct_url, ji, undistorted_image, calibrated_image, difference_image, load_count = 0;
            captures = model.get('captures');
            lc = captures[captures.length - 1];

            console.log(lc);
            
            var distorted = lc.distorted;
            if( lc.distorted === undefined ) {
                distorted = lc.checked['in'];
            } else {
                distorted = distorted.out;
            }
            ji = model.get('result').job_id;
            correct_url = '/api/undistort/' +
                          distorted +
                          '?job_id=' + ji;
                    /*
                          '&cx=' + parseFloat(t[0], 10) +
                          '&cy=' + parseFloat(t[4], 10) +
                          '&fx=' + parseFloat(t[2], 10) +
                          '&fy=' + parseFloat(t[5], 10);
                    */

            var width = 200; var height = 200;
                        
            

            tr = _.template('<tr class="' + i + '"><td class="undistorted_image"></td><td><img src="/uploads/<%=distorted%>" /></td><td class="calibrated_image"></td><td><canvas width=200 height=200 /></td></tr>', {lc : lc, cu : correct_url, distorted: distorted });

            tr = $(tr);
            diff_grid.prepend(tr);

            undistorted_image = new Image();

            calibrated_image = new Image();

            var target_canvas = $(tr.find('canvas')[0]);
            undistorted_image.onload = calibrated_image.onload = function () {

                target_canvas.attr('width', undistorted_image.width);
                target_canvas.attr('height', undistorted_image.height);
                target_canvas.css( { "width" : "200px", "height" : "200px" } );

                var context = target_canvas[0].getContext('2d');
                load_count += 1;
                if (load_count >= 2) {
                    tr.find('.undistorted_image').html(undistorted_image);
                    tr.find('.calibrated_image').html(calibrated_image);
                    difference_image = imagediff.diff(undistorted_image, calibrated_image);
                    context.putImageData(difference_image, 0, 0);
                }
            };
            var un_im_url = lc.undistorted;
            if( lc.undistorted === undefined ) {
                un_im_url = '/uploads/'+lc.checked['in'];
            } else {
                un_im_url = un_im_url.url;
            }
            undistorted_image.src = un_im_url;
            calibrated_image.src = correct_url;
        });
        
    },
    render : function (options) {
        "use strict";
        var that;
        that = this;
        if (options.type === 'calibration') {
            options = that.set_up_calibration(options);
        } else if (options.type === 'capture') {
            that.$('.modal-body').html(_.template(SimCam.Template.Modal[options.type], options));
        }
        that.$('#modal_tab a').click(function (e) { e.preventDefault(); $(this).tab('show'); });

        that.$('#modal_tab a:first').tab('show');
        that.$('a[href="#modal_nav_current_graph"]').on('shown', function () { that.on_graph_tab_shown(); });


        that.$el.modal('show');
    }
});

SimCam.Constructor.View.Main = Backbone.View.extend({
    initialize: function (options) {
        "use strict";
        var that, main_viewer_frame, camera_viewer_frame, mv_body, cv_body, side_el, bottom_el, popovers, calibration;
        that = this;

        that.mode = options.mode;
        main_viewer_frame = that.$('#main_viewer');
        camera_viewer_frame = that.$('#camera_viewer');

        mv_body = $(main_viewer_frame[0].contentDocument).find('body');
        cv_body = $(camera_viewer_frame[0].contentDocument).find('body');

        bottom_el = that.$('.bottom_bar');
        side_el   = that.$('.sidemenu');


        that.bottom_bar_viewer = new SimCam.Constructor.View.BottomBar({ el: bottom_el, mode: that.mode, app: options.app });
        that.side_bar_viewer   = new SimCam.Constructor.View.SideMenu({ el: side_el, mode: that.mode, app: options.app });

            if( options.mode.type !== 'webcam') {
                 that.camera_viewer     = new SimCam.Constructor.View.SideCanvas({ el: cv_body, mode: that.mode, app: options.app });

                that.main_viewer       = new SimCam.Constructor.View.MainCanvas({ el: mv_body, mode: that.mode, app: options.app, render_cb : function (t) { that.on_main_viewer_render(t); } });
                that.$el.append(SimCam.Template.Modal.obj_RT);
                that.object_modal  = new SimCam.Constructor.View.ObjectRTModal({ el: that.$('#object_rt'), app: options.app});
                       }
            else {
                camera_viewer_frame.css('height', '150px');
                main_viewer_frame.css('height', '640px');

                that.main_viewer = new SimCam.Constructor.View.MainWebCamView({ el : mv_body, cv_el :  cv_body, app: options.app, view: that });
            }
                that.$el.css('height', '670px');

        that.modal_view        = new SimCam.Constructor.View.ResultsModal({ el: options.app.el.find('#results_modal'), mode: that.mode, app: options.app});

        main_viewer_frame.on('load', function () { that.main_viewer.trigger('load'); });
        camera_viewer_frame.on('load', function () { that.camera_viewer.trigger('load'); });

        if (that.mode.learning_environment) {
            popovers = that.$('[data-toggle="popover"]');
            popovers.popover({ html: true});
            popovers.popover('toggle');
        }
        calibration = options.app.models.calibration;

        calibration.bind('request_calibrate', that.on_request_calibrate, that);
        calibration.bind('request_results', that.on_request_result, that);
    },
    events: {
        'load' : 'on_load',
        'click .close_popover' : 'on_click_close_popover'
    },
    on_main_viewer_render : function (t) {
        "use strict";
        var that;
        that = this;
        if (!that.options.learning_environment) {
            return;
        }
        _.each(t.objects, function (o, i) {
            var elem, loc, placement;
            loc = t.to_screen_xy(i);
            elem = $('<p style="position:absolute; z-index:4; top: ' + loc.y + 'px; left: ' + loc.x + 'px;" data-toggle="popover" ></p>');
            that.$el.append(elem);
            placement = 'top';
            if (i % 2) {
                placement = 'bottom';
            }
            elem.popover({
                'placement' : placement,
                'html': true,
                'title': '3D element',
                'content': 'Click and drag to move. Hold shift and drag to rotate. <input type="button" class="close_popover btn" value="close">'
            });
            elem.popover('toggle');
        });
    },
    on_load : function () {
        "use strict";

    },
    on_click_close_popover: function (e) {
        "use strict";
        var that, cur_target, rel_data_toggle;
        that = this;
        cur_target = $(e.currentTarget);

        rel_data_toggle = $(cur_target.parents('.popover').prevAll('[data-toggle="popover"]')[0]);
        rel_data_toggle.popover('toggle');
    },
    render : function () {
        "use strict";
        var that;
        that = this;

    },
    on_request_calibrate : function (calibration_model) {
        "use strict";
        var that, captures, calibrations, current_calibration, calibrate_images_data;
        that = this;
        captures = calibration_model.get('captures');
        calibrations = calibration_model.get('calibrations');

        calibrate_images_data = captures.to_calibrate();

        current_calibration = new SimCam.Constructor.Model.Generic({});

        current_calibration.set('captures', captures.toJSON());
        $.getJSON('/api/calibrate' + calibrate_images_data, function (d) { current_calibration.set('result', d); })
            .done(function () { calibrations.add(current_calibration); });
    },
    on_request_result : function () {
        "use strict";
        var that, calibrations, modal;
        that = this;

        calibrations = that.options.app.models.calibration.get('calibrations');

        //construct or acquire modal

        that.modal_view.render({ "type" : "calibration", "data" : calibrations});
    }
});


/*Router Constructor*/
SimCam.Constructor.Router.App = Backbone.Router.extend({
    version : 0.01,
    el: $('body'),
    initialize: function (options) {
        "use strict";
        var that, env_frame, env_frame_body;
        that = this;

        that.element = options.element;


        that.models = {
            camera: new SimCam.Constructor.Model.Generic(options.camera),
            grid: new SimCam.Constructor.Model.Generic(),
            calibration: new SimCam.Constructor.Model.Generic({ captures: new SimCam.Constructor.Collection.Captures(), calibrations: new SimCam.Constructor.Collection.Calibrations() })
        };
        env_frame = $(SimCam.Template.MainFrame);

        env_frame.load(function () { 
                that.on_env_frame_load(options, env_frame);
                if (options.success) {
                    options.success(that);
                }
            });

        that.element.append(env_frame);
        that.capture_mousewheel = false;
        $(window).on('mousewheel', function(e) { if( that.capture_mousewheel ) { e.preventDefault(); } } ); 

        env_frame.on('mouseenter', function(e) { that.capture_mousewheel = true;  } );
        env_frame.on('mouseleave', function(e) { that.capture_mousewheel = false;  } );

        that.el.append(SimCam.Template.ResultsModal);
    
    },
    routes: {
	    '': 'default_route',
        'camera/:distortion' : 'route_camera_distortion'
    },
    //ROUTES
    default_route : function () {
        "use strict";
        var that;
        that = this;
    },
    route_camera_distortion : function (dist) {
        "use strict";
        var that = this,
            params = {};
        _.each(dist.split('&'), function (param) {
            var kv = param.split('=');
            params[kv[0]] = kv[1];
            that.models.camera.set(kv[0], parseFloat(kv[1], 10));
            that.models.camera.trigger('update_distortions_params');            
        });

    },
    //EVENTS 
    on_env_frame_load : function (options, env_frame) {
        "use strict";
        var that, env_frame_body;
        that = this;
        env_frame_body = $(env_frame[0].contentDocument).find('body');

        that.view = new SimCam.Constructor.View.Main({ el : env_frame_body, mode: options.mode, app: that });
	    that.view.render();
    }
});

 
SimCam.initialize = function (options) {
    "use strict";

    $(function () {
   
        if (options.mode.type === 'calibration' || options.mode.type === 'webcam' ) {
            SimCam.ScriptLoader.loadscript('/js/highcharts.js');
            SimCam.ScriptLoader.loadscript('/js/imagediff.js');

        }
        
        options.element.css({height: 640 + 'px' });
 

    });

    $(function () {

        var app, image_preload;
        image_preload = new Image();
        image_preload.onload = function () {


            SimCam.grid_texture_map = THREE.ImageUtils.loadTexture("/img/grid.gif", undefined, function () {
                app = new SimCam.Constructor.Router.App(options);

                Backbone.history.start();

            });
        };
        image_preload.src = '/img/grid.gif';
        return app;
    });
};



SimCam.ScriptLoader = {
    loadscript : function (scr) {
        "use strict";
        var script = document.createElement("script");
        script.type = "text/javascript";
        script.src = scr;
        document.body.appendChild(script);
    }
};
 

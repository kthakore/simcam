/*jslint browser: true*/
/*jslint newcap: false*/
/*jslint nomen: true */
/*global $, _, jQuery, Backbone, console, alert, THREE, requestAnimationFrame, SimCam */
/*jshint globalstrict: true*/

/*Templates*/

SimCam.Template.MainFrame = '<iframe src="/iframes/environment.html" allowfullscreen="true" webkitallowfullscreen="true" mozallowfullscreen="true" allowfullscreen="true" webkitallowfullscreen="true" mozallowfullscreen="true" frameborder="0" class="simcam_iframe" width="100%" height="640px" ></iframe>';

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

    "matrix" : '<h5>Apply Matrix</h5>' +
                '<li><input type="button" class="btn btn-primary matrix_sidemenu_apply_btn" value="Apply" /></li>'

};



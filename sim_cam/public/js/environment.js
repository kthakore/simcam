/*jslint browser: true*/
/*jslint newcap: false*/
/*jslint nomen: true */
/*global $, _, jQuery, Backbone, console, alert */
/*jshint globalstrict: true*/

var SimCam = {
    "Template" : {},
    "Constructor" : {
        "Collection": {},
        "Model"  :    {},
        "View"   :    {},
        "Router" :    {}
    }
};

/*Model Constructors*/

SimCam.Constructor.Model.Generic = Backbone.Model.extend({});

/*Templates*/

SimCam.Template.MainFrame = '<iframe src="/iframes/environment.html" allowfullscreen="true" webkitallowfullscreen="true" mozallowfullscreen="true" allowfullscreen="true" webkitallowfullscreen="true" mozallowfullscreen="true" frameborder="0" class="simcam_iframe" width="100%" height="640px" ></iframe>';

SimCam.Template.SideMenu = {
    "Pinhole" : '<h5>Pinhole Camera Model</h5>' +
                '<li class="nav-header">Field of View</li>' +
                '<li><a href="javascript:void(0)"><input type="text" name="fov" class="span1 pinhole_sidemenu_input"/></a></li>' +
                '<li class="nav-header">Sensor Size in Pixels</li>' +
                '<li><a href="javascript:void(0)">X: <input type="text" name="u" class="span1 pinhole_sidemenu_input"/></a></li>' +
                '<li><a href="javascript:void(0)">Y: <input type="text" name="v" class="span1 pinhole_sidemenu_input"/></a></li>' +
                '<li class="nav-header">Aspect Ratio</li>' +
                '<li><a href="javascript:void(0)"><input type="text" name="aspect_ratio" class="span1 pinhole_sidemenu_input"/></a></li>' +
                '<li style="width=100%; height=100%; background-color:red"></li>'


};


/*View Constructors*/
SimCam.Constructor.View.MainCanvas = Backbone.View.extend({
    initialize: function (options) {
        "use strict";

    }
});

SimCam.Constructor.View.SideCanvas = Backbone.View.extend({
    initialize: function (options) {
        "use strict";

    }

});


SimCam.Constructor.View.SideMenu = Backbone.View.extend({
    initialize: function (options) {
        "use strict";
        var that;
        that = this;
        that.app = options.app;
        that.render(options.mode);
    },
    events : {
    },
    render: function (mode) {
        "use strict";
        var that;
        that = this;
        switch (mode.type) {
        case 'pinhole':
            that.render_pinhole();
            break;
        default:
            console.error('SideMenu: Mode not implemented');
        }
    },
    render_pinhole: function () {
        "use strict";
        var that, template;
        that = this;
        template = SimCam.Template.SideMenu.Pinhole;
        that.$('.body').html(template);

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

    }
});

SimCam.Constructor.View.Main = Backbone.View.extend({
    initialize: function (options) {
        "use strict";
        var that, main_viewer_frame, camera_viewer_frame, mv_body, cv_body, side_el, bottom_el, popovers;
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

        that.main_viewer       = new SimCam.Constructor.View.MainCanvas({ el: mv_body, mode: that.mode, app: options.app });
        that.camera_viewer     = new SimCam.Constructor.View.SideCanvas({ el: cv_body, mode: that.mode, app: options.app });

        main_viewer_frame.on('load', function () { that.main_viewer.trigger('load'); });
        camera_viewer_frame.on('load', function () { that.camera_viewer.trigger('load'); });

        if (that.mode.learning_environment) {
            popovers = that.$('[data-toggle="popover"]');
            popovers.popover({ html: true});
            popovers.popover('toggle');
        }

    },
    events: {
        'load' : 'on_load',
        'click .close_popover' : 'on_click_close_popover'
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

    }
});


/*Router Constuctor*/
SimCam.Constructor.Router.App = Backbone.Router.extend({
    version : 0.01,
    initialize: function (options) {
        "use strict";
        var that, env_frame, env_frame_body;
        that = this;

        that.element = options.element;

        that.models = { camera: new SimCam.Constructor.Model.Generic() };

        env_frame = $(SimCam.Template.MainFrame);

        env_frame.load(function () { that.on_env_frame_load(options, env_frame); });

        that.element.append(env_frame);

    },
    routes: {
	    '': 'default_route'
    },
    //ROUTES
    default_route : function () {
        "use strict";
        var that;
        that = this;
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
    var app;
    app = new SimCam.Constructor.Router.App(options);
    Backbone.history.start();
};


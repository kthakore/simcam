/*jslint browser: true*/
/*jslint newcap: false*/
/*jslint nomen: true */
/*global $, _, jQuery, Backbone, console, PageView */
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

SimCam.Template.MainFrame = '<iframe src="/iframes/environment.html" allowfullscreen="true" webkitallowfullscreen="true" mozallowfullscreen="true" allowfullscreen="true" webkitallowfullscreen="true" mozallowfullscreen="true" frameborder="0" class="simcam_iframe" width="100%" height="640px" ></iframe>';

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

        that.bottom_bar_viewer = new SimCam.Constructor.View.BottomBar({ el: bottom_el, mode: that.mode });
        that.side_bar_viewer   = new SimCam.Constructor.View.SideMenu({ el: side_el, mode: that.mode });

        that.main_viewer       = new SimCam.Constructor.View.MainCanvas({ el: mv_body, mode: that.mode });
        that.camera_viewer     = new SimCam.Constructor.View.SideCanvas({ el: cv_body, mode: that.mode });

        main_viewer_frame.on('load', function () { that.main_viewer.trigger('load'); });
        camera_viewer_frame.on('load', function () { that.camera_viewer.trigger('load'); });

        if (that.mode.learning_environment) {
            popovers = that.$('[data-toggle="popover"]');
            popovers.popover();
            popovers.popover('toggle');
        }

    },
    events: {
        'load' : 'on_load'
    },
    on_load : function () {
        "use strict";

    },
    render : function () {
        "use strict";
        var that;
        that = this;

    }
});

SimCam.Constructor.Router.App = Backbone.Router.extend({
    version : 0.01,
    initialize: function (options) {
        "use strict";
        var that, env_frame, env_frame_body;
        that = this;

        that.element = options.element;

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

        that.view = new SimCam.Constructor.View.Main({ el : env_frame_body, mode: options.mode });
	    that.view.render();


    }
});


SimCam.initialize = function (options) {
    "use strict";
    var app;
    app = new SimCam.Constructor.Router.App(options);
    Backbone.history.start();
};


$(function () {
    window.debug = console.log ? function (x) {
        console.log(x);
    } : function () { };

    debug("Start");

    var Entry = Backbone.Model.extend({
        urlRoot: '/api/entry',
        defaults: function () {
            return {
                body: ''
            }
        }
    });

    var FormView = Backbone.View.extend({
        el: $('#Body'),
        template: window.tmpl($('#formTmpl').html()),
        events: {
            'submit form': 'onSubmit'
        },
        render: function () {
            debug('render formView');
            $('#Body').html(this.template({}));
        },
        onSubmit: function (ev) {
            ev.stopPropagation();
            ev.preventDefault();

            var entry = new Entry();
            debug(this.el.find('form').serializeArray()[0]);
            entry.set(_.reduce($('form').serializeArray(), function (a,b) { a[b.name]=b.value; return a }, {}));
            entry.save().success(function (dat) {
                debug(dat);
                window.router.navigate("entry/" + dat.id, true);
            });
        }
    });
    window.formView = new FormView();

    var EntryView = Backbone.View.extend({
        template: window.tmpl($('#entryTmpl').html()),
        render: function () {
            $('#Body').html(this.template({entry: this.model}));
        }
    });
    window.entryView = new EntryView();

    var AppRouter = Backbone.Router.extend({
        routes: {
            "": 'top',
            "entry/:id": "show"
        },
        top: function () {
            debug('top');
            window.formView.render();
        },
        show: function (id) {
            debug('show : ' + id);
            var entry = new Entry();
            entry.id = id;
            entry.fetch().success(function (dat) {
                debug("succ1");
                debug(dat);
                window.entryView.model = dat;
                window.entryView.render();
            });
        }
    });
    window.router = new AppRouter();

    Backbone.history.start({ pushState: true });
});

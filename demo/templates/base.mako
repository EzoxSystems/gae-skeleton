<!DOCTYPE html>
<html>
    <head>
        <title>Demo</title>
        <link rel="stylesheet" type="text/css" href="/static/css/lib.css">
        <link rel="stylesheet" type="text/css" href="/static/css/demo.css">
    </head>
    <body>
        <div id="demo">
            <div class="navbar navbar-fixed-top">
                <div class="navbar-inner">
                    <div class="container">
                        <a class="brand" href="#">Demo</a>
                        <div id="demoheader" class="nav-collapse">
                            <ul id="demo-menu" class="nav">
                            </ul>
                        </div><!--/.nav-collapse -->
                    </div>
                </div>
            </div>
            <div id="democontainer" class="container">
                <div id="demoapp"></div>
            </div>
        </div>
        <div class="footer">
          <center><strong>View the source at:</strong> <a href="https://github.com/ezoxsystems/gae-skeleton">https://github.com/ezoxsystems/gae-skeleton</a></center>
        </div>
        <script type="application/javascript" src="/static/script/libs.js"></script>
        <script type="application/javascript" src="/static/script/template.js"></script>
        <script type="application/javascript" src="/static/script/skel.js"></script>
        <script type="application/javascript" src="/static/script/demo.js"></script>
        <script type="text/javascript">
        $(function(){
            var demo = new App.Demo.Router
            Backbone.history.start();
            App.Demo.router = demo;
        });
        </script>
    </body>
</html>

<!DOCTYPE html>
<html>
  <head>
    <title>Demo<%block name="title"/></title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" type="text/css" href="/static/css/lib.css">
    <link rel="stylesheet" type="text/css" href="/static/css/demo.css">
  </head>
  <body>
    <div class="navbar navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container">
          <button type="button" class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="brand" href="/">Demo</a>
          <div id="demoheader" class="nav-collapse">
            <ul id="demo-menu" class="nav"></ul>
          </div>
        </div>
      </div>
    </div>
    <div id="demo">
        <div id="democontainer" class="container"></div>
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

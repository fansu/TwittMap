<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<%@ page import="com.amazonaws.*" %>
<%@ page import="com.amazonaws.auth.*" %>
<%@ page import="com.amazonaws.services.ec2.*" %>
<%@ page import="com.amazonaws.services.ec2.model.*" %>
<%@ page import="com.amazonaws.services.s3.*" %>
<%@ page import="com.amazonaws.services.s3.model.*" %>
<%@ page import="com.amazonaws.services.dynamodbv2.*" %>
<%@ page import="com.amazonaws.services.dynamodbv2.model.*" %>

<%@ page import="com.datastax.driver.core.Cluster" %>
<%@ page import="com.datastax.driver.core.Metadata" %>
<%@ page import="com.datastax.driver.core.Session" %>
<%@ page import="com.datastax.driver.core.ResultSet" %>
<%@ page import="com.datastax.driver.core.Row" %>
<%@ page import="com.datastax.driver.core.policies.DCAwareRoundRobinPolicy" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="twitter4j.*" %>
<%@ page import="twitter4j.QueryResult" %>
<%@ page import="twitter4j.conf.ConfigurationBuilder" %>

<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.io.InputStreamReader" %>
<%@ page import="java.net.HttpURLConnection" %>
<%@ page import="java.net.URL" %>
<%@ page import="java.net.URLEncoder" %>

<%@ page import="org.json.simple.JSONArray" %>
<%@ page import="org.json.simple.JSONObject" %>
<%@ page import="org.json.simple.JSONValue" %>

<%! // Share the client objects across threads to
    // avoid creating new clients for each web request
    private AmazonEC2         ec2;
    private AmazonS3           s3;
    private AmazonDynamoDB dynamo;
 %>
<%
    /*
     * AWS Elastic Beanstalk checks your application's health by periodically
     * sending an HTTP HEAD request to a resource in your application. By
     * default, this is the root or default resource in your application,
     * but can be configured for each environment.
     *
     * Here, we report success as long as the app server is up, but skip
     * generating the whole page since this is a HEAD request only. You
     * can employ more sophisticated health checks in your application.
     */
    if (request.getMethod().equals("HEAD")) return;
%>

<%
    if (ec2 == null) {
        AWSCredentialsProvider credentialsProvider = new ClasspathPropertiesFileCredentialsProvider();
        ec2    = new AmazonEC2Client(credentialsProvider);
        s3     = new AmazonS3Client(credentialsProvider);
        dynamo = new AmazonDynamoDBClient(credentialsProvider);
    }

	String choice = request.getParameter("dropdown");	
	
	ConfigurationBuilder cb = new ConfigurationBuilder();
%>

<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8">
    <title>TwittMap Application</title>
    <link rel="stylesheet" href="styles/styles.css" type="text/css" media="screen">
        <style>
      #map-canvas {
        width: 90%;
        height: 600px;
        margin-top: 50px;
      }
      body {
     	height: 100%;
     	width: 100%;
      	padding-left: 50px;
      	padding-right: 50px;
      }
      .button-borders{
        height: 64px;
      }
      .button-bottom{
        padding-bottom: 0;
      }
    </style>
    <link rel="stylesheet" href="//code.jquery.com/ui/1.11.2/themes/smoothness/jquery-ui.css">
    <script src="http://code.jquery.com/jquery-1.10.2.js"></script>
    <script src="http://code.jquery.com/ui/1.11.2/jquery-ui.js"></script>
  
    <!-- Latest compiled and minified CSS -->
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
	
	<!-- Optional theme -->
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css">
	
	<!-- Latest compiled and minified JavaScript -->
	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>

    <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&libraries=visualization"></script>
    
    <script>
// Adding 500 Data Points
var map, pointarray, heatmap;

function initialize() {
  var mapOptions = {
    zoom: 4,
    center: new google.maps.LatLng(33.774546, -122.433523),
    mapTypeId: google.maps.MapTypeId.SATELLITE
  };

  map = new google.maps.Map(document.getElementById('map-canvas'),
      mapOptions);
  window.setInterval(function (){
	  heatmap = null;
    var keywords = 'halloween';
	$.get('Servlet', {
	    keyword : keywords
	}, function(responseText) {		
	  $.each(responseText, function(key, val) {
		var data = JSON.stringify(val);
		var data_s = data.substr(1, data.length-2);
		var data_spl = data_s.split(',');
		var lat = data_spl[0];
		var lon = data_spl[1];

		var taxiData = [
          new google.maps.LatLng(lat, lon)];
  		var pointArray = new google.maps.MVCArray(taxiData);

		heatmap = new google.maps.visualization.HeatmapLayer({
		    data: pointArray
		  });
  
  		heatmap.setMap(map);
  	  });
	});
  }, 3000);
}

function toggleHeatmap() {
  heatmap.setMap(heatmap.getMap() ? null : map);
}

function changeGradient() {
  var gradient = [
    'rgba(0, 255, 255, 0)',
    'rgba(0, 255, 255, 1)',
    'rgba(0, 191, 255, 1)',
    'rgba(0, 127, 255, 1)',
    'rgba(0, 63, 255, 1)',
    'rgba(0, 0, 255, 1)',
    'rgba(0, 0, 223, 1)',
    'rgba(0, 0, 191, 1)',
    'rgba(0, 0, 159, 1)',
    'rgba(0, 0, 127, 1)',
    'rgba(63, 0, 91, 1)',
    'rgba(127, 0, 63, 1)',
    'rgba(191, 0, 31, 1)',
    'rgba(255, 0, 0, 1)'
  ]
  heatmap.set('gradient', heatmap.get('gradient') ? null : gradient);
}

function changeRadius() {
  heatmap.set('radius', heatmap.get('radius') ? null : 20);
}

function changeOpacity() {
  heatmap.set('opacity', heatmap.get('opacity') ? null : 0.2);
}

google.maps.event.addDomListener(window, 'load', initialize);

</script>
</head>
<body>
<nav class="navbar navbar-default" role="navigation">
  <div class="container-fluid">
    <!-- Brand and toggle get grouped for better mobile display -->
    <div class="navbar-header">
      <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <a class="navbar-brand" href="/index">TwittMap</a>
    </div>

    <!-- Collect the nav links, forms, and other content for toggling -->
    <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
      <ul class="nav navbar-nav">
        <li><a href="/index">Main</a></li>
        <li class="active"><a href="/real-time">Real-time</a></li>
        <li><a href="/about">About</a></li>
      </ul>
    </div>
   </div>
 </nav>
  <h1 class="text-center">TwittMap Application Real time Display</h1>
  <div class="row">
   <div class="col-md-6">
     <div class="btn-group">
      <button class="btn btn-info" onclick="toggleHeatmap()">Toggle Heatmap</button>
      <button class="btn btn-info" onclick="changeGradient()">Change gradient</button>
      <button class="btn btn-info" onclick="changeRadius()">Change radius</button>
      <button class="btn btn-info" onclick="changeOpacity()">Change opacity</button>
     </div>
   </div>
   <div class="col-md-6"></div>
  </div>
  <div id="map-canvas" class="span4, text-center"></div>
</body>
</html>
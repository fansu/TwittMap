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

	Cluster cluster;
	Session c_session;
	cluster = Cluster.builder().withLoadBalancingPolicy(new DCAwareRoundRobinPolicy("")).addContactPoint("").build();
	Metadata metadata = cluster.getMetadata();
	System.out.printf("Connected to cluster: %s\n", 
	         metadata.getClusterName());
	
	String startdate = request.getParameter("startdatepicker");
	String enddate = request.getParameter("enddatepicker");
	if (startdate == null){
		startdate = "";
	}
	if (enddate == null){
		enddate = "";
	}
	String choice = request.getParameter("dropdown");
	String date_query = "";
	String choice_query = "keywords = 'halloween'";
	String and_query = "";
	Boolean date_boolean = false;
	DateFormat userDateFormat = new SimpleDateFormat("MM/dd/yyyy");
	DateFormat dateFormatNeeded = new SimpleDateFormat("yyyy-MM-dd"); 
	if (startdate!=null && enddate!=null && startdate.length() !=0 && enddate.length()!=0){
		date_query = "date >= '" + dateFormatNeeded.format(userDateFormat.parse(startdate)) + "' and date <= '" + dateFormatNeeded.format(userDateFormat.parse(enddate)) + "' allow filtering";
		date_boolean = true;
	}
	if (date_boolean){
		and_query = " and ";
	}
	if (choice!=null){
		choice_query = "keywords = '" + choice + "'";
	}
	String query = "SELECT * FROM twitt_all where " + choice_query + and_query + date_query;
	
	c_session = cluster.connect("demo"); 
	ResultSet results = c_session.execute(query + ";");
	ArrayList<Double> ids = new ArrayList<Double>();
	ArrayList<String> contents = new ArrayList<String>();
	ArrayList<Double> lats = new ArrayList<Double>();
	ArrayList<Double> lons = new ArrayList<Double>();
	for (Row row : results) {
		ids.add(row.getDouble("id"));
		lats.add(row.getDouble("latitude"));
		lons.add(row.getDouble("longitude"));
		contents.add(row.getString("content"));
	}
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
    <script src="//code.jquery.com/jquery-1.10.2.js"></script>
    <script src="//code.jquery.com/ui/1.11.2/jquery-ui.js"></script>
  
    <!-- Latest compiled and minified CSS -->
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css">
	
	<!-- Optional theme -->
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap-theme.min.css">
	
	<!-- Latest compiled and minified JavaScript -->
	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>

    <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&libraries=visualization"></script>
    
    <script>
    $(function() {
        $( "#startdatepicker" ).datepicker();
        $( "#enddatepicker" ).datepicker();
      });
// Adding 500 Data Points
var map, pointarray, heatmap;

var taxiData = [
  <% for (int i = 0;i < ids.size(); i++) { %>
  new google.maps.LatLng(<%= lats.get(i) %>
  ,
  <%= lons.get(i) %>),   
  <% } %>
//  new google.maps.LatLng(37.751266, -122.403355)
];

function initialize() {
  var mapOptions = {
    zoom: 4,
    center: new google.maps.LatLng(33.774546, -122.433523),
    mapTypeId: google.maps.MapTypeId.SATELLITE
  };

  map = new google.maps.Map(document.getElementById('map-canvas'),
      mapOptions);

  var pointArray = new google.maps.MVCArray(taxiData);

  heatmap = new google.maps.visualization.HeatmapLayer({
    data: pointArray
  });

  heatmap.setMap(map);
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
        <li class="active"><a href="/index">Main</a></li>
        <li><a href="/real-time">Real-time</a></li>
        <li><a href="/about">About</a></li>
      </ul>
    </div>
   </div>
 </nav>
        
  <h1 class="text-center">TwittMap Application Display and search</h1>
  
  <form action="index.jsp" method="POST">
    <div class="row">
      <div class="col-md-2">
        <div class="form-group, span4" id="selection"> 
          <label class="label label-primary" for="sel1">keywords selection</label>
          <select name="dropdown" class="form-control" id="sel1">
            <option value="halloween" ${param.dropdown == 'halloween' ? 'selected' : ''}>Halloween</option>
            <option value="usairway" ${param.dropdown == 'usairway' ? 'selected' : ''}>USAirway</option>
            <option value="newyork" ${param.dropdown == 'newyork' ? 'selected' : ''}>NewYork</option>
            <option value="columbia" ${param.dropdown == 'columbia' ? 'selected' : ''}>Columbia</option>
          </select>
        </div>
      </div>
      <div class="col-md-2"><p>Start Date: <input class="form-control" type="text" name="startdatepicker" id="startdatepicker" placeholder=<%= startdate %>></p></div>
      <div class="col-md-2"><p>End Date: <input class="form-control" type="text" name="enddatepicker" id="enddatepicker" placeholder=<%= enddate %>></p></div>
      <div class="col-md-6"></div>
    </div>
    <div class="row">
      <div class="col-md-2"><input class="btn btn-primary" type="submit" value="Submit" /></div>
      <div class="col-md-10"></div>
    </div> 
  </form>
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
COMSE6998 CLOUD COMPUTING & BIG DATA - TwittMap(Assignment1)


Team Member
-----------
Fan Su		 	()
Jingyi	Guo		(jg3421)

website for demon
-----------
http://twittapp-env.elasticbeanstalk.com/index.jsp

Files
-----
README						- this file
AutoLoad.java		 		- java file using Elastic Beanstalk API to create, configure, and deploy
							Elastic LoadBalancing API to configure load balancing.


Internal Design
---------------
Features:
1. Display twitts' location on map with predefined keywords search ('halloween', 'USAirway', 'NewYork', 'Columbia')
2. Display twitts' location based on time range filter
3. Color gradient and density map display for twitts on map based on location
4. Real time twitts location display 

Tools used:
1. Web server: Tomcat 7.0 on AWS Elastic Beanstalk
2. Database: Apache Cassandra on AWS EC2
3. API: Twitter Live and Streaming API, Google Map API,Elastic Beanstalk,Elastic LoadBalancing

Steps to use without installing source code:
1. Go to page http://twittapp-env.elasticbeanstalk.com/
2. 'Main' will show main feature with locations of twitts, keywords filtering in dropdown, time range filtering
3. 'Real time' will show real-time twitts' location with predefined search keywords 'halloween'

Steps in using source code
1. Git clone source code
2. Link to AWS account with access key and secret key and connect with current development environment
3. Create application and environment on AWS Elastic Beanstalk 
4. Add jars to build path
5. Create Cassandra Database on AWS EC2
6. Create account in Twitter API and get access keys
7. Deploy project in AWS Elastic Beanstalk







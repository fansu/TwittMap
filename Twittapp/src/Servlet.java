
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.datastax.driver.core.Cluster;
import com.datastax.driver.core.Metadata;
import com.datastax.driver.core.ResultSet;
import com.datastax.driver.core.Row;
import com.datastax.driver.core.Session;
import com.datastax.driver.core.policies.DCAwareRoundRobinPolicy;

import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.JSONValue;

import twitter4j.FilterQuery;
import twitter4j.StallWarning;
import twitter4j.Status;
import twitter4j.StatusDeletionNotice;
import twitter4j.StatusListener;
import twitter4j.TwitterStream;
import twitter4j.TwitterStreamFactory;

import com.datastax.driver.core.Cluster;
import com.datastax.driver.core.Metadata;
import com.datastax.driver.core.ResultSet;
import com.datastax.driver.core.Row;
import com.datastax.driver.core.Session;
import com.datastax.driver.core.policies.DCAwareRoundRobinPolicy;
import com.google.gson.Gson;

/**
 * Servlet implementation class Servlet
 */

class Pair {
	Double lats;
	Double lons;
}
public class Servlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public Servlet() {
        super();
        // TODO Auto-generated constructor stub
    	TwitterStream twitterStream = new TwitterStreamFactory().getInstance();
    	final Cluster cluster;
		final Session session;
		cluster = Cluster.builder().withLoadBalancingPolicy(new DCAwareRoundRobinPolicy("")).addContactPoint("").build();
		
		session = cluster.connect("demo");
	    StatusListener listener = new StatusListener(){
	        public void onStatus(Status t) {
	        	try {
		    		final String keywords = "halloween";
					HttpURLConnection conn;
					String location;
					if (t.getGeoLocation() == null){
						if (t.getUser().getLocation() != null && t.getUser().getLocation().length() > 8 && !t.getUser().getLocation().substring(0, 8).equals("Location"))
						{
							try {
								location = URLEncoder.encode(t.getUser().getLocation(), "UTF-8").replace("+", "%20");
								URL url = new URL("http://nominatim.openstreetmap.org/search/" + location + "?format=json&addressdetails=1&limit=1&polygon_svg=1");
								conn = (HttpURLConnection) url.openConnection();
								conn.setRequestMethod("GET");
								conn.setRequestProperty("Accept", "application/json");
						 
								if (conn.getResponseCode() == 200) {
									BufferedReader br = new BufferedReader(new InputStreamReader((conn.getInputStream())));
									String output;
									if (br != null){
										output = br.readLine();
										if (output!=null){
											JSONArray array = (JSONArray)JSONValue.parse(output);
											if (array != null){
												if (array.size()!=0){
													JSONObject obj2=(JSONObject)array.get(0);
													String text = t.getText().replace("'","");
													java.util.Date date= new java.util.Date();
													String q = "INSERT INTO twitt (keywords, id, content, createddate, date, latitude, longitude) VALUES (" + "'" + keywords + "', "+ t.getId() + ", '" + text + "', " + date.getTime() + "," + t.getCreatedAt().getTime() + ", " + obj2.get("lat") + ", " + obj2.get("lon") + ") using TTL 5;";
													session.execute(q);
													String q2 = "INSERT INTO twitt_all (keywords, id, content, createddate, date, latitude, longitude) VALUES (" + "'" + keywords + "', "+ t.getId() + ", '" + text + "', " + date.getTime() + "," + t.getCreatedAt().getTime() + ", " + obj2.get("lat") + ", " + obj2.get("lon") + ");";
													session.execute(q2);
												}
											}
										}
									}
									conn.disconnect();								
								}			
							} catch (IOException  | IllegalArgumentException ie) {
								// TODO Auto-generated catch block
//								e.printStackTrace();
							} 
						}
					} else {
						String text = t.getText().replace("'","");
						java.util.Date date= new java.util.Date();
						String q = "INSERT INTO twitt (keywords, id, content, createddate, date, latitude, longitude) VALUES (" + "'" + keywords + "', "+ t.getId() + ", '" + text + "', " + date.getTime() + ", " + t.getCreatedAt().getTime() + ", " + t.getGeoLocation().getLatitude() + ", " + t.getGeoLocation().getLongitude() + ") using TTL 5;";
						session.execute(q);
						String q2 = "INSERT INTO twitt_all (keywords, id, content, createddate, date, latitude, longitude) VALUES (" + "'" + keywords + "', "+ t.getId() + ", '" + text + "', " + date.getTime() + ", " + t.getCreatedAt().getTime() + ", " + t.getGeoLocation().getLatitude() + ", " + t.getGeoLocation().getLongitude() + ");";
						session.execute(q2);
					}
	        	} catch (IllegalArgumentException e) {
					cluster.close();
					session.close();
				} 
	        	
	        }
	        public void onDeletionNotice(StatusDeletionNotice statusDeletionNotice) {}
	        public void onTrackLimitationNotice(int numberOfLimitedStatuses) {}
	        public void onException(Exception ex) {
//	            ex.printStackTrace();
	        }
			@Override
			public void onScrubGeo(long arg0, long arg1) {
				// TODO Auto-generated method stub
				
			}
			@Override
			public void onStallWarning(StallWarning arg0) {
				// TODO Auto-generated method stub
				
			}
	    }; 
		
		FilterQuery q = new FilterQuery();
		String[] keywordsArray = { "halloween"};
	    q.track(keywordsArray);		
	    twitterStream.addListener(listener);
		twitterStream.filter(q);
		
	    // sample() method internally creates a thread which manipulates TwitterStream and calls these adequate listener methods continuously.
	    twitterStream.sample();
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String keywords = request.getParameter("keyword");
        
    	List<Double[]> locations = new ArrayList<Double[]>();
    	
    	Cluster cluster;
    	Session c_session;
    	cluster = Cluster.builder().withLoadBalancingPolicy(new DCAwareRoundRobinPolicy("")).addContactPoint("").build();
    	Metadata metadata = cluster.getMetadata();
    	String query = "SELECT * FROM twitt where keywords= '" + keywords + "' limit 5 allow filtering;";
    	c_session = cluster.connect("demo"); 
    	ResultSet results = c_session.execute(query + ";");
    	
    	int find_count = 0;
    	for (Row row : results) {
    		if (find_count == 5)
    			break;
    		Double[] tmp = new Double[2];
    		tmp[0] = row.getDouble("latitude");
    		tmp[1] = row.getDouble("longitude");
    		locations.add(tmp);
    		find_count++;
    	}
    	
    	Gson gson = new Gson();
    	String json =gson.toJson(locations);
        response.setContentType("application/json");
        PrintWriter out = response.getWriter(); 
        out.print(json);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
	}
}

<?xml version="1.0" encoding="UTF-8" ?>
<%--

// -------------------------------------------------------------------------------
// The Bio2RDF software is copyright Peter Ansell, 2007-2009
// as part of the Microsoft QUT eResearch Centre
// 
// This program is released under the GPL (GNU General Public License) v2.0 or later licence
// 
// The terms of GPL version 2.0 are specified at the following url, 
// and can also be found in the gpl-v2.0.txt file
// 
// http://www.gnu.org/licenses/gpl-2.0.html
// 
// If you wish to use the GPL version 3, the terms are specified at the following url, 
// and can also be found in the gpl-v3.txt file
// 
// http://www.gnu.org/copyleft/gpl.html
// 
// You can contact the Bio2RDF team at bio2rdf@googlegroups.com
// Visit our wiki at http://bio2rdf.wiki.sourceforge.net/
// Visit our main Bio2RDF application at http://www.bio2rdf.org
// -------------------------------------------------------------------------------

--%>
<%@ page contentType="text/html;charset=UTF-8" %>  
<%@page import="org.bio2rdf.servlets.*"%>
<%@page import="org.queryall.helpers.*"%>
<%@page import="org.queryall.blacklist.*"%>
<%@page import="java.io.StringReader,java.util.Date,java.util.Collection,java.util.HashSet,java.util.regex.Matcher"%>
<%@page import="org.apache.log4j.Logger"%>
<%

Logger log = Logger.getLogger("org.bio2rdf.blacklisterror");

Date queryStartTime = new Date();

Settings localSettings = Settings.getSettings();

String realHostName = request.getScheme() + "://" + request.getServerName() + (request.getServerPort() == 80 && request.getScheme().equals("http") ? "" : ":"+ request.getServerPort())+"/";

String serverName = request.getServerName();

String requesterIpAddress = request.getRemoteAddr();

String userAgentHeader = request.getHeader("User-Agent");

if(userAgentHeader == null)
{
	userAgentHeader = "";
}

BlacklistController.doBlacklistExpiry();

boolean userIsBlocked = BlacklistController.isClientBlacklisted(requesterIpAddress);

boolean userIsPermanentlyBlocked = BlacklistController.isClientPermanentlyBlacklisted(requesterIpAddress);

if(!Settings.USER_AGENT_BLACKLIST_REGEX.trim().equals(""))
{
    Matcher userAgentBlacklistMatcher = Settings.USER_AGENT_BLACKLIST_PATTERN.matcher(userAgentHeader);
    
    if(userAgentBlacklistMatcher.find())
    {
        log.error("WARNING: Blacklisterror.jsp: found blocked user-agent trying to access the error redirect page userAgentHeader="+userAgentHeader + " requesterIpAddress="+requesterIpAddress);
        
        userIsPermanentlyBlocked = true;
        userIsBlocked = true;
    }
}

Collection<QueryDebug> allQueriesByUser = BlacklistController.getCurrentDebugInformationFor(requesterIpAddress);

// get the list from the permanent block evidence if they are permanently blocked
if(userIsPermanentlyBlocked)
{
	allQueriesByUser = BlacklistController.permanentServletLifetimeIPBlacklistEvidence.get(requesterIpAddress);
}

int overallCount = 0;
int robotsTxtCount = 0;
double robotsPercentage = 0.0;

if(allQueriesByUser == null)
{
    allQueriesByUser = new HashSet<QueryDebug>(1);
}
else
{
    overallCount = allQueriesByUser.size();
    robotsTxtCount = 0;
    
    for(QueryDebug nextQueryDebug : allQueriesByUser)
    {
        boolean isQueryRobotsTxt = false;
        
        for(String nextQueryDebugTitle : nextQueryDebug.matchingQueryTitles)
        {
            for(QueryType nextQueryDebugType : localSettings.getQueryTypesByUri(nextQueryDebugTitle))
            {
                if(nextQueryDebugType.inRobotsTxt())
                {
                    if(log.isTraceEnabled())
                    {
                        log.trace("BlacklistError.jsp: found query in robots.txt client="+requesterIpAddress+" nextQueryDebugTitle="+nextQueryDebugTitle);
                    }
                    
                    isQueryRobotsTxt = true;
                    break;
                }
            }
            
            if(isQueryRobotsTxt)
                break;
        }
        
        if(isQueryRobotsTxt)
            robotsTxtCount++;
    }
    
    robotsPercentage = robotsTxtCount*1.0/overallCount;
    
    if(userIsBlocked)
    {
        out.write("<h2>Reasons for blocking:</h2>");
    }
    else
    {
        out.write("<h2>Current request history (Not blocked currently):</h2>");
    }
    
    for(QueryDebug nextQuery : allQueriesByUser)
    {
        out.write("<li>"+nextQuery.toString()+"</li>");
    }
    
    out.write("Count of queries not allowed for bots by <a href=\""+realHostName+"robots.txt\">robots.txt</a>="+robotsTxtCount +"<br />\n Overall query count="+overallCount+ "<br />\n Percentage of queries in robots.txt="+robotsPercentage+"<br />\n Maximum allowed percentage of queries in robots.txt="+Settings.getFloatPropertyFromConfig("blacklistPercentageOfRobotTxtQueriesBeforeAutomatic")+"<br />\n Maximum allowed queries in current period ="+Settings.getIntPropertyFromConfig("blacklistClientMaxQueriesPerPeriod")+" <br />\n");
}

if(log.isTraceEnabled())
{
	log.trace("BlacklistError.jsp: results requesterIpAddress="+requesterIpAddress+" robotsTxtCount="+robotsTxtCount +" overallCount="+overallCount+ " robotsPercentage="+robotsPercentage);
}

if(!userIsPermanentlyBlocked && Settings.getBooleanPropertyFromConfig("automaticallyBlacklistClients"))
{
	if(Settings.getBooleanPropertyFromConfig("blacklistResetClientBlacklistWithEndpoints"))
	{
		Date currentDate = new Date();
		
		long differenceMilliseconds = currentDate.getTime() - BlacklistController.lastExpiryDate.getTime();
		
		
		out.write("Current date : "+currentDate.toString()+"<br />\n");
		out.write("Last error reset date: "+BlacklistController.lastExpiryDate.toString()+"<br />\n");
		out.write("Server startup date: "+BlacklistController.lastServerStartupDate.toString()+"<br />\n");
		out.write("Reset period "+Settings.getLongPropertyFromConfig("blacklistResetPeriodMilliseconds")+"<br />\n");
		out.write("Client blacklist will reset in "+((Settings.getLongPropertyFromConfig("blacklistResetPeriodMilliseconds")-differenceMilliseconds)/1000)+" seconds.<br /><br />\n");
		
		if(!userIsBlocked && overallCount < Settings.getIntPropertyFromConfig("blacklistMinimumQueriesBeforeBlacklistRules"))
		{
			out.write("You have "+(Settings.getIntPropertyFromConfig("blacklistMinimumQueriesBeforeBlacklistRules")-overallCount)+" queries left in this period before you are subject to the blacklisting rules, after which time you must keep your percentage of robots.txt disallowed queries below "+Settings.getFloatPropertyFromConfig("blacklistPercentageOfRobotTxtQueriesBeforeAutomatic")*100+"%.<br />\n");
		}
	}
	else
	{
		out.write("Client blacklist not set to reset automatically.<br />\n");
	}
}

if(userIsBlocked)
{
	out.write("<span class=\"error\">Please contact <a href=\"mailto:"+Settings.BLACKLIST_CONTACT_ADDRESS+">"+Settings.BLACKLIST_CONTACT_ADDRESS+"</a> for information about how to avoid getting this message, and why robots.txt disallowed queries should not called repeatedly within a short space of time and why the robots.txt maximum request rate must be respected</span><br />\n");
}

if(userIsPermanentlyBlocked)
{
	out.write("Note: your block is permanent until the next time this server restarts. Contact the server administrator to have a better chance of this occuring sooner rather than later.");
}
%>

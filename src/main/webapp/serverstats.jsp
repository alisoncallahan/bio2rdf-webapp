<%@page
import="java.io.File,org.queryall.statistics.*,org.queryall.blacklist.*,org.queryall.enumerations.*,org.openrdf.repository.Repository,org.openrdf.repository.RepositoryConnection,org.openrdf.repository.sail.SailRepository,org.openrdf.sail.memory.MemoryStore,org.openrdf.query.GraphQueryResult,org.openrdf.query.QueryLanguage,org.openrdf.rio.RDFFormat,org.openrdf.rio.Rio,org.openrdf.rio.RDFParseException,java.io.StringReader,java.util.Date,java.util.Collection,java.util.HashSet,java.util.Hashtable,java.util.regex.Pattern,java.util.regex.Matcher,org.apache.log4j.Logger"%><%
// -------------------------------------------------------------------------------
// Bio2RDF is a creation of
// 
// Francois Belleau
// Marc-Alexandre Nolin
// Peter Ansell
// 
// from the Centre de Recherche du CHUL de Québec 
// and the Microsoft QUT eResearch Centre
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

// DO NOT EDIT version. It is auto-replaced by the build process in order to debug when people have issues with this file
String subversionId = "$Id: serverstats.jsp 917 2010-12-10 22:09:50Z p_ansell $";
String version = "%%__VERSION__%%";
String propertiesSubversionId = "";

Logger log = Logger.getLogger("org.bio2rdf.serverstats");
Settings localSettings = Settings.getSettings();
BlacklistController blacklistController = BlacklistController.getDefaultController();

if(localSettings.getBooleanPropertyFromConfig("statisticsSubmitStatistics", false))
{
    return;
}

Date queryStartTime = new Date();

String realHostName = request.getScheme() + "://" + request.getServerName() + (request.getServerPort() == 80 && request.getScheme().equals("http") ? "" : ":"+ request.getServerPort())+"/";
String requesterIpAddress = request.getRemoteAddr();

String serverName = request.getServerName();

String acceptHeader = request.getHeader("Accept");
String userAgentHeader = request.getHeader("User-Agent");

if(acceptHeader == null || acceptHeader.equals(""))
{
	acceptHeader = localSettings.getStringPropertyFromConfig("preferredDisplayContentType", "application/rdf+xml");
}

if(userAgentHeader == null)
{
	userAgentHeader = "";
}

if(!localSettings.USER_AGENT_BLACKLIST_REGEX.trim().equals(""))
{
    Matcher userAgentBlacklistMatcher = localSettings.USER_AGENT_BLACKLIST_PATTERN.matcher(userAgentHeader);
    
    if(userAgentBlacklistMatcher.find())
    {
        log.error("serverstats.jsp: found blocked user-agent userAgentHeader="+userAgentHeader +" requesterIpAddress="+requesterIpAddress);
        
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        // response.sendRedirect(Settings.getStringPropertyFromConfig("blacklistRedirectPage"));
        return;
    }
}

// log.info("serverstats: about to sleep to test thread handling");
Thread.sleep(10);
// log.info("serverstats: woke up... about to clear statistics upload list");

if(blacklistController.isClientBlacklisted(requesterIpAddress))
{
    log.warn("Atlas2RDF: sending requesterIpAddress="+requesterIpAddress+" to blacklist redirect page");
	
	response.setStatus(HttpServletResponse.SC_FORBIDDEN);
	// response.sendRedirect(Settings.getStringPropertyFromConfig("blacklistRedirectPage"));
	return;
}

blacklistController.clearStatisticsUploadList();

String keyParam = request.getParameter("key");

String keyVariable = "";

if(keyParam != null && !keyParam.trim().equals(""))
{
	keyVariable = keyParam;
}

String acceptHeaderParam = request.getParameter("acceptHeader");

String acceptHeaderVariable = "";

if(acceptHeaderParam != null && !acceptHeaderParam.trim().equals(""))
{
	acceptHeaderVariable = acceptHeaderParam;
}

String requestedContentTypeParam = request.getParameter("requestedContentType");

String requestedContentTypeVariable = "";

if(requestedContentTypeParam != null && !requestedContentTypeParam.trim().equals(""))
{
	requestedContentTypeVariable = requestedContentTypeParam;
}

String lastServerRestartParam = request.getParameter("lastServerRestart");

String lastServerRestartVariable = "";

if(lastServerRestartParam != null && !lastServerRestartParam.trim().equals(""))
{
	lastServerRestartVariable = lastServerRestartParam;
}

String serverSoftwareVersionParam = request.getParameter("serverSoftwareVersion");

String serverSoftwareVersionVariable = "";

if(serverSoftwareVersionParam != null && !serverSoftwareVersionParam.trim().equals(""))
{
	serverSoftwareVersionVariable = serverSoftwareVersionParam;
}

String profileUrisParam = request.getParameter("profileUris");

Collection<String> profileUrisVariable = new HashSet<String>();

if(profileUrisParam != null && !profileUrisParam.trim().equals(""))
{
	profileUrisVariable = ListUtils.listFromStringArray(profileUrisParam.split(","));
}

String successfulproviderUrisParam = request.getParameter("successfulproviderUris");

Collection<String> successfulproviderUrisVariable = new HashSet<String>();

if(successfulproviderUrisParam != null && !successfulproviderUrisParam.trim().equals(""))
{
	successfulproviderUrisVariable = ListUtils.listFromStringArray(successfulproviderUrisParam.split(","));

}

String errorproviderUrisParam = request.getParameter("errorproviderUris");

Collection<String> errorproviderUrisVariable = new HashSet<String>();

if(errorproviderUrisParam != null && !errorproviderUrisParam.trim().equals(""))
{
	errorproviderUrisVariable = ListUtils.listFromStringArray(errorproviderUrisParam.split(","));

}

String configLocationsParam = request.getParameter("configLocations");

Collection<String> configLocationsVariable = new HashSet<String>();

if(configLocationsParam != null && !configLocationsParam.trim().equals(""))
{
	configLocationsVariable = ListUtils.listFromStringArray(configLocationsParam.split(","));

}

String querytypeUrisParam = request.getParameter("querytypeUris");

Collection<String> querytypeUrisVariable = new HashSet<String>();

if(querytypeUrisParam != null && !querytypeUrisParam.trim().equals(""))
{
	querytypeUrisVariable = ListUtils.listFromStringArray(querytypeUrisParam.split(","));

}

String namespaceUrisParam = request.getParameter("namespaceUris");

Collection<String> namespaceUrisVariable = new HashSet<String>();

if(namespaceUrisParam != null && !namespaceUrisParam.trim().equals(""))
{
	namespaceUrisVariable = ListUtils.listFromStringArray(namespaceUrisParam.split(","));

}

String configVersionParam = request.getParameter("configVersion");

String configVersionVariable = "";

if(configVersionParam != null && !configVersionParam.trim().equals(""))
{
	configVersionVariable = configVersionParam;
}

String readtimeoutParam = request.getParameter("readtimeout");

int readtimeoutVariable = 0;

if(readtimeoutParam != null && !readtimeoutParam.trim().equals(""))
{
	try
	{
		readtimeoutVariable = Integer.parseInt(readtimeoutParam);
	}
	catch(NumberFormatException nfe)
	{
		log.trace(nfe);
	}
}

String connecttimeoutParam = request.getParameter("connecttimeout");

int connecttimeoutVariable = 0;

if(connecttimeoutParam != null && !connecttimeoutParam.trim().equals(""))
{
	try
	{
		connecttimeoutVariable = Integer.parseInt(connecttimeoutParam);
	}
	catch(NumberFormatException nfe)
	{
		log.trace(nfe);
	}
}

String userHostAddressParam = request.getParameter("userHostAddress");

String userHostAddressVariable = "";

if(userHostAddressParam != null && !userHostAddressParam.trim().equals(""))
{
	userHostAddressVariable = userHostAddressParam;
}

String userAgentParam = request.getParameter("userAgent");

String userAgentVariable = "";

if(userAgentParam != null && !userAgentParam.trim().equals(""))
{
	userAgentVariable = userAgentParam;
}

String realHostNameParam = request.getParameter("realHostName");

String realHostNameVariable = "";

if(realHostNameParam != null && !realHostNameParam.trim().equals(""))
{
	realHostNameVariable = realHostNameParam;
}

String queryStringParam = request.getParameter("queryString");

String queryStringVariable = "";

if(queryStringParam != null && !queryStringParam.trim().equals(""))
{
	queryStringVariable = queryStringParam;
}

String responseTimeParam = request.getParameter("responseTime");

long responseTimeVariable = 0;

if(responseTimeParam != null && !responseTimeParam.trim().equals(""))
{
	try
	{
		responseTimeVariable = Long.parseLong(responseTimeParam);
	}
	catch(NumberFormatException nfe)
	{
		log.trace(nfe);
	}
}


String sumLatencyParam = request.getParameter("sumLatency");

long sumLatencyVariable = 0;

if(sumLatencyParam != null && !sumLatencyParam.trim().equals(""))
{
	try
	{
		sumLatencyVariable = Long.parseLong(sumLatencyParam);
	}
	catch(NumberFormatException nfe)
	{
		log.trace(nfe);
	}
}

String sumQueriesParam = request.getParameter("sumQueries");

int sumQueriesVariable = 0;

if(sumQueriesParam != null && !sumQueriesParam.trim().equals(""))
{
	try
	{
		sumQueriesVariable = Integer.parseInt(sumQueriesParam);
	}
	catch(NumberFormatException nfe)
	{
		log.trace(nfe);
	}
}

String stdevlatencyParam = request.getParameter("stdevlatency");


double stdevlatencyVariable = 0;

if(stdevlatencyParam != null && !stdevlatencyParam.trim().equals(""))
{
	try
	{
		stdevlatencyVariable = Double.parseDouble(stdevlatencyParam);
	}
	catch(NumberFormatException nfe)
	{
		log.trace(nfe);
	}
}

String sumerrorsParam = request.getParameter("sumerrors");

int sumerrorsVariable = 0;

if(sumerrorsParam != null && !sumerrorsParam.trim().equals(""))
{
	try
	{
		sumerrorsVariable = Integer.parseInt(sumerrorsParam);
	}
	catch(NumberFormatException nfe)
	{
		log.trace(nfe);
	}
}


String sumerrorlatencyParam = request.getParameter("sumerrorlatency");

long sumerrorlatencyVariable = 0;

if(sumerrorlatencyParam != null && !sumerrorlatencyParam.trim().equals(""))
{
	try
	{
		sumerrorlatencyVariable = Long.parseLong(sumerrorlatencyParam);
	}
	catch(NumberFormatException nfe)
	{
		log.trace(nfe);
	}
}

String stdeverrorlatencyParam = request.getParameter("stdeverrorlatency");

double stdeverrorlatencyVariable = 0;

if(stdeverrorlatencyParam != null && !stdeverrorlatencyParam.trim().equals(""))
{
	try
	{
		stdeverrorlatencyVariable = Double.parseDouble(stdeverrorlatencyParam);
	}
	catch(NumberFormatException nfe)
	{
		log.trace(nfe);
	}
}

	StatisticsEntry nextStatsEntry = new StatisticsEntry(
	keyVariable,
	profileUrisVariable,
	successfulproviderUrisVariable,
	errorproviderUrisVariable,
	configLocationsVariable,
	querytypeUrisVariable,
	namespaceUrisVariable,
	configVersionVariable,
	readtimeoutVariable,
	connecttimeoutVariable,
	userHostAddressVariable,
	userAgentVariable,
	realHostNameVariable,
	queryStringVariable,
	responseTimeVariable,
	sumLatencyVariable,
	sumQueriesVariable,
	stdevlatencyVariable,
	sumerrorsVariable,
	sumerrorlatencyVariable,
	stdeverrorlatencyVariable,
    lastServerRestartVariable,
    serverSoftwareVersionVariable,
    acceptHeaderVariable,
    requestedContentTypeVariable);
	
	Collection<StatisticsEntry> currentStatistics = new HashSet<StatisticsEntry>();
	
	currentStatistics.add(nextStatsEntry);
	
	blacklistController.persistStatistics(currentStatistics, Settings.CONFIG_API_VERSION);
	
    if(log.isInfoEnabled())
    {
        log.info("serverstats.jsp: user submission keyVariable="+keyVariable+" userAgentVariable="+userAgentVariable);
    }
%>

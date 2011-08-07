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

--%><%@ page contentType="text/html;charset=UTF-8" %><%@page import="org.queryall.enumerations.*,java.util.Random,java.net.URLEncoder,java.util.List,java.util.Hashtable,java.util.Collection,java.util.Enumeration,org.apache.log4j.Logger"%><%
// DO NOT EDIT version. It is auto-replaced by the build process in order to debug when people have issues with this file
String subversionId = "$Id: redirectToId.jsp 910 2010-12-03 22:07:48Z p_ansell $";
String version = "%%__VERSION__%%";

Logger log = Logger.getLogger("atlas2rdf");

Settings localSettings = Settings.getSettings();

String realHostName = request.getScheme() + "://" + request.getServerName() + (request.getServerPort() == 80 ? "" : ":"+ request.getServerPort())+"/";

String contextPath = request.getContextPath();

if(localSettings.getBooleanPropertyFromConfig("useHardcodedRequestContext", false))
{
    contextPath = localSettings.getStringPropertyFromConfig("hardcodedRequestContext", contextPath);
}

if(contextPath == null || contextPath.equals("/"))
{
    contextPath = "";
}
else if(contextPath.startsWith("/") && contextPath.length() > 1 )
{
    // take off the first slash and add one to the end for our purposes
    contextPath = contextPath.substring(1)+"/";
}

if(localSettings.getBooleanPropertyFromConfig("useHardcodedRequestHostname", false))
{
    realHostName = localSettings.getStringPropertyFromConfig("hardcodedRequestHostname", realHostName);
}

String serverName = request.getServerName();

String querytype = request.getParameter("querytype");

String redirectPoint = "";

if(querytype != null && querytype.equals("search"))
{
    String searchterm = request.getParameter("searchterm");
    redirectPoint = contextPath+"search/"+StringUtils.percentEncode(searchterm);
}
else if(querytype != null && querytype.equals("linksns"))
{
    String linksns = request.getParameter("linksns");
    String nsid = request.getParameter("nsid");
    redirectPoint = contextPath+"linksns/"+StringUtils.percentEncode(linksns)+"/"+nsid;
}
else
{
    String submitted_bio2rdf_id = request.getParameter("submitted_bio2rdf_id");
    
    if(log.isInfoEnabled())
    {
        log.info("redirectToId.jsp: submitted_bio2rdf_id="+submitted_bio2rdf_id);
    }
    
    redirectPoint = contextPath+submitted_bio2rdf_id;
}

response.sendRedirect(realHostName+redirectPoint);
%>

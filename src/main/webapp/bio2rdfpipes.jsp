<%@ page pageEncoding="utf-8" session="false" %><%@page import="java.io.*,org.bio2rdf.*,org.openrdf.OpenRDFException,org.openrdf.repository.Repository,org.openrdf.repository.RepositoryConnection,org.openrdf.repository.sail.SailRepository,org.openrdf.sail.memory.MemoryStore,org.openrdf.query.GraphQueryResult,org.openrdf.query.QueryLanguage,org.openrdf.rio.RDFFormat,org.openrdf.rio.Rio,org.openrdf.rio.RDFParseException,java.io.StringReader,java.util.Date,java.util.List,java.util.HashSet,java.util.Hashtable, java.util.Collection,java.util.ArrayList,java.util.Map,java.io.File,java.io.BufferedWriter,java.io.CharArrayWriter,java.util.regex.Pattern,java.util.regex.Matcher,org.apache.log4j.Logger,org.deri.pipes.core.Engine,org.deri.pipes.core.Pipe,org.deri.pipes.core.ExecBuffer,org.deri.pipes.store.FilePipeStore,org.deri.pipes.endpoints.PipeConfig,java.net.URLDecoder
"%>
<%
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

// DO NOT EDIT version. It is auto-replaced by the build process in order to debug when people have issues with this file
String subversionId = "$Id: bio2rdfpipes.jsp 936 2011-02-06 05:34:23Z p_ansell $";

Logger log = Logger.getLogger("org.bio2rdf.bio2rdfpipes");

String realHostName = request.getScheme() + "://" + request.getServerName() + (request.getServerPort() == 80 ? "" : ":"+ request.getServerPort()+"/");

String requesterIpAddress = request.getRemoteAddr();

String queryString = request.getParameter("queryString");

log.info("Bio2RDFPipes.jsp: queryString="+queryString);
log.info("Bio2RDFPipes.jsp: getRequestURI="+request.getRequestURI());

String[] queryParameters = queryString.split("/",0);
String pipeId = request.getParameter("id");
log.debug("queryString="+queryString);
log.debug("pipeId="+pipeId);
// String actualQueryString = request.getQueryString();
// log.debug("actualQueryString="+actualQueryString);

String realPath =
request.getSession().getServletContext().getRealPath("/");
log.debug("realPath=" + realPath);

String pipeStorePath = realPath+"WEB-INF"+File.separator+"classes"+File.separator;
log.debug("pipeStorePath=" + pipeStorePath);


String originalAcceptHeader = request.getHeader("Accept");
String userAgentHeader = request.getHeader("User-Agent");
String acceptHeader = "";

Collection<String> debugStrings = new ArrayList<String>(5);

if(originalAcceptHeader == null || originalAcceptHeader.equals(""))
{
	acceptHeader = Settings.getStringPropertyFromConfig("preferredDisplayContentType");
}
else
{
    acceptHeader = originalAcceptHeader;
}

if(userAgentHeader == null)
{
	userAgentHeader = "";
}

if(!Settings.USER_AGENT_BLACKLIST_REGEX.trim().equals(""))
{
    Matcher userAgentBlacklistMatcher = Settings.USER_AGENT_BLACKLIST_PATTERN.matcher(userAgentHeader);
    
    if(userAgentBlacklistMatcher.find())
    {
        log.error("Atlas2Rdf: found blocked user-agent userAgentHeader="+userAgentHeader + " queryString="+queryString+" requesterIpAddress="+requesterIpAddress);
        
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        response.sendRedirect(Settings.getStringPropertyFromConfig("blacklistRedirectPage"));
        return;
    }
}

String originalRequestedContentType = QueryallContentNegotiator.getResponseContentType(acceptHeader, userAgentHeader);

String requestedContentType = originalRequestedContentType;

String explicitUrlContentType = request.getParameter("chosenContentType");

if(explicitUrlContentType != null && !explicitUrlContentType.equals(""))
{
    if(Settings._ATLASDEBUG)
    {
        log.debug("Atlas2Rdf.jsp: found explicitUrlContentType="+explicitUrlContentType);
	}
    
	// override whatever was requested with the urlrewrite variable
	requestedContentType = explicitUrlContentType;
}

// even if they request a random format, we need to make sure that Rio has a writer compatible with it, otherwise we revert to one of the defaults as a failsafe mechanism
RDFFormat writerFormat = Rio.getWriterFormatForMIMEType(requestedContentType);

if(writerFormat == null)
{
    writerFormat = Rio.getWriterFormatForMIMEType(Settings.getStringPropertyFromConfig("preferredDisplayContentType"));
    
    if(writerFormat == null)
    {
        writerFormat = RDFFormat.RDFXML;
        
        if(!requestedContentType.equals("text/html"))
        {
            requestedContentType = "application/rdf+xml";
            
            log.error("Atlas2Rdf.jsp: content negotiation failed to find a suitable content type for results. Defaulting to hard coded RDF/XML writer. Please set Settings.getStringPropertyFromConfig("preferredDisplayContentType") to a MIME type which is understood by the RDF package being used by the servlet to ensure this message doesn't appear.");
        }
    }
    else if(!requestedContentType.equals("text/html"))
    {
        requestedContentType = Settings.getStringPropertyFromConfig("preferredDisplayContentType");
        
        log.error("Atlas2Rdf.jsp: content negotiation failed to find a suitable content type for results. Defaulting to Settings.getStringPropertyFromConfig("preferredDisplayContentType")="+Settings.getStringPropertyFromConfig("preferredDisplayContentType"));
    }
}

if(BlacklistController.isClientBlacklisted(requesterIpAddress))
{
    log.warn("Atlas2RDF: sending requesterIpAddress="+requesterIpAddress+" to blacklist redirect page");
	
	response.setStatus(HttpServletResponse.SC_FORBIDDEN);
	response.sendRedirect(Settings.getStringPropertyFromConfig("blacklistRedirectPage"));
	return;
}

Repository myRepository = new SailRepository(new MemoryStore());
myRepository.initialize();
RepositoryConnection myRepositoryConnection = myRepository.getConnection();

try
{
	Engine currentEngine = Engine.defaultEngine();
	currentEngine.setPipeStore(new FilePipeStore(pipeStorePath));
	
	List<PipeConfig> currentPipeList = currentEngine.getPipeStore().getPipeList();
	
	log.debug("Bio2RDFPipes.jsp: found "+currentPipeList.size()+ " pipes");
	
	for(PipeConfig nextCurrentPipe : currentPipeList)
	{
		log.debug("Bio2RDFPipes.jsp: nextCurrentPipe id="+nextCurrentPipe.getId() + " name="+nextCurrentPipe.getName()); log.trace("Bio2RDFPipes.jsp: nextCurrentPipe syntax="+nextCurrentPipe.getSyntax());
	}
	
	Pipe currentPipe = currentEngine.getStoredPipe(pipeId);
	
	for(String nextParameter : queryParameters)
	{
		String[] nextSplitParameter = nextParameter.split("=",2);
		
		if(nextSplitParameter.length != 2)
		{
			log.error("Bio2RDFPipes.jsp: Parameter not formatted correctly: "+nextParameter);
			continue;
		}
		
		String parameterName = nextSplitParameter[0];
		String parameterValue = nextSplitParameter[1];
		
		if(!parameterValue.equals(URLDecoder.decode(parameterValue, "UTF-8")))
		{
			log.info("Bio2RDFPipes.jsp: Found encoded characters in parameter value. Fixing Servlet container bug by unencoding the string again parameterValue="+parameterValue);
			
			parameterValue = URLDecoder.decode(parameterValue, "UTF-8");
			
			log.info("Bio2RDFPipes.jsp: After decoding parameterValue="+parameterValue);
		}
		
		if(log.isDebugEnabled())
		{
			log.debug("Bio2RDFPipes.jsp: setting parameter name="+parameterName+" value="+parameterValue);
		}
		
		currentPipe.setParameter(parameterName,parameterValue);
	}
	
	// override this to make sure we use this instance for any Bio2RDF URI resolution
	currentPipe.setParameter("server_address",realHostName);

	ExecBuffer currentPipeResult = currentPipe.execute(currentEngine.newContext());
	
	ByteArrayOutputStream currentPipeOutput = new ByteArrayOutputStream();
	
	currentPipeResult.stream(currentPipeOutput);
	
    myRepositoryConnection.add(new java.io.StringReader(currentPipeOutput.toString("UTF-8")), Settings.getDefaultHostAddress(), Rio.getParserFormatForMIMEType(Settings.getStringPropertyFromConfig("assumedRequestContentType")));
    myRepositoryConnection.commit();
	// out.write(currentPipeOutput.toString("UTF-8").replace("<?xml version=\"1.0\" encoding=\"UTF-8\"?>",""));
    
    java.io.StringWriter cleanOutput = new java.io.StringWriter();
    
    //java.io.StringWriter cleanOutput = new java.io.StringWriter(new BufferedWriter(new CharArrayWriter()));
    
    if(requestedContentType.equals("text/html"))
    {
        if(Settings._ATLASDEBUG)
        {
            log.debug("Atlas2Rdf.jsp: about to call html rendering method");
        }
        
        try
        {
            HtmlPageRenderer.renderHtml(getServletContext(), myRepository, cleanOutput, debugStrings, queryString, Settings.getDefaultHostAddress() + "/" + queryString, realHostName + "/", request.getContextPath(), 1);
        }
        catch(OpenRDFException ordfe)
        {
            log.error("Atlas2Rdf.jsp: couldn't render HTML because of an RDF exception", ordfe);
        }
        catch(Exception ex)
        {
            log.error("Atlas2Rdf.jsp: couldn't render HTML because of an unknown exception", ex);
        }
    }
    else
    {
        Utilities.toWriter(myRepository, cleanOutput, writerFormat);
    }
    
    String actualRdfString = cleanOutput.toString();
    
    if(Settings._ATLASTRACE)
    {
        log.trace("Atlas2Rdf.jsp: actualRdfString="+actualRdfString);
    }
    
    if(requestedContentType.equals("application/rdf+xml"))
    {
        out.write("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n");
        
        for(String nextDebugString : debugStrings)
        {
            out.write(nextDebugString+"\n");
        }
        // HACK: can't find a way to get sesame to print out the rdf without the xml PI
        out.write(actualRdfString.replace("<?xml version=\"1.0\" encoding=\"UTF-8\"?>", ""));
    }
    else if(requestedContentType.equals("text/rdf+n3"))
    {
        for(String nextDebugString : debugStrings)
        {
            out.write(nextDebugString+"\n");
        }
        
        out.write(actualRdfString);
    }
    else
    {
        // log.error("entering UTF-8 conversion section");
        
        // try{
            // byte[] bytes = new byte[actualRdfString.length()];
            // for (int i = 0; i < actualRdfString.length(); i++) 
            // {
                // bytes[i] = (byte) actualRdfString.charAt(i);
            // }
            // 
            // actualRdfString = new String(bytes, "UTF-8");
        // }
        // catch(java.io.UnsupportedEncodingException 
        // {
            // log.error("Atlas2rdf.jsp: unsupported encoding exception for UTF-8");
        // }
        
        out.write(actualRdfString);
    }
    out.flush();
}
catch(Exception ex)
{
	log.error(ex.getMessage());
	out.write("<rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"> <rdf:Description rdf:about=\"http://bio2rdf.org/error/Pipes\"><errorMessage xmlns=\"http://bio2rdf.org/bio2rdf_resource:\">The pipe was not able to execute properly. See the server logs for more information</errorMessage></rdf:Description></rdf:RDF>");
}
%>

<%--

-------------------------------------------------------------------------------
Bio2RDF is a creation of

Francois Belleau
Marc-Alexandre Nolin
Peter Ansell

from the Centre de Recherche du CHUL de Québec 
and the Microsoft QUT eResearch Centre

This program is released under the GPL (GNU General Public License) v2.0 or later licence

The terms of GPL version 2.0 are specified at the following url, 
and can also be found in the gpl-v2.0.txt file

http://www.gnu.org/licenses/gpl-2.0.html

If you wish to use the GPL version 3, the terms are specified at the following url, 
and can also be found in the gpl-v3.txt file

http://www.gnu.org/copyleft/gpl.html

You can contact the Bio2RDF team at bio2rdf@googlegroups.com
Visit our wiki at http://bio2rdf.wiki.sourceforge.net/
Visit our main Bio2RDF application at http://www.bio2rdf.org
-------------------------------------------------------------------------------

--%><%@page import="org.bio2rdf.*,org.openrdf.OpenRDFException,org.openrdf.rio.RDFFormat,org.openrdf.rio.Rio,org.openrdf.repository.Repository,org.openrdf.repository.RepositoryConnection,org.openrdf.repository.sail.SailRepository,org.openrdf.sail.memory.MemoryStore,org.openrdf.rio.RDFFormat,org.openrdf.rio.RDFParseException,java.io.StringReader,java.util.Date,java.util.List,java.util.HashSet,java.util.Hashtable,java.util.regex.Matcher,java.util.regex.Pattern,java.util.Collection,org.apache.log4j.Logger"%><%
// DO NOT EDIT version. It is auto-replaced by the build process in order to debug when people have issues with this file
String subversionId = "$Id: multifetch.jsp 940 2011-02-08 04:11:58Z p_ansell $";
String version = "%%__VERSION__%%";
String propertiesSubversionId = Settings.SUBVERSION_INFO;

Logger log = Logger.getLogger("org.bio2rdf.multifetch");

Date queryStartTime = new Date();

String realHostName = request.getScheme() + "://" + request.getServerName() + (request.getServerPort() == 80 && request.getScheme().equals("http") ? "" : ":"+ request.getServerPort())+"/";

String serverName = request.getServerName();

String queryString = request.getParameter("queryString");

String queryType = request.getParameter("queryType");

String pretendString = request.getParameter("pretend");

boolean isPretendQuery = false;
String pretendQuery = "";

if(pretendString != null && pretendString.equals("yes"))
{
	isPretendQuery = true;
    pretendQuery = "queryplan/";
}

String namespaceParameter = request.getParameter("namespaceParameter");

String originalRequestedContentType = QueryallContentNegotiator.getResponseContentType(request.getHeader("Accept"), request.getHeader("User-Agent"));

String requestedContentType = originalRequestedContentType;

String requesterIpAddress = request.getRemoteAddr();

Collection<String> debugStrings = new HashSet<String>();

String explicitUrlContentType = request.getParameter("chosenContentType");

if(explicitUrlContentType != null && !explicitUrlContentType.equals(""))
{
    if(log.isDebugEnabled())
    {
        log.debug("multifetch.jsp: found explicitUrlContentType="+explicitUrlContentType);
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
            
            log.error("multifetch.jsp: content negotiation failed to find a suitable content type for results. Defaulting to hard coded RDF/XML writer. Please set Settings.getStringPropertyFromConfig("preferredDisplayContentType") to a MIME type which is understood by the RDF package being used by the servlet to ensure this message doesn't appear.");
        }
    }
    else if(!requestedContentType.equals("text/html"))
    {
        requestedContentType = Settings.getStringPropertyFromConfig("preferredDisplayContentType");
        
        log.error("multifetch.jsp: content negotiation failed to find a suitable content type for results. Defaulting to Settings.getStringPropertyFromConfig("preferredDisplayContentType")="+Settings.getStringPropertyFromConfig("preferredDisplayContentType"));
    }
}

if(log.isInfoEnabled())
{
	log.info("multifetch.jsp: query started on "+serverName+" requesterIpAddress="+requesterIpAddress+" queryString="+queryString);
	log.info("multifetch.jsp: requestedContentType="+requestedContentType+ " acceptHeader="+request.getHeader("Accept")+" userAgent="+request.getHeader("User-Agent"));
	
    if(!originalRequestedContentType.equals(requestedContentType))
	{
		log.info("multifetch.jsp: originalRequestedContentType was overwritten originalRequestedContentType="+originalRequestedContentType+" requestedContentType="+requestedContentType);
	}
}

// String realHostName = request.getScheme() + "://" + request.getServerName() + (request.getServerPort() == 80 ? "" : ":"+ request.getServerPort())+"/";


if(BlacklistController.isClientBlacklisted(requesterIpAddress))
{
    log.warn("Atlas2RDF: sending requesterIpAddress="+requesterIpAddress+" to blacklist redirect page");
	
	response.setStatus(HttpServletResponse.SC_FORBIDDEN);
	response.sendRedirect(Settings.getStringPropertyFromConfig("blacklistRedirectPage"));
	return;
}

boolean useDefaultProviders = true;

// Split the inputs, create query bundles, and then create runnables based on http://realHostName/queryPart

String[] splitInputs = queryString.split("/");

Collection<String> actualInputs = new HashSet<String>(splitInputs.length*2);

if(queryType.equals("searchns"))
{
    for(String nextSplitInput : splitInputs)
    {
        actualInputs.add(nextSplitInput);
    }
}
else
{
    for(String nextSplitInput : splitInputs)
    {
        Matcher matcher = Settings.getPlainNamespaceAndIdentifierPattern().matcher(nextSplitInput);
        
        boolean found = false;
        
        if(matcher.find() && matcher.groupCount() == 2)
        {
            // Avoid fetching duplicates by weeding them out here
            if(!actualInputs.contains(nextSplitInput))
            {
                actualInputs.add(nextSplitInput);
            }
        }
        else
        {
            log.warn("Multifetch: Found non-matching input nextSplitInput="+nextSplitInput);
        }
    }
}
Collection<QueryBundle> queryBundles = new HashSet<QueryBundle>();

Collection<String> resultStrings = new HashSet<String>();

// default to assuming the queryString is matched with queryType this way, and just modify below in special cases where namespace parameter is known or the construct is invisible
String actualQueryString = "multiple"+queryType+"/"+queryString;

if(queryType.equals("construct"))
{
    actualQueryString = "multiple/"+queryString;
}
else if(queryType.equals("label"))
{
    actualQueryString = "multiplelabel/"+queryString;
}
else if(queryType.equals("linkstonamespace"))
{
    actualQueryString = "multiplelinkstonamespace/"+namespaceParameter+"/"+queryString;
}
else if(queryType.equals("linksns"))
{
    actualQueryString = "multiplelinksns/"+namespaceParameter+"/"+queryString;
}
else if(queryType.equals("searchns"))
{
    actualQueryString = "multiplesearchns/"+namespaceParameter+"/"+queryString;
}
else
{
    actualQueryString = "multiple"+queryType+"/"+queryString;
}

for(String nextActualInput : actualInputs)
{
	QueryBundle nextQueryBundle = new QueryBundle();
	
	Provider dummyProvider = new Provider();
	
	dummyProvider.endpointUrls = new HashSet<String>();
	
	if(queryType.equals("construct"))
	{
		dummyProvider.endpointUrls.add(realHostName+pretendQuery+nextActualInput);
		nextQueryBundle.queryEndpoint = realHostName+pretendQuery+nextActualInput;
	}
	else if(queryType.equals("label"))
	{
		dummyProvider.endpointUrls.add(realHostName+pretendQuery+"label/"+nextActualInput);		
		nextQueryBundle.queryEndpoint = realHostName+pretendQuery+"label/"+nextActualInput;
	}
	else if(queryType.equals("linkstonamespace"))
	{
		dummyProvider.endpointUrls.add(realHostName+pretendQuery+"linkstonamespace/"+namespaceParameter+"/"+nextActualInput);		
		nextQueryBundle.queryEndpoint = realHostName+pretendQuery+"linkstonamespace/"+namespaceParameter+"/"+nextActualInput;
	}
	else if(queryType.equals("linksns"))
	{
		dummyProvider.endpointUrls.add(realHostName+pretendQuery+"linksns/"+namespaceParameter+"/"+nextActualInput);		
		nextQueryBundle.queryEndpoint = realHostName+pretendQuery+"linksns/"+namespaceParameter+"/"+nextActualInput;
	}
	else if(queryType.equals("searchns"))
	{
		dummyProvider.endpointUrls.add(realHostName+pretendQuery+"searchns/"+namespaceParameter+"/"+nextActualInput);		
		nextQueryBundle.queryEndpoint = realHostName+pretendQuery+"searchns/"+namespaceParameter+"/"+nextActualInput;
	}
    else
    {
		dummyProvider.endpointUrls.add(realHostName+pretendQuery+queryType+"/"+nextActualInput);		
		nextQueryBundle.queryEndpoint = realHostName+pretendQuery+queryType+"/"+nextActualInput;
    }
	
	dummyProvider.setEndpointMethod(ProviderImpl.providerHttpGetUrl);
    dummyProvider.setKey(realHostName+pretendQuery+Settings.DEFAULT_RDF_PROVIDER_NAMESPACE+Settings.getStringPropertyFromConfig("separator")+nextActualInput);
	dummyProvider.setIsDefaultSource(true);
	
	nextQueryBundle.setProvider(dummyProvider);
	
	QueryType dummyQuery = new QueryTypeImpl();
	
    dummyQuery.setKey(realHostName+pretendQuery+Settings.DEFAULT_RDF_QUERY_NAMESPACE+Settings.getStringPropertyFromConfig("separator")+nextActualInput);
	dummyQuery.setTitle("$$__partialmultifetch__$$");
    dummyQuery.setIncludeDefaults(true);
	
	nextQueryBundle.setQueryType(dummyQuery);
	
	queryBundles.add(nextQueryBundle);
}

log.info("multifetch.jsp: queryBundles.size()="+queryBundles.size());

RdfFetchController fetchController = new RdfFetchController(queryBundles);

try
{
	fetchController.fetchRdfForQueries();
}
catch(InterruptedException ie)
{
	log.fatal(ie.getMessage());
	ie.printStackTrace();
	throw ie;
}
Collection<RdfFetcherQueryRunnable> rdfResults = fetchController.successfulResults;

Collection<String> currentNormalisedResultStrings = new HashSet<String>();

Repository myRepository = new SailRepository(new MemoryStore());
myRepository.initialize();

RdfUtils.insertResultsIntoRepository(fetchController.getResults(), myRepository);


response.setContentType(requestedContentType);
response.setCharacterEncoding("UTF-8");
response.setStatus(200);
response.flushBuffer();

java.io.StringWriter stBuff = new java.io.StringWriter();

if(requestedContentType.equals("text/html"))
{
    if(log.isDebugEnabled())
    {
        log.debug("multifetch.jsp: about to call html rendering method");
    }
    
    try
    {
        HtmlPageRenderer.renderHtml(getServletContext(), myRepository, stBuff, fetchController, debugStrings, actualQueryString, Settings.getDefaultHostAddress() + actualQueryString, realHostName, request.getContextPath(), 1);
    }
    catch(OpenRDFException ordfe)
    {
        log.error("multifetch.jsp: couldn't render HTML because of an RDF exception", ordfe);
    }
    catch(Exception ex)
    {
        log.error("multifetch.jsp: couldn't render HTML because of an unknown exception", ex);
    }
}
else
{
    RdfUtils.toWriter(myRepository, stBuff, writerFormat);
}

String actualRdfString = stBuff.toString();

if(log.isTraceEnabled())
{
	log.trace("multifetch.jsp: actualRdfString="+actualRdfString);
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
	out.write(actualRdfString);
}

out.flush();
%>

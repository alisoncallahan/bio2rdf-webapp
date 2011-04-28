package org.bio2rdf.servlets.queryparsers;

import org.queryall.helpers.Constants;
import org.queryall.helpers.Settings;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

import org.apache.log4j.Logger;

/** 
 * Parses query options out of a query string
 */

public class DefaultQueryOptions
{
    public static final Logger log = Logger.getLogger(DefaultQueryOptions.class.getName());
    public static final boolean _TRACE = log.isTraceEnabled();
    public static final boolean _DEBUG = log.isDebugEnabled();
    public static final boolean _INFO = log.isInfoEnabled();
    
    private boolean _hasExplicitFormat = false;
    private String _chosenFormat = "";
    private boolean _hasExplicitPageOffsetValue = false;
    private int pageoffset = 1;
    private boolean _hasQueryPlanRequest = false;

    private String parsedRequestString = "";
    
    private Settings localSettings;
	private Pattern queryPlanPattern;
    
    public DefaultQueryOptions(String requestUri, Settings localSettings)
    {
        this.localSettings = localSettings;

        String requestString = requestUri;
        
        String pageoffsetUrlOpeningPrefix = localSettings.getStringPropertyFromConfig("pageoffsetUrlOpeningPrefix", "pageoffset");
        String pageoffsetUrlClosingPrefix = localSettings.getStringPropertyFromConfig("pageoffsetUrlClosingPrefix", "/");
        String pageoffsetUrlSuffix = localSettings.getStringPropertyFromConfig("pageoffsetUrlSuffix", "");

        String pageOffsetPatternString = "^"+pageoffsetUrlOpeningPrefix+"(\\d+)"+pageoffsetUrlClosingPrefix+"(.+)"+pageoffsetUrlSuffix+"$";

        if(_DEBUG)
            log.debug("pageOffsetPatternString="+pageOffsetPatternString);
        
        queryPlanPattern = Pattern.compile(pageOffsetPatternString);

        if(requestString.startsWith("/"))
        {
            log.debug("requestString="+requestString);
            requestString = requestString.substring(1);
            log.debug("requestString="+requestString);
        }
        
        requestString = parseForFormat(requestString);
        
        requestString = parseForQueryPlan(requestString);
        
        requestString = parseForPageOffset(requestString);
        
        parsedRequestString = requestString;
    }
    
    private String parseForFormat(String requestString)
    {
        String htmlUrlPrefix = localSettings.getStringPropertyFromConfig("htmlUrlPrefix", "page/");
        String htmlUrlSuffix = localSettings.getStringPropertyFromConfig("htmlUrlSuffix", "");
        String rdfXmlUrlPrefix = localSettings.getStringPropertyFromConfig("rdfXmlUrlPrefix", "rdfxml/");
        String rdfXmlUrlSuffix = localSettings.getStringPropertyFromConfig("rdfXmlUrlSuffix", "");
        String n3UrlPrefix = localSettings.getStringPropertyFromConfig("n3UrlPrefix", "n3/");
        String n3UrlSuffix = localSettings.getStringPropertyFromConfig("n3UrlSuffix", "");
        
        if(matchesPrefixAndSuffix(requestString, htmlUrlPrefix, htmlUrlSuffix))
        {
            _hasExplicitFormat = true;
            _chosenFormat = Constants.TEXT_HTML;
            log.debug("requestString="+requestString);
            requestString = takeOffPrefixAndSuffix(requestString, htmlUrlPrefix, htmlUrlSuffix);
            log.debug("requestString="+requestString);
        }
        else if(matchesPrefixAndSuffix(requestString, rdfXmlUrlPrefix, rdfXmlUrlSuffix))
        {
            _hasExplicitFormat = true;
            _chosenFormat = Constants.APPLICATION_RDF_XML;
            log.debug("requestString="+requestString);
            requestString = takeOffPrefixAndSuffix(requestString, rdfXmlUrlPrefix, rdfXmlUrlSuffix);
            log.debug("requestString="+requestString);
        }
        else if(matchesPrefixAndSuffix(requestString, n3UrlPrefix, n3UrlSuffix))
        {
            _hasExplicitFormat = true;
            _chosenFormat = Constants.TEXT_RDF_N3;
            log.debug("requestString="+requestString);
            requestString = takeOffPrefixAndSuffix(requestString, n3UrlPrefix, n3UrlSuffix);
            log.debug("requestString="+requestString);
        }
        
        return requestString;
    }
    
    private boolean matchesPrefixAndSuffix(String nextString, String nextPrefix, String nextSuffix)
    {
        return nextString.startsWith(nextPrefix) 
            && nextString.endsWith(nextSuffix) 
            && nextString.length() >= (nextPrefix.length() + nextSuffix.length());
    }
    
    private String takeOffPrefixAndSuffix(String nextString, String nextPrefix, String nextSuffix)
    {
        if(matchesPrefixAndSuffix(nextString, nextPrefix, nextSuffix))
        {
            return nextString.substring(nextPrefix.length(),
                nextString.length()-nextSuffix.length());
        }
        else
        {
            log.error("Could not takeOffPrefixAndSuffix because the string was not long enough");
        }
        
        return nextString;
    }

    private String parseForQueryPlan(String requestString)
    {
        String queryplanUrlPrefix = localSettings.getStringPropertyFromConfig("queryplanUrlPrefix", "queryplan/");
        String queryplanUrlSuffix = localSettings.getStringPropertyFromConfig("queryplanUrlSuffix", "");
        
        if(matchesPrefixAndSuffix(requestString, queryplanUrlPrefix, queryplanUrlSuffix))
        {
            _hasQueryPlanRequest = true;
            log.debug("requestString="+requestString);
            requestString = takeOffPrefixAndSuffix(requestString, queryplanUrlPrefix, queryplanUrlSuffix);
            log.debug("requestString="+requestString);
        }
        
        return requestString;
    }
    
    private String parseForPageOffset(String requestString)
    {
        Matcher matcher = queryPlanPattern.matcher(requestString);
        
        if(!matcher.matches())
        {
            return requestString;
        }
        
        try
        {
            // This will always be a non-negative integer due to the way the pattern matches, but it may be 0 so we correct that case
            pageoffset = Integer.parseInt(matcher.group(1));
        }
        catch(NumberFormatException nfe)
        {
            pageoffset = 1;
        }
        
        if(pageoffset == 0)
            pageoffset = 1;
        
        _hasExplicitPageOffsetValue = true;
        
        requestString = matcher.group(2);
        
        log.debug("pageoffset="+pageoffset);
        log.debug("requestString="+requestString);

        return requestString;
    }
    
    public boolean containsExplicitFormat()
    {
        return _hasExplicitFormat;
    }
    
    public String getExplicitFormat()
    {
        return _chosenFormat;
    }

    public boolean containsExplicitPageOffsetValue()
    {
        return _hasExplicitPageOffsetValue;
    }

    public int getPageOffset()
    {
        return pageoffset;
    }

    public boolean isQueryPlanRequest()
    {
        return _hasQueryPlanRequest;
    }
    
    public String getParsedRequest()
    {
        return parsedRequestString;
    }
}

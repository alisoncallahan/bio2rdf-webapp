package org.bio2rdf.servlets.queryparsers;

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
    
    public DefaultQueryOptions(String requestUri)
    {
        String requestString = requestUri;
        
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
        String htmlUrlPrefix = Settings.getSettings().getStringPropertyFromConfig("htmlUrlPrefix", "");
        String htmlUrlSuffix = Settings.getSettings().getStringPropertyFromConfig("htmlUrlSuffix", "");
        String rdfXmlUrlPrefix = Settings.getSettings().getStringPropertyFromConfig("rdfXmlUrlPrefix", "");
        String rdfXmlUrlSuffix = Settings.getSettings().getStringPropertyFromConfig("rdfXmlUrlSuffix", "");
        String n3UrlPrefix = Settings.getSettings().getStringPropertyFromConfig("n3UrlPrefix", "");
        String n3UrlSuffix = Settings.getSettings().getStringPropertyFromConfig("n3UrlSuffix", "");
        
        if(matchesPrefixAndSuffix(requestString, htmlUrlPrefix, htmlUrlSuffix))
        {
            _hasExplicitFormat = true;
            _chosenFormat = "text/html";
            log.debug("requestString="+requestString);
            requestString = takeOffPrefixAndSuffix(requestString, htmlUrlPrefix, htmlUrlSuffix);
            log.debug("requestString="+requestString);
        }
        else if(matchesPrefixAndSuffix(requestString, rdfXmlUrlPrefix, rdfXmlUrlSuffix))
        {
            _hasExplicitFormat = true;
            _chosenFormat = "application/rdf+xml";
            log.debug("requestString="+requestString);
            requestString = takeOffPrefixAndSuffix(requestString, rdfXmlUrlPrefix, rdfXmlUrlSuffix);
            log.debug("requestString="+requestString);
        }
        else if(matchesPrefixAndSuffix(requestString, n3UrlPrefix, n3UrlSuffix))
        {
            _hasExplicitFormat = true;
            _chosenFormat = "text/rdf+n3";
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
        String queryplanUrlPrefix = Settings.getSettings().getStringPropertyFromConfig("queryplanUrlPrefix", "");
        String queryplanUrlSuffix = Settings.getSettings().getStringPropertyFromConfig("queryplanUrlSuffix", "");
        
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
        String pageoffsetUrlOpeningPrefix = Settings.getSettings().getStringPropertyFromConfig("pageoffsetUrlOpeningPrefix", "");
        String pageoffsetUrlClosingPrefix = Settings.getSettings().getStringPropertyFromConfig("pageoffsetUrlClosingPrefix", "");
        String pageoffsetUrlSuffix = Settings.getSettings().getStringPropertyFromConfig("pageoffsetUrlSuffix", "");

        String queryPlanPatternString = "^"+pageoffsetUrlOpeningPrefix+"(\\d+)"+pageoffsetUrlClosingPrefix+"(.+)"+pageoffsetUrlSuffix+"$";

        if(_DEBUG)
            log.debug("queryPlanPatternString="+queryPlanPatternString);
        
        Pattern queryPlanPattern = Pattern.compile(queryPlanPatternString);
        
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

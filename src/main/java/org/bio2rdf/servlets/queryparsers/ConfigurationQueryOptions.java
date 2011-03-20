package org.bio2rdf.servlets.queryparsers;

import org.queryall.helpers.Settings;
import org.queryall.helpers.StringUtils;

import java.util.regex.Pattern;
import java.util.regex.Matcher;

import org.apache.log4j.Logger;

/** 
 * Parses query options out of a query string
 */

public class ConfigurationQueryOptions
{
    public static final Logger log = Logger.getLogger(ConfigurationQueryOptions.class.getName());
    public static final boolean _TRACE = log.isTraceEnabled();
    public static final boolean _DEBUG = log.isDebugEnabled();
    public static final boolean _INFO = log.isInfoEnabled();
    
//    private Settings localSettings = Settings.getSettings();

    private boolean _adminPrefixMatch = false;
    private boolean _adminBasicWebappConfigurationMatch = false;
    private boolean _adminConfigurationMatch = false;
    private boolean _isRefresh = false;

    private boolean _hasExplicitFormat = false;
    private String _chosenFormat = "";
    private boolean _hasExplicitApiVersionValue = false;
    private int _apiVersion = Settings.CONFIG_API_VERSION;
    private boolean _isPlainNamespaceAndIdentifier = false;

    private String parsedRequestString = "";

    
    public ConfigurationQueryOptions(String requestUri)
    {
        String requestString = requestUri;
        
        if(requestString == null)
        {
            requestString = "";
            log.error("ConfigurationQueryOptions: requestString was null");
        }
        
        if(requestString.startsWith("/"))
        {
            log.debug("requestString="+requestString);
            requestString = requestString.substring(1);
            log.debug("requestString="+requestString);
        }
        
        requestString = parseForAdminPrefix(requestString);

        if(_adminPrefixMatch)
        {
            requestString = parseForRefresh(requestString);
    
            if(!_isRefresh)
            {
                requestString = parseForAdminConfiguration(requestString);
                
                if(_adminConfigurationMatch || _adminBasicWebappConfigurationMatch)
                {
                    requestString = parseForApiVersion(requestString);
                    
                    requestString = parseForAdminFormat(requestString);
                }
            }
        }
        else
        {
            requestString = parseForNsIdFormat(requestString);
            
            if(StringUtils.isPlainNamespaceAndIdentifier(requestString))
            {
                _isPlainNamespaceAndIdentifier = true;
            }
        }

        parsedRequestString = requestString;
    }
    
    private String parseForAdminPrefix(String requestString)
    {
        String adminUrlPrefix = Settings.getSettings().getStringPropertyFromConfig("adminUrlPrefix", "");
        
        if(matchesPrefixAndSuffix(requestString, adminUrlPrefix, ""))
        {
            _adminPrefixMatch = true;
            
            requestString = takeOffPrefixAndSuffix(requestString, adminUrlPrefix, "");
        }
        
        return requestString;
    }
    
    private String parseForAdminConfiguration(String requestString)
    {
        String adminConfigurationPrefix = Settings.getSettings().getStringPropertyFromConfig("adminConfigurationPrefix", "");

        String adminWebappConfigurationPrefix = Settings.getSettings().getStringPropertyFromConfig("adminWebappConfigurationPrefix", "");
        
        if(matchesPrefixAndSuffix(requestString, adminConfigurationPrefix, ""))
        {
            requestString = takeOffPrefixAndSuffix(requestString, adminConfigurationPrefix, "");
            
            _adminConfigurationMatch = true;
        }
        else if(matchesPrefixAndSuffix(requestString, adminWebappConfigurationPrefix, ""))
        {
            requestString = takeOffPrefixAndSuffix(requestString, adminWebappConfigurationPrefix, "");
            
            _adminBasicWebappConfigurationMatch = true;
        }
        
        return requestString;
    }

    private String parseForRefresh(String requestString)
    {
        String adminConfigurationRefreshPrefix = Settings.getSettings().getStringPropertyFromConfig("adminConfigurationRefreshPrefix", "");
        
        if(matchesPrefixAndSuffix(requestString, adminConfigurationRefreshPrefix, ""))
        {
            _isRefresh = true;
            requestString = takeOffPrefixAndSuffix(requestString, adminConfigurationRefreshPrefix, "");
        }
        
        return requestString;
    }
    
    private String parseForAdminFormat(String requestString)
    {
        String adminConfigurationHtmlPrefix = Settings.getSettings().getStringPropertyFromConfig("adminConfigurationHtmlPrefix", "");
        String adminConfigurationHtmlSuffix = Settings.getSettings().getStringPropertyFromConfig("adminConfigurationHtmlSuffix", "");
        String adminConfigurationRdfxmlPrefix = Settings.getSettings().getStringPropertyFromConfig("adminConfigurationRdfxmlPrefix", "");
        String adminConfigurationRdfxmlSuffix = Settings.getSettings().getStringPropertyFromConfig("adminConfigurationRdfxmlSuffix", "");
        String adminConfigurationN3Prefix = Settings.getSettings().getStringPropertyFromConfig("adminConfigurationN3Prefix", "");
        String adminConfigurationN3Suffix = Settings.getSettings().getStringPropertyFromConfig("adminConfigurationN3Suffix", "");
        
        if(matchesPrefixAndSuffix(requestString, adminConfigurationHtmlPrefix, adminConfigurationHtmlSuffix))
        {
            _hasExplicitFormat = true;
            _chosenFormat = "text/html";
            log.debug("html: requestString="+requestString);
            requestString = takeOffPrefixAndSuffix(requestString, adminConfigurationHtmlPrefix, adminConfigurationHtmlSuffix);
            log.debug("html: requestString="+requestString);
        }
        else if(matchesPrefixAndSuffix(requestString, adminConfigurationRdfxmlPrefix, adminConfigurationRdfxmlSuffix))
        {
            _hasExplicitFormat = true;
            _chosenFormat = "application/rdf+xml";
            log.debug("rdfxml: requestString="+requestString);
            requestString = takeOffPrefixAndSuffix(requestString, adminConfigurationRdfxmlPrefix, adminConfigurationRdfxmlSuffix);
            log.debug("rdfxml: requestString="+requestString);
        }
        else if(matchesPrefixAndSuffix(requestString, adminConfigurationN3Prefix, adminConfigurationN3Suffix))
        {
            _hasExplicitFormat = true;
            _chosenFormat = "text/rdf+n3";
            log.debug("n3: requestString="+requestString);
            requestString = takeOffPrefixAndSuffix(requestString, adminConfigurationN3Prefix, adminConfigurationN3Suffix);
            log.debug("n3: requestString="+requestString);
        }
        
        return requestString;
    }

    private String parseForNsIdFormat(String requestString)
    {
        String nsIdHtmlPrefix = Settings.getSettings().getStringPropertyFromConfig("htmlUrlPrefix", "");
        String nsIdHtmlSuffix = Settings.getSettings().getStringPropertyFromConfig("htmlUrlSuffix", "");
        String nsIdRdfxmlPrefix = Settings.getSettings().getStringPropertyFromConfig("rdfXmlUrlPrefix", "");
        String nsIdRdfxmlSuffix = Settings.getSettings().getStringPropertyFromConfig("rdfXmlUrlSuffix", "");
        String nsIdN3Prefix = Settings.getSettings().getStringPropertyFromConfig("n3UrlPrefix", "");
        String nsIdN3Suffix = Settings.getSettings().getStringPropertyFromConfig("n3UrlSuffix", "");
        
        if(matchesPrefixAndSuffix(requestString, nsIdHtmlPrefix, nsIdHtmlSuffix))
        {
            _hasExplicitFormat = true;
            _chosenFormat = "text/html";
            log.debug("html: requestString="+requestString);
            requestString = takeOffPrefixAndSuffix(requestString, nsIdHtmlPrefix, nsIdHtmlSuffix);
            log.debug("html: requestString="+requestString);
        }
        else if(matchesPrefixAndSuffix(requestString, nsIdRdfxmlPrefix, nsIdRdfxmlSuffix))
        {
            _hasExplicitFormat = true;
            _chosenFormat = "application/rdf+xml";
            log.debug("rdfxml: requestString="+requestString);
            requestString = takeOffPrefixAndSuffix(requestString, nsIdRdfxmlPrefix, nsIdRdfxmlSuffix);
            log.debug("rdfxml: requestString="+requestString);
        }
        else if(matchesPrefixAndSuffix(requestString, nsIdN3Prefix, nsIdN3Suffix))
        {
            _hasExplicitFormat = true;
            _chosenFormat = "text/rdf+n3";
            log.debug("n3: requestString="+requestString);
            requestString = takeOffPrefixAndSuffix(requestString, nsIdN3Prefix, nsIdN3Suffix);
            log.debug("n3: requestString="+requestString);
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

    private String parseForApiVersion(String requestString)
    {
        String adminConfigurationApiOpeningPrefix = Settings.getSettings().getStringPropertyFromConfig("adminConfigurationApiVersionOpeningPrefix", "");
        String adminConfigurationApiClosingPrefix = Settings.getSettings().getStringPropertyFromConfig("adminConfigurationApiVersionClosingPrefix", "");
        String adminConfigurationApiSuffix = Settings.getSettings().getStringPropertyFromConfig("adminConfigurationApiVersionSuffix", "");

        String apiVersionPatternString = "^"+adminConfigurationApiOpeningPrefix+"(\\d+)"+adminConfigurationApiClosingPrefix+"(.*)"+adminConfigurationApiSuffix+"$";
        
        log.debug("apiVersionPatternString="+apiVersionPatternString);
        log.debug("requestString="+requestString);
        
        Pattern apiVersionPattern = Pattern.compile(apiVersionPatternString);
        
        Matcher matcher = apiVersionPattern.matcher(requestString);
        
        if(!matcher.matches())
        {
            return requestString;
        }
        
        try
        {
            // This will always be a non-negative integer due to the way the pattern matches, but it may be 0 so we correct that case
            _apiVersion = Integer.parseInt(matcher.group(1));

            if(_apiVersion == 0)
            {
                _apiVersion = Settings.CONFIG_API_VERSION;
            }
            else
            {
                _hasExplicitApiVersionValue = true;
            }
        }
        catch(NumberFormatException nfe)
        {
            _apiVersion = Settings.CONFIG_API_VERSION;
            log.error("ConfigurationQueryOptions: nfe", nfe);
        }
        
        requestString = matcher.group(2);
        
        log.debug("apiVersion="+_apiVersion);
        log.debug("requestString="+requestString);

        return requestString;
    }
    
    public boolean isRefresh()
    {
        return _isRefresh;
    }
    
    public boolean containsExplicitFormat()
    {
        return _hasExplicitFormat;
    }
    
    public String getExplicitFormat()
    {
        return _chosenFormat;
    }

    public boolean containsExplicitApiVersion()
    {
        return _hasExplicitApiVersionValue;
    }
    
    public boolean containsAdminConfiguration()
    {
        return _adminConfigurationMatch;
    }
    
    public boolean containsAdminBasicWebappConfiguration()
    {
        return _adminBasicWebappConfigurationMatch;
    }
    
    public int getApiVersion()
    {
        return _apiVersion;
    }

    public boolean isPlainNamespaceAndIdentifier()
    {
        return _isPlainNamespaceAndIdentifier;
    }
    
    public String getParsedRequest()
    {
        return parsedRequestString;
    }
}

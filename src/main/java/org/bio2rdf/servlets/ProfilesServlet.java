package org.bio2rdf.servlets;

import java.io.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;

import org.queryall.*;
import org.queryall.helpers.*;
import org.queryall.blacklist.*;

import org.apache.log4j.Logger;

import org.openrdf.model.URI;

/** 
 * 
 */

public class ProfilesServlet extends HttpServlet 
{
    public static final Logger log = Logger.getLogger(ProfilesServlet.class.getName());
    public static final boolean _TRACE = log.isTraceEnabled();
    public static final boolean _DEBUG = log.isDebugEnabled();
    public static final boolean _INFO = log.isInfoEnabled();

    
    @Override
    public void doGet(HttpServletRequest request,
                        HttpServletResponse response)
        throws ServletException, IOException 
    {
        // Settings.setServletContext(getServletConfig().getServletContext());
        
        PrintWriter out = response.getWriter();
        response.setContentType("text/html");
        
        String realHostName = request.getScheme() + "://" + request.getServerName() + (request.getServerPort() == 80 ? "" : ":"+ request.getServerPort())+"/";
        
        Map<URI, Provider> allProviders = Settings.getAllProviders();
        
        Map<URI, QueryType> allCustomQueries = Settings.getAllCustomQueries();
        
        Map<URI, NormalisationRule> allRdfRules = Settings.getAllNormalisationRules();
        
        Map<URI, Profile> allProfiles = Settings.getAllProfiles();
        
        List<Profile> enabledProfiles = Settings.getAndSortProfileList(Settings.getURICollectionPropertiesFromConfig("activeProfiles"), Settings.LOWEST_ORDER_FIRST);
        
        out.write("<br />Number of queries = " + allCustomQueries.size()+"<br />\n");
        out.write("<br />Number of providers = " + allProviders.size()+"<br />\n");
        out.write("<br />Number of rdf normalisation rules = " + allRdfRules.size()+"<br />\n");
        out.write("<br />Number of profiles = " + allProfiles.size()+"<br />\n");
        
        out.write("<br />Enabled profiles: ("+Settings.getStringCollectionPropertiesFromConfig("activeProfiles").size()+")<br />\n");
        
        out.write("<ul>\n");
        
        for(Profile nextEnabledProfile : enabledProfiles)
        {
            out.write("<li>" + nextEnabledProfile.getKey() + "</li>");
        }
        
        out.write("</ul>\n");
        
        List<URI> includedProviders = new ArrayList<URI>();
        List<URI> excludedProviders = new ArrayList<URI>();
        List<URI> includedQueries = new ArrayList<URI>();
        List<URI> excludedQueries = new ArrayList<URI>();
        List<URI> includedRdfRules = new ArrayList<URI>();
        List<URI> excludedRdfRules = new ArrayList<URI>();
        
        out.write("The following list is authoritative across all of the currently enabled profiles<br/>\n");
        
        for(Provider nextProvider : allProviders.values())
        {
            if(Settings.isProviderUsedWithProfileList(nextProvider.getKey(), nextProvider.getProfileIncludeExcludeOrder(), enabledProfiles))
            {
                // included for this profile...
                //out.write("Provider included: "+nextProvider.getKey()+"<br />\n");
                includedProviders.add(nextProvider.getKey());
            }
            else
            {
                // not included for this profile...
                excludedProviders.add(nextProvider.getKey());
            }
        }
        
        for(QueryType nextQuery : allCustomQueries.values())
        {
            if(Settings.isQueryUsedWithProfileList(nextQuery.getKey(), nextQuery.getProfileIncludeExcludeOrder(), enabledProfiles))
            {
                // included for this profile...
                //out.write("Query included: "+nextQuery.getKey()+"<br />\n");
                includedQueries.add(nextQuery.getKey());
            }
            else
            {
                // not included for this profile...
                excludedQueries.add(nextQuery.getKey());
            }
        }
        
        for(NormalisationRule nextRdfRule : allRdfRules.values())
        {
            if(Settings.isRdfRuleUsedWithProfileList(nextRdfRule.getKey(), nextRdfRule.getProfileIncludeExcludeOrder(), enabledProfiles))
            {
                // included for this profile...
                //out.write("Rdfrule included: "+nextRdfrule.getKey()+"<br />\n");
                includedRdfRules.add(nextRdfRule.getKey());
            }
            else
            {
                // not included for this profile...
                excludedRdfRules.add(nextRdfRule.getKey());
            }
        }
        
        out.write("Included providers: ("+includedProviders.size()+")");
        out.write("<ul>\n");
        for(URI nextInclude : includedProviders)
        {
            out.write("<li>"+nextInclude+"</li>\n");
        }
        out.write("</ul>\n");
        
        out.write("Excluded providers: ("+excludedProviders.size()+")");
        out.write("<ul>\n");
        for(URI nextExclude : excludedProviders)
        {
            out.write("<li>"+nextExclude+"</li>\n");
        }
        out.write("</ul>\n");
        
        out.write("Included queries: ("+includedQueries.size()+")");
        out.write("<ul>\n");
        for(URI nextInclude : includedQueries)
        {
            out.write("<li>"+nextInclude+"</li>\n");
        }
        out.write("</ul>\n");
        
        out.write("Excluded queries: ("+excludedQueries.size()+")");
        out.write("<ul>\n");
        for(URI nextExclude : excludedQueries)
        {
            out.write("<li>"+nextExclude+"</li>\n");
        }
        out.write("</ul>\n");
        
        out.write("Included rdfrules: ("+includedRdfRules.size()+")");
        out.write("<ul>\n");
        for(URI nextInclude : includedRdfRules)
        {
            out.write("<li>"+nextInclude+"</li>\n");
        }
        out.write("</ul>\n");
        
        out.write("Excluded rdfrules: ("+excludedRdfRules.size()+")");
        out.write("<ul>\n");
        for(URI nextExclude : excludedRdfRules)
        {
            out.write("<li>"+nextExclude+"</li>\n");
        }
        out.write("</ul>\n");
        
        out.write("<div>The next section details the profile by profile details, and does not necessarily match the actual effect if there is more than one profile enabled</div>");
        
        for(Profile nextProfile : enabledProfiles)
        {
            includedProviders = new ArrayList<URI>();
            excludedProviders = new ArrayList<URI>();
            
            List<Profile> nextProfileAsList = new ArrayList<Profile>(1);
            nextProfileAsList.add(nextProfile);
            
            if(Settings.getStringCollectionPropertiesFromConfig("activeProfiles").contains(nextProfile.getKey()))
            {
                out.write("<div style=\"display:block;\">\n");
                out.write("Profile:"+nextProfile.getKey()+"\n");
                out.write("<span>Profile enabled</span>\n");
            }
            else
            {
                out.write("<div style=\"display:none;\">\n");
                out.write("Profile:"+nextProfile.getKey()+"\n");
                out.write("<span>Profile disabled</span>\n");
            }
            
            out.write("<br />");
            
            
            for(Provider nextProvider : allProviders.values())
            {
                if(Settings.isProviderUsedWithProfileList(nextProvider.getKey(), nextProvider.getProfileIncludeExcludeOrder(), nextProfileAsList))
                {
                    // included for this profile...
                    //out.write("Provider included: "+nextProvider.getKey()+"<br />\n");
                    includedProviders.add(nextProvider.getKey());
                }
                else
                {
                    // not included for this profile...
                    excludedProviders.add(nextProvider.getKey());
                }
            }
            
            for(QueryType nextQuery : allCustomQueries.values())
            {
                if(Settings.isQueryUsedWithProfileList(nextQuery.getKey(), nextQuery.getProfileIncludeExcludeOrder(), nextProfileAsList))
                {
                    // included for this profile...
                    //out.write("Query included: "+nextQuery.getKey()+"<br />\n");
                    includedQueries.add(nextQuery.getKey());
                }
                else
                {
                    // not included for this profile...
                    excludedQueries.add(nextQuery.getKey());
                }
            }
            
            for(NormalisationRule nextRdfRule : allRdfRules.values())
            {
                if(Settings.isRdfRuleUsedWithProfileList(nextRdfRule.getKey(), nextRdfRule.getProfileIncludeExcludeOrder(), nextProfileAsList))
                {
                    // included for this profile...
                    //out.write("RdfRule included: "+nextRdfRule.getKey()+"<br />\n");
                    includedRdfRules.add(nextRdfRule.getKey());
                }
                else
                {
                    // not included for this profile...
                    excludedRdfRules.add(nextRdfRule.getKey());
                }
            }
            
            out.write("Included providers: ("+includedProviders.size()+")");
            out.write("<ul>\n");
            for(URI nextInclude : includedProviders)
            {
                out.write("<li>"+nextInclude+"</li>\n");
            }
            out.write("</ul>\n");
            
            out.write("Excluded providers: ("+excludedProviders.size()+")");
            out.write("<ul>\n");
            for(URI nextExclude : excludedProviders)
            {
                out.write("<li>"+nextExclude+"</li>\n");
            }
            out.write("</ul>\n");
            
            out.write("Included queries: ("+includedQueries.size()+")");
            out.write("<ul>\n");
            for(URI nextInclude : includedQueries)
            {
                out.write("<li>"+nextInclude+"</li>\n");
            }
            out.write("</ul>\n");
            
            out.write("Excluded queries: ("+excludedQueries.size()+")");
            out.write("<ul>\n");
            for(URI nextExclude : excludedQueries)
            {
                out.write("<li>"+nextExclude+"</li>\n");
            }
            out.write("</ul>\n");
            
            out.write("Included rdfrules: ("+includedRdfRules.size()+")");
            out.write("<ul>\n");
            for(URI nextInclude : includedRdfRules)
            {
                out.write("<li>"+nextInclude+"</li>\n");
            }
            out.write("</ul>\n");
            
            out.write("Excluded rdfrules: ("+excludedRdfRules.size()+")");
            out.write("<ul>\n");
            for(URI nextExclude : excludedRdfRules)
            {
                out.write("<li>"+nextExclude+"</li>\n");
            }
            out.write("</ul>\n");
            out.write("</div>\n");
        }
    
  }
  
}


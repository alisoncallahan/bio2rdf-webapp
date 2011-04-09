package org.bio2rdf.servlets;

import java.io.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;

import org.bio2rdf.servlets.queryparsers.*;
import org.queryall.api.RuleTest;
import org.queryall.helpers.*;

import org.apache.log4j.Logger;

import org.openrdf.model.URI;

/** 
 * 
 */

public class RuleTesterServlet extends HttpServlet 
{
    /**
	 * 
	 */
	private static final long serialVersionUID = 7617736644136389429L;
	public static final Logger log = Logger.getLogger(RuleTesterServlet.class.getName());
    public static final boolean _TRACE = log.isTraceEnabled();
    public static final boolean _DEBUG = log.isDebugEnabled();
    public static final boolean _INFO = log.isInfoEnabled();

    
    @Override
    public void doGet(HttpServletRequest request,
                        HttpServletResponse response)
        throws ServletException, IOException 
    {
        Settings localSettings = Settings.getSettings();
        // Settings.setServletContext(getServletConfig().getServletContext());
        
        log.debug("testUri parameter="+request.getAttribute("org.queryall.RuleTesterServlet.testUri"));
        
        RuleTesterQueryOptions requestRuleTesterQueryOptions = new RuleTesterQueryOptions((String)request.getAttribute("org.queryall.RuleTesterServlet.testUri"));
        
        PrintWriter out = response.getWriter();
    
        String methodToTest = "";
        
        if(requestRuleTesterQueryOptions.hasTestUri())
        {
            methodToTest = requestRuleTesterQueryOptions.getTestUri();
        }
        
        log.debug("test-regexmethods: testuri="+methodToTest);
        
        Map<URI, RuleTest> allRuleTests = localSettings.getAllRuleTests();
        
        boolean allTestsPassed = true;
        
        @SuppressWarnings("unused")
        List<String> automatedTestResults = new ArrayList<String>();
        
        if(!localSettings.runRuleTests(allRuleTests.values()))
        {
            allTestsPassed = false;
        }
        
        if(!allTestsPassed)
        {
            out.write("<h1><span class='error'>Test Failure occured</span></h1>");
        }
        else
        {
            out.write("<h1><span class='info'>All Tests passed</span></h1>");
        }
    }
  
}


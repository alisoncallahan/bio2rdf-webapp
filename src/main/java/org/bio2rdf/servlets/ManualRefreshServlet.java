package org.queryall.servlets;

import java.io.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;

import org.queryall.queryutils.*;
import org.queryall.helpers.*;
import org.queryall.blacklist.*;

import org.apache.log4j.Logger;

/** 
 * 
 */

public class ManualRefreshServlet extends HttpServlet 
{
    public static final Logger log = Logger.getLogger(ManualRefreshServlet.class.getName());
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
        
        boolean refreshAllowed = Settings.isManualRefreshAllowed();
        
        if(refreshAllowed)
        {
            if(Settings.configRefreshCheck(true))
            {
                BlacklistController.doBlacklistExpiry();
                
                response.setStatus(HttpServletResponse.SC_OK);
                log.info("manualrefresh.jsp: manual refresh succeeded requesterIpAddress="+request.getRemoteAddr());
                out.write("Refresh succeeded.");
            }
            else
            {
                response.setStatus(500);
                log.error("manualrefresh.jsp: refresh failed for an unknown reason, as it was supposedly allowed in a previous check requesterIpAddress="+request.getRemoteAddr());
                out.write("Refresh failed for an unknown reason");
            }
        }
        else
        {
            response.setStatus(401);
            log.error("manualrefresh.jsp: refresh not allowed right now requesterIpAddress="+request.getRemoteAddr());
            out.write("Refresh not allowed right now.");
        }
    }
}

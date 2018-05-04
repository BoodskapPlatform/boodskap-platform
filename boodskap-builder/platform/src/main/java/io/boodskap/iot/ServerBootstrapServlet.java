package io.boodskap.iot;

import java.io.File;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;

import org.apache.log4j.PropertyConfigurator;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Servlet implementation class ServerBootstrapServlet
 */
@WebServlet("/ServerBootstrapServlet")
public class ServerBootstrapServlet extends HttpServlet {
	
	static {
		
		try {
			
			File HOME = new File(System.getProperty("user.home"));
			File CONF = new File(HOME, "conf");
			File PROP = new File(CONF, "log4j.properties");
			
			if(PROP.exists()) {
				PropertyConfigurator.configure(PROP.getAbsolutePath());
			}
			
		}catch(Exception ex) {
			System.err.println(ex.getMessage());
		}
	}
	
	private static final Logger LOG = LoggerFactory.getLogger(ServerBootstrapServlet.class);

	private static final long serialVersionUID = 1L;
       
    public ServerBootstrapServlet() {
        super();
    }

    
    @Override
	public void init(ServletConfig config) throws ServletException {
		
    	LOG.warn("Starting Boodskap IoT Platform services");
		
		super.init(config);
		
		try {
			Server.get().start();
		} catch (Exception e) {
			throw new ServletException(e);
		}
	}

    @Override
	public void destroy() {
		try {
			
			Server.get().shutdown();
			
		}finally {
			super.destroy();
		}
	}

}

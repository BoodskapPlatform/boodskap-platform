package io.boodskap.iot;

import java.io.File;

import org.eclipse.jetty.webapp.WebAppClassLoader;
import org.eclipse.jetty.webapp.WebAppContext;

/**
 * 
 * @author jvincent
 * 
 *         Platform entry point
 */
public class ServerBootstrap {
	
	private static final File TARGET_WAR_FILE = new File("target", "boodskap.war");
	private static final File BASE_PATH = new File(System.getProperty("user.home"));
	private static final File WAR_FOLDER = new File(BASE_PATH, "lib");
	private static final File WAR_FILE = new File(WAR_FOLDER, "boodskap.war");

	public static void main(String[] args) throws Exception {
		
		final org.eclipse.jetty.server.Server server = new org.eclipse.jetty.server.Server(18080);
		
		WebAppContext webapp = new WebAppContext();
		webapp.setClassLoader(new WebAppClassLoader(ServerBootstrap.class.getClassLoader(), webapp));
		webapp.setConfigurationDiscovered(true);
		webapp.setContextPath("/");
		
		if(TARGET_WAR_FILE.exists()) {
			webapp.setWar(TARGET_WAR_FILE.getAbsolutePath());
		}else if(new File(WAR_FOLDER, "WEB-INF").exists()) {
			webapp.setWar(WAR_FOLDER.getAbsolutePath());
		}else if(WAR_FILE.exists()) {
			webapp.setWar(WAR_FILE.getAbsolutePath());
		}
		
		server.setHandler(webapp);
		
		try {
			server.start();
			server.setStopAtShutdown(true);
			server.dumpStdErr();
			server.join();
		}finally {
			server.stop();
			server.destroy();
		}
	}
}

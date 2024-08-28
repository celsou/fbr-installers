/*
 * JavaVersion.java
 * 
 * Tests the JVM version from the command line
 * Copyright 2024 - Celso Dell Anhol Ubaldo
 * 
 * License: MIT
 */

public class JavaVersion {
	public static void main(String[] args) {
		if (args.length < 1) {
			System.out.println("ERROR: Specify a version to compare");
            System.exit(2);
		}
		
		int referenceVersion = Integer.parseInt(args[0]);
		
		if (getVersion() < referenceVersion) {
			System.exit(1);
		} else {
			System.exit(0);
		}
		
	}
	
	private static int getVersion() {
		String version = System.getProperty("java.version");
		
		if (version.startsWith("1.")) {
			version = version.substring(2, 3);
		} else {
			int dot = version.indexOf(".");
			if (dot != -1) {
				version = version.substring(0, dot);
			}
		}
		
		return Integer.parseInt(version);
	}

}

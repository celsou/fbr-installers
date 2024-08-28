/*
 * RegexEditor.java
 * 
 * Edit text files from command line using RegEx 
 * Copyright 2024 - Celso Dell Anhol Ubaldo
 * 
 * License: MIT
 */

import java.util.Date;

import java.io.File;
import java.io.IOException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.BufferedReader;
import java.io.BufferedWriter;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;


public class RegexEditor {

    public static void main(String[] args) {                
        if (args.length < 3) {
            System.out.println("ERROR: Too few arguments");
            System.out.println("Usage: java RegexEditor [file to edit] [regular expression] [replacement]");
            System.exit(1);
        }

        String filename = args[0];
        String regex = args[1];
        String replacement = args[2].replaceAll("&#13;", System.getProperty("line.separator"));

        if (!(new File(filename).exists())) {
            System.out.println("ERROR: file " + filename + " does not exist");
            System.exit(1);
        }
        
        String backupFile = createBackup(filename);        
        String fileContent = readFile(filename);

        if (fileContent != null) {
			fileContent = fileContent.replaceAll(regex, replacement);
            boolean success = writeFile(filename, fileContent);
            
            if (!success) {
                restoreBackup(filename, backupFile);
            }
        }
        
        
        
    }
    
    private static String createBackup(String filename) {
		try {
            String timestamp = String.valueOf(new Date().getTime());
            String backupFilename = filename + "_backup" + timestamp + ".bak";
            
            Path in = (Path) Paths.get(filename);
            Path out = (Path) Paths.get(backupFilename);
            Files.copy(in, out, StandardCopyOption.REPLACE_EXISTING);
            
            return backupFilename;
        } catch (IOException e) {
            e.printStackTrace();
        }

        return null;
	}
	
	private static void restoreBackup(String originalFilename, String backupFilename) {
		try {            
            Path in = (Path) Paths.get(originalFilename);
            Path out = (Path) Paths.get(backupFilename);
            Files.copy(in, out, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            e.printStackTrace();
        }
	}
    
    private static boolean writeFile(String filename, String contents) {
		try (BufferedWriter bw = new BufferedWriter(new FileWriter(filename))) {
            bw.write(contents);
            bw.flush();           
            return true;
            
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		return false;
	}
    
    private static String readFile(String filename) {
		String fileContent;
        
        try (BufferedReader br = new BufferedReader(new FileReader(filename))) {                                
            StringBuffer contents = new StringBuffer();
            String line;

            while ((line = br.readLine()) != null) {
                contents.append(line);
                contents.append("\r\n");
            }

            fileContent = contents.toString();
            
            return fileContent;
        } catch (IOException e) {
            e.printStackTrace();
        }
        
        return null;
	}
    
}

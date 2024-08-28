/*
 * MapToDefaultServlet.java
 * 
 * Map file extensions to "default" Tomcat servlet
 * Copyright 2024 - Celso Dell Anhol Ubaldo
 * 
 * License: MIT
 */

import org.w3c.dom.*;
import org.xml.sax.SAXException;

import javax.xml.XMLConstants;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.*;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathException;
import javax.xml.xpath.XPathFactory;

import java.util.List;
import java.util.ListIterator;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;

import java.text.SimpleDateFormat;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.FileOutputStream;
import java.nio.file.CopyOption;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

public class MapToDefaultServlet {

    public static void main(String[] args) {

        if (args.length < 2) {
            System.out.println("ERROR: Too few arguments");
            System.out.println("Usage: java MapToDefaultServlet [web.xml path] [extensions separated by semicolon]");
            System.exit(1);
        }

        File file = new File(args[0]);
        List<String> extensions = new ArrayList<String>(Arrays.asList(args[1].split(";")));

        if (!file.exists()) {
            System.out.println("ERROR: File not found!");
            System.out.println("Exiting...");
            System.exit(1);
        } else {
            createBackupFile(file);
        }

        // Instantiate the Factory
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();

        try {

            // optional, but recommended
            // process XML securely, avoid attacks like XML External Entities (XXE)
            dbf.setFeature(XMLConstants.FEATURE_SECURE_PROCESSING, true);

            // parse XML file
            DocumentBuilder db = dbf.newDocumentBuilder();

            Document doc = db.parse(file);

			Element root = doc.getDocumentElement();
			root.normalize();

            NodeList list = doc.getElementsByTagName("servlet-mapping");
            for (int temp = 0; temp < list.getLength(); temp++) {

                Node node = list.item(temp);
                
                if (node.getNodeType() == Node.ELEMENT_NODE) {
                    Element element = (Element) node;
                    String pattern = element.getElementsByTagName("url-pattern").item(0).getTextContent();

					ListIterator<String> iterator = extensions.listIterator();
                    while (iterator.hasNext()) {
                        String ext = iterator.next();                        
                        if (ext.equals(pattern)) {
                            iterator.remove();
                        }
                    }
                }
            }
			
			for (String ext : extensions) {
				Node servletMapping = doc.createElement("servlet-mapping");
				Node servletName = doc.createElement("servlet-name");
				Node urlPattern = doc.createElement("url-pattern");
				
				servletName.setTextContent("default");
				urlPattern.setTextContent(ext);				
				
				servletMapping.appendChild(servletName);
				servletMapping.appendChild(urlPattern);
				
				root.appendChild(servletMapping);
				System.out.println("Added mapping to " + ext + " extension");
			}
			
            clearBlankLines(doc);
            writeXml(doc, file);
            
            System.out.println("All done.");
            System.exit(0);

        } catch (ParserConfigurationException | SAXException | IOException e) {
            e.printStackTrace();
            System.exit(1);
        }
    }

    private static void createBackupFile(File originalFile) {
        try {
            String timestamp = String.valueOf(new Date().getTime());
            String filename = "XML_backup_" + timestamp + ".xml.bak";
            
            Path in = (Path) Paths.get(originalFile.getAbsolutePath());
            Path out = (Path) Paths.get(filename);
            Files.copy(in, out, StandardCopyOption.REPLACE_EXISTING);
            
            System.out.println(filename);
        } catch (IOException e) {
            e.printStackTrace();
            System.exit(1);
        }
    }

    private static void clearBlankLines(Document doc) {
        try {
            XPath xp = XPathFactory.newInstance().newXPath();
            NodeList nl = (NodeList) xp.evaluate("//text()[normalize-space(.)='']", doc, XPathConstants.NODESET);
            for (int i = 0; i < nl.getLength(); ++i) { // note the position of the '++'
                Node node = nl.item(i);
                node.getParentNode().removeChild(node);
            }
        } catch (XPathException e) {
            e.printStackTrace();
            System.exit(1);
        }
    }

    private static void writeXml(Document doc, File file) {
        try (FileOutputStream output = new FileOutputStream(file)) {
            TransformerFactory transformerFactory = TransformerFactory.newInstance();
            Transformer transformer = transformerFactory.newTransformer();
            
            transformer.setOutputProperty(OutputKeys.INDENT, "yes");
			transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "2");
            
            DOMSource source = new DOMSource(doc);
            StreamResult result = new StreamResult(output);

            transformer.transform(source, result);
        } catch (TransformerException | IOException e) {
            e.printStackTrace();
            System.exit(1);
        }
    }

}

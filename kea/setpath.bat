cd kea
set KEAHOME=C:\InstantRails\rails_apps\intven2\kea
set CLASSPATH=%CLASSPATH%;%KEAHOME%;%KEAHOME%/lib/commons-logging.jar;%KEAHOME%/lib/icu4j_3_4.jar;%KEAHOME%/lib/iri.jar;%KEAHOME%/lib/jena.jar;%KEAHOME%/lib/snowball.jar;%KEAHOME%/lib/weka.jar;%KEAHOME%/lib/xercesImpl.jar;%KEAHOME%/lib/kea-5.0.jar 
java -Xmx128m TestKea

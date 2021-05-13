# A script for importing a full tracking model with preset parameters, then redo that tracking on a new video clip
# Must be run in TrackMate's Script Editor

### !!! To save data, remember to set savexml = True !!! ###


import sys
from sys import path
#sys.path.append('C:\\Users\\Jazzy\\Fiji.app')

from fiji.plugin.trackmate.visualization.hyperstack import HyperStackDisplayer
from fiji.plugin.trackmate.io import TmXmlReader
from fiji.plugin.trackmate import Logger
from fiji.plugin.trackmate import Settings
from fiji.plugin.trackmate import SelectionModel
from fiji.plugin.trackmate.providers import DetectorProvider
from fiji.plugin.trackmate.providers import TrackerProvider
from fiji.plugin.trackmate.providers import SpotAnalyzerProvider
from fiji.plugin.trackmate.providers import EdgeAnalyzerProvider
from fiji.plugin.trackmate.providers import TrackAnalyzerProvider
from java.io import File

 
from ij import IJ
from ij import WindowManager
from ij.process import ImageConverter
from fiji.stacks import Hyperstack_rearranger
 
from fiji.plugin.trackmate import Model
from fiji.plugin.trackmate import TrackMate
from fiji.plugin.trackmate.detection import LogDetectorFactory
from fiji.plugin.trackmate.tracking import LAPUtils
from fiji.plugin.trackmate.tracking.sparselap import SparseLAPTrackerFactory
import fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer as HyperStackDisplayer
import fiji.plugin.trackmate.features.FeatureFilter as FeatureFilter
  
#----------------
# Setup variables
#----------------
  
# Put here the path to the TrackMate file you want to load

# This path depends on the machine you are working on...
# Jasper's PC
#path.append()

file = File('C:\Users\jazzy\Documents\GitRepos\Landsberg_Thesis\Data\\10_70_Parameters.xml')
  
# We have to feed a logger to the reader.
logger = Logger.IJ_LOGGER
  
#-------------------
# Instantiate reader
#-------------------
  
reader = TmXmlReader(file)
if not reader.isReadingOk():
    sys.exit(reader.getErrorMessage())
#-----------------
# Get a full model
#-----------------
  
# This will return a fully working model, with everything
# stored in the file. Missing fields (e.g. tracks) will be 
# null or None in python
model = reader.getModel()
# model is a fiji.plugin.trackmate.Model
  
#----------------
# Display results
#----------------
  
# We can now plainly display the model. It will be shown on an
# empty image with default magnification.
sm = SelectionModel(model)
displayer =  HyperStackDisplayer(model, sm)
displayer.render()
  
#---------------------------------------
# Building a settings object from a file
#---------------------------------------
  
# Reading the Settings object is actually currently complicated. The 
# reader wants to initialize properly everything you saved in the file,
# including the spot, edge, track analyzers, the filters, the detector,
# the tracker, etc...
# It can do that, but you must provide the reader with providers, that
# are able to instantiate the correct TrackMate Java classes from
# the XML data.
  
# We start by creating an empty settings object
settings = Settings()
  
# Then we create all the providers, and point them to the target model:
detectorProvider        = DetectorProvider()
trackerProvider         = TrackerProvider()
spotAnalyzerProvider    = SpotAnalyzerProvider()
edgeAnalyzerProvider    = EdgeAnalyzerProvider()
trackAnalyzerProvider   = TrackAnalyzerProvider()
  
# Ouf! now we can flesh out our settings object:
reader.readSettings(settings, detectorProvider, trackerProvider, spotAnalyzerProvider, edgeAnalyzerProvider, trackAnalyzerProvider)
  
logger.log(str('-----------Old settings and Old Model-----------'))
logger.log(str('\n\nSETTINGS:'))
logger.log(str(settings))
model.setLogger(Logger.IJ_LOGGER)
model.getLogger().log(str(model))
  
# The settings object is also instantiated with the target image.
# Note that the XML file only stores a link to the image.
# If the link is not valid, the image will not be found.
imp = settings.imp
print(str('The image link is given as'))
print(imp)
#imp.show()

#---------------------------------------
# Point at a new video file
#---------------------------------------

#These are all the video files that we've clipped for processing, each is given a unique variable.
vid_man = '133_10sec_710_720_manual'
vid0 = '133_30sec_230_300' #original 30sec that we analyzed over the summer, may want to eyeball test heatmaps, etc.
vid1 = '133_30sec_1120_1150'
vid2 = '133_30sec_1910_1940'
vid3 = '133_30sec_2424_2454'
vid4 = '133_30sec_2455_2525'
vid5 = '133_60sec_225_325' #includes vid0
vid6 = '133_180sec_720_1020'

# A list for looping below
#vidlist = [vid_man, vid0, vid1, vid2, vid3, vid4, vid5, vid6]
#ran with rad=9.5 on 2/22/2021
#ran with rad=9.6 on 4/5/2021
vidlist = [vid_man]

for vid in vidlist:

	# This path depends on the machine you are working on...
	# Jasper's PC
	proc_vid = 'processed_'+vid+'.avi'
	imp = IJ.openImage('C:\Users\jazzy\Documents\GitRepos\Locust_Data\Collection\\'+proc_vid)
	
	#Fiji/Trackmate thinks our video is still in color. This has something to do with the codec we're using to save the video in an nv12 format.
	IJ.run(imp,"8-bit",""); #convert to 8-bit greyscale
	
	# ImageJ Background subtraction?! ################################################################# TO DO #########################################################
	
	imp = Hyperstack_rearranger.reorderHyperstack(imp,"CTZ",True,True); #switch Z slices and T frames
	#imp.show()
	print(str('The image link is given as'))
	print(imp)
	
	
	    
	# Send all messages to ImageJ log window.
	model.setLogger(Logger.IJ_LOGGER)
	    
	    
	       
	#------------------------
	# Prepare settings object
	#------------------------
	
	# at the moment we change nothing about the detection or tracking parameters, hence this is all commented out
	
	#settings = Settings()
	settings.setFrom(imp)
	
	# Configure detector - We use the Strings for the keys
	#settings.detectorFactory = LogDetectorFactory()
	settings.detectorSettings = { 
		'DO_SUBPIXEL_LOCALIZATION' : True,
		'RADIUS' : 9.6, #don't let this be an integer
		'TARGET_CHANNEL' : 1,
		'THRESHOLD' : 0.1,
		'DO_MEDIAN_FILTERING' : False,
	} 
	 
	     
	# Configure tracker - 

	#settings.trackerFactory = SparseLAPTrackerFactory()
	#settings.trackerSettings = LAPUtils.getDefaultLAPSettingsMap() # almost good enough
	#settings.trackerSettings['ALLOW_TRACK_SPLITTING'] = True
	#settings.trackerSettings['ALLOW_TRACK_MERGING'] = True
	 
	# Add ALL the feature analyzers known to TrackMate, via
	# providers. 
	# They offer automatic analyzer detection, so all the 
	# available feature analyzers will be added. 
	 
	spotAnalyzerProvider = SpotAnalyzerProvider()
	for key in spotAnalyzerProvider.getKeys():
	    print( key )
	    settings.addSpotAnalyzerFactory( spotAnalyzerProvider.getFactory( key ) )
 
	edgeAnalyzerProvider = EdgeAnalyzerProvider()
	for  key in edgeAnalyzerProvider.getKeys():
	    print( key )
	    settings.addEdgeAnalyzer( edgeAnalyzerProvider.getFactory( key ) )
	 
	trackAnalyzerProvider = TrackAnalyzerProvider()
	for key in trackAnalyzerProvider.getKeys():
	    print( key )
	    settings.addTrackAnalyzer( trackAnalyzerProvider.getFactory( key ) )
	    
	# Configure track filters - We want to get rid of the two immobile spots at 
	# the bottom right of the image. Track displacement must be above 10 pixels.
	
	#filter2 = FeatureFilter('TRACK_DISPLACEMENT', 10, True)
	#settings.addTrackFilter(filter2)
	        
	#-------------------
	# Instantiate plugin
	#-------------------
	
	trackmate = TrackMate(model, settings)
	       
	#--------
	# Process
	#--------
	    
	ok = trackmate.checkInput()
	if not ok:
	    sys.exit(str(trackmate.getErrorMessage()))
	    
	ok = trackmate.process()
	if not ok:
	    sys.exit(str(trackmate.getErrorMessage()))

	# User input Quality filter? ################################################################# TO DO #########################################################
	#	1) Get spot quality from Model
	#spots = model.getSpots()
	#qualities = list([])
	#for spot in spots:
	#	qualities.append(spot.getFeature('QUALITY'))
	#	2) plot histogram using python, pyplot?
	#	3) ask for user input value
	#	4) apply a filter with that value for Quality
	# Configure spot filters - Classical filter on quality
	# In the user interface this value gets chosen when you look at the histogram of Qualities.
	#filter1 = FeatureFilter('QUALITY', 1.6, True)
	#settings.addSpotFilter(filter1)

	#	5) do "Process" above again...
	       
	#----------------
	# Display results
	#----------------
	     
	selectionModel = SelectionModel(model)
	displayer =  HyperStackDisplayer(model, selectionModel, imp)
	displayer.render()
	displayer.refresh()
	    
	# Echo results with the logger we set at start:
	logger.log(str('-----------New settings and New Model-----------'))
	logger.log(str('\n\nSETTINGS:'))
	logger.log(str(settings))
	model.getLogger().log(str(model))
	
	#----------------
	# Export the resulting model to a .xml file
	#----------------
	import fiji.plugin.trackmate.action.ExportTracksToXML as ExportTracksToXML
	import fiji.plugin.trackmate.io.TmXmlWriter as TmXmlWriter

	savexml = False
	if savexml:
		if 'manual' in vid:
			trackfile = 'tracks_133_10sec_710_720_scripted.xml'
		else: 
			trackfile='tracks_'+vid+'.xml'
		file_out = File('C:\Users\jazzy\Documents\GitRepos\Locust_Data\Collection\\'+trackfile)
		# NOT the full Trackmate .xml file. It is just the data .xml file obtained in the GUI by "Save Tracks as .xml" -> "Execute".
		ExportTracksToXML.export( model, settings, file_out)
	
# END FOR LOOP over vidlist		
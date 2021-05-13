
Landsberg_Thesis/Data
===

Date: 5/5/2021

All files are derived from the tracking, cleaning, and processing described by Jacob Landsberg in his 2021 thesis and executed on the 10-second example video clip viewable here:
<https://youtu.be/IrikqqKJ7Gg>

* 10_70_Parameters.xml: TrackMate *file and data* resulting from automatic tracking with the GUI, to be loaded during scripted tracking.

  * input for Collection/load_track.py

* tracks_133_10sec_710_720_scripted.xml: TrackMate *data only* resulting from scripted tracking.

  * output of Collection/load_track.py

* data_rough.mat: The tracking data described in the last bullet, now imported for use in Matlab.

  * output of Collection/import_xml2mat.m

* data_clean.mat: The cleaned tracking data described in the last bullet

  * output of Data_Cleaning.m

* data_final.mat: The processed data including inferred information (e.g. velocity, heading direction, etc.) described in the last bullet.

  * output of Data_Formation.m

* 710-720_tracks.xml: TrackMate *file and data* resulting from manual tracking of a 10-second clip.

* manual_clean.mat: The cleaned (I.e. properly scaled) .mat file of manual data. This is used for accuracy metric computations.

  * input for Accuracy_Metric.m

* JSC.mat: Houses information about which radii for tracking correspond to what LSC scores.

  * output of Accuracy_Metric.m

Landsberg_Thesis
===

Date: 5/5/21

This repository contains all the code necessary for the excecuting the tracking, cleaning, processing, and analysis of raw video footage described in the thesis of Jacob Landsberg:
LINK

Dependencies: Some of my scripts rely on MATLAB code rely on codes built by others. To generate certain figures, a new user would need to download:

* Circular stats package: LINK

* 2D histogram script: LINK

Folders
---

Collection: Scripts used to process raw video in .mp4 format, to execute automated TrackMate tracking without the GUI, and to convert the data for use in MATLAB

Data: Example raw and processed data. For more detailed information on data files see the README file in the Data folder. All data is from this example of video: <https://youtu.be/IrikqqKJ7Gg>

Figures: MATLAB codes to create figure files, where the inputs are data_final.mat, unless specified otherwise, and the outputs are .eps file. Each file outputs a .eps file.

Files
---

Data_Cleaning.m:
This file reformats the rough data and adds a data type flag. It takes in data_rough.mat, which is a # of locusts x # 3x(of frames) size matrix. Each row corresponds to a locust and the columns go as follows: frame, x, y, frame, x, y, frame... This file outputs data_clean.mat, which is a # of locusts x 3 x # of frames matrix. Each row is a different locust, the columns go x, y, flag, and the third dimension of matrix defines the frame. The flag can be 0, if the locust is not in frame, 1 if the locust is in frame and we have a data point, or 2 if the locust is in frame, but we are missing the data point, indicating we need to interpolate the position.

Data_Formation.m:
This file adds inferred data points what we found in data_clean. Ittakes data_clean.mat as an input. This data is then directly copied over to data_final.mat. However, 5 new columns of inferred data are added. In order, they are speed, heading direction, stopped/walking/hopping, acceleration parallel to
direction of motion, and acceleration perpendicular to direction of motion. You can change whether you want to use smoothed (our choice) or unsmoothed velocities by changing the smooth flag in the dataForm function. We also add the k nearest neighbors' x and y displacements from the focal locust. They are placed in the third column of the cell array. Each row represents a locust, each column holds x1, x2, ...xk, y1, y2, ...yk. This
matrix is number of frames deep.

StateData.m:
This file is responsible for finding time in states and transitions between states. This file takes relies on having data_final.mat. We compute the percent of time for all locusts combined in each state in the "PercentInState" matrix. We also compute the transitions between states in the "Transitions" matrix.  

Movement_State_Exploration.m:
This function is used to explore how local standard deviations and
locally-averaged velocities relate to heading directions, etc.

Accuracy_Metric.m:
Accuracy_Metric.m is used to compute the Landsberg Similarity Coefficient for automatically tracked data, corresponding to manually tracked data (in our case 7:10-7:20 of Buhl133). For our purposes the input for Accuracy_Metric.m, data_clean_radstudy.mat is a 3 column, N row cell array where the 1st column is just a matrix name, the 2nd column is the cleaned matrix (i.e. a matrix run through Data_Cleaning.m), and the 3rd is the radius. JSC is your output matrix of, with the 1st column being diameter, not radius and the second column being the Landsberg Similarity Coefficent.

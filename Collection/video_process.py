import os
import subprocess

os.chdir('C:\Users\jazzy\Documents\GitRepos\Landsberg_Thesis\Data')
#These are all the video files that we've clipped for processing, each is given a unique variable.
vid_man = '133_10sec_710_720_manual' #the clip for which we have manual tracking data
vid0 = '133_30sec_230_300' #original 30sec that we analyzed over the summer, may want to eyeball test heatmaps, etc.
vid1 = '133_30sec_1120_1150'
vid2 = '133_30sec_1910_1940'
vid3 = '133_30sec_2424_2454'
vid4 = '133_30sec_2455_2525'
vid5 = '133_60sec_225_325' #includes vid0
vid6 = '133_180sec_720_1020'

# A list for looping below
# vidlist = [vid_man, vid0, vid1, vid2, vid3, vid4, vid5, vid6] #ran on 2/22/2021
vidlist = [vid_man]

# Our video processing, calls ffmpeg
def vidprocess(vidfile):
    '''A routine that calls ffmpeg over and over to preprocess our videos including:
    1) deinterlacing
    2) color inversion
    3) brightness, contrast, saturation adjustment
    4) blur
    5) crop
    6) greyscale
    7) convert to .AVI format ready for ImageJ to read
    
    Input is a file name without extension, file should be a .MP4 but that may not matter.
    Returns Null but creates a series of video files with final version in .AVI format'''

    subprocess.call(['ffmpeg', '-i', vidfile, '-vf', 'yadif=0', '-acodec', 'ac3', '-ab', '192k', '-vcodec',
                    'mpeg4', '-f', 'mp4', '-y', '-qscale', '0', '-y', 'outfile0.mp4'])
    #wait = input("Press Enter to continue.") #for debugging
    subprocess.call(['ffmpeg','-i', 'outfile0.mp4', '-vf', 'negate', '-y', 'outfile1.mp4'])
    subprocess.call(['ffmpeg','-i', 'outfile1.mp4', '-vf', 'eq=brightness=.1:contrast=1000:saturation=1', '-c:a', 'copy', '-y', 'outfile2.mp4' ])
    subprocess.call(['ffmpeg','-i', 'outfile2.mp4', '-vf', "boxblur=5:1", '-y', 'outfile3.mp4'])
    subprocess.call(['ffmpeg','-i', 'outfile3.mp4', '-filter:v', "crop=iw*0.95:ih*0.95", '-y', 'outfile4.mp4'])
    subprocess.call(['ffmpeg','-i', 'outfile4.mp4', '-vf', 'hue=s=0', '-y', 'outfile5.mp4'])
    subprocess.call(['ffmpeg','-i', 'outfile5.mp4', '-pix_fmt', 'nv12', '-f', 'avi', '-vcodec', 'rawvideo', vidout])

    # ffmpeg -i 710_720_Manual.mp4 -vf yadif=0 -acodec ac3 -ab 192k -vcodec mpeg4 -f mp4 -y -qscale 0 outfile0.mp4
    # ffmpeg -i outfile0.mp4 -vf negate outfile1.mp4
    # ffmpeg -i outfile1.mp4 -vf eq=brightness=.1:contrast=1000:saturation=1 -c:a copy outfile2.mp4
    # ffmpeg -i outfile2.mp4 -vf "boxblur=5:1" outfile3.mp4
    # ffmpeg -i outfile3.mp4 -filter:v "crop=iw*.95:ih*.95" outfile4.mp4
    # ffmpeg -i outfile4.mp4 -vf hue=s=0 outfile5.mp4
    # ffmpeg -i outfile5.mp4 -pix_fmt nv12 -f avi -vcodec rawvideo outfileFinal.avi

    # Delete all the intermediate files
    subprocess.call(['rm','outfile*'])

for vidin in vidlist:
    vidfile = vidin+'.mp4'
    vidout = 'processed_'+vidin+'.avi'

    #wait = input("Press Enter to continue.") #for debugging
    vidprocess(vidfile)

#!/usr/bin/env python3

import matplotlib.pyplot as pyplot
import os.path
import sys

AXIS_SCALE = 0.05
FMT = "png"
SEP = ','

def getFMT(centroid, centroids):
    colors = ["b","g","r","c","m","y","k"]
    shapes = ["o","s","^","p","h"]
    index = centroids.index(centroid)
    color = colors[index%len(colors)]
    shape = shapes[(index//len(colors))%len(shapes)]
    return (color+shape)

def plotClusters2D(inputPath, outputPath):
    with open(inputPath,"r") as inputFile, open(outputPath,"w") as outputFile:
        # get input header & verify if #-of-fields is ok
        headerLine = inputFile.readline().strip().split(SEP)
        if (len(headerLine) != 4):
            raise RuntimeError
        centroids = list()
        xMin = yMin = sys.float_info.max
        xMax = yMax = sys.float_info.min
        # iterate over input entries (i.e. containers)
        for (index,line) in enumerate(inputFile):
            splitLine = line.strip().split(SEP)
            # verify if entry has as many fields as header
            if (len(headerLine) != len(splitLine)):
                raise RuntimeError
            else:
                try:
                    # get X & Y values
                    x = float(splitLine[2])
                    if (x > xMax):
                        xMax = x + AXIS_SCALE
                    elif (x < xMin):
                        xMin = x - AXIS_SCALE
                    y = float(splitLine[3])
                    if (y > yMax):
                        yMax = y + AXIS_SCALE
                    elif (y < yMin):
                        yMin = y - AXIS_SCALE
                except ValueError:
                    raise
                else:
                    # add centroid to list
                    if splitLine[1] not in centroids:
                        centroids.append(splitLine[1])
                    # plot data point
                    pyplot.plot(x,y,getFMT(splitLine[1],centroids))
        # label axes
        pyplot.xlabel(headerLine[2])
        pyplot.ylabel(headerLine[3])
        # define axes min's & max's
        ex = xMax*AXIS_SCALE
        ey = yMax*AXIS_SCALE
        pyplot.axis([(xMin-ex),(xMax+ex),(yMin-ey),(yMax+ey)])
        pyplot.savefig(outputFile,format=FMT)
    return True

if __name__ == "__main__":
    if ((len(sys.argv) < 2) or (len(sys.argv) > 3) or (len(sys.argv) == 3 and sys.argv[1] != "--no-overwrite")):
        print("Wrong usage.")
        sys.exit(1)
    elif ((len(sys.argv) == 2 and not os.path.isfile(sys.argv[1])) or (len(sys.argv) == 3 and not os.path.isfile(sys.argv[2]))):
        print("Inexistent input file.")
        sys.exit(2)
    elif (len(sys.argv) == 2):
        inputPath = sys.argv[1]
        outputPath = os.path.splitext(sys.argv[1])[0] + "." + FMT
    else: # len(sys.argv) == 3:
        inputPath = sys.argv[2]
        index = 1
        basePath = os.path.splitext(sys.argv[2])[0] + "." + FMT
        outputPath = basePath
        while os.path.isfile(outputPath):
            outputPath = os.path.splitext(basePath)[0] + "-" + str(index) + "." + FMT
            index += 1
    try:
        plotClusters2D(inputPath, outputPath)
    except (RuntimeError,ValueError):
        print("Poorly formatted input file")
        sys.exit(3)
    else:
        print("Done. Plot in " + outputPath)
        sys.exit(0)

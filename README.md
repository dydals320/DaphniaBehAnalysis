# DaphniaBehAnalysis


### The main MATLAB code is a 'DaphniaPhenotyping.m'

1. Overview
   - Daphnia phenotype tracking was performed using a multistep process beginning with raw video data. All analyses were performed in MATLAB 2020a using custom-written scripts, based in part on the previous algorithms (Albrecht et al & Le et al) to segment video frames and identify continuous centroid paths of individual daphnids. Each frame was turned into a binary image using adaptive background correction and thresholding method. The resulting binary image was analyzed using a consensus approach informed by positional and size parameters to separate the target objects (adult Daphnia) from other objects and then performed tracking followed by measurements of the morphological and behavioral parameters. 

2. The workflow of the algorithm
   - Setup parameters depending on the experimental conditions in the *DaphniaPhenotyping* (Main function). 
   - Background subtraction and object segmentation and detection in the *DaphniaTracker*.
   - Extract various phenotypic parameters in the *DaphniaSegmentTracks*. Users can tune the feature extraction setting parameter in the *InitialSettings*.
   - Visualize the extracted features via *Ethogram* and *DaphniaDensity*.

3. Data



![TankImage_small](https://user-images.githubusercontent.com/51148581/122502031-d1c73d80-cfc3-11eb-8236-835515342782.gif)

4. References
   - [Albrecht, D. R. & Bargmann, C. I. High-content behavioral analysis of Caenorhabditis elegans in precise spatiotemporal chemical environments. Nature methods 8, 599 (2011).](https://www.nature.com/articles/nmeth.1630)
   - [Le, K. N. et al. An automated platform to monitor long-term behavior and healthspan in Caenorhabditis elegans under precise environmental control. Communications Biology 3, doi:10.1038/s42003-020-1013-2 (2020).](https://www.nature.com/articles/s42003-020-1013-2)

### *counter.m* can be used to manually curate the counting results for the lifespan assay

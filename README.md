# BoW-CCF
**Code for the paper "Searching for category-consistent features: A computational approach to understanding visual category representation"**

Paper: http://www.chenpingyu.org/docs/Yu_ccf_2016.pdf

Contact: cxy7452@gmail.com

<br/>

This code package allows you to:

* Create a SIFT Bag-of-Words (BoW) dictionary for your own image dataset.
* Extract the Category-Consistent-Features (CCFs) from your dataset.
* Visualize the CCFs of specified categories, and compute CCF-distances between images of your categories.

Implemented and tested on Windows 7, using Matlab R2016a. 

<br />

In summary, CCFs are what we coined as generative and representative features of an object category (note that these are different from being *discriminative*). Given an object category, its CCFs are defined as features that appear *frequently* and *reliably*; in terms of an image descriptor histogram where each bin (x-axis) represent a visual feature, i.e. SIFT BoW histograms, *frequently* translates to bins with high y-values, and *reliably* translates to the bins with low variances. They are learned unsupervised from individual categories.

Therefore, given n images of an object category, a visual feature (bin) is identified as a CCF if its `signal-to-noise-ratio (SNR) = mean/std` is higher than some threshold, where the threshold is determined automatically using kmeans clustering with k = 2. Please refer to the paper for more details.

<br />

## Installation

Download the entire package, save and extract all files to a location, for example `C:\work\bow-ccf\`. The the first thing is to set up the vlfeat library that is included in this package. To set it up, start Matlab and navigate to for example, `C:\work\bow-ccf\vlfeat-0.9.20\toolbox\`, and just type in the command `run vl_setup`. This should automatically add all the VLFeat directories to your Matlab paths, which the code utilitizes.

The following sections must be done in order!

## 1. SIFT Bag-of-Words (BoW) generation

Open up file `genBoW.m` in Matlab, and pay attention to line 10 (datasetPath), 13 (featurePath), and 16 (numTrain). These are the input parameters for you to specify. Currently `datasetPath` is set to the dataset we used for our paper, it takes the name `SBU-hierarchical68` and contains 48 directories with 100 images each. If you want to use your own dataset, replace your dataset with ours, and update line 10 with the path to your dataset. Make sure the dataset contains the same exact file structure: each object category is a separate sub-directory, containing just image files.

`featurePath` on line 13 defines where you would like the generated features to be saved, we recommand using the default. `numTrain` on line 16 asks the user to specify how many images per category are to be used for generating the BoW dictionary. Typically this is 1/4 or 1/5 of your dataset, since we have 100 images per category the default here is 25.

After specifying your dataset and inputs, type in the command `run genBoW` at the Matlab command line to proceed. After the script is finished, there should be several new files and directories appearing under your specified `featurePath` location.

## 2. Extracting CCFs from the categories

Open up file `extractCCFs.m` in Matlab, and make sure line 11 (`datasetPath`) and line 14 (`featurePath`) is the same as in the previous step, so that the script can load the appropriate features for this step to process. Then type in the command `run extractCCFs` at the Matlab command line to proceed.

When this process finishes, a `categoryID.xls` excel file will be generated under the `featurePath` location. This file specifies the ID (column 1) and the name of the category (column 2) that will be useful for the next 2 sections.

## 3. Visualizing the extracted CCFs

The CCFs are just SIFT features that appear frequently and reliably given an object category, therefore those SIFT patches can be visualized and inspected. Open up `visCCFs.m`, and first make sure line 8 (`datasetPath`) and 9 (`featurePath`) are correctly specified according to your previous steps, then you can specify which category's CCFs you would like the script to visualize, on line 10 (`catNum`), where the number is the category ID that you can look up from `categoryID.xls` under your `featurePath`. 

You can also specify the number of CCFs to visualize at line 11 (`topCCFs`). Then, the script will visualize that many CCFs based on the SNR scores of the CCFs (SIFT patches averaged over images of a category). Examples of visualizing the top 10 CCFs of the 'Knit caps', 'Sugar cookie', and 'Sailboats' categories:

![CCF Visualization](https://raw.githubusercontent.com/cxy7452/bow-ccf/master/CCFsVis.png "CCF Visualization Example")

## 4. Computing CCF distances

`ccfDist.m` allows you to compute the CCF diatance (image similarity based on the CCFs) of a given image to a given category. The image can be any image regardless of being part of your object dataset or not, but the category to be compared with must be part of your object category dataset. Please refer to the comments in the file for the usage and example.

`ccfDist2.m` allows you to compute the CCF distance between a pair of images. In this case, while both images don't have to be actual images as part of your dataset, they must come from some object categories that are part of your dataset. For example if your oject category dataset contains a "credit card" category with 100 images, you may use one of those 100 images, or even just grab a random credit card image online, but the category that the image belongs to must exist in your dataset.

For both functions, the output value is between 0 and 1, where 0 means exactly the same, and closer to 1 means more different from each other.

## Contact

If the code has problems or if you have any questions about any part of the code, feel free to contact me at cxy7452@gmail.com, thanks!
